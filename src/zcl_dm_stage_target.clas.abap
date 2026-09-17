CLASS zcl_dm_stage_target DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_dm_object_provider.
ENDCLASS.

CLASS zcl_dm_stage_target IMPLEMENTATION.
  METHOD zif_dm_object_provider~get_objects.
    SELECT target_transport AS transport_id,
           pgmid,
           object_type,
           object_name,
           tabkey,
           evidence_uri
      FROM zdm_r_tobj
      INTO CORRESPONDING FIELDS OF TABLE @rt_objects.
  ENDMETHOD.
ENDCLASS.
