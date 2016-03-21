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