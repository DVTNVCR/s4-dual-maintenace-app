@EndUserText.label: 'Reconciliation Source Transport'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_DM_SourceTransport
  as projection on ZI_DM_SourceTransport
{
  key TransportUUID,
      RequestUUID,
      TransportID,
      SourceSystem,
      IsConfirmed,
      ProductionImported,
      ImportDate,
      ImportEvidence,
      DeploymentState,
      LocalLastChangedAt,
      _Reconciliation : redirected to parent ZC_DM_Reconciliation,
      _SourceObjects  : redirected to composition child ZC_DM_SourceObject
}
