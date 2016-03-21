DEF section_id = '5b';
DEF section_name = 'Top Lock(s)';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&tunas360_prefix.','&&section_id.');
SPO &&tunas360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF title = 'Top Blocker(s)';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
SELECT blocking_inst_id, blocking_session, blocking_session_status, num_sessions_blocked,
       TRUNC(100*RATIO_TO_REPORT(num_sessions_blocked) OVER (),2) percent_impact
  FROM (SELECT COUNT(DISTINCT inst_id||'',''||sid||'',''||serial#) num_sessions_blocked, blocking_inst_id, blocking_session, blocking_session_status
          FROM (SELECT position inst_id, cpu_cost sid, io_cost serial#,
                       SUBSTR(partition_stop,1,INSTR(partition_stop,'','',1,1)-1) blocking_session_status,
                       SUBSTR(partition_stop,INSTR(partition_stop,'','',1,1)+1,INSTR(partition_stop,'','',1,2)-INSTR(partition_stop,'','',1,1)-1) blocking_inst_id,
                       SUBSTR(partition_stop,INSTR(partition_stop,'','',1,2)+1,INSTR(partition_stop,'','',1,3)-INSTR(partition_stop,'','',1,2)-1) blocking_session
                  FROM plan_table
                 WHERE statement_id = ''TUNAS360_DATA''
                   AND SUBSTR(partition_stop,INSTR(partition_stop,'','',1,2)+1,INSTR(partition_stop,'','',1,3)-INSTR(partition_stop,'','',1,2)-1) IS NOT NULL)
         GROUP BY blocking_session_status, blocking_inst_id, blocking_session)
 ORDER BY num_sessions_blocked DESC NULLS LAST
';
END;
/
@sql/tunas360_9a_pre_one.sql


DEF title = 'Top Blocked';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
SELECT inst_id, sid, serial#, num_samples,
       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent_impact
  FROM (SELECT COUNT(*) num_samples, inst_id, sid, serial#
          FROM (SELECT position inst_id, cpu_cost sid, io_cost serial#, timestamp sample_time, parent_id sample_id
                  FROM plan_table
                 WHERE statement_id = ''TUNAS360_DATA''
                   AND SUBSTR(partition_stop,INSTR(partition_stop,'','',1,2)+1,INSTR(partition_stop,'','',1,3)-INSTR(partition_stop,'','',1,2)-1) IS NOT NULL)
         GROUP BY inst_id, sid, serial#)
 ORDER BY num_samples DESC NULLS LAST
';
END;
/
@sql/tunas360_9a_pre_one.sql


DEF title = 'All Blocked';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
SELECT parent_id sample_id, timestamp sample_time, position inst_id, cpu_cost sid, io_cost serial#, object_node event, 
       SUBSTR(partition_start,1,INSTR(partition_start,'','',1,1)-1) seq#, 
       SUBSTR(partition_stop,INSTR(partition_stop,'','',1,1)+1,INSTR(partition_stop,'','',1,2)-INSTR(partition_stop,'','',1,1)-1) blocking_inst_id,
       SUBSTR(partition_stop,INSTR(partition_stop,'','',1,2)+1,INSTR(partition_stop,'','',1,3)-INSTR(partition_stop,'','',1,2)-1) blocking_session,
       SUBSTR(partition_stop,1,INSTR(partition_stop,'','',1,1)-1) blocking_session_status
  FROM plan_table
 WHERE statement_id = ''TUNAS360_DATA''
   AND SUBSTR(partition_stop,INSTR(partition_stop,'','',1,2)+1,INSTR(partition_stop,'','',1,3)-INSTR(partition_stop,'','',1,2)-1) IS NOT NULL
 ORDER BY sample_id, inst_id, sid
';
END;
/
@sql/tunas360_9a_pre_one.sql


SPO &&tunas360_main_report..html APP;
PRO </ol>
SPO OFF;