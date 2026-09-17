@EndUserText.label: 'Dual Maintenance Reconciliation'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define root view entity ZI_DM_Reconciliation
  as select from zdm_r_hdr
  composition [0..*] of ZI_DM_SourceTransport as _SourceTransports
  composition [0..*] of ZI_DM_Exception       as _Exceptions
{
  key request_uuid       as RequestUUID,
      jira_key           as JiraKey,
      deployment_request as DeploymentRequest,
      cab_approved       as CabApproved,
      cab_date           as CabDate,
      deployment_state   as DeploymentState,
      business_owner     as BusinessOwner,
      technical_owner    as TechnicalOwner,
      risk_level         as RiskLevel,
      overall_status     as OverallStatus,
      created_by         as CreatedBy,
      created_at         as CreatedAt,
      last_changed_by    as LastChangedBy,
      last_changed_at    as LastChangedAt,
      local_last_changed as LocalLastChangedAt,
      _SourceTransports,
      _Exceptions
}
