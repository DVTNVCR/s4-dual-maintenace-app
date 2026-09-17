CLASS zcl_dm_match_engine_test DEFINITION
  FOR TESTING RISK LEVEL HARMLESS DURATION SHORT.
  PRIVATE SECTION.
    METHODS canonical_ignores_transport FOR TESTING.
    METHODS normalizes_key FOR TESTING.
    METHODS exact_match FOR TESTING.
    METHODS missing_target FOR TESTING.
    METHODS duplicate_targets FOR TESTING.
    METHODS approved_exception_wins FOR TESTING.
    METHODS unresolved_not_eligible FOR TESTING.
    METHODS exact_and_exception_eligible FOR TESTING.
ENDCLASS.

CLASS zcl_dm_match_engine_test IMPLEMENTATION.
  METHOD canonical_ignores_transport.
    DATA(lv_first) = zcl_dm_match_engine=>canonical_identity(
      iv_pgmid = 'R3TR' iv_object_type = 'CLAS'
      iv_object_name = 'ZCL_DEMO' iv_tabkey = '' ).
    DATA(lv_second) = zcl_dm_match_engine=>canonical_identity(
      iv_pgmid = 'R3TR' iv_object_type = 'CLAS'
      iv_object_name = 'ZCL_DEMO' iv_tabkey = '' ).
    cl_abap_unit_assert=>assert_equals( act = lv_first exp = lv_second ).
    cl_abap_unit_assert=>assert_false(
      act = xsdbool( lv_first CS 'DEVK900001' ) ).
  ENDMETHOD.

  METHOD normalizes_key.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_dm_match_engine=>normalize_tabkey( '  0001 ab c ' )
      exp = '0001ABC' ).
  ENDMETHOD.

  METHOD exact_match.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_dm_match_engine=>classify(
        iv_confirmed = abap_true iv_prod_imported = abap_true
        iv_target_count = 1 iv_evidence_complete = abap_true
        iv_exception_approved = abap_false )
      exp = zcl_dm_match_engine=>co_exact_match ).
  ENDMETHOD.

  METHOD missing_target.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_dm_match_engine=>classify(
        iv_confirmed = abap_true iv_prod_imported = abap_true
        iv_target_count = 0 iv_evidence_complete = abap_true
        iv_exception_approved = abap_false )
      exp = zcl_dm_match_engine=>co_missing_target ).
  ENDMETHOD.

  METHOD duplicate_targets.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_dm_match_engine=>classify(
        iv_confirmed = abap_true iv_prod_imported = abap_true
        iv_target_count = 2 iv_evidence_complete = abap_true
        iv_exception_approved = abap_false )
      exp = zcl_dm_match_engine=>co_multiple_targets ).
  ENDMETHOD.

  METHOD approved_exception_wins.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_dm_match_engine=>classify(
        iv_confirmed = abap_true iv_prod_imported = abap_true
        iv_target_count = 0 iv_evidence_complete = abap_false
        iv_exception_approved = abap_true )
      exp = zcl_dm_match_engine=>co_approved_exception ).
  ENDMETHOD.

  METHOD unresolved_not_eligible.
    DATA(lt_status) = VALUE zcl_dm_match_engine=>tt_status(
      ( zcl_dm_match_engine=>co_exact_match )
      ( zcl_dm_match_engine=>co_missing_target ) ).
    cl_abap_unit_assert=>assert_false(
      zcl_dm_match_engine=>are_statuses_eligible( lt_status ) ).
  ENDMETHOD.

  METHOD exact_and_exception_eligible.
    DATA(lt_status) = VALUE zcl_dm_match_engine=>tt_status(
      ( zcl_dm_match_engine=>co_exact_match )
      ( zcl_dm_match_engine=>co_approved_exception ) ).
    cl_abap_unit_assert=>assert_true(
      zcl_dm_match_engine=>are_statuses_eligible( lt_status ) ).
  ENDMETHOD.
ENDCLASS.
