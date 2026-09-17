@EndUserText.label: 'Reconciliation Exception Report'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true
define view entity ZC_DM_ExceptionReport
  as select from zdm_r_map as map
    inner join zdm_r_sobj as src
      on src.source_obj_uuid = map.source_obj_uuid
    inner join zdm_r_strn as trn
      on trn.transport_uuid = src.transport_uuid
    inner join zdm_r_hdr as hdr
      on hdr.request_uuid = trn.request_uuid
{
  key map.mapping_uuid   as MappingUUID,
      hdr.request_uuid   as RequestUUID,
      hdr.jira_key       as JiraKey,
      hdr.business_owner as BusinessOwner,
      trn.transport_id   as SourceTransport,
      src.pgmid          as PGMID,
      src.object_type    as ObjectType,
      src.object_name    as ObjectName,
      src.norm_tabkey    as NormalizedTabKey,
      src.delta_detected as DeltaDetected,
      map.match_status   as MatchStatus,
      map.disposition    as Disposition,
      map.evidence_complete as EvidenceComplete,
      case
        when map.match_status = 'EXACT_MATCH' then 3
        when map.match_status = 'APPROVED_EXCEPTION' then 2
        else 1
      end as Criticality
}
where map.match_status <> 'EXACT_MATCH'
   or src.delta_detected = 'X'
