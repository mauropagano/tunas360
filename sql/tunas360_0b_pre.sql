--WHENEVER SQLERROR EXIT SQL.SQLCODE;
SET TERM ON; 
SET VER OFF; 
SET FEED OFF; 
SET ECHO OFF;
SET TIM OFF;
SET TIMI OFF;
CL COL;
COL row_num FOR 9999999 HEA '#' PRI;

-- version
DEF tunas360_vYYNN = 'v1602';
DEF tunas360_vrsn = '&&tunas360_vYYNN. (2016-03-24)';
DEF tunas360_prefix = 'tunas360';

-- get dbid
COL tunas360_dbid NEW_V tunas360_dbid;
SELECT TRIM(TO_CHAR(dbid)) tunas360_dbid FROM v$database;

-- get dbmod
COL tunas360_dbmod NEW_V tunas360_dbmod;
SELECT LPAD(MOD(dbid,1e6),6,'6') tunas360_dbmod FROM v$database;

-- get host hash
COL host_hash NEW_V host_hash;
SELECT LPAD(ORA_HASH(SYS_CONTEXT('USERENV', 'SERVER_HOST'),999999),6,'6') host_hash FROM DUAL;

-- get instance number
COL connect_instance_number NEW_V connect_instance_number;
SELECT TO_CHAR(instance_number) connect_instance_number FROM v$instance;

-- get instance name 
COL connect_instance_name NEW_V connect_instance_name;
SELECT TO_CHAR(instance_name) connect_instance_name FROM v$instance;

-- get database name (up to 10, stop before first '.', no special characters)
COL database_name_short NEW_V database_name_short FOR A10;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'DB_NAME'), 1, 10)) database_name_short FROM DUAL;
SELECT SUBSTR('&&database_name_short.', 1, INSTR('&&database_name_short..', '.') - 1) database_name_short FROM DUAL;
SELECT TRANSLATE('&&database_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') database_name_short FROM DUAL;

-- get host name (up to 30, stop before first '.', no special characters)
COL host_name_short NEW_V host_name_short FOR A30;
SELECT LOWER(SUBSTR(SYS_CONTEXT('USERENV', 'SERVER_HOST'), 1, 30)) host_name_short FROM DUAL;
SELECT SUBSTR('&&host_name_short.', 1, INSTR('&&host_name_short..', '.') - 1) host_name_short FROM DUAL;
SELECT TRANSLATE('&&host_name_short.',
'abcdefghijklmnopqrstuvwxyz0123456789-_ ''`~!@#$%&*()=+[]{}\|;:",.<>/?'||CHR(0)||CHR(9)||CHR(10)||CHR(13)||CHR(38),
'abcdefghijklmnopqrstuvwxyz0123456789-_') host_name_short FROM DUAL;

-- number fo rows per report
COL row_num NEW_V row_num HEA '#' PRI;

-- get rdbms version
COL db_version NEW_V db_version;
SELECT version db_version FROM v$instance;
DEF skip_10g = '';
COL skip_10g NEW_V skip_10g;
SELECT '--' skip_10g FROM v$instance WHERE version LIKE '10%';
COL skip_11g NEW_V skip_11g;
SELECT '--' skip_11g FROM v$instance WHERE version LIKE '11%';
DEF skip_11r1 = '';
COL skip_11r1 NEW_V skip_11r1;
SELECT '--' skip_11r1 FROM v$instance WHERE version LIKE '11.1%';
DEF skip_11r201 = '';
COL skip_11r201 NEW_V skip_11r201;
SELECT '--' skip_11r201 FROM v$instance WHERE version LIKE '11.2.0.1%';
-- this is to bypass some bugs in 11.2.0.3 that can cause slowdown
DEF skip_11r203 = '';
COL skip_11r203 NEW_V skip_11r203;
SELECT '--' skip_11r203 FROM v$instance WHERE version LIKE '11.2.0.3%';
DEF skip_12r101 = '';
COL skip_12r101 NEW_V skip_12r101;
SELECT '--' skip_12r101 FROM v$instance WHERE version LIKE '12.1.0.1%';

-- get average number of CPUs
COL avg_cpu_count NEW_V avg_cpu_count FOR A3;
SELECT ROUND(AVG(TO_NUMBER(value))) avg_cpu_count FROM gv$system_parameter2 WHERE name = 'cpu_count';

-- get total number of CPUs
COL sum_cpu_count NEW_V sum_cpu_count FOR A3;
SELECT SUM(TO_NUMBER(value)) sum_cpu_count FROM gv$system_parameter2 WHERE name = 'cpu_count';

-- determine if rac or single instance (null means rac)
COL is_single_instance NEW_V is_single_instance FOR A1;
SELECT CASE COUNT(*) WHEN 1 THEN 'Y' END is_single_instance FROM gv$instance;

-- timestamp on filename
COL tunas360_file_time NEW_V tunas360_file_time FOR A20;
SELECT TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MI') tunas360_file_time FROM DUAL;

-- local or remote exec (local will be --) 
COL tunas360_remote_exec NEW_V tunas360_remote_exec FOR A20;
SELECT '--' tunas360_remote_exec FROM dual;
-- this SQL errors out in 11.1.0.6 and < 10.2.0.5, this is expected, the value is used only >= 11.2
SELECT CASE WHEN a.port <> 0 AND a.machine <> b.host_name THEN NULL ELSE '--' END tunas360_remote_exec FROM v$session a, v$instance b WHERE sid = USERENV('SID');

-- udump mnd pid, oved here from 0c_post
-- get udump directory path
COL tunas360_udump_path NEW_V tunas360_udump_path FOR A500;
SELECT value||DECODE(INSTR(value, '/'), 0, '\', '/') tunas360_udump_path FROM v$parameter2 WHERE name = 'user_dump_dest';

-- get diag_trace path
COL tunas360_diagtrace_path NEW_V tunas360_diagtrace_path FOR A500;
SELECT value||DECODE(INSTR(value, '/'), 0, '\', '/') tunas360_diagtrace_path FROM v$diag_info WHERE name = 'Diag Trace';

-- get pid
COL tunas360_spid NEW_V tunas360_spid FOR A5;
SELECT TO_CHAR(spid) tunas360_spid FROM v$session s, v$process p WHERE s.sid = SYS_CONTEXT('USERENV', 'SID') AND p.addr = s.paddr;

-- get block_size
COL database_block_size NEW_V database_block_size;
SELECT TRIM(TO_NUMBER(value)) database_block_size FROM v$system_parameter2 WHERE name = 'db_block_size';

-- the minimum time is hardcoded for now, should become a config param
COL minimum_snap_id NEW_V minimum_snap_id;
SELECT NVL(TO_CHAR(MIN(snap_id)), '0') minimum_snap_id FROM dba_hist_snapshot WHERE dbid = &&tunas360_dbid. AND '&&tunas360_diag_license.' = 'Y' AND begin_interval_time > SYSDATE - '&&tunas360_baseline_history.';  
SELECT '-1' minimum_snap_id FROM DUAL WHERE TRIM('&&minimum_snap_id.') IS NULL;
COL maximum_snap_id NEW_V maximum_snap_id;
SELECT NVL(TO_CHAR(MAX(snap_id)), '&&minimum_snap_id.') maximum_snap_id FROM dba_hist_snapshot WHERE dbid = &&tunas360_dbid. AND '&&tunas360_diag_license.' = 'Y';
SELECT '-1' maximum_snap_id FROM DUAL WHERE TRIM('&&maximum_snap_id.') IS NULL;


-- inclusion config determine skip flags
COL tunas360_skip_html NEW_V tunas360_skip_html;
COL tunas360_skip_xml  NEW_V tunas360_skip_xml;
COL tunas360_skip_text NEW_V tunas360_skip_text;
COL tunas360_skip_csv  NEW_V tunas360_skip_csv;
COL tunas360_skip_line NEW_V tunas360_skip_line;
COL tunas360_skip_pie  NEW_V tunas360_skip_pie;
COL tunas360_skip_bar  NEW_V tunas360_skip_bar;
COL tunas360_skip_tree NEW_V tunas360_skip_tree;
COL tunas360_skip_bubble NEW_V tunas360_skip_bubble;

SELECT CASE '&&tunas360_conf_incl_html.'   WHEN 'N' THEN '--' END tunas360_skip_html   FROM DUAL;
SELECT CASE '&&tunas360_conf_incl_xml.'    WHEN 'N' THEN '--' END tunas360_skip_xml    FROM DUAL;
SELECT CASE '&&tunas360_conf_incl_text.'   WHEN 'N' THEN '--' END tunas360_skip_text   FROM DUAL;
SELECT CASE '&&tunas360_conf_incl_csv.'    WHEN 'N' THEN '--' END tunas360_skip_csv    FROM DUAL;
SELECT CASE '&&tunas360_conf_incl_line.'   WHEN 'N' THEN '--' END tunas360_skip_line   FROM DUAL;
SELECT CASE '&&tunas360_conf_incl_pie.'    WHEN 'N' THEN '--' END tunas360_skip_pie    FROM DUAL;
SELECT CASE '&&tunas360_conf_incl_bar.'    WHEN 'N' THEN '--' END tunas360_skip_bar    FROM DUAL;
SELECT CASE '&&tunas360_conf_incl_tree.'   WHEN 'N' THEN '--' END tunas360_skip_tree   FROM DUAL;
SELECT CASE '&&tunas360_conf_incl_bubble.' WHEN 'N' THEN '--' END tunas360_skip_bubble FROM DUAL;

COL tunas360_skip_background NEW_V tunas360_skip_background;
SELECT CASE '&&tunas360_conf_incl_background.' WHEN 'N' THEN '--' END tunas360_skip_background FROM DUAL;

COL tunas360_skip_awr NEW_V tunas360_skip_awr;
SELECT CASE '&&tunas360_diag_license.' WHEN 'Y' THEN NULL ELSE '--' END tunas360_skip_awr FROM DUAL;

-- setup
DEF sql_trace_level = '1';
DEF main_table = '';
DEF title = '';
DEF title_no_spaces = '';
DEF title_suffix = '';
DEF common_tunas360_prefix = '&&tunas360_prefix._&&tunas360_dbmod.';
DEF tunas360_main_report = '00001_&&common_tunas360_prefix._index';
DEF tunas360_log = '00002_&&common_tunas360_prefix._log';

DEF tunas360_tkprof = '00003_&&common_tunas360_prefix._tkprof';
DEF tunas360_main_filename = '&&common_tunas360_prefix._&&host_hash.';
DEF tunas360_log2 = '00004_&&common_tunas360_prefix._log2';
DEF tunas360_tracefile_identifier = '&&common_tunas360_prefix.';
DEF tunas360_copyright = ' (c) 2015';
DEF top_level_hints = 'NO_MERGE';
DEF sq_fact_hints = 'MATERIALIZE NO_MERGE';
DEF ds_hint = 'DYNAMIC_SAMPLING(4)';
DEF def_max_rows = '50000';
DEF max_rows = '5e4';
DEF num_parts = '100';
--DEF translate_lowhigh = 'Y';
DEF default_dir = 'tunas360_DIR'
DEF sqlmon_date_mask = 'YYYYMMDDHH24MISS';
DEF sqlmon_text = 'Y';
DEF sqlmon_active = 'Y';
DEF sqlmon_hist = 'Y';
--DEF sqlmon_max_reports = '12';
DEF ash_date_mask = 'YYYYMMDDHH24MISS';
DEF ash_text = 'Y';
DEF ash_html = 'Y';
DEF ash_mem = 'Y';
DEF ash_awr = 'Y';
DEF ash_max_reports = '12';
--DEF skip_tcb = '';
--DEF skip_ash_rpt = '--';
DEF skip_html = '';
DEF skip_xml = '';
DEF skip_text = '';
DEF skip_csv = '';
DEF skip_lch = 'Y';
DEF skip_pch = 'Y';
DEF skip_bch = 'Y';
DEF skip_tch = 'Y';
DEF skip_uch = 'Y';
DEF skip_all = '';
DEF abstract = '';
DEF abstract2 = '';
DEF foot = '';
DEF treeColor = '';
DEF bubbleMaxValue = '';
DEF bubbleSeries = '';
DEF bubblesDetails = '';
DEF sql_text = '';
DEF chartype = '';
DEF stacked = '';
DEF haxis = '&&db_version. dbname:&&tunas360_dbmod. host:&&host_hash. (avg cpu_count: &&avg_cpu_count.)';
DEF vaxis = '';
DEF vbaseline = '';
DEF tit_01 = '';
DEF tit_02 = '';
DEF tit_03 = '';
DEF tit_04 = '';
DEF tit_05 = '';
DEF tit_06 = '';
DEF tit_07 = '';
DEF tit_08 = '';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
DEF exadata = '';
DEF max_col_number = '5';
DEF column_number = '1';
COL skip_html NEW_V skip_html;
COL skip_text NEW_V skip_text;
COL skip_csv NEW_V skip_csv;
COL skip_lch NEW_V skip_lch;
COL skip_pch NEW_V skip_pch;
COL skip_bch NEW_V skip_bch;
COL skip_all NEW_V skip_all;
COL dummy_01 NOPRI;
COL dummy_02 NOPRI;
COL dummy_03 NOPRI;
COL dummy_04 NOPRI;
COL dummy_05 NOPRI;
COL dummy_06 NOPRI;
COL dummy_07 NOPRI;
COL dummy_08 NOPRI;
COL dummy_09 NOPRI;
COL dummy_10 NOPRI;
COL dummy_11 NOPRI;
COL dummy_12 NOPRI;
COL dummy_13 NOPRI;
COL dummy_14 NOPRI;
COL dummy_15 NOPRI;
COL tunas360_time_stamp NEW_V tunas360_time_stamp FOR A20;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') tunas360_time_stamp FROM DUAL;
COL hh_mm_ss NEW_V hh_mm_ss FOR A8;
COL title_no_spaces NEW_V title_no_spaces;
COL spool_filename NEW_V spool_filename;
COL one_spool_filename NEW_V one_spool_filename;
COL report_sequence NEW_V report_sequence;
VAR row_count NUMBER;
-- next two are using to hold the reports SQL
VAR sql_text CLOB;
VAR sql_text_backup CLOB;
VAR sql_text_backup2 CLOB;
--VAR sql_text_backup2 CLOB;
VAR sql_text_display CLOB;
VAR file_seq NUMBER;
VAR repo_seq NUMBER;
-- the next one is used to store the report sequence before moving to a second-layer page
VAR repo_seq_bck NUMBER;
EXEC :repo_seq := 1;
SELECT TO_CHAR(:repo_seq) report_sequence FROM DUAL;
EXEC :repo_seq_bck := 0;
EXEC :file_seq := 5;
VAR get_time_t0 NUMBER;
VAR get_time_t1 NUMBER;
-- Exadata
ALTER SESSION SET "_serial_direct_read" = ALWAYS;
ALTER SESSION SET "_small_table_threshold" = 1001;
-- nls
ALTER SESSION SET NLS_NUMERIC_CHARACTERS = ".,";
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD/HH24:MI:SS';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'YYYY-MM-DD/HH24:MI:SS.FF';
ALTER SESSION SET NLS_TIMESTAMP_TZ_FORMAT = 'YYYY-MM-DD/HH24:MI:SS.FF TZH:TZM';
-- adding to prevent slow access to ASH with non default NLS settings
ALTER SESSION SET NLS_SORT = 'BINARY';
ALTER SESSION SET NLS_COMP = 'BINARY';
-- to work around bug 12672969
ALTER SESSION SET "_optimizer_order_by_elimination_enabled"=false; 
-- to work around bug 19567916
ALTER SESSION SET "_optimizer_aggr_groupby_elim"=false; 
-- workaround bug 21150273
ALTER SESSION SET "_optimizer_dsdir_usage_control"=0;
ALTER SESSION SET "_sql_plan_directive_mgmt_control" = 0;
ALTER SESSION SET optimizer_dynamic_sampling = 0;
-- workaround nigeria
ALTER SESSION SET "_gby_hash_aggregation_enabled" = TRUE;
ALTER SESSION SET "_hash_join_enabled" = TRUE;
ALTER SESSION SET "_optim_peek_user_binds" = TRUE;
ALTER SESSION SET "_optimizer_skip_scan_enabled" = TRUE;
ALTER SESSION SET "_optimizer_sortmerge_join_enabled" = TRUE;
ALTER SESSION SET cursor_sharing = EXACT;
ALTER SESSION SET db_file_multiblock_read_count = 128;
ALTER SESSION SET optimizer_index_caching = 0;
-- to work around Siebel
ALTER SESSION SET optimizer_index_cost_adj = 100;
-- leaving the next one here to remember we used to set it
--ALTER SESSION SET optimizer_dynamic_sampling = 2;
ALTER SESSION SET "_always_semi_join" = CHOOSE;
ALTER SESSION SET "_and_pruning_enabled" = TRUE;
ALTER SESSION SET "_subquery_pruning_enabled" = TRUE;
-- workaround fairpoint
COL db_vers_ofe NEW_V db_vers_ofe;
SELECT TRIM('.' FROM TRIM('0' FROM version)) db_vers_ofe FROM v$instance;
ALTER SESSION SET optimizer_features_enable = '&&db_vers_ofe.';
-- tracing script in case it takes long to execute so we can diagnose it
ALTER SESSION SET MAX_DUMP_FILE_SIZE = '1G';
ALTER SESSION SET TRACEFILE_IDENTIFIER = "&&tunas360_tracefile_identifier.";
--ALTER SESSION SET STATISTICS_LEVEL = 'ALL';
ALTER SESSION SET EVENTS '10046 TRACE NAME CONTEXT FOREVER, LEVEL &&sql_trace_level.';
SET TERM OFF; 
SET HEA ON; 
SET LIN 32767; 
SET NEWP NONE; 
SET PAGES &&def_max_rows.; 
SET LONG 32000; 
SET LONGC 2000; 
SET WRA ON; 
SET TRIMS ON; 
SET TRIM ON; 
SET TI OFF; 
SET TIMI OFF; 
SET ARRAY 1000; 
SET NUM 20; 
SET SQLBL ON; 
SET BLO .; 
SET RECSEP OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- log header
SPO &&tunas360_log..txt;
PRO begin log
PRO
host env
DEF;
SPO OFF;

-- main header
SPO &&tunas360_main_report..html;
@@tunas360_0c_html_header.sql
PRO </head>
PRO <body>
PRO <h1><em>&&tunas360_conf_tool_page.TUNAs360</a></em> &&tunas360_vYYNN.: (TUN)ing with (A)ctive (s)essions 360-degree view &&tunas360_conf_all_pages_logo.</h1>
PRO
PRO <pre>
SET SERVEROUTPUT ON
BEGIN
  IF '&&tunas360_diag_license.' = 'Y' THEN
    DBMS_OUTPUT.PUT_LINE('<b>This execution of TUNAs360 is making use of the Oracle Diagnostics Pack as per manual setup of configuration file tunas360_00_config.sql.</b><br>');
  END IF;
END;
/ 
SET SERVEROUTPUT OFF
PRO dbname:&&tunas360_dbmod. version:&&db_version. host:&&host_hash. today:&&tunas360_time_stamp.
PRO </pre>
PRO
SPO OFF;

-- zip
HOS zip -jq &&tunas360_main_filename._&&tunas360_file_time. js/sorttable.js
HOS zip -jq &&tunas360_main_filename._&&tunas360_file_time. js/TUNAs360_img.jpg
HOS zip -jq &&tunas360_main_filename._&&tunas360_file_time. js/TUNAs360_favicon.ico
HOS zip -jq &&tunas360_main_filename._&&tunas360_file_time. js/TUNAs360_all_pages_logo.jpg
