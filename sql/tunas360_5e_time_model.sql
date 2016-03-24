DEF section_id = '5e';
DEF section_name = 'Time Model';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&tunas360_prefix.','&&section_id.');
SPO &&tunas360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF title = 'Difference in Time Model statistics';
DEF main_table = 'GV$SYS_TIME_MODEL';
BEGIN
  :sql_text := '
   SELECT tm_stop.inst_id, tm_stop.statname name, NVL(tm_start.statvalue,0) start_value, tm_stop.statvalue stop_value, tm_stop.statvalue - NVL(tm_start.statvalue,0) diff
     FROM (SELECT position inst_id, object_node statname, partition_id statvalue
             FROM plan_table
            WHERE statement_id = ''TUNAS360_TIMEMODEL_START'') tm_start, 
          (SELECT position inst_id, object_node statname, partition_id statvalue
             FROM plan_table
            WHERE statement_id = ''TUNAS360_TIMEMODEL_STOP'') tm_stop 
    WHERE tm_start.statname(+) = tm_stop.statname
      AND tm_start.inst_id(+)  = tm_stop.inst_id
    ORDER BY name
';
END;
/
@sql/tunas360_9a_pre_one.sql


SPO &&tunas360_main_report..html APP;
PRO </ol>
SPO OFF;