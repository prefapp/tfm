#!/usr/bin/env python3
"""Fail-closed preflight for an OVHcloud PostgreSQL availability offer."""

import hashlib
import json
import os
import sys
import urllib.error
import urllib.parse
import urllib.request
from decimal import Decimal, InvalidOperation


API_HOSTS = {
    "ovh-eu": "https://api.eu.ovhcloud.com/1.0",
    "ovh-us": "https://api.us.ovhcloud.com/1.0",
    "ovh-ca": "https://api.ca.ovhcloud.com/1.0",
}
AUTH_HOSTS = {
    "ovh-eu": "https://auth.eu.ovhcloud.com/oauth2/token",
    "ovh-us": "https://auth.us.ovhcloud.com/oauth2/token",
    "ovh-ca": "https://auth.ca.ovhcloud.com/oauth2/token",
}
LIFECYCLE_STATUSES = {"STABLE", "BETA", "DEPRECATED"}
MAX_RESPONSE_BYTES = 10 * 1024 * 1024
TIMEOUT_SECONDS = 20


class OfferError(Exception):
    pass


class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, request, response, code, message, headers, new_url):
        return None


def required(mapping, key):
    if not isinstance(mapping, dict) or key not in mapping or mapping[key] is None:
        raise OfferError("availability response is incomplete")
    return mapping[key]


def positive_integer(value):
    if isinstance(value, bool) or not isinstance(value, int) or value <= 0:
        raise OfferError("availability response is incomplete")
    return value


def compatible_offer(offers, requested):
    if not isinstance(offers, list):
        raise OfferError("availability response is invalid")

    for offer in offers:
        engine = required(offer, "engine")
        version = required(offer, "version")
        plan = required(offer, "plan")
        region = required(offer, "region")
        if (engine, version, plan, region) != (
            requested["engine"],
            requested["version"],
            requested["plan"],
            requested["region"],
        ):
            continue

        lifecycle = required(offer, "lifecycle")
        specifications = required(offer, "specifications")
        flavor = required(specifications, "flavor")
        network = required(specifications, "network")
        if (flavor, network) != (requested["flavor"], requested["network"]):
            continue

        status = required(lifecycle, "status")
        if status not in LIFECYCLE_STATUSES:
            continue

        nodes = required(specifications, "nodes")
        minimum_nodes = positive_integer(required(nodes, "minimum"))
        maximum_nodes = positive_integer(required(nodes, "maximum"))
        if minimum_nodes > maximum_nodes:
            raise OfferError("availability response is invalid")
        if not minimum_nodes <= requested["nodes"] <= maximum_nodes:
            continue

        storage = required(specifications, "storage")
        minimum = required(storage, "minimum")
        maximum = required(storage, "maximum")
        step = required(storage, "step")
        if any(required(limit, "unit") != "GB" for limit in (minimum, maximum, step)):
            raise OfferError("availability response is incomplete")

        minimum_size = positive_integer(required(minimum, "value"))
        maximum_size = positive_integer(required(maximum, "value"))
        step_size = positive_integer(required(step, "value"))
        if minimum_size > maximum_size:
            raise OfferError("availability response is invalid")

        try:
            disk_size = Decimal(requested["disk_size"])
        except InvalidOperation as error:
            raise OfferError("requested disk size is invalid") from error
        if not disk_size.is_finite() or disk_size != disk_size.to_integral_value():
            raise OfferError("requested disk size is invalid")
        disk_size = int(disk_size)
        if minimum_size <= disk_size <= maximum_size and (disk_size - minimum_size) % step_size == 0:
            return True

    return False


def open_url(url, headers=None, data=None):
    request = urllib.request.Request(url, data=data, headers=headers or {})
    opener = urllib.request.build_opener(NoRedirect)
    with opener.open(request, timeout=TIMEOUT_SECONDS) as response:
        body = response.read(MAX_RESPONSE_BYTES + 1)
        if len(body) > MAX_RESPONSE_BYTES:
            raise OfferError("availability response is too large")
        return response.status, body


def auth_headers(endpoint, method, url):
    access_token = os.environ.get("OVH_ACCESS_TOKEN")
    client_id = os.environ.get("OVH_CLIENT_ID")
    client_secret = os.environ.get("OVH_CLIENT_SECRET")
    app_key = os.environ.get("OVH_APPLICATION_KEY")
    app_secret = os.environ.get("OVH_APPLICATION_SECRET")
    consumer_key = os.environ.get("OVH_CONSUMER_KEY")

    modes = []
    if access_token:
        modes.append("token")
    if client_id or client_secret:
        modes.append("oauth")
    if app_key or app_secret or consumer_key:
        modes.append("classic")
    if len(modes) != 1:
        raise OfferError("invalid OVH authentication configuration")

    if modes[0] == "token":
        return {"Authorization": "Bearer " + access_token}
    if modes[0] == "oauth":
        if not client_id or not client_secret:
            raise OfferError("invalid OVH authentication configuration")
        token_url = AUTH_HOSTS[endpoint]
        body = urllib.parse.urlencode({
            "grant_type": "client_credentials",
            "client_id": client_id,
            "client_secret": client_secret,
            "scope": "all",
        }).encode()
        status, response_body = open_url(
            token_url,
            {"Content-Type": "application/x-www-form-urlencoded"},
            body,
        )
        if status < 200 or status >= 300:
            raise OfferError("OAuth token request failed (HTTP {})".format(status))
        try:
            token = json.loads(response_body)["access_token"]
        except (ValueError, KeyError, TypeError) as error:
            raise OfferError("OAuth token response is invalid") from error
        if not isinstance(token, str) or not token:
            raise OfferError("OAuth token response is invalid")
        return {"Authorization": "Bearer " + token}

    if not app_key or not app_secret or not consumer_key:
        raise OfferError("invalid OVH authentication configuration")
    _, time_body = open_url(API_HOSTS[endpoint] + "/auth/time")
    try:
        timestamp = int(time_body)
    except ValueError as error:
        raise OfferError("OVH time response is invalid") from error
    body = ""
    signature = hashlib.sha1(
        "{}+{}+{}+{}+{}+{}".format(
            app_secret, consumer_key, method, url, body, timestamp
        ).encode()
    ).hexdigest()
    return {
        "X-Ovh-Application": app_key,
        "X-Ovh-Consumer": consumer_key,
        "X-Ovh-Timestamp": str(timestamp),
        "X-Ovh-Signature": "$1$" + signature,
    }


def read_query():
    try:
        query = json.load(sys.stdin)
    except (ValueError, OSError) as error:
        raise OfferError("external query is invalid") from error
    if not isinstance(query, dict):
        raise OfferError("external query is invalid")
    return query


def main():
    query = read_query()
    endpoint = os.environ.get("OVH_ENDPOINT", "")
    api_host = API_HOSTS.get(endpoint)
    if not api_host:
        raise OfferError("OVH_ENDPOINT must be ovh-eu, ovh-us or ovh-ca")
    service_name = query.get("service_name", "")
    if not service_name:
        raise OfferError("Public Cloud project could not be resolved")

    path = "/cloud/project/{}/database/availability".format(
        urllib.parse.quote(service_name, safe="")
    )
    url = api_host + path
    headers = {"Accept": "application/json"}
    headers.update(auth_headers(endpoint, "GET", url))
    status, body = open_url(url, headers)
    if status < 200 or status >= 300:
        raise OfferError("availability request failed (HTTP {})".format(status))
    try:
        offers = json.loads(body)
    except (ValueError, UnicodeDecodeError) as error:
        raise OfferError("availability response is invalid") from error

    request = {
        key: query[key]
        for key in ("engine", "version", "plan", "region", "flavor", "network", "disk_size")
    }
    try:
        request["nodes"] = int(query["nodes"])
    except (KeyError, ValueError) as error:
        raise OfferError("external query is invalid") from error

    print(json.dumps({"compatible": str(compatible_offer(offers, request)).lower()}))


def cli():
    try:
        main()
    except urllib.error.HTTPError as error:
        code = error.code if isinstance(error.code, int) else 0
        print("OVH request failed (HTTP {})".format(code), file=sys.stderr)
        sys.exit(1)
    except (urllib.error.URLError, TimeoutError, OSError):
        print("OVH request failed (network error)", file=sys.stderr)
        sys.exit(1)
    except OfferError as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
    except Exception:
        print("OVH availability check failed (internal error)", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    cli()
