@EndUserText.label: 'Approved Exception'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZI_DM_Exception
  as select from zdm_r_exc
  association to parent ZI_DM_Reconciliation as _Reconciliation
    on $projection.RequestUUID = _Reconciliation.RequestUUID
{
  key exception_uuid   as ExceptionUUID,
      request_uuid     as RequestUUID,
      source_obj_uuid  as SourceObjectUUID,
      exception_type   as ExceptionType,
      impact           as Impact,
      exception_owner  as ExceptionOwner,
      due_date         as DueDate,
      approval_state   as ApprovalState,
      approved_by      as ApprovedBy,
      approved_on      as ApprovedOn,
      approval_reference as ApprovalReference,
      created_by       as CreatedBy,
      created_at       as CreatedAt,
      last_changed_by  as LastChangedBy,
      last_changed_at  as LastChangedAt,
      local_last_changed as LocalLastChangedAt,
      _Reconciliation
}
