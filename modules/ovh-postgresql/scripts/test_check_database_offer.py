import importlib.util
import io
import json
import os
import unittest
from contextlib import redirect_stdout
from contextlib import redirect_stderr
from unittest.mock import patch


SPEC = importlib.util.spec_from_file_location(
    "check_database_offer", os.path.join(os.path.dirname(__file__), "check_database_offer.py")
)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


REQUESTED = {
    "engine": "postgresql",
    "version": "18",
    "plan": "production",
    "region": "GRA",
    "flavor": "b3-8",
    "network": "private",
    "nodes": 2,
    "disk_size": "95",
}


def offer(**overrides):
    value = {
        "engine": "postgresql",
        "version": "18",
        "plan": "production",
        "region": "GRA",
        "lifecycle": {"status": "STABLE"},
        "specifications": {
            "flavor": "b3-8",
            "network": "private",
            "nodes": {"minimum": 1, "maximum": 3},
            "storage": {
                "minimum": {"unit": "GB", "value": 85},
                "maximum": {"unit": "GB", "value": 205},
                "step": {"unit": "GB", "value": 10},
            },
        },
    }
    value.update(overrides)
    return value


class OfferTests(unittest.TestCase):
    def test_exact_compatible_offer_and_known_lifecycle_states(self):
        for status in MODULE.LIFECYCLE_STATUSES:
            with self.subTest(status=status):
                item = offer(lifecycle={"status": status})
                self.assertTrue(MODULE.compatible_offer([item], REQUESTED))

    def test_mismatch_and_unavailable_lifecycle_reject(self):
        for field in ("engine", "version", "plan", "region"):
            with self.subTest(field=field):
                self.assertFalse(MODULE.compatible_offer([offer(**{field: "other"})], REQUESTED))
        item = offer()
        item["specifications"]["flavor"] = "other"
        self.assertFalse(MODULE.compatible_offer([item], REQUESTED))
        for status in ("END_OF_LIFE", "END_OF_SALE", "UNAVAILABLE", "FUTURE"):
            with self.subTest(status=status):
                item = offer(lifecycle={"status": status})
                self.assertFalse(MODULE.compatible_offer([item], REQUESTED))

    def test_node_network_and_disk_constraints(self):
        item = offer()
        item["specifications"]["nodes"] = {"minimum": 3, "maximum": 4}
        self.assertFalse(MODULE.compatible_offer([item], REQUESTED))
        item = offer()
        item["specifications"]["network"] = "public"
        self.assertFalse(MODULE.compatible_offer([item], REQUESTED))
        for disk_size in ("84", "206", "100"):
            with self.subTest(disk_size=disk_size):
                request = {**REQUESTED, "disk_size": disk_size}
                self.assertFalse(MODULE.compatible_offer([offer()], request))

    def test_disk_range_includes_endpoints_and_step_is_relative_to_minimum(self):
        for disk_size in ("85", "95", "205"):
            with self.subTest(disk_size=disk_size):
                request = {**REQUESTED, "disk_size": disk_size}
                self.assertTrue(MODULE.compatible_offer([offer()], request))

    def test_missing_null_bad_unit_and_invalid_step_fail_closed(self):
        cases = []
        missing = offer()
        del missing["specifications"]["storage"]["step"]
        cases.append(missing)
        null_value = offer()
        null_value["specifications"]["storage"]["maximum"] = None
        cases.append(null_value)
        wrong_unit = offer()
        wrong_unit["specifications"]["storage"]["step"]["unit"] = "TB"
        cases.append(wrong_unit)
        bad_step = offer()
        bad_step["specifications"]["storage"]["step"]["value"] = 0
        cases.append(bad_step)
        for item in cases:
            with self.subTest(item=item), self.assertRaises(MODULE.OfferError):
                MODULE.compatible_offer([item], REQUESTED)

    def test_invalid_collection_and_malformed_offer_fail(self):
        with self.assertRaises(MODULE.OfferError):
            MODULE.compatible_offer({}, REQUESTED)
        with self.assertRaises(MODULE.OfferError):
            MODULE.compatible_offer([{"engine": "postgresql"}], REQUESTED)


class AuthenticationTests(unittest.TestCase):
    def test_bearer_token_is_passed_without_exposing_it_elsewhere(self):
        with patch.dict(os.environ, {"OVH_ACCESS_TOKEN": "temporary-token"}, clear=True):
            self.assertEqual(
                MODULE.auth_headers("ovh-eu", "GET", "https://api.example/path"),
                {"Authorization": "Bearer temporary-token"},
            )

    def test_classic_signature_uses_timestamp_and_full_url(self):
        def fake_open(url, headers=None, data=None):
            self.assertEqual(url, MODULE.API_HOSTS["ovh-eu"] + "/auth/time")
            return 200, b"1700000000"

        env = {
            "OVH_APPLICATION_KEY": "key",
            "OVH_APPLICATION_SECRET": "secret",
            "OVH_CONSUMER_KEY": "consumer",
        }
        with patch.dict(os.environ, env, clear=True), patch.object(MODULE, "open_url", fake_open):
            headers = MODULE.auth_headers("ovh-eu", "GET", "https://api.example/path")
        self.assertEqual(headers["X-Ovh-Timestamp"], "1700000000")
        expected = MODULE.hashlib.sha1(
            b"secret+consumer+GET+https://api.example/path++1700000000"
        ).hexdigest()
        self.assertEqual(headers["X-Ovh-Signature"], "$1$" + expected)

    def test_ambiguous_or_partial_authentication_fails(self):
        with patch.dict(os.environ, {"OVH_CLIENT_ID": "id"}, clear=True):
            with self.assertRaises(MODULE.OfferError):
                MODULE.auth_headers("ovh-eu", "GET", "https://api.example/path")
        with patch.dict(os.environ, {"OVH_ACCESS_TOKEN": "token", "OVH_CLIENT_ID": "id"}, clear=True):
            with self.assertRaises(MODULE.OfferError):
                MODULE.auth_headers("ovh-eu", "GET", "https://api.example/path")

    def test_oauth_form_credentials_are_not_in_query(self):
        calls = []

        def fake_open(url, headers=None, data=None):
            calls.append((url, headers, data))
            return 200, b'{"access_token":"issued-token"}'

        env = {"OVH_CLIENT_ID": "client-id", "OVH_CLIENT_SECRET": "client-secret"}
        with patch.dict(os.environ, env, clear=True), patch.object(MODULE, "open_url", fake_open):
            result = MODULE.auth_headers("ovh-eu", "GET", "https://api.example/path")
        self.assertEqual(result, {"Authorization": "Bearer issued-token"})
        self.assertEqual(calls[0][0], MODULE.AUTH_HOSTS["ovh-eu"])
        self.assertIn(b"client-secret", calls[0][2])


class ExternalProtocolTests(unittest.TestCase):
    def test_external_protocol_outputs_only_boolean_string(self):
        query = {
            "service_name": "project",
            **{key: str(value) for key, value in REQUESTED.items()},
        }

        def fake_open(url, headers=None, data=None):
            if url == MODULE.API_HOSTS["ovh-eu"] + "/cloud/project/project/database/availability":
                return 200, json.dumps([offer()]).encode()
            raise AssertionError("unexpected URL")

        output = io.StringIO()
        with (
            patch.dict(os.environ, {"OVH_ENDPOINT": "ovh-eu", "OVH_ACCESS_TOKEN": "test-token"}, clear=True),
            patch.object(MODULE, "open_url", fake_open),
            patch.object(MODULE.sys, "stdin", io.StringIO(json.dumps(query))),
            redirect_stdout(output),
        ):
            MODULE.main()
        self.assertEqual(json.loads(output.getvalue()), {"compatible": "true"})

    def test_external_protocol_never_returns_malformed_results(self):
        query = {"service_name": "project", **REQUESTED}
        output = io.StringIO()
        with (
            patch.dict(os.environ, {"OVH_ENDPOINT": "ovh-eu"}, clear=True),
            patch.object(MODULE.sys, "stdin", io.StringIO(json.dumps(query))),
            redirect_stdout(output),
            self.assertRaises(MODULE.OfferError),
        ):
            MODULE.main()
        self.assertEqual(output.getvalue(), "")

    def test_api_http_error_exits_with_only_status_code(self):
        query = {
            "service_name": "project",
            **{key: str(value) for key, value in REQUESTED.items()},
        }
        error = MODULE.urllib.error.HTTPError(
            "https://api.example/path", 403, "secret-bearing response", {}, io.BytesIO(b"secret")
        )
        output = io.StringIO()
        with (
            patch.dict(os.environ, {"OVH_ENDPOINT": "ovh-eu", "OVH_ACCESS_TOKEN": "test-secret"}, clear=True),
            patch.object(MODULE, "open_url", side_effect=error),
            patch.object(MODULE.sys, "stdin", io.StringIO(json.dumps(query))),
            redirect_stderr(output),
            self.assertRaises(SystemExit),
        ):
            MODULE.cli()
        self.assertIn("HTTP 403", output.getvalue())
        self.assertNotIn("secret", output.getvalue())

    def test_http_and_network_failures_are_sanitized(self):
        failures = [
            MODULE.urllib.error.HTTPError(
                "https://api.example/path?secret=credential",
                403,
                "remote secret message",
                {},
                io.BytesIO(b"response contains credential"),
            ),
            MODULE.urllib.error.URLError("credential in network error"),
        ]
        for error in failures:
            output = io.StringIO()
            with self.subTest(error=type(error).__name__), patch.object(
                MODULE, "main", side_effect=error
            ), redirect_stderr(output), self.assertRaises(SystemExit) as exit_error:
                MODULE.cli()
            self.assertEqual(exit_error.exception.code, 1)
            self.assertNotIn("credential", output.getvalue())
            self.assertNotIn("remote secret", output.getvalue())
            if isinstance(error, MODULE.urllib.error.HTTPError):
                self.assertIn("HTTP 403", output.getvalue())
            else:
                self.assertIn("network error", output.getvalue())


if __name__ == "__main__":
    unittest.main()
