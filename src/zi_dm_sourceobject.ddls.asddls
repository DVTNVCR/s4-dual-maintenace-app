@EndUserText.label: 'Source Object'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZI_DM_SourceObject
  as select from zdm_r_sobj
  association to parent ZI_DM_SourceTransport as _SourceTransport
    on $projection.TransportUUID = _SourceTransport.TransportUUID
  association [1..1] to ZI_DM_Reconciliation as _Reconciliation
    on $projection.RequestUUID = _Reconciliation.RequestUUID
  composition [0..*] of ZI_DM_Mapping as _Mappings
{
  key source_obj_uuid as SourceObjectUUID,
      transport_uuid  as TransportUUID,
      _SourceTransport.RequestUUID as RequestUUID,
      pgmid           as PGMID,
      object_type     as ObjectType,
      object_name     as ObjectName,
      tabkey          as TabKey,
      norm_tabkey     as NormalizedTabKey,
      identity_hash   as IdentityHash,
      delta_detected  as DeltaDetected,
      delta_description as DeltaDescription,
      created_by      as CreatedBy,
      created_at      as CreatedAt,
      last_changed_by as LastChangedBy,
      last_changed_at as LastChangedAt,
      local_last_changed as LocalLastChangedAt,
      _SourceTransport,
      _Reconciliation,
      _Mappings
}
