@EndUserText.label: 'Reconciliation Mapping'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_DM_Mapping
  as projection on ZI_DM_Mapping
{
  key MappingUUID,
      SourceObjectUUID,
      TargetObjectUUID,
      MatchStatus,
      Disposition,
      IsDesignated,
      EvidenceComplete,
      EvidenceURI,
      Reviewer,
      ReviewedOn,
      CompletedOn,
      LocalLastChangedAt,
      _SourceObject : redirected to parent ZC_DM_SourceObject,
      _TargetObject
}
