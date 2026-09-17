CLASS zcl_dm_seed_data DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PRIVATE SECTION.
    CLASS-METHODS uuid RETURNING VALUE(rv_uuid) TYPE sysuuid_x16.
ENDCLASS.

CLASS zcl_dm_seed_data IMPLEMENTATION.
  METHOD uuid.
    TRY.
        rv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
      CATCH cx_uuid_error.
        ASSERT 1 = 0.
    ENDTRY.
  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.
    SELECT SINGLE @abap_true FROM zdm_r_hdr
      WHERE jira_key = 'DM-POC-01' INTO @DATA(lv_exists).
    IF lv_exists = abap_true.
      out->write( 'Seed data already exists; no rows inserted.' ).
      RETURN.
    ENDIF.

    GET TIME STAMP FIELD DATA(lv_ts).
    DATA lt_hdr  TYPE STANDARD TABLE OF zdm_r_hdr WITH EMPTY KEY.
    DATA lt_trn  TYPE STANDARD TABLE OF zdm_r_strn WITH EMPTY KEY.
    DATA lt_src  TYPE STANDARD TABLE OF zdm_r_sobj WITH EMPTY KEY.
    DATA lt_tgt  TYPE STANDARD TABLE OF zdm_r_tobj WITH EMPTY KEY.
    DATA lt_map  TYPE STANDARD TABLE OF zdm_r_map WITH EMPTY KEY.
    DATA lt_exc  TYPE STANDARD TABLE OF zdm_r_exc WITH EMPTY KEY.
    DATA lt_run  TYPE STANDARD TABLE OF zdm_r_run WITH EMPTY KEY.

    " 01: exact canonical identity, intentionally different transports
    DATA(lv_h1) = uuid( ). DATA(lv_tr1) = uuid( ).
    DATA(lv_s1) = uuid( ). DATA(lv_t1) = uuid( ).
    APPEND VALUE #( request_uuid = lv_h1 jira_key = 'DM-POC-01'
      deployment_request = 'Exact/different transports' cab_approved = abap_true
      cab_date = sy-datum deployment_state = 'PRODUCTION'
      business_owner = sy-uname technical_owner = sy-uname
      risk_level = 'LOW' overall_status = 'RECONCILED'
      created_by = sy-uname created_at = lv_ts last_changed_by = sy-uname
      last_changed_at = lv_ts local_last_changed = lv_ts ) TO lt_hdr.
    APPEND VALUE #( transport_uuid = lv_tr1 request_uuid = lv_h1
      transport_id = 'DEVK900101' source_system = 'S420'
      is_confirmed = abap_true prod_imported = abap_true
      import_date = sy-datum import_evidence = 'POC import log 01'
      deployment_state = 'COMPLETE' local_last_changed = lv_ts ) TO lt_trn.
    APPEND VALUE #( source_obj_uuid = lv_s1 transport_uuid = lv_tr1
      pgmid = 'R3TR' object_type = 'CLAS' object_name = 'ZCL_DM_EXACT'
      norm_tabkey = '' identity_hash = 'R3TR|CLAS|ZCL_DM_EXACT|'
      local_last_changed = lv_ts ) TO lt_src.
    APPEND VALUE #( target_obj_uuid = lv_t1 target_transport = 'QASK910201'
      target_system = 'S423' pgmid = 'R3TR' object_type = 'CLAS'
      object_name = 'ZCL_DM_EXACT' norm_tabkey = ''
      identity_hash = 'R3TR|CLAS|ZCL_DM_EXACT|' technical_state = 'VALID'
      evidence_uri = 'adt://target/ZCL_DM_EXACT' local_last_changed = lv_ts ) TO lt_tgt.
    APPEND VALUE #( mapping_uuid = uuid( ) source_obj_uuid = lv_s1
      target_obj_uuid = lv_t1 match_status = 'EXACT_MATCH'
      disposition = 'IMPLEMENT' is_designated = abap_true
      evidence_complete = abap_true evidence_uri = 'adt://target/ZCL_DM_EXACT'
      reviewer = sy-uname reviewed_on = sy-datum completed_on = sy-datum
      local_last_changed = lv_ts ) TO lt_map.

    " 02: confirmed source with no target
    DATA(lv_h2) = uuid( ). DATA(lv_tr2) = uuid( ). DATA(lv_s2) = uuid( ).
    APPEND VALUE #( request_uuid = lv_h2 jira_key = 'DM-POC-02'
      deployment_request = 'Missing target' cab_approved = abap_true
      cab_date = sy-datum deployment_state = 'PRODUCTION'
      business_owner = sy-uname risk_level = 'HIGH' overall_status = 'IN_REVIEW'
      created_by = sy-uname created_at = lv_ts last_changed_at = lv_ts
      local_last_changed = lv_ts ) TO lt_hdr.
    APPEND VALUE #( transport_uuid = lv_tr2 request_uuid = lv_h2
      transport_id = 'DEVK900102' source_system = 'S420'
      is_confirmed = abap_true prod_imported = abap_true import_date = sy-datum
      import_evidence = 'POC import log 02' deployment_state = 'COMPLETE'
      local_last_changed = lv_ts ) TO lt_trn.
    APPEND VALUE #( source_obj_uuid = lv_s2 transport_uuid = lv_tr2
      pgmid = 'R3TR' object_type = 'PROG' object_name = 'ZDM_MISSING'
      identity_hash = 'R3TR|PROG|ZDM_MISSING|' local_last_changed = lv_ts ) TO lt_src.
    APPEND VALUE #( mapping_uuid = uuid( ) source_obj_uuid = lv_s2
      match_status = 'MISSING_TARGET' disposition = 'PENDING'
      evidence_complete = abap_false local_last_changed = lv_ts ) TO lt_map.

    " 03: two targets share one canonical identity
    DATA(lv_h3) = uuid( ). DATA(lv_tr3) = uuid( ).
    DATA(lv_s3) = uuid( ). DATA(lv_t31) = uuid( ). DATA(lv_t32) = uuid( ).
    APPEND VALUE #( request_uuid = lv_h3 jira_key = 'DM-POC-03'
      deployment_request = 'Duplicate targets' cab_approved = abap_true
      cab_date = sy-datum deployment_state = 'PRODUCTION'
      business_owner = sy-uname risk_level = 'HIGH' overall_status = 'IN_REVIEW'
      created_by = sy-uname created_at = lv_ts last_changed_at = lv_ts
      local_last_changed = lv_ts ) TO lt_hdr.
    APPEND VALUE #( transport_uuid = lv_tr3 request_uuid = lv_h3
      transport_id = 'DEVK900103' source_system = 'S420'
      is_confirmed = abap_true prod_imported = abap_true import_date = sy-datum
      import_evidence = 'POC import log 03' deployment_state = 'COMPLETE'
      local_last_changed = lv_ts ) TO lt_trn.
    APPEND VALUE #( source_obj_uuid = lv_s3 transport_uuid = lv_tr3
      pgmid = 'R3TR' object_type = 'TABL' object_name = 'ZDM_DUPLICATE'
      identity_hash = 'R3TR|TABL|ZDM_DUPLICATE|' local_last_changed = lv_ts ) TO lt_src.
    DO 2 TIMES.
      DATA(lv_target_uuid) = COND sysuuid_x16(
        WHEN sy-index = 1 THEN lv_t31 ELSE lv_t32 ).
      APPEND VALUE #( target_obj_uuid = lv_target_uuid
        target_transport = COND #( WHEN sy-index = 1
          THEN 'QASK910203' ELSE 'QASK910204' )
        target_system = 'S423' pgmid = 'R3TR' object_type = 'TABL'
        object_name = 'ZDM_DUPLICATE'
        identity_hash = 'R3TR|TABL|ZDM_DUPLICATE|'
        technical_state = 'VALID' local_last_changed = lv_ts ) TO lt_tgt.
    ENDDO.
    APPEND VALUE #( mapping_uuid = uuid( ) source_obj_uuid = lv_s3
      match_status = 'MULTIPLE_TARGETS' disposition = 'PENDING'
      evidence_complete = abap_false local_last_changed = lv_ts ) TO lt_map.

    " 04: proposed source transport is not in the denominator
    DATA(lv_h4) = uuid( ). DATA(lv_tr4) = uuid( ). DATA(lv_s4) = uuid( ).
    APPEND VALUE #( request_uuid = lv_h4 jira_key = 'DM-POC-04'
      deployment_request = 'Provisional source' cab_approved = abap_true
      cab_date = sy-datum deployment_state = 'PROPOSED'
      business_owner = sy-uname risk_level = 'MEDIUM' overall_status = 'OPEN'
      created_by = sy-uname created_at = lv_ts last_changed_at = lv_ts
      local_last_changed = lv_ts ) TO lt_hdr.
    APPEND VALUE #( transport_uuid = lv_tr4 request_uuid = lv_h4
      transport_id = 'DEVK900104' source_system = 'S420'
      is_confirmed = abap_false prod_imported = abap_false
      deployment_state = 'PROVISIONAL' local_last_changed = lv_ts ) TO lt_trn.
    APPEND VALUE #( source_obj_uuid = lv_s4 transport_uuid = lv_tr4
      pgmid = 'R3TR' object_type = 'DDLS' object_name = 'ZDM_PROVISIONAL'
      identity_hash = 'R3TR|DDLS|ZDM_PROVISIONAL|' local_last_changed = lv_ts ) TO lt_src.
    APPEND VALUE #( mapping_uuid = uuid( ) source_obj_uuid = lv_s4
      match_status = 'PROVISIONAL_SOURCE' disposition = 'OUT_OF_SCOPE'
      local_last_changed = lv_ts ) TO lt_map.

    " 05: confirmed transport without completed production import
    DATA(lv_h5) = uuid( ). DATA(lv_tr5) = uuid( ). DATA(lv_s5) = uuid( ).
    APPEND VALUE #( request_uuid = lv_h5 jira_key = 'DM-POC-05'
      deployment_request = 'Partial deployment' cab_approved = abap_true
      cab_date = sy-datum deployment_state = 'PARTIAL'
      business_owner = sy-uname risk_level = 'HIGH' overall_status = 'OPEN'
      created_by = sy-uname created_at = lv_ts last_changed_at = lv_ts
      local_last_changed = lv_ts ) TO lt_hdr.
    APPEND VALUE #( transport_uuid = lv_tr5 request_uuid = lv_h5
      transport_id = 'DEVK900105' source_system = 'S420'
      is_confirmed = abap_true prod_imported = abap_false
      deployment_state = 'PARTIAL' local_last_changed = lv_ts ) TO lt_trn.
    APPEND VALUE #( source_obj_uuid = lv_s5 transport_uuid = lv_tr5
      pgmid = 'R3TR' object_type = 'SRVD' object_name = 'ZDM_PARTIAL'
      identity_hash = 'R3TR|SRVD|ZDM_PARTIAL|' local_last_changed = lv_ts ) TO lt_src.
    APPEND VALUE #( mapping_uuid = uuid( ) source_obj_uuid = lv_s5
      match_status = 'PROVISIONAL_SOURCE' disposition = 'PENDING'
      local_last_changed = lv_ts ) TO lt_map.

    " 06: missing implementation accepted through governed exception
    DATA(lv_h6) = uuid( ). DATA(lv_tr6) = uuid( ). DATA(lv_s6) = uuid( ).
    APPEND VALUE #( request_uuid = lv_h6 jira_key = 'DM-POC-06'
      deployment_request = 'Approved exception' cab_approved = abap_true
      cab_date = sy-datum deployment_state = 'PRODUCTION'
      business_owner = sy-uname risk_level = 'MEDIUM'
      overall_status = 'RECONCILED' created_by = sy-uname created_at = lv_ts
      last_changed_at = lv_ts local_last_changed = lv_ts ) TO lt_hdr.
    APPEND VALUE #( transport_uuid = lv_tr6 request_uuid = lv_h6
      transport_id = 'DEVK900106' source_system = 'S420'
      is_confirmed = abap_true prod_imported = abap_true import_date = sy-datum
      import_evidence = 'POC import log 06' deployment_state = 'COMPLETE'
      local_last_changed = lv_ts ) TO lt_trn.
    APPEND VALUE #( source_obj_uuid = lv_s6 transport_uuid = lv_tr6
      pgmid = 'R3TR' object_type = 'FUGR' object_name = 'ZDM_EXCEPTED'
      identity_hash = 'R3TR|FUGR|ZDM_EXCEPTED|' local_last_changed = lv_ts ) TO lt_src.
    APPEND VALUE #( mapping_uuid = uuid( ) source_obj_uuid = lv_s6
      match_status = 'APPROVED_EXCEPTION' disposition = 'EXCLUDE'
      evidence_complete = abap_true reviewer = sy-uname reviewed_on = sy-datum
      completed_on = sy-datum local_last_changed = lv_ts ) TO lt_map.
    APPEND VALUE #( exception_uuid = uuid( ) request_uuid = lv_h6
      source_obj_uuid = lv_s6 exception_type = 'NOT_REQUIRED'
      impact = 'Function group retired in target design'
      exception_owner = sy-uname due_date = sy-datum
      approval_state = 'APPROVED' approved_by = sy-uname
      approved_on = sy-datum approval_reference = 'CAB-POC-06'
      local_last_changed = lv_ts ) TO lt_exc.

    " 07: exact target exists but a later source delta reopens review
    DATA(lv_h7) = uuid( ). DATA(lv_tr7) = uuid( ).
    DATA(lv_s7) = uuid( ). DATA(lv_t7) = uuid( ).
    APPEND VALUE #( request_uuid = lv_h7 jira_key = 'DM-POC-07'
      deployment_request = 'Later production delta' cab_approved = abap_true
      cab_date = sy-datum deployment_state = 'PRODUCTION'
      business_owner = sy-uname risk_level = 'HIGH' overall_status = 'IN_REVIEW'
      created_by = sy-uname created_at = lv_ts last_changed_at = lv_ts
      local_last_changed = lv_ts ) TO lt_hdr.
    APPEND VALUE #( transport_uuid = lv_tr7 request_uuid = lv_h7
      transport_id = 'DEVK900107' source_system = 'S420'
      is_confirmed = abap_true prod_imported = abap_true import_date = sy-datum
      import_evidence = 'POC import log 07' deployment_state = 'COMPLETE'
      local_last_changed = lv_ts ) TO lt_trn.
    APPEND VALUE #( source_obj_uuid = lv_s7 transport_uuid = lv_tr7
      pgmid = 'R3TR' object_type = 'CLAS' object_name = 'ZCL_DM_DELTA'
      identity_hash = 'R3TR|CLAS|ZCL_DM_DELTA|' delta_detected = abap_true
      delta_description = 'Changed after baseline reconciliation'
      local_last_changed = lv_ts ) TO lt_src.
    APPEND VALUE #( target_obj_uuid = lv_t7 target_transport = 'QASK910207'
      target_system = 'S423' pgmid = 'R3TR' object_type = 'CLAS'
      object_name = 'ZCL_DM_DELTA' identity_hash = 'R3TR|CLAS|ZCL_DM_DELTA|'
      technical_state = 'VALID' evidence_uri = 'adt://target/ZCL_DM_DELTA'
      local_last_changed = lv_ts ) TO lt_tgt.
    APPEND VALUE #( mapping_uuid = uuid( ) source_obj_uuid = lv_s7
      target_obj_uuid = lv_t7 match_status = 'EVIDENCE_INCOMPLETE'
      disposition = 'REVALIDATE' is_designated = abap_true
      evidence_complete = abap_false local_last_changed = lv_ts ) TO lt_map.

    APPEND VALUE #( run_uuid = uuid( ) run_timestamp = lv_ts run_by = sy-uname
      approval_population = 7 production_deployment = 5 scope_validity = 5
      transport_complete = 5 object_complete = 4 implementation_evid = 2
      delta_detection = 1 exclusion_governance = 1 exact_count = 1
      missing_count = 1 multiple_count = 1 exception_count = 1
      eligible_count = 2 ) TO lt_run.

    INSERT zdm_r_hdr  FROM TABLE @lt_hdr.
    INSERT zdm_r_strn FROM TABLE @lt_trn.
    INSERT zdm_r_sobj FROM TABLE @lt_src.
    INSERT zdm_r_tobj FROM TABLE @lt_tgt.
    INSERT zdm_r_map  FROM TABLE @lt_map.
    INSERT zdm_r_exc  FROM TABLE @lt_exc.
    INSERT zdm_r_run  FROM TABLE @lt_run.

    COMMIT WORK.
    out->write( |Inserted { lines( lt_hdr ) } reconciliation scenarios.| ).
  ENDMETHOD.
ENDCLASS.
