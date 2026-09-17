CLASS zcl_dm_match_engine DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    CONSTANTS:
      co_exact_match        TYPE c LENGTH 24 VALUE 'EXACT_MATCH',
      co_missing_target     TYPE c LENGTH 24 VALUE 'MISSING_TARGET',
      co_multiple_targets   TYPE c LENGTH 24 VALUE 'MULTIPLE_TARGETS',
      co_provisional_source TYPE c LENGTH 24 VALUE 'PROVISIONAL_SOURCE',
      co_evidence_incomplete TYPE c LENGTH 24 VALUE 'EVIDENCE_INCOMPLETE',
      co_approved_exception TYPE c LENGTH 24 VALUE 'APPROVED_EXCEPTION'.

    CLASS-METHODS normalize_tabkey
      IMPORTING iv_tabkey TYPE csequence
      RETURNING VALUE(rv_tabkey) TYPE zdm_r_sobj-norm_tabkey.

    CLASS-METHODS canonical_identity
      IMPORTING
        iv_pgmid       TYPE csequence
        iv_object_type TYPE csequence
        iv_object_name TYPE csequence
        iv_tabkey      TYPE csequence
      RETURNING VALUE(rv_identity) TYPE string.

    CLASS-METHODS classify
      IMPORTING
        iv_confirmed         TYPE abap_bool
        iv_prod_imported     TYPE abap_bool
        iv_target_count      TYPE i
        iv_evidence_complete TYPE abap_bool
        iv_exception_approved TYPE abap_bool
      RETURNING VALUE(rv_status) TYPE zdm_r_map-match_status.

    CLASS-METHODS classify_source
      IMPORTING iv_source_obj_uuid TYPE sysuuid_x16
      RETURNING VALUE(rv_status) TYPE zdm_r_map-match_status.

    TYPES tt_status TYPE STANDARD TABLE OF zdm_r_map-match_status
      WITH EMPTY KEY.

    CLASS-METHODS are_statuses_eligible
      IMPORTING it_status TYPE tt_status
      RETURNING VALUE(rv_eligible) TYPE abap_bool.

    CLASS-METHODS is_request_eligible
      IMPORTING iv_request_uuid TYPE sysuuid_x16
      RETURNING VALUE(rv_eligible) TYPE abap_bool.
ENDCLASS.

CLASS zcl_dm_match_engine IMPLEMENTATION.
  METHOD normalize_tabkey.
    rv_tabkey = iv_tabkey.
    TRANSLATE rv_tabkey TO UPPER CASE.
    CONDENSE rv_tabkey NO-GAPS.
  ENDMETHOD.

  METHOD canonical_identity.
    DATA(lv_pgmid) = to_upper( val = condense( val = CONV string( iv_pgmid ) ) ).
    DATA(lv_type) = to_upper( val = condense( val = CONV string( iv_object_type ) ) ).
    DATA(lv_name) = to_upper( val = condense( val = CONV string( iv_object_name ) ) ).
    DATA(lv_key) = CONV string( normalize_tabkey( iv_tabkey ) ).
    rv_identity = |{ lv_pgmid }\|{ lv_type }\|{ lv_name }\|{ lv_key }|.
  ENDMETHOD.

  METHOD classify.
    IF iv_exception_approved = abap_true.
      rv_status = co_approved_exception.
    ELSEIF iv_confirmed = abap_false OR iv_prod_imported = abap_false.
      rv_status = co_provisional_source.
    ELSEIF iv_target_count = 0.
      rv_status = co_missing_target.
    ELSEIF iv_target_count > 1.
      rv_status = co_multiple_targets.
    ELSEIF iv_evidence_complete = abap_false.
      rv_status = co_evidence_incomplete.
    ELSE.
      rv_status = co_exact_match.
    ENDIF.
  ENDMETHOD.

  METHOD classify_source.
    SELECT SINGLE trn~is_confirmed, trn~prod_imported,
                  src~pgmid, src~object_type, src~object_name, src~norm_tabkey
      FROM zdm_r_sobj AS src
      INNER JOIN zdm_r_strn AS trn
        ON trn~transport_uuid = src~transport_uuid
      WHERE src~source_obj_uuid = @iv_source_obj_uuid
      INTO @DATA(ls_source).

    IF sy-subrc <> 0.
      rv_status = co_provisional_source.
      RETURN.
    ENDIF.

    SELECT COUNT( * )
      FROM zdm_r_tobj
      WHERE pgmid       = @ls_source-pgmid
        AND object_type = @ls_source-object_type
        AND object_name = @ls_source-object_name
        AND norm_tabkey = @ls_source-norm_tabkey
      INTO @DATA(lv_target_count).

    SELECT SINGLE @abap_true
      FROM zdm_r_exc
      WHERE source_obj_uuid = @iv_source_obj_uuid
        AND approval_state  = 'APPROVED'
      INTO @DATA(lv_exception_approved).

    SELECT SINGLE evidence_complete
      FROM zdm_r_map
      WHERE source_obj_uuid = @iv_source_obj_uuid
        AND is_designated   = @abap_true
      INTO @DATA(lv_evidence_complete).

    rv_status = classify(
      iv_confirmed          = ls_source-is_confirmed
      iv_prod_imported      = ls_source-prod_imported
      iv_target_count       = lv_target_count
      iv_evidence_complete  = lv_evidence_complete
      iv_exception_approved = lv_exception_approved ).
  ENDMETHOD.

  METHOD are_statuses_eligible.
    rv_eligible = abap_false.
    IF it_status IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_status ASSIGNING FIELD-SYMBOL(<lv_status>).
      IF <lv_status> <> co_exact_match
         AND <lv_status> <> co_approved_exception.
        RETURN.
      ENDIF.
    ENDLOOP.
    rv_eligible = abap_true.
  ENDMETHOD.

  METHOD is_request_eligible.
    rv_eligible = abap_false.

    SELECT obj~source_obj_uuid
      FROM zdm_r_sobj AS obj
      INNER JOIN zdm_r_strn AS trn
        ON trn~transport_uuid = obj~transport_uuid
      WHERE trn~request_uuid = @iv_request_uuid
        AND trn~is_confirmed = @abap_true
        AND trn~prod_imported = @abap_true
      INTO TABLE @DATA(lt_source).

    IF lt_source IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_status TYPE tt_status.
    LOOP AT lt_source ASSIGNING FIELD-SYMBOL(<ls_source>).
      APPEND classify_source( <ls_source>-source_obj_uuid ) TO lt_status.
    ENDLOOP.
    rv_eligible = are_statuses_eligible( lt_status ).
  ENDMETHOD.
ENDCLASS.
