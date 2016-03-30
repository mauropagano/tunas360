DEF section_id = '4a';
DEF section_name = 'Top &&tunas360_num_top_sqls_plan. SQLs';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&tunas360_prefix.','&&section_id.');
SPO &&tunas360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;



SET SERVEROUT ON;
SPO 9997_&&common_tunas360_prefix._top_sqls_plan_driver.sql;
DECLARE

  sstats_start_stop NUMBER := 0;

  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;

BEGIN

  -- will need text output for DBMS_XPLAN
  put('SET DEF @');
  put('DEF skip_text_bck = ''@@tunas360_skip_text.'';');
  put('DEF tunas360_skip_text=''''');
  put('SET DEF &');
  put('COL executions FOR 999999999999999');

  FOR i IN (SELECT * 
              FROM (SELECT COUNT(*) num_samples, remarks sql_id
                      FROM plan_table  
                     WHERE statement_id = 'TUNAS360_DATA'
                       AND remarks IS NOT NULL
                     GROUP BY remarks
                     ORDER BY 1 DESC) 
             WHERE ROWNUM <= &&tunas360_num_top_sqls_plan.)
  LOOP
    
       put('SPO &&tunas360_main_report..html APP;');
       put('PRO <h4>SQL_ID: '||i.sql_id||' NumSamples:'||i.num_samples||'</h4>');
       put('SPO OFF');


       put('DEF title=''SQL Text for SQL_ID '||i.sql_id||'''');
       put('DEF main_table = ''GV$SQL''');
       put('DEF skip_html=''Y''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT sql_fulltext ');
       put('  FROM gv$sql' );
       put(' WHERE sql_id = '''''||i.sql_id||''''' ');
       put('  AND sql_fulltext IS NOT NULL');
       put('  AND ROWNUM = 1 ');
       put(''';');
       put('END;');
       put('/ ');
       put('COL inst_child NOPRI');
       put('@sql/tunas360_9a_pre_one.sql');   
       put('DEF skip_html='''''); 
       put('COL inst_child PRI');


       put('COL optimizer_env NOPRI');
       put('DEF title=''Cursor statistics for SQL_ID '||i.sql_id||'''');
       put('DEF main_table = ''GV$SQL''');
       put('DEF skip_text=''Y''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT * ');
       put('  FROM gv$sql ');
       put(' WHERE sql_id = '''''||i.sql_id||''''' ');
       put(' ORDER BY inst_id, child_number');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/tunas360_9a_pre_one.sql');   
       put('COL optimizer_env PRI');

       put('COL address NOPRI');
       put('COL child_address NOPRI');
       put('DEF title=''Execution Plan statistics for SQL_ID '||i.sql_id||'''');
       put('DEF main_table = ''GV$SQL_PLAN_STATISTICS_ALL''');
       put('DEF skip_text=''Y''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT * ');
       put('  FROM gv$sql_plan_statistics_all ');
       put(' WHERE sql_id = '''''||i.sql_id||''''' ');
       put(' ORDER BY inst_id, child_number, id');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/tunas360_9a_pre_one.sql');   
       put('COL address PRI');
       put('COL child_address PRI');  


       put('DEF title=''Top 15 Waits events for SQL_ID '||i.sql_id||'''');
       put('DEF main_table = ''GV$SESSION''');
       put('DEF skip_text=''Y''');
       put('DEF skip_pch=''''');
       put('DEF slices = ''15''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT event,');
       put('       num_samples,');
       put('       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,');
       put('       NULL dummy_01');
       put('  FROM (SELECT object_node event,');
       put('               count(*) num_samples');
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''TUNAS360_DATA'''' ');
       put('           AND remarks =  '''''||i.sql_id||'''''');
       put('         GROUP BY object_node'); 
       put('         ORDER BY 2 DESC)');
       put(' WHERE rownum <= 15');
       put(' ORDER BY 2 DESC');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/tunas360_9a_pre_one.sql'); 

       put('DEF title=''Top 15 Objects for SQL_ID '||i.sql_id||'''');
       put('DEF main_table = ''GV$SESSION''');
       put('DEF skip_text=''Y''');
       put('DEF skip_pch=''''');
       put('DEF slices = ''15''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT data.obj#||');
       put('       CASE WHEN data.obj# = 0 THEN '''' UNDO ''''  ');
       put('            ELSE (SELECT TRIM(''''.'''' FROM '''' ''''||o.owner||''''.''''||o.object_name||''''.''''||o.subobject_name) FROM dba_objects o WHERE o.object_id = data.obj# AND ROWNUM = 1)'); 
       put('       END data_object,');
       put('       num_samples,');
       put('       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,');
       put('       NULL dummy_01');
       put('  FROM (SELECT a.object_instance obj#,');
       put('               count(*) num_samples');
       put('          FROM plan_table a');
       put('         WHERE statement_id = ''''TUNAS360_DATA'''' ');
       put('           AND remarks =  '''''||i.sql_id||'''''');
       put('           AND a.other_tag IN (''''Application'''',''''Cluster'''', ''''Concurrency'''', ''''User I/O'''', ''''System I/O'''')');
       put('         GROUP BY a.object_instance'); 
       put('         ORDER BY 2 DESC) data');       
       put(' WHERE rownum <= 15');
       put(' ORDER BY 2 DESC');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/tunas360_9a_pre_one.sql');


       put('DEF title=''Top 15 Event/Object for SQL_ID '||i.sql_id||'''');
       put('DEF main_table = ''GV$SESSION''');
       put('DEF skip_text=''Y''');
       put('DEF skip_pch=''''');
       put('DEF slices = ''15''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT data.event||'''' / ''''||data.obj#||');
       put('       CASE WHEN data.obj# = 0 THEN ''''UNDO''''  ');
       put('            ELSE (SELECT TRIM(''''.'''' FROM '''' ''''||o.owner||''''.''''||o.object_name||''''.''''||o.subobject_name) FROM dba_objects o WHERE o.object_id = data.obj# AND ROWNUM = 1)'); 
       put('       END data_object,');
       put('       num_samples,');
       put('       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,');
       put('       NULL dummy_01');
       put('  FROM (SELECT a.object_node event, ');
       put('               a.object_instance obj#,');
       put('               count(*) num_samples');
       put('          FROM plan_table a');
       put('         WHERE statement_id = ''''TUNAS360_DATA'''' ');
       put('           AND remarks =  '''''||i.sql_id||'''''');
       put('           AND a.other_tag IN (''''Application'''',''''Cluster'''', ''''Concurrency'''', ''''User I/O'''', ''''System I/O'''')');
       put('         GROUP BY a.object_instance, a.object_node'); 
       put('         ORDER BY 2 DESC) data');       
       put(' WHERE rownum <= 15');
       put(' ORDER BY 2 DESC');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/tunas360_9a_pre_one.sql');


       put('DEF title=''Execution plan(s) for SQL_ID '||i.sql_id||'''');
       put('DEF main_table = ''GV$SQL_PLAN_STATISTICS_ALL''');
       put('DEF skip_html=''Y''');
       put('BEGIN');
       put(' :sql_text := ''');
       --put('SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('''''||i.sql_id||''''', NULL, format=> ''''ADVANCED ALLSTATS LAST''''))');
       put('WITH v AS ( ');
       put(' SELECT /*+ MATERIALIZE */ ');
       put('        DISTINCT sql_id, inst_id, child_number ');
       put('   FROM gv$sql ');
       put('  WHERE sql_id = '''''||i.sql_id||''''' ');
       put('    AND loaded_versions > 0 ');
       put('  ORDER BY 1, 2, 3 ) ');
       put(' SELECT /*+ ORDERED USE_NL(t) */ ');
       put('        RPAD(''''Inst: ''''||v.inst_id, 9)||'''' ''''||RPAD(''''Child: ''''||v.child_number, 11) inst_child, '); 
       put('        t.plan_table_output ');
       put('   FROM v, TABLE(DBMS_XPLAN.DISPLAY(''''gv$sql_plan_statistics_all'''', NULL, ''''ADVANCED ALLSTATS LAST'''', '); 
       put('            ''''inst_id = ''''||v.inst_id||'''' AND sql_id = ''''''''''''||v.sql_id||'''''''''''' AND child_number = ''''||v.child_number)) t ');
       put(''';');
       put('END;');
       put('/ ');
       put('COL inst_child NOPRI');
       put('@sql/tunas360_9a_pre_one.sql');   
       put('DEF skip_html='''''); 
       put('COL inst_child PRI');

       put('DEF title=''Historical execution plan(s) for SQL_ID '||i.sql_id||'''');
       put('DEF main_table = ''DBA_HIST_SQL_PLAN''');
       put('DEF skip_html=''Y''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_AWR('''''||i.sql_id||''''', NULL, format=> ''''ADVANCED ALLSTATS LAST''''))');
       put(''';');
       put('END;');
       put('/ ');
       put('@&&tunas360_skip_awr.sql/tunas360_9a_pre_one.sql'); 
       put('DEF skip_html=''''');

       -- PlanX
       put('SET TERM ON');
       put('PRO Running PlanX, might take a bit');
       put('SET TERM OFF');
       put('@sql/planx.sql &&tunas360_diag_license. '||i.sql_id);
       put('HOS zip -m &&tunas360_main_filename._&&tunas360_file_time. planx_'||i.sql_id||'_'||CHR(38)||chr(38)||'current_time..txt');
       put('SPO &&tunas360_main_report..html APP;');
       put('PRO <li>PlanX');
       put('PRO <a href="planx_'||i.sql_id||'_'||CHR(38)||chr(38)||'current_time..txt">text</a>');
       put('PRO </li>');
       put('SPO OFF');  

       put('SPO &&tunas360_main_report..html APP;');
       put('PRO <br>');
       put('SPO OFF');   

  END LOOP;

  -- turn it back off
  put('SET DEF @');
  put('DEF tunas360_skip_text=''@@skip_text_bck.''');
  put('SET DEF &');

END;
/
SPO OFF;
SET SERVEROUT OFF;
@9997_&&common_tunas360_prefix._top_sqls_plan_driver.sql;
HOS zip -mq &&tunas360_main_filename._&&tunas360_file_time. 9997_&&common_tunas360_prefix._top_sqls_plan_driver.sql


SPO &&tunas360_main_report..html APP;
PRO </ol>
SPO OFF;