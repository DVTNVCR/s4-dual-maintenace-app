@EndUserText.label: 'Object Mapping'
@AccessControl.authorizationCheck: #NOT_REQUIRED
define view entity ZI_DM_Mapping
  as select from zdm_r_map
  association to parent ZI_DM_SourceObject as _SourceObject
    on $projection.SourceObjectUUID = _SourceObject.SourceObjectUUID
  association [1..1] to ZI_DM_Reconciliation as _Reconciliation
    on $projection.RequestUUID = _Reconciliation.RequestUUID
  association [0..1] to ZI_DM_TargetObject as _TargetObject
    on $projection.TargetObjectUUID = _TargetObject.TargetObjectUUID
{
  key mapping_uuid      as MappingUUID,
      source_obj_uuid   as SourceObjectUUID,
      _SourceObject.RequestUUID as RequestUUID,
      target_obj_uuid   as TargetObjectUUID,
      match_status      as MatchStatus,
      disposition       as Disposition,
      is_designated     as IsDesignated,
      evidence_complete as EvidenceComplete,
      evidence_uri      as EvidenceURI,
      reviewer          as Reviewer,
      reviewed_on       as ReviewedOn,
      completed_on      as CompletedOn,
      created_by        as CreatedBy,
      created_at        as CreatedAt,
      last_changed_by   as LastChangedBy,
      last_changed_at   as LastChangedAt,
      local_last_changed as LocalLastChangedAt,
      _SourceObject,
      _Reconciliation,
      _TargetObject
}
