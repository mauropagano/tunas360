DEF section_id = '5f';
DEF section_name = 'Top Segments by';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&tunas360_prefix.','&&section_id.');
SPO &&tunas360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF title = 'Logical reads';
DEF main_table = 'GV$SEGSTAT';
BEGIN
  :sql_text := '
  WITH top_segments AS (SELECT obj#, ROWNUM fake_rank
                          FROM (SELECT segstat_stop.obj#, SUM(NVL(segstat_stop.value,0)-NVL(segstat_start.value,0)) diff -- no inst_id, doing sum across nodes
                                  FROM (SELECT position inst_id, io_cost obj#, partition_id value
                                          FROM plan_table
                                         WHERE statement_id = ''TUNAS360_SEGSTAT_START''
                                           AND object_node = ''logical reads'') segstat_start,
                                       (SELECT position inst_id, io_cost obj#, partition_id value
                                          FROM plan_table
                                         WHERE statement_id = ''TUNAS360_SEGSTAT_STOP''
                                           AND object_node = ''logical reads'') segstat_stop
                                 WHERE segstat_stop.obj# = segstat_start.obj# -- inner join, assuming the info have not been flushed
                                   AND segstat_stop.inst_id = segstat_start.inst_id
                                 GROUP BY segstat_stop.obj#
                                 ORDER BY diff DESC)
                         WHERE ROWNUM <= &&tunas360_num_top_segments.)
SELECT inst_id, ts#, obj#, dataobj#, 
       (SELECT object_type||'' ''||owner||''.''||object_name||''.''||subobject_name FROM dba_objects a WHERE a.object_id = obj# AND NVL(a.data_object_id,0) = NVL(dataobj#,0)) object_name,
       MAX(logical_reads) logical_reads,
       MAX(buffer_busy_waits) buffer_busy_waits,
       MAX(gc_buffer_busy) gc_buffer_busy,
       MAX(db_block_changes) db_block_changes,
       MAX(physical_reads) physical_reads,
       MAX(physical_writes) physical_writes,
       MAX(physical_read_requests) physical_read_requests,
       MAX(physical_write_requests) physical_write_requests,
       MAX(physical_reads_direct) physical_reads_direct,
       MAX(physical_writes_direct) physical_writes_direct,
       MAX(optimized_physical_reads) optimized_physical_reads,
       MAX(optimized_physical_writes) optimized_physical_writes,
       MAX(gc_cr_blocks_received) gc_cr_blocks_received,
       MAX(gc_current_blocks_received) gc_current_blocks_received,
       MAX(ITL_waits) ITL_waits,
       MAX(row_lock_waits) row_lock_waits,
       MAX(IM_non_local_db_block_changes) IM_non_local_db_block_changes,
       MAX(space_used) space_used,
       MAX(space_allocated) space_allocated,
       MAX(segment_scans) segment_scans,
       MAX(IM_scans) IM_scans,
       MAX(IM_populate_CUs) IM_populate_CUs,
       MAX(IM_prepopulate_CUs) IM_prepopulate_CUs,
       MAX(IM_repopulate_CUs) IM_repopulate_CUs,
       MAX(IM_repopulate_trickle_CUs) IM_repopulate_trickle_CUs         
  FROM (SELECT segstat_stop.inst_id, segstat_stop.ts#, segstat_stop.obj#, segstat_stop.dataobj#, top_segments.fake_rank,
               CASE WHEN segstat_stop.statistic_name = ''logical reads'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END logical_reads,
               CASE WHEN segstat_stop.statistic_name = ''buffer busy waits'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END buffer_busy_waits,
               CASE WHEN segstat_stop.statistic_name = ''gc buffer busy'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END gc_buffer_busy,
               CASE WHEN segstat_stop.statistic_name = ''db block changes'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END db_block_changes,
               CASE WHEN segstat_stop.statistic_name = ''physical reads'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_reads,
               CASE WHEN segstat_stop.statistic_name = ''physical writes'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_writes,
               CASE WHEN segstat_stop.statistic_name = ''physical read requests'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_read_requests,
               CASE WHEN segstat_stop.statistic_name = ''physical write requests'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_write_requests,
               CASE WHEN segstat_stop.statistic_name = ''physical reads direct'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_reads_direct,
               CASE WHEN segstat_stop.statistic_name = ''physical writes direct'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_writes_direct,
               CASE WHEN segstat_stop.statistic_name = ''optimized physical reads'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END optimized_physical_reads,
               CASE WHEN segstat_stop.statistic_name = ''loptimized physical writes'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END optimized_physical_writes,
               CASE WHEN segstat_stop.statistic_name = ''gc cr blocks received'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END gc_cr_blocks_received,
               CASE WHEN segstat_stop.statistic_name = ''gc current blocks received'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END gc_current_blocks_received,
               CASE WHEN segstat_stop.statistic_name = ''ITL waits'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END ITL_waits,
               CASE WHEN segstat_stop.statistic_name = ''row lock waits'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END row_lock_waits,
               CASE WHEN segstat_stop.statistic_name = ''IM non local db block changes'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_non_local_db_block_changes,
               CASE WHEN segstat_stop.statistic_name = ''space used'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END space_used,
               CASE WHEN segstat_stop.statistic_name = ''space allocated'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END space_allocated,
               CASE WHEN segstat_stop.statistic_name = ''segment scans'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END segment_scans,
               CASE WHEN segstat_stop.statistic_name = ''IM scans'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_scans,
               CASE WHEN segstat_stop.statistic_name = ''IM populate CUs'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_populate_CUs,
               CASE WHEN segstat_stop.statistic_name = ''IM prepopulate CUs'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_prepopulate_CUs,
               CASE WHEN segstat_stop.statistic_name = ''IM repopulate CUs'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_repopulate_CUs,
               CASE WHEN segstat_stop.statistic_name = ''IM repopulate (trickle) CUs'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_repopulate_trickle_CUs       
          FROM (SELECT position inst_id, cpu_cost ts#, io_cost obj#, parent_id dataobj#, object_node statistic_name, partition_id value
                  FROM plan_table
                 WHERE statement_id = ''TUNAS360_SEGSTAT_START'') segstat_start,
               (SELECT position inst_id, cpu_cost ts#, io_cost obj#, parent_id dataobj#, object_node statistic_name, partition_id value
                  FROM plan_table
                 WHERE statement_id = ''TUNAS360_SEGSTAT_STOP'') segstat_stop,
               top_segments 
         WHERE segstat_stop.obj# = segstat_start.obj# -- inner join, assuming the info have not been flushed
           AND segstat_stop.inst_id = segstat_start.inst_id
           AND segstat_stop.statistic_name = segstat_start.statistic_name
           AND segstat_stop.obj# = top_segments.obj#)
GROUP BY inst_id, ts#, obj#, dataobj#, fake_rank 
ORDER BY inst_id, fake_rank, logical_reads DESC
';
END;
/
@sql/tunas360_9a_pre_one.sql


DEF title = 'Physical reads';
DEF main_table = 'GV$SEGSTAT';
BEGIN
  :sql_text := '
  WITH top_segments AS (SELECT obj#, ROWNUM fake_rank
                          FROM (SELECT segstat_stop.obj#, SUM(NVL(segstat_stop.value,0)-NVL(segstat_start.value,0)) diff -- no inst_id, doing sum across nodes
                                  FROM (SELECT position inst_id, io_cost obj#, partition_id value
                                          FROM plan_table
                                         WHERE statement_id = ''TUNAS360_SEGSTAT_START''
                                           AND object_node = ''physical reads'') segstat_start,
                                       (SELECT position inst_id, io_cost obj#, partition_id value
                                          FROM plan_table
                                         WHERE statement_id = ''TUNAS360_SEGSTAT_STOP''
                                           AND object_node = ''physical reads'') segstat_stop
                                 WHERE segstat_stop.obj# = segstat_start.obj# -- inner join, assuming the info have not been flushed
                                   AND segstat_stop.inst_id = segstat_start.inst_id
                                 GROUP BY segstat_stop.obj#
                                 ORDER BY diff DESC)
                         WHERE ROWNUM <= &&tunas360_num_top_segments.)
SELECT inst_id, ts#, obj#, dataobj#, 
       (SELECT object_type||'' ''||owner||''.''||object_name||''.''||subobject_name FROM dba_objects a WHERE a.object_id = obj# AND NVL(a.data_object_id,0) = NVL(dataobj#,0)) object_name,
       MAX(logical_reads) logical_reads,
       MAX(buffer_busy_waits) buffer_busy_waits,
       MAX(gc_buffer_busy) gc_buffer_busy,
       MAX(db_block_changes) db_block_changes,
       MAX(physical_reads) physical_reads,
       MAX(physical_writes) physical_writes,
       MAX(physical_read_requests) physical_read_requests,
       MAX(physical_write_requests) physical_write_requests,
       MAX(physical_reads_direct) physical_reads_direct,
       MAX(physical_writes_direct) physical_writes_direct,
       MAX(optimized_physical_reads) optimized_physical_reads,
       MAX(optimized_physical_writes) optimized_physical_writes,
       MAX(gc_cr_blocks_received) gc_cr_blocks_received,
       MAX(gc_current_blocks_received) gc_current_blocks_received,
       MAX(ITL_waits) ITL_waits,
       MAX(row_lock_waits) row_lock_waits,
       MAX(IM_non_local_db_block_changes) IM_non_local_db_block_changes,
       MAX(space_used) space_used,
       MAX(space_allocated) space_allocated,
       MAX(segment_scans) segment_scans,
       MAX(IM_scans) IM_scans,
       MAX(IM_populate_CUs) IM_populate_CUs,
       MAX(IM_prepopulate_CUs) IM_prepopulate_CUs,
       MAX(IM_repopulate_CUs) IM_repopulate_CUs,
       MAX(IM_repopulate_trickle_CUs) IM_repopulate_trickle_CUs         
  FROM (SELECT segstat_stop.inst_id, segstat_stop.ts#, segstat_stop.obj#, segstat_stop.dataobj#, top_segments.fake_rank,
               CASE WHEN segstat_stop.statistic_name = ''logical reads'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END logical_reads,
               CASE WHEN segstat_stop.statistic_name = ''buffer busy waits'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END buffer_busy_waits,
               CASE WHEN segstat_stop.statistic_name = ''gc buffer busy'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END gc_buffer_busy,
               CASE WHEN segstat_stop.statistic_name = ''db block changes'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END db_block_changes,
               CASE WHEN segstat_stop.statistic_name = ''physical reads'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_reads,
               CASE WHEN segstat_stop.statistic_name = ''physical writes'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_writes,
               CASE WHEN segstat_stop.statistic_name = ''physical read requests'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_read_requests,
               CASE WHEN segstat_stop.statistic_name = ''physical write requests'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_write_requests,
               CASE WHEN segstat_stop.statistic_name = ''physical reads direct'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_reads_direct,
               CASE WHEN segstat_stop.statistic_name = ''physical writes direct'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_writes_direct,
               CASE WHEN segstat_stop.statistic_name = ''optimized physical reads'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END optimized_physical_reads,
               CASE WHEN segstat_stop.statistic_name = ''loptimized physical writes'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END optimized_physical_writes,
               CASE WHEN segstat_stop.statistic_name = ''gc cr blocks received'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END gc_cr_blocks_received,
               CASE WHEN segstat_stop.statistic_name = ''gc current blocks received'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END gc_current_blocks_received,
               CASE WHEN segstat_stop.statistic_name = ''ITL waits'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END ITL_waits,
               CASE WHEN segstat_stop.statistic_name = ''row lock waits'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END row_lock_waits,
               CASE WHEN segstat_stop.statistic_name = ''IM non local db block changes'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_non_local_db_block_changes,
               CASE WHEN segstat_stop.statistic_name = ''space used'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END space_used,
               CASE WHEN segstat_stop.statistic_name = ''space allocated'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END space_allocated,
               CASE WHEN segstat_stop.statistic_name = ''segment scans'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END segment_scans,
               CASE WHEN segstat_stop.statistic_name = ''IM scans'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_scans,
               CASE WHEN segstat_stop.statistic_name = ''IM populate CUs'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_populate_CUs,
               CASE WHEN segstat_stop.statistic_name = ''IM prepopulate CUs'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_prepopulate_CUs,
               CASE WHEN segstat_stop.statistic_name = ''IM repopulate CUs'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_repopulate_CUs,
               CASE WHEN segstat_stop.statistic_name = ''IM repopulate (trickle) CUs'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_repopulate_trickle_CUs       
          FROM (SELECT position inst_id, cpu_cost ts#, io_cost obj#, parent_id dataobj#, object_node statistic_name, partition_id value
                  FROM plan_table
                 WHERE statement_id = ''TUNAS360_SEGSTAT_START'') segstat_start,
               (SELECT position inst_id, cpu_cost ts#, io_cost obj#, parent_id dataobj#, object_node statistic_name, partition_id value
                  FROM plan_table
                 WHERE statement_id = ''TUNAS360_SEGSTAT_STOP'') segstat_stop,
               top_segments 
         WHERE segstat_stop.obj# = segstat_start.obj# -- inner join, assuming the info have not been flushed
           AND segstat_stop.inst_id = segstat_start.inst_id
           AND segstat_stop.statistic_name = segstat_start.statistic_name
           AND segstat_stop.obj# = top_segments.obj#)
GROUP BY inst_id, ts#, obj#, dataobj#, fake_rank 
ORDER BY inst_id, fake_rank, physical_reads DESC
';
END;
/
@sql/tunas360_9a_pre_one.sql


DEF title = 'DB block changes';
DEF main_table = 'GV$SEGSTAT';
BEGIN
  :sql_text := '
  WITH top_segments AS (SELECT obj#, ROWNUM fake_rank
                          FROM (SELECT segstat_stop.obj#, SUM(NVL(segstat_stop.value,0)-NVL(segstat_start.value,0)) diff -- no inst_id, doing sum across nodes
                                  FROM (SELECT position inst_id, io_cost obj#, partition_id value
                                          FROM plan_table
                                         WHERE statement_id = ''TUNAS360_SEGSTAT_START''
                                           AND object_node = ''db block changes'') segstat_start,
                                       (SELECT position inst_id, io_cost obj#, partition_id value
                                          FROM plan_table
                                         WHERE statement_id = ''TUNAS360_SEGSTAT_STOP''
                                           AND object_node = ''db block changes'') segstat_stop
                                 WHERE segstat_stop.obj# = segstat_start.obj# -- inner join, assuming the info have not been flushed
                                   AND segstat_stop.inst_id = segstat_start.inst_id
                                 GROUP BY segstat_stop.obj#
                                 ORDER BY diff DESC)
                         WHERE ROWNUM <= &&tunas360_num_top_segments.)
SELECT inst_id, ts#, obj#, dataobj#, 
       (SELECT object_type||'' ''||owner||''.''||object_name||''.''||subobject_name FROM dba_objects a WHERE a.object_id = obj# AND NVL(a.data_object_id,0) = NVL(dataobj#,0)) object_name,
       MAX(logical_reads) logical_reads,
       MAX(buffer_busy_waits) buffer_busy_waits,
       MAX(gc_buffer_busy) gc_buffer_busy,
       MAX(db_block_changes) db_block_changes,
       MAX(physical_reads) physical_reads,
       MAX(physical_writes) physical_writes,
       MAX(physical_read_requests) physical_read_requests,
       MAX(physical_write_requests) physical_write_requests,
       MAX(physical_reads_direct) physical_reads_direct,
       MAX(physical_writes_direct) physical_writes_direct,
       MAX(optimized_physical_reads) optimized_physical_reads,
       MAX(optimized_physical_writes) optimized_physical_writes,
       MAX(gc_cr_blocks_received) gc_cr_blocks_received,
       MAX(gc_current_blocks_received) gc_current_blocks_received,
       MAX(ITL_waits) ITL_waits,
       MAX(row_lock_waits) row_lock_waits,
       MAX(IM_non_local_db_block_changes) IM_non_local_db_block_changes,
       MAX(space_used) space_used,
       MAX(space_allocated) space_allocated,
       MAX(segment_scans) segment_scans,
       MAX(IM_scans) IM_scans,
       MAX(IM_populate_CUs) IM_populate_CUs,
       MAX(IM_prepopulate_CUs) IM_prepopulate_CUs,
       MAX(IM_repopulate_CUs) IM_repopulate_CUs,
       MAX(IM_repopulate_trickle_CUs) IM_repopulate_trickle_CUs         
  FROM (SELECT segstat_stop.inst_id, segstat_stop.ts#, segstat_stop.obj#, segstat_stop.dataobj#, top_segments.fake_rank,
               CASE WHEN segstat_stop.statistic_name = ''logical reads'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END logical_reads,
               CASE WHEN segstat_stop.statistic_name = ''buffer busy waits'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END buffer_busy_waits,
               CASE WHEN segstat_stop.statistic_name = ''gc buffer busy'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END gc_buffer_busy,
               CASE WHEN segstat_stop.statistic_name = ''db block changes'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END db_block_changes,
               CASE WHEN segstat_stop.statistic_name = ''physical reads'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_reads,
               CASE WHEN segstat_stop.statistic_name = ''physical writes'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_writes,
               CASE WHEN segstat_stop.statistic_name = ''physical read requests'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_read_requests,
               CASE WHEN segstat_stop.statistic_name = ''physical write requests'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_write_requests,
               CASE WHEN segstat_stop.statistic_name = ''physical reads direct'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_reads_direct,
               CASE WHEN segstat_stop.statistic_name = ''physical writes direct'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END physical_writes_direct,
               CASE WHEN segstat_stop.statistic_name = ''optimized physical reads'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END optimized_physical_reads,
               CASE WHEN segstat_stop.statistic_name = ''loptimized physical writes'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END optimized_physical_writes,
               CASE WHEN segstat_stop.statistic_name = ''gc cr blocks received'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END gc_cr_blocks_received,
               CASE WHEN segstat_stop.statistic_name = ''gc current blocks received'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END gc_current_blocks_received,
               CASE WHEN segstat_stop.statistic_name = ''ITL waits'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END ITL_waits,
               CASE WHEN segstat_stop.statistic_name = ''row lock waits'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END row_lock_waits,
               CASE WHEN segstat_stop.statistic_name = ''IM non local db block changes'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_non_local_db_block_changes,
               CASE WHEN segstat_stop.statistic_name = ''space used'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END space_used,
               CASE WHEN segstat_stop.statistic_name = ''space allocated'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END space_allocated,
               CASE WHEN segstat_stop.statistic_name = ''segment scans'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END segment_scans,
               CASE WHEN segstat_stop.statistic_name = ''IM scans'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_scans,
               CASE WHEN segstat_stop.statistic_name = ''IM populate CUs'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_populate_CUs,
               CASE WHEN segstat_stop.statistic_name = ''IM prepopulate CUs'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_prepopulate_CUs,
               CASE WHEN segstat_stop.statistic_name = ''IM repopulate CUs'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_repopulate_CUs,
               CASE WHEN segstat_stop.statistic_name = ''IM repopulate (trickle) CUs'' THEN NVL(segstat_stop.value,0)-NVL(segstat_start.value,0) ELSE NULL END IM_repopulate_trickle_CUs       
          FROM (SELECT position inst_id, cpu_cost ts#, io_cost obj#, parent_id dataobj#, object_node statistic_name, partition_id value
                  FROM plan_table
                 WHERE statement_id = ''TUNAS360_SEGSTAT_START'') segstat_start,
               (SELECT position inst_id, cpu_cost ts#, io_cost obj#, parent_id dataobj#, object_node statistic_name, partition_id value
                  FROM plan_table
                 WHERE statement_id = ''TUNAS360_SEGSTAT_STOP'') segstat_stop,
               top_segments 
         WHERE segstat_stop.obj# = segstat_start.obj# -- inner join, assuming the info have not been flushed
           AND segstat_stop.inst_id = segstat_start.inst_id
           AND segstat_stop.statistic_name = segstat_start.statistic_name
           AND segstat_stop.obj# = top_segments.obj#)
GROUP BY inst_id, ts#, obj#, dataobj#, fake_rank 
ORDER BY inst_id, fake_rank, db_block_changes DESC
';
END;
/
@sql/tunas360_9a_pre_one.sql


SPO &&tunas360_main_report..html APP;
PRO </ol>
SPO OFF;