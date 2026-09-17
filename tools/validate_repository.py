"""Perform structural checks before pushing the abapGit repository."""

from __future__ import annotations

import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SRC = ROOT / "src"
errors: list[str] = []

if not (ROOT / ".abapgit.xml").is_file():
    errors.append("Missing .abapgit.xml")
if not (SRC / "package.devc.xml").is_file():
    errors.append("Missing package.devc.xml")

definition_files = sorted(SRC.glob("*.xml"))
for path in definition_files:
    try:
        ET.parse(path)
    except ET.ParseError as exc:
        errors.append(f"Invalid XML {path.name}: {exc}")

for source_pattern, metadata_suffix in (
    ("*.clas.abap", ".clas.xml"),
    ("*.intf.abap", ".intf.xml"),
    ("*.ddls.asddls", ".ddls.xml"),
    ("*.bdef.asbdef", ".bdef.xml"),
    ("*.ddlx.asddlxs", ".ddlx.xml"),
    ("*.srvd.srvdsrv", ".srvd.xml"),
):
    for source in SRC.glob(source_pattern):
        object_name = source.name.split(".")[0]
        metadata = SRC / f"{object_name}{metadata_suffix}"
        if not metadata.is_file():
            errors.append(f"Missing metadata for {source.name}")

required_tables = {
    "zdm_r_hdr",
    "zdm_r_strn",
    "zdm_r_sobj",
    "zdm_r_tobj",
    "zdm_r_map",
    "zdm_r_exc",
    "zdm_r_run",
}
for table in required_tables:
    path = SRC / f"{table}.tabl.xml"
    if not path.is_file():
        errors.append(f"Missing table definition {path.name}")

required_objects = {
    "zi_dm_reconciliation.bdef.xml",
    "zc_dm_reconciliation.bdef.xml",
    "zbp_i_dm_reconciliation.clas.xml",
    "zui_dm_reconciliation.srvd.xml",
    "zui_dm_recon_o2.srvb.xml",
}
for name in required_objects:
    if not (SRC / name).is_file():
        errors.append(f"Missing required object {name}")

for path in SRC.iterdir():
    if path.is_file() and path.name != path.name.lower():
        errors.append(f"abapGit filename is not lowercase: {path.name}")

engine = (SRC / "zcl_dm_match_engine.clas.abap").read_text(encoding="utf-8")
identity = re.search(
    r"METHOD canonical_identity\.(.*?)ENDMETHOD\.", engine, flags=re.DOTALL
)
if identity is None:
    errors.append("Canonical identity method was not found")
elif "transport" in identity.group(1).lower():
    errors.append("Transport unexpectedly participates in canonical identity")

if errors:
    print("\n".join(f"ERROR: {error}" for error in errors))
    sys.exit(1)

print(f"Validated {len(definition_files)} abapGit object definition files.")
print(f"Validated {len(list(SRC.iterdir()))} total files under /src/.")
