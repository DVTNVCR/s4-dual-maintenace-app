@EndUserText.label: 'Target Object'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZI_DM_TargetObject
  as select from zdm_r_tobj
{
  key target_obj_uuid as TargetObjectUUID,
      target_transport as TargetTransport,
      target_system    as TargetSystem,
      pgmid            as PGMID,
      object_type      as ObjectType,
      object_name      as ObjectName,
      tabkey           as TabKey,
      norm_tabkey      as NormalizedTabKey,
      identity_hash    as IdentityHash,
      technical_state  as TechnicalState,
      evidence_uri     as EvidenceURI,
      created_by       as CreatedBy,
      created_at       as CreatedAt,
      last_changed_by  as LastChangedBy,
      last_changed_at  as LastChangedAt,
      local_last_changed as LocalLastChangedAt
}
