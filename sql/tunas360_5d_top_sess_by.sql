DEF section_id = '5d';
DEF section_name = 'Top &&tunas360_num_top_sess. Session by';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&tunas360_prefix.','&&section_id.');
SPO &&tunas360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF title = 'Amount of redo generated';
DEF main_table = 'GV$SESSTAT';
BEGIN
  :sql_text := '
  SELECT * 
    FROM (SELECT sstats_stop.inst_id, sstats_stop.sid, sstats_stop.serial#, sstats_stop.statname name, sstats_stop.statvalue - NVL(sstats_start.statvalue,0) diff
            FROM (SELECT position inst_id, cpu_cost sid, io_cost serial#, object_node statname, partition_id statvalue
                    FROM plan_table
                   WHERE statement_id = ''TUNAS360_SESSTAT_START''
                     AND object_node = ''redo size'') sstats_start, 
                 (SELECT position inst_id, cpu_cost sid, io_cost serial#, object_node statname, partition_id statvalue
                    FROM plan_table
                   WHERE statement_id = ''TUNAS360_SESSTAT_STOP''  
                     AND object_node = ''redo size''
                     AND partition_id > 0) sstats_stop 
           WHERE sstats_start.statname(+) = sstats_stop.statname
             AND sstats_start.inst_id(+) = sstats_stop.inst_id
             AND sstats_start.sid(+) = sstats_stop.sid
             AND sstats_start.serial#(+) = sstats_stop.serial#
           ORDER BY diff DESC)
 WHERE ROWNUM <= &&tunas360_num_top_sess.
';
END;
/
@sql/tunas360_9a_pre_one.sql


DEF title = 'Amount of undo generated';
DEF main_table = 'GV$SESSTAT';
BEGIN
  :sql_text := '
  SELECT * 
    FROM (SELECT sstats_stop.inst_id, sstats_stop.sid, sstats_stop.serial#, sstats_stop.statname name, sstats_stop.statvalue - NVL(sstats_start.statvalue,0) diff
            FROM (SELECT position inst_id, cpu_cost sid, io_cost serial#, object_node statname, partition_id statvalue
                    FROM plan_table
                   WHERE statement_id = ''TUNAS360_SESSTAT_START''
                     AND object_node = ''undo change vector size'') sstats_start, 
                 (SELECT position inst_id, cpu_cost sid, io_cost serial#, object_node statname, partition_id statvalue
                    FROM plan_table
                   WHERE statement_id = ''TUNAS360_SESSTAT_STOP''  
                     AND object_node = ''undo change vector size''
                     AND partition_id > 0) sstats_stop 
           WHERE sstats_start.statname(+) = sstats_stop.statname
             AND sstats_start.inst_id(+) = sstats_stop.inst_id
             AND sstats_start.sid(+) = sstats_stop.sid
             AND sstats_start.serial#(+) = sstats_stop.serial#
           ORDER BY diff DESC)
 WHERE ROWNUM <= &&tunas360_num_top_sess.
';
END;
/
@sql/tunas360_9a_pre_one.sql


DEF title = 'Number of sessions used (logon/logoff)';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
  SELECT *
    FROM (SELECT username, module, program, COUNT(DISTINCT sid) num_distinct_sid, SUM(dist_serial_per_sid) num_dist_sessions
            FROM (SELECT object_type username, object_name module, object_owner program, cpu_cost sid, COUNT(DISTINCT io_cost) dist_serial_per_sid
                    FROM plan_table
                   GROUP BY object_type, object_name, object_owner, cpu_cost)
           GROUP BY username, module, program
           ORDER BY num_dist_sessions DESC)
   WHERE ROWNUM <= &&tunas360_num_top_sess.
';
END;
/
@sql/tunas360_9a_pre_one.sql


SPO &&tunas360_main_report..html APP;
PRO </ol>
SPO OFF;