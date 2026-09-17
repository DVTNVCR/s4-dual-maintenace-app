CLASS lhc_reconciliation DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Reconciliation
      RESULT result.
    METHODS setInitialStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Reconciliation~setInitialStatus.
    METHODS validateApproval FOR VALIDATE ON SAVE
      IMPORTING keys FOR Reconciliation~validateApproval.
    METHODS validateReconciled FOR VALIDATE ON SAVE
      IMPORTING keys FOR Reconciliation~validateReconciled.
    METHODS ConfirmProductionScope FOR MODIFY
      IMPORTING keys FOR ACTION Reconciliation~ConfirmProductionScope RESULT result.
    METHODS RunReconciliation FOR MODIFY
      IMPORTING keys FOR ACTION Reconciliation~RunReconciliation RESULT result.
    METHODS Reopen FOR MODIFY
      IMPORTING keys FOR ACTION Reconciliation~Reopen RESULT result.
    METHODS MarkReconciled FOR MODIFY
      IMPORTING keys FOR ACTION Reconciliation~MarkReconciled RESULT result.
ENDCLASS.

CLASS lhc_reconciliation IMPLEMENTATION.
  METHOD get_instance_authorizations.
    result = VALUE #( FOR key IN keys
      ( %tky = key-%tky
        %update = if_abap_behv=>auth-allowed
        %action-ConfirmProductionScope = if_abap_behv=>auth-allowed
        %action-RunReconciliation = if_abap_behv=>auth-allowed
        %action-Reopen = if_abap_behv=>auth-allowed
        %action-MarkReconciled = if_abap_behv=>auth-allowed ) ).
  ENDMETHOD.

  METHOD setInitialStatus.
    MODIFY ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Reconciliation
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR key IN keys
        ( %tky = key-%tky OverallStatus = 'OPEN' ) ).
  ENDMETHOD.

  METHOD validateApproval.
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Reconciliation
      FIELDS ( CabApproved CabDate )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).
    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<header>).
      IF <header>-CabApproved = abap_true AND <header>-CabDate IS INITIAL.
        APPEND VALUE #( %tky = <header>-%tky ) TO failed-Reconciliation.
        APPEND VALUE #( %tky = <header>-%tky
          %msg = new_message( id = '00' number = '398'
            severity = if_abap_behv_message=>severity-error
            v1 = 'CAB date is required for approval' )
          %element-CabDate = if_abap_behv=>mk-on )
          TO reported-Reconciliation.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateReconciled.
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Reconciliation
      FIELDS ( RequestUUID OverallStatus )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).
    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<header>).
      IF <header>-OverallStatus = 'RECONCILED'
         AND zcl_dm_match_engine=>is_request_eligible(
               <header>-RequestUUID ) = abap_false.
        APPEND VALUE #( %tky = <header>-%tky ) TO failed-Reconciliation.
        APPEND VALUE #( %tky = <header>-%tky
          %msg = new_message( id = '00' number = '398'
            severity = if_abap_behv_message=>severity-error
            v1 = 'Unresolved in-scope objects remain' )
          %element-OverallStatus = if_abap_behv=>mk-on )
          TO reported-Reconciliation.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD ConfirmProductionScope.
    MODIFY ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Reconciliation UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR key IN keys
        ( %tky = key-%tky OverallStatus = 'SCOPE_CONFIRMED' ) ).
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Reconciliation ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).
    result = VALUE #( FOR header IN lt_header
      ( %tky = header-%tky %param = header ) ).
  ENDMETHOD.

  METHOD RunReconciliation.
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Reconciliation FIELDS ( RequestUUID )
      WITH CORRESPONDING #( keys ) RESULT DATA(lt_requests).
    LOOP AT lt_requests ASSIGNING FIELD-SYMBOL(<request>).
      SELECT map~mapping_uuid, src~source_obj_uuid
        FROM zdm_r_map AS map
        INNER JOIN zdm_r_sobj AS src
          ON src~source_obj_uuid = map~source_obj_uuid
        INNER JOIN zdm_r_strn AS trn
          ON trn~transport_uuid = src~transport_uuid
        WHERE trn~request_uuid = @<request>-RequestUUID
        INTO TABLE @DATA(lt_mappings).
      LOOP AT lt_mappings ASSIGNING FIELD-SYMBOL(<mapping>).
        DATA(lv_match_status) = zcl_dm_match_engine=>classify_source(
          <mapping>-source_obj_uuid ).
        MODIFY ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
          ENTITY Mapping UPDATE FIELDS ( MatchStatus )
          WITH VALUE #( ( MappingUUID = <mapping>-mapping_uuid
                          MatchStatus = lv_match_status ) ).
      ENDLOOP.
    ENDLOOP.

    MODIFY ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Reconciliation UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR key IN keys
        ( %tky = key-%tky OverallStatus = 'IN_REVIEW' ) ).
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Reconciliation ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).
    result = VALUE #( FOR header IN lt_header
      ( %tky = header-%tky %param = header ) ).
  ENDMETHOD.

  METHOD Reopen.
    MODIFY ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Reconciliation UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR key IN keys
        ( %tky = key-%tky OverallStatus = 'OPEN' ) ).
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Reconciliation ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).
    result = VALUE #( FOR header IN lt_header
      ( %tky = header-%tky %param = header ) ).
  ENDMETHOD.

  METHOD MarkReconciled.
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Reconciliation FIELDS ( RequestUUID )
      WITH CORRESPONDING #( keys ) RESULT DATA(lt_check).
    LOOP AT lt_check ASSIGNING FIELD-SYMBOL(<check>).
      IF zcl_dm_match_engine=>is_request_eligible(
           <check>-RequestUUID ) = abap_true.
        MODIFY ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
          ENTITY Reconciliation UPDATE FIELDS ( OverallStatus )
          WITH VALUE #( ( %tky = <check>-%tky
                          OverallStatus = 'RECONCILED' ) ).
      ELSE.
        APPEND VALUE #( %tky = <check>-%tky ) TO failed-Reconciliation.
        APPEND VALUE #( %tky = <check>-%tky
          %msg = new_message( id = '00' number = '398'
            severity = if_abap_behv_message=>severity-error
            v1 = 'Request is not eligible' ) )
          TO reported-Reconciliation.
      ENDIF.
    ENDLOOP.
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Reconciliation ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_header).
    result = VALUE #( FOR header IN lt_header
      ( %tky = header-%tky %param = header ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_sourcetransport DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS validateProductionEvidence FOR VALIDATE ON SAVE
      IMPORTING keys FOR SourceTransport~validateProductionEvidence.
ENDCLASS.

CLASS lhc_sourcetransport IMPLEMENTATION.
  METHOD validateProductionEvidence.
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY SourceTransport
      FIELDS ( ProductionImported ImportEvidence ImportDate )
      WITH CORRESPONDING #( keys ) RESULT DATA(lt_transport).
    LOOP AT lt_transport ASSIGNING FIELD-SYMBOL(<transport>).
      IF <transport>-ProductionImported = abap_true
         AND ( <transport>-ImportEvidence IS INITIAL
               OR <transport>-ImportDate IS INITIAL ).
        APPEND VALUE #( %tky = <transport>-%tky ) TO failed-SourceTransport.
        APPEND VALUE #( %tky = <transport>-%tky
          %msg = new_message( id = '00' number = '398'
            severity = if_abap_behv_message=>severity-error
            v1 = 'Production import evidence is required' ) )
          TO reported-SourceTransport.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_sourceobject DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS normalizeIdentity FOR DETERMINE ON MODIFY
      IMPORTING keys FOR SourceObject~normalizeIdentity.
ENDCLASS.

CLASS lhc_sourceobject IMPLEMENTATION.
  METHOD normalizeIdentity.
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY SourceObject FIELDS ( PGMID ObjectType ObjectName TabKey )
      WITH CORRESPONDING #( keys ) RESULT DATA(lt_object).
    MODIFY ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY SourceObject
      UPDATE FIELDS ( NormalizedTabKey IdentityHash )
      WITH VALUE #( FOR object IN lt_object
        ( %tky = object-%tky
          NormalizedTabKey = zcl_dm_match_engine=>normalize_tabkey(
                               object-TabKey )
          IdentityHash = zcl_dm_match_engine=>canonical_identity(
            iv_pgmid = object-PGMID
            iv_object_type = object-ObjectType
            iv_object_name = object-ObjectName
            iv_tabkey = object-TabKey ) ) ).
  ENDMETHOD.
ENDCLASS.

CLASS lhc_mapping DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS validateDesignation FOR VALIDATE ON SAVE
      IMPORTING keys FOR Mapping~validateDesignation.
ENDCLASS.

CLASS lhc_mapping IMPLEMENTATION.
  METHOD validateDesignation.
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Mapping
      FIELDS ( IsDesignated TargetObjectUUID Disposition EvidenceComplete )
      WITH CORRESPONDING #( keys ) RESULT DATA(lt_mapping).
    LOOP AT lt_mapping ASSIGNING FIELD-SYMBOL(<mapping>).
      IF <mapping>-IsDesignated = abap_true
         AND ( <mapping>-TargetObjectUUID IS INITIAL
               OR <mapping>-Disposition IS INITIAL
               OR <mapping>-EvidenceComplete = abap_false ).
        APPEND VALUE #( %tky = <mapping>-%tky ) TO failed-Mapping.
        APPEND VALUE #( %tky = <mapping>-%tky
          %msg = new_message( id = '00' number = '398'
            severity = if_abap_behv_message=>severity-error
            v1 = 'Designated mapping needs target and evidence' ) )
          TO reported-Mapping.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lhc_exception DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS ApproveException FOR MODIFY
      IMPORTING keys FOR ACTION Exception~ApproveException RESULT result.
    METHODS validateExceptionApproval FOR VALIDATE ON SAVE
      IMPORTING keys FOR Exception~validateExceptionApproval.
ENDCLASS.

CLASS lhc_exception IMPLEMENTATION.
  METHOD ApproveException.
    MODIFY ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Exception
      UPDATE FIELDS ( ApprovalState ApprovedBy ApprovedOn )
      WITH VALUE #( FOR key IN keys
        ( %tky = key-%tky ApprovalState = 'APPROVED'
          ApprovedBy = sy-uname ApprovedOn = sy-datum ) ).
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Exception ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_exception).
    result = VALUE #( FOR exception IN lt_exception
      ( %tky = exception-%tky %param = exception ) ).
  ENDMETHOD.

  METHOD validateExceptionApproval.
    READ ENTITIES OF zi_dm_reconciliation IN LOCAL MODE
      ENTITY Exception
      FIELDS ( ApprovalState ApprovedBy ApprovedOn ApprovalReference )
      WITH CORRESPONDING #( keys ) RESULT DATA(lt_exception).
    LOOP AT lt_exception ASSIGNING FIELD-SYMBOL(<exception>).
      IF <exception>-ApprovalState = 'APPROVED'
         AND ( <exception>-ApprovedBy IS INITIAL
               OR <exception>-ApprovedOn IS INITIAL
               OR <exception>-ApprovalReference IS INITIAL ).
        APPEND VALUE #( %tky = <exception>-%tky ) TO failed-Exception.
        APPEND VALUE #( %tky = <exception>-%tky
          %msg = new_message( id = '00' number = '398'
            severity = if_abap_behv_message=>severity-error
            v1 = 'Approved exception needs traceability' ) )
          TO reported-Exception.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
