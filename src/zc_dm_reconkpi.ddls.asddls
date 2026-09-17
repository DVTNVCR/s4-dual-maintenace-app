@EndUserText.label: 'Reconciliation KPI Snapshot'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Analytics.dataCategory: #CUBE
@Metadata.allowExtensions: true
define view entity ZC_DM_ReconKPI
  as select from zdm_r_run
{
  key run_uuid              as RunUUID,
      request_uuid          as RequestUUID,
      run_timestamp         as RunTimestamp,
      run_by                as RunBy,
      @DefaultAggregation: #SUM
      approval_population   as ApprovalPopulation,
      @DefaultAggregation: #SUM
      production_deployment as ProductionDeployment,
      @DefaultAggregation: #SUM
      scope_validity        as ScopeValidity,
      @DefaultAggregation: #SUM
      transport_complete    as TransportCompleteness,
      @DefaultAggregation: #SUM
      object_complete       as ObjectCompleteness,
      @DefaultAggregation: #SUM
      implementation_evid   as ImplementationEvidence,
      @DefaultAggregation: #SUM
      delta_detection       as DeltaDetection,
      @DefaultAggregation: #SUM
      exclusion_governance  as ExclusionGovernance,
      @DefaultAggregation: #SUM
      exact_count           as ExactCount,
      @DefaultAggregation: #SUM
      missing_count         as MissingCount,
      @DefaultAggregation: #SUM
      multiple_count        as MultipleCount,
      @DefaultAggregation: #SUM
      exception_count       as ExceptionCount,
      @DefaultAggregation: #SUM
      eligible_count        as EligibleCount
}
