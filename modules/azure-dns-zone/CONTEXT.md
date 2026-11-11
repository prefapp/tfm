# azure-dns-zone

Owns one public DNS zone and its records.

Terms below are specific to this module. Cross-cutting vocabulary (Firestartr, ghaps,
`config`, CR, module contract, state boundary, composite module) lives in the root
[`CONTEXT.md`](../../CONTEXT.md); [`CONTEXT-MAP.md`](../../CONTEXT-MAP.md) lists the
other contexts.

## Language

**record family**:
One input list per record type (`a_records`, `cname_records`, `mx_records`, `txt_records`, `srv_records`, `caa_records`, `ns_records`, `ptr_records`, `aaaa_records`). Each list is independent and may be empty.

**record set**:
One entry of a record family: a name, a TTL, and the values. Azure groups values by name and type, so two entries with the same name in the same family collide.
_Avoid_: record (a single value)
