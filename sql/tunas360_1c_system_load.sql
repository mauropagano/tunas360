DEF section_id = '1c';
DEF section_name = 'Database Load';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&tunas360_prefix.','&&section_id.');
SPO &&tunas360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


-- need to remove the noise from the sampler
DEF title = 'System Statistics';
DEF main_table = 'GV$SYSSTAT';
DEF foot = 'Samples collected between &&min_sample_time. and &&min_sample_time. (format mask YYYYMMDDHH24MISS).'
BEGIN
  :sql_text := '
SELECT sstats_stop.inst_id, sstats_stop.statname name, NVL(sstats_start.statvalue,0) begin_value, sstats_stop.statvalue end_value, sstats_stop.statvalue - NVL(sstats_start.statvalue,0) diff, 
       TRUNC((sstats_stop.statvalue - NVL(sstats_start.statvalue,0))/((TO_DATE(''&&max_sample_time.'',''YYYYMMDDHH24MISS'') - TO_DATE(''&&min_sample_time.'',''YYYYMMDDHH24MISS''))*66400),3) diff_per_sec 
  FROM (SELECT position inst_id, object_node statname, partition_id-NVL(tunas_session.statvalue,0) statvalue
          FROM plan_table whole_sys, 
               (SELECT /* this is to remove the noise introduced by TUNAs360 itself */ position inst_id, object_node statname, partition_id statvalue
                  FROM plan_table
                 WHERE statement_id = ''TUNAS360_SESSTAT_START''
                   AND position = &&connect_instance_number.
                   AND cpu_cost = &&tunas360_sid.) tunas_session
         WHERE statement_id = ''TUNAS360_SYSSTAT_START''
           AND tunas_session.inst_id(+) = whole_sys.position
           AND tunas_session.statname(+) = whole_sys.object_node) sstats_start, 
        (SELECT position inst_id, object_node statname, partition_id-NVL(tunas_session.statvalue,0) statvalue
          FROM plan_table whole_sys, 
               (SELECT /* this is to remove the noise introduced by TUNAs360 itself */ position inst_id, object_node statname, partition_id statvalue
                  FROM plan_table
                 WHERE statement_id = ''TUNAS360_SESSTAT_STOP''
                   AND position = &&connect_instance_number.
                   AND cpu_cost = &&tunas360_sid.) tunas_session
         WHERE statement_id = ''TUNAS360_SYSSTAT_STOP''
           AND tunas_session.inst_id(+) = whole_sys.position
           AND tunas_session.statname(+) = whole_sys.object_node 
           AND partition_id > 0) sstats_stop 
 WHERE sstats_start.statname(+) = sstats_stop.statname
   AND sstats_start.inst_id(+) = sstats_stop.inst_id
 ORDER BY 1,2
';
END;
/
@@tunas360_9a_pre_one.sql

SPO &&tunas360_main_report..html APP;
PRO </ol>
SPO OFF;