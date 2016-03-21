DEF section_id = '2a';
DEF section_name = 'Active Sessions';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&tunas360_prefix.','&&section_id.');
SPO &&tunas360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

SET SERVEROUT ON;
SPO 9998_&&common_tunas360_prefix._chart_setup_driver.sql;
DECLARE
  l_count NUMBER;
BEGIN
  FOR i IN 1 .. 15
  LOOP
    SELECT COUNT(*) INTO l_count FROM gv$instance WHERE instance_number = i;
    IF l_count = 0 THEN
      DBMS_OUTPUT.PUT_LINE('COL inst_'||LPAD(i, 2, '0')||' NOPRI;');
      DBMS_OUTPUT.PUT_LINE('DEF tit_'||LPAD(i, 2, '0')||' = '''';');
    ELSE
      DBMS_OUTPUT.PUT_LINE('COL inst_'||LPAD(i, 2, '0')||' HEA ''Inst '||i||''' FOR 999990.0 PRI;');
      DBMS_OUTPUT.PUT_LINE('DEF tit_'||LPAD(i, 2, '0')||' = ''Inst '||i||''';');
    END IF;
  END LOOP;
END;
/
SPO OFF;
SET SERVEROUT OFF;
@9998_&&common_tunas360_prefix._chart_setup_driver.sql;
HOS zip -mq &&tunas360_main_filename._&&tunas360_file_time. 9998_&&common_tunas360_prefix._chart_setup_driver.sql

DEF main_table = 'GV$SESSION';
DEF vaxis = 'Active Sessions - AS (stacked)';
DEF vbaseline = '';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';

BEGIN
  :sql_text_backup := '
SELECT 0 snap_id,
       TO_CHAR(sample_time, ''YYYY-MM-DD HH24:MI:SS'') begin_time,
       TO_CHAR(sample_time, ''YYYY-MM-DD HH24:MI:SS'') end_time,
       SUM(CASE inst_id WHEN 1 THEN 1 ELSE 0 END) inst_01,
       SUM(CASE inst_id WHEN 2 THEN 1 ELSE 0 END) inst_02,
       SUM(CASE inst_id WHEN 3 THEN 1 ELSE 0 END) inst_03,
       SUM(CASE inst_id WHEN 4 THEN 1 ELSE 0 END) inst_04,
       SUM(CASE inst_id WHEN 5 THEN 1 ELSE 0 END) inst_05,
       SUM(CASE inst_id WHEN 6 THEN 1 ELSE 0 END) inst_06,
       SUM(CASE inst_id WHEN 7 THEN 1 ELSE 0 END) inst_07,
       SUM(CASE inst_id WHEN 8 THEN 1 ELSE 0 END) inst_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM (SELECT position inst_id, timestamp sample_time, parent_id sample_id 
          FROM plan_table
         WHERE statement_id = ''TUNAS360_DATA''
           AND @filter_predicate@)
 GROUP BY
       sample_time, sample_id
 ORDER BY
       sample_id
';
END;
/

DEF skip_lch = '';
DEF title = 'AS Total per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', '1 = 1');
@@tunas360_9a_pre_one.sql

DEF skip_lch = '';
DEF title = 'AS On CPU per Instance';
EXEC :sql_text := REPLACE(:sql_text_backup, '@filter_predicate@', 'object_node = ''ON CPU''');
@@tunas360_9a_pre_one.sql

------------------------------
------------------------------

DEF main_table = 'GV$SESSION';
DEF chartype = 'AreaChart';
DEF stacked = 'isStacked: true,';
DEF vaxis = 'Active Sessions - AS (stacked)';
DEF vbaseline = '';

DEF tit_01 = '';
DEF tit_02 = 'On CPU';
DEF tit_03 = 'User I/O';
DEF tit_04 = 'System I/O';
DEF tit_05 = 'Cluster';
DEF tit_06 = 'Commit';
DEF tit_07 = 'Concurrency';
DEF tit_08 = 'Application';
DEF tit_09 = 'Administrative';
DEF tit_10 = 'Configuration';
DEF tit_11 = 'Network';
DEF tit_12 = 'Queueing';
DEF tit_13 = 'Scheduler';
DEF tit_14 = 'Idle';
DEF tit_15 = 'Other';

COL aas_total FOR 999990.000;
COL aas_on_cpu FOR 999990.000;
COL aas_administrative FOR 999990.000;
COL aas_application FOR 999990.000;
COL aas_cluster FOR 999990.000;
COL aas_commit FOR 999990.000;
COL aas_concurrency FOR 999990.000;
COL aas_configuration FOR 999990.000;
COL aas_idle FOR 999990.000;
COL aas_network FOR 999990.000;
COL aas_other FOR 999990.000;
COL aas_queueing FOR 999990.000;
COL aas_scheduler FOR 999990.000;
COL aas_system_io FOR 999990.000;
COL aas_user_io FOR 999990.000;

BEGIN
  :sql_text_backup := '
SELECT 0 snap_id,
       TO_CHAR(sample_time, ''YYYY-MM-DD HH24:MI:SS'') begin_time,
       TO_CHAR(sample_time, ''YYYY-MM-DD HH24:MI:SS'') end_time,
       COUNT(*) aas_total,
       SUM(CASE event       WHEN ''ON CPU''         THEN 1 ELSE 0 END) aas_on_cpu,
       SUM(CASE wait_class  WHEN ''User I/O''       THEN 1 ELSE 0 END) aas_user_io,
       SUM(CASE wait_class  WHEN ''System I/O''     THEN 1 ELSE 0 END) aas_system_io,
       SUM(CASE wait_class  WHEN ''Cluster''        THEN 1 ELSE 0 END) aas_cluster,
       SUM(CASE wait_class  WHEN ''Commit''         THEN 1 ELSE 0 END) aas_commit,
       SUM(CASE wait_class  WHEN ''Concurrency''    THEN 1 ELSE 0 END) aas_concurrency,
       SUM(CASE wait_class  WHEN ''Application''    THEN 1 ELSE 0 END) aas_application,
       SUM(CASE wait_class  WHEN ''Administrative'' THEN 1 ELSE 0 END) aas_administrative,
       SUM(CASE wait_class  WHEN ''Configuration''  THEN 1 ELSE 0 END) aas_configuration,
       SUM(CASE wait_class  WHEN ''Network''        THEN 1 ELSE 0 END) aas_network,
       SUM(CASE wait_class  WHEN ''Queueing''       THEN 1 ELSE 0 END) aas_queueing,
       SUM(CASE wait_class  WHEN ''Scheduler''      THEN 1 ELSE 0 END) aas_scheduler,
       SUM(CASE wait_class  WHEN ''Idle''           THEN 1 ELSE 0 END) aas_idle,
       SUM(CASE wait_class  WHEN  ''Other''         THEN 1 ELSE 0 END) aas_other
  FROM (SELECT position inst_id, other_tag wait_class, object_node event, timestamp sample_time, parent_id sample_id 
          FROM plan_table
         WHERE statement_id = ''TUNAS360_DATA''
           AND position = @instance_number@)
 GROUP BY
       sample_time, sample_id
 ORDER BY
       sample_id
';
END;
/

DEF skip_lch = '';
DEF skip_all = '&&is_single_instance.';
DEF title = 'AS per Wait Class for Cluster';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', 'position');
@@&&skip_all.tunas360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 1;
DEF title = 'AS per Wait Class for Instance 1';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '1');
@@&&skip_all.tunas360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 2;
DEF title = 'AS per Wait Class for Instance 2';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '2');
@@&&skip_all.tunas360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 3;
DEF title = 'AS per Wait Class for Instance 3';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '3');
@@&&skip_all.tunas360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 4;
DEF title = 'AS per Wait Class for Instance 4';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '4');
@@&&skip_all.tunas360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 5;
DEF title = 'AS per Wait Class for Instance 5';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '5');
@@&&skip_all.tunas360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 6;
DEF title = 'AS per Wait Class for Instance 6';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '6');
@@&&skip_all.tunas360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 7;
DEF title = 'AS per Wait Class for Instance 7';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '7');
@@&&skip_all.tunas360_9a_pre_one.sql

DEF skip_lch = '';
DEF skip_all = 'Y';
SELECT NULL skip_all FROM gv$instance WHERE instance_number = 8;
DEF title = 'AS per Wait Class for Instance 8';
EXEC :sql_text := REPLACE(:sql_text_backup, '@instance_number@', '8');
@@&&skip_all.tunas360_9a_pre_one.sql

-- reset previous env
DEF skip_lch = 'Y';

SPO &&tunas360_main_report..html APP;
PRO </ol>
SPO OFF;