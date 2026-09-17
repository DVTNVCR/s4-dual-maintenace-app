@EndUserText.label: 'Source Transport'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZI_DM_SourceTransport
  as select from zdm_r_strn
  association to parent ZI_DM_Reconciliation as _Reconciliation
    on $projection.RequestUUID = _Reconciliation.RequestUUID
  composition [0..*] of ZI_DM_SourceObject as _SourceObjects
{
  key transport_uuid   as TransportUUID,
      request_uuid     as RequestUUID,
      transport_id     as TransportID,
      source_system    as SourceSystem,
      is_confirmed     as IsConfirmed,
      prod_imported    as ProductionImported,
      import_date      as ImportDate,
      import_evidence  as ImportEvidence,
      deployment_state as DeploymentState,
      created_by       as CreatedBy,
      created_at       as CreatedAt,
      last_changed_by  as LastChangedBy,
      last_changed_at  as LastChangedAt,
      local_last_changed as LocalLastChangedAt,
      _Reconciliation,
      _SourceObjects
}
