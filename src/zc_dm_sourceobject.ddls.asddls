@EndUserText.label: 'Reconciliation Source Object'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_DM_SourceObject
  as projection on ZI_DM_SourceObject
{
  key SourceObjectUUID,
      TransportUUID,
      PGMID,
      ObjectType,
      ObjectName,
      TabKey,
      NormalizedTabKey,
      DeltaDetected,
      DeltaDescription,
      LocalLastChangedAt,
      _SourceTransport : redirected to parent ZC_DM_SourceTransport,
      _Mappings        : redirected to composition child ZC_DM_Mapping
}
