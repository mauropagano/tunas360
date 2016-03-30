DEF section_id = '3a';
DEF section_name = 'Top &&tunas360_num_top_sess. Sessions';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&tunas360_prefix.','&&section_id.');
SPO &&tunas360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;



SET SERVEROUT ON;
SPO 9999_&&common_tunas360_prefix._top_sessions_driver.sql;
DECLARE

  sstats_start_stop NUMBER := 0;

  PROCEDURE put (p_line IN VARCHAR2)
  IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE(p_line);
  END put;

BEGIN
  FOR i IN (SELECT * 
              FROM (SELECT COUNT(*) num_samples, position inst_id, cpu_cost sid, io_cost serial#
                      FROM plan_table  
                     WHERE statement_id = 'TUNAS360_DATA'
                     GROUP BY position, cpu_cost, io_cost
                     ORDER BY 1 DESC) 
             WHERE ROWNUM <= &&tunas360_num_top_sess.)
  LOOP
    
       put('SPO &&tunas360_main_report..html APP;');
       put('PRO <h4>Instance: '||i.inst_id||' SID:'||i.sid||' Serial#:'||i.serial#||' NumSamples:'||i.num_samples||'</h4>');
       put('SPO OFF');

       put('DEF title=''Top 15 Waits events for Instance:SID:Serial# '||i.inst_id||':'||i.sid||':'||i.serial#||'''');
       put('DEF main_table = ''GV$SESSION''');
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
       put('           AND position =  '||i.inst_id||'');
       put('           AND cpu_cost = '||i.sid||''); 
       put('           AND io_cost = '||i.serial#||''); 
       put('         GROUP BY object_node'); 
       put('         ORDER BY 2 DESC)');
       put(' WHERE rownum <= 15');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/tunas360_9a_pre_one.sql');    

       put('DEF title=''Top 15 SQL_IDs for Instance:SID:Serial# '||i.inst_id||':'||i.sid||':'||i.serial#||'''');
       put('DEF main_table = ''GV$SESSION''');
       put('DEF skip_pch=''''');
       put('DEF slices = ''15''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT sql_id,');
       put('       num_samples,');
       put('       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,');
       put('       NULL dummy_01');
       put('  FROM (SELECT NVL(remarks,''''N/A'''') sql_id,');
       put('               count(*) num_samples');
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''TUNAS360_DATA'''' ');
       put('           AND position =  '||i.inst_id||'');
       put('           AND cpu_cost = '||i.sid||''); 
       put('           AND io_cost = '||i.serial#||''); 
       put('         GROUP BY NVL(remarks,''''N/A'''')'); 
       put('         ORDER BY 2 DESC)');
       put(' WHERE rownum <= 15');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/tunas360_9a_pre_one.sql');   

       put('DEF title=''Top 15 SQL_ID/Event for Instance:SID:Serial# '||i.inst_id||':'||i.sid||':'||i.serial#||'''');
       put('DEF main_table = ''GV$SESSION''');
       put('DEF skip_pch=''''');
       put('DEF slices = ''15''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT sqlid_event,');
       put('       num_samples,');
       put('       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,');
       put('       NULL dummy_01');
       put('  FROM (SELECT NVL(remarks,''''N/A'''')||'''' / ''''||object_node sqlid_event,');
       put('               count(*) num_samples');
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''TUNAS360_DATA'''' ');
       put('           AND position =  '||i.inst_id||'');
       put('           AND cpu_cost = '||i.sid||''); 
       put('           AND io_cost = '||i.serial#||''); 
       put('         GROUP BY NVL(remarks,''''N/A'''')||'''' / ''''||object_node'); 
       put('         ORDER BY 2 DESC)');
       put(' WHERE rownum <= 15');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/tunas360_9a_pre_one.sql'); 

       put('DEF title=''Top 15 Modules for Instance:SID:Serial# '||i.inst_id||':'||i.sid||':'||i.serial#||'''');
       put('DEF main_table = ''GV$SESSION''');
       put('DEF skip_pch=''''');
       put('DEF slices = ''15''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT module,');
       put('       num_samples,');
       put('       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,');
       put('       NULL dummy_01');
       put('  FROM (SELECT object_name module,');
       put('               count(*) num_samples');
       put('          FROM plan_table');
       put('         WHERE statement_id = ''''TUNAS360_DATA'''' ');
       put('           AND position =  '||i.inst_id||'');
       put('           AND cpu_cost = '||i.sid||''); 
       put('           AND io_cost = '||i.serial#||''); 
       put('         GROUP BY object_name'); 
       put('         ORDER BY 2 DESC)');
       put(' WHERE rownum <= 15');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/tunas360_9a_pre_one.sql');   

       put('DEF title=''Top 15 Objects for Instance:SID:Serial# '||i.inst_id||':'||i.sid||':'||i.serial#||'''');
       put('DEF main_table = ''GV$SESSION''');
       put('DEF skip_pch=''''');
       put('DEF slices = ''15''');
       put('BEGIN');
       put(' :sql_text := ''');
       put('SELECT data.obj#||');
       put('       CASE WHEN data.obj# = 0 THEN ''''UNDO''''  ');
       put('            ELSE (SELECT TRIM(''''.'''' FROM '''' ''''||o.owner||''''.''''||o.object_name||''''.''''||o.subobject_name) FROM dba_objects o WHERE o.object_id = data.obj# AND ROWNUM = 1)'); 
       put('       END data_object,');
       put('       num_samples,');
       put('       TRUNC(100*RATIO_TO_REPORT(num_samples) OVER (),2) percent,');
       put('       NULL dummy_01');
       put('  FROM (SELECT a.object_instance obj#,');
       put('               count(*) num_samples');
       put('          FROM plan_table a');
       put('         WHERE statement_id = ''''TUNAS360_DATA'''' ');
       put('           AND position =  '||i.inst_id||'');
       put('           AND cpu_cost = '||i.sid||''); 
       put('           AND io_cost = '||i.serial#||''); 
       put('           AND a.other_tag IN (''''Application'''',''''Cluster'''', ''''Concurrency'''', ''''User I/O'''', ''''System I/O'''')');
       put('         GROUP BY a.object_instance'); 
       put('         ORDER BY 2 DESC) data');       
       put(' WHERE rownum <= 15');
       put(''';');
       put('END;');
       put('/ ');
       put('@sql/tunas360_9a_pre_one.sql');


       SELECT COUNT(DISTINCT statement_id)
         INTO sstats_start_stop
         FROM plan_table
        WHERE position = i.inst_id
          AND cpu_cost = i.sid
          AND io_cost = i.serial#
          AND statement_id LIKE 'TUNAS360_SESSTAT%';

       IF sstats_start_stop = 2 THEN -- it means the same session was always connected between start and end time

         put('DEF title=''Session Statistics for Instance:SID:Serial# '||i.inst_id||':'||i.sid||':'||i.serial#||'''');
         put('DEF foot =''Samples collected between &&min_sample_time. and &&min_sample_time. (format mask YYYYMMDDHH24MISS).''');
         put('DEF main_table = ''GV$SESSTAT''');
         put('BEGIN');
         put(' :sql_text := ''');
         put('SELECT sstats_stop.statname name, NVL(sstats_start.statvalue,0) begin_value, sstats_stop.statvalue end_value, sstats_stop.statvalue - NVL(sstats_start.statvalue,0) diff, ');
         put('       TRUNC((sstats_stop.statvalue - NVL(sstats_start.statvalue,0))/((TO_DATE(''''&&max_sample_time.'''',''''YYYYMMDDHH24MISS'''') - TO_DATE(''''&&min_sample_time.'''',''''YYYYMMDDHH24MISS''''))*66400),3) diff_per_sec ');
         put('  FROM (SELECT object_node statname, partition_id statvalue');
         put('          FROM plan_table');
         put('         WHERE position =  '||i.inst_id||'');
         put('           AND cpu_cost = '||i.sid||''); 
         put('           AND io_cost = '||i.serial#||'');
         put('           AND statement_id = ''''TUNAS360_SESSTAT_START'''') sstats_start, ');
         put('       (SELECT object_node statname, partition_id statvalue');
         put('          FROM plan_table');
         put('         WHERE position =  '||i.inst_id||'');
         put('           AND cpu_cost = '||i.sid||''); 
         put('           AND io_cost = '||i.serial#||'');
         put('           AND statement_id = ''''TUNAS360_SESSTAT_STOP''''   ');
         put('           AND partition_id > 0) sstats_stop ');
         put(' WHERE sstats_start.statname(+) = sstats_stop.statname');
         put(' ORDER BY 1');
         put(''';');
         put('END;');
         put('/ ');
         put('@sql/tunas360_9a_pre_one.sql'); 

         put('DEF title=''Session Statistics with no activity for Instance:SID:Serial# '||i.inst_id||':'||i.sid||':'||i.serial#||'''');
         put('DEF main_table = ''GV$SESSTAT''');
         put('BEGIN');
         put(' :sql_text := ''');
         put('SELECT object_node statname');
         put('  FROM plan_table');
         put(' WHERE position =  '||i.inst_id||'');
         put('   AND cpu_cost = '||i.sid||''); 
         put('   AND io_cost = '||i.serial#||'');
         put('   AND statement_id = ''''TUNAS360_SESSTAT_STOP''''   ');
         put('   AND partition_id = 0');
         put(' ORDER BY 1');
         put(''';');
         put('END;');
         put('/ ');
         put('@sql/tunas360_9a_pre_one.sql'); 

       END IF;


       put('SPO &&tunas360_main_report..html APP;');
       put('PRO <br>');
       put('SPO OFF');   

  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
@9999_&&common_tunas360_prefix._top_sessions_driver.sql;
HOS zip -mq &&tunas360_main_filename._&&tunas360_file_time. 9999_&&common_tunas360_prefix._top_sessions_driver.sql


SPO &&tunas360_main_report..html APP;
PRO </ol>
SPO OFF;