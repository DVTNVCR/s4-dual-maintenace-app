# S4 dual-maintenance reconciliation app

abapGit source repository for the RAP/Fiori Elements reconciliation POC
targeting SAP S/4HANA 2020 FPS02.

## Install in DS4

1. In standalone abapGit, create an online repository for this GitHub URL.
2. Assign the repository to package `TEST_DUAL_MAINTENANCE`.
3. Confirm that the repository root maps to `/src/`, then pull.
4. Activate in dependency order: tables, classes/interfaces, interface CDS
   views, managed behavior, projection CDS/behavior, metadata extensions,
   service definition, and service binding.
5. In ADT, generate the draft persistence tables referenced by
   `ZI_DM_RECONCILIATION`:
   `ZDM_R_HDR_D`, `ZDM_R_STRN_D`, `ZDM_R_SOBJ_D`, `ZDM_R_MAP_D`, and
   `ZDM_R_EXC_D`.
6. Run behavior consistency checks and repair/regenerate behavior-pool stubs
   if the FPS02 compiler requests release-specific signatures.
7. Activate and publish the OData V2 service binding
   `ZUI_DM_RECONCILIATION_O2`.
8. Run class `ZCL_DM_SEED_DATA`, ABAP Unit, ATC, and a service metadata test.

The service binding is intentionally committed as unpublished. Publishing it
in DS4 creates the system-specific Gateway artifacts.

## Important limitations

- The repository is serialized for standalone abapGit's classic XML format.
- The source has local model validation but has not yet completed ABAP syntax,
  activation, ATC, or service-metadata validation in DS4.
- Draft tables are ADT-generated artifacts and are intentionally not
  hand-authored in this repository.
- `TEST_DUAL_MAINTENANCE` currently has transport recording disabled. That is
  acceptable for this POC but not for promotion through the SAP transport
  landscape.

## Object model

The source population contains only transports confirmed as imported into the
S4 2020 production system. Object matching uses:

`PGMID | OBJECT | OBJ_NAME | normalized TABKEY`

Transport numbers provide traceability but are not part of object identity.