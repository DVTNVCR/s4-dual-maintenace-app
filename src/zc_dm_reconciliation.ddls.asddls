@EndUserText.label: 'Reconciliation Worklist'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define root view entity ZC_DM_Reconciliation
  as projection on ZI_DM_Reconciliation
{
  key RequestUUID,
      JiraKey,
      DeploymentRequest,
      CabApproved,
      CabDate,
      DeploymentState,
      BusinessOwner,
      TechnicalOwner,
      RiskLevel,
      OverallStatus,
      case OverallStatus
        when 'RECONCILED' then 3
        when 'IN_REVIEW' then 2
        when 'SCOPE_CONFIRMED' then 2
        else 1
      end as OverallStatusCriticality,
      CreatedBy,
      CreatedAt,
      LastChangedBy,
      LastChangedAt,
      LocalLastChangedAt,
      _SourceTransports : redirected to composition child ZC_DM_SourceTransport,
      _Exceptions       : redirected to composition child ZC_DM_Exception
}
