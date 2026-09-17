@EndUserText.label: 'Reconciliation Source Object'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_DM_SourceObject
  as projection on ZI_DM_SourceObject
{
  key SourceObjectUUID,
      TransportUUID,
      RequestUUID,
      PGMID,
      ObjectType,
      ObjectName,
      TabKey,
      NormalizedTabKey,
      DeltaDetected,
      DeltaDescription,
      LocalLastChangedAt,
      _Reconciliation  : redirected to ZC_DM_Reconciliation,
      _SourceTransport : redirected to parent ZC_DM_SourceTransport,
      _Mappings        : redirected to composition child ZC_DM_Mapping
}
