@EndUserText.label: 'Reconciliation Exception'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_DM_Exception
  as projection on ZI_DM_Exception
{
  key ExceptionUUID,
      RequestUUID,
      SourceObjectUUID,
      ExceptionType,
      Impact,
      ExceptionOwner,
      DueDate,
      ApprovalState,
      ApprovedBy,
      ApprovedOn,
      ApprovalReference,
      LocalLastChangedAt,
      _Reconciliation : redirected to parent ZC_DM_Reconciliation
}
