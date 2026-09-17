CLASS zcl_dm_stage_source DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_dm_object_provider.
ENDCLASS.

CLASS zcl_dm_stage_source IMPLEMENTATION.
  METHOD zif_dm_object_provider~get_objects.
    SELECT trn~transport_id,
           obj~pgmid,
           obj~object_type,
           obj~object_name,
           obj~tabkey,
           trn~import_evidence AS evidence_uri
      FROM zdm_r_sobj AS obj
      INNER JOIN zdm_r_strn AS trn
        ON trn~transport_uuid = obj~transport_uuid
      WHERE trn~is_confirmed = @abap_true
        AND trn~prod_imported = @abap_true
      INTO CORRESPONDING FIELDS OF TABLE @rt_objects.
  ENDMETHOD.
ENDCLASS.
