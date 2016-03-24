DEF section_id = '1a';
DEF section_name = 'Database Configuration';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&tunas360_prefix.','&&section_id.');
SPO &&tunas360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

DEF title = 'Identification';
DEF main_table = 'V$DATABASE';
BEGIN
  :sql_text := '
SELECT d.dbid,
       d.name dbname,
       d.db_unique_name,
       d.platform_name,
       i.version,
       i.inst_id,
       i.instance_number,
       i.instance_name,
       LOWER(SUBSTR(i.host_name||''.'', 1, INSTR(i.host_name||''.'', ''.'') - 1)) host_name,
       LPAD(ORA_HASH(LOWER(SUBSTR(i.host_name||''.'', 1, INSTR(i.host_name||''.'', ''.'') - 1)),999999),6,''6'') host_hv,
       p.value cpu_count
  FROM v$database d,
       gv$instance i,
       gv$system_parameter2 p
 WHERE p.inst_id = i.inst_id
   AND p.name = ''cpu_count''
';
END;
/
@@tunas360_9a_pre_one.sql

DEF title = 'Version';
DEF main_table = 'V$VERSION';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM v$version
';
END;
/
@@tunas360_9a_pre_one.sql

DEF title = 'Database';
DEF main_table = 'V$DATABASE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM v$database
';
END;
/
@@tunas360_9a_pre_one.sql

DEF title = 'Instance';
DEF main_table = 'GV$INSTANCE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$instance
 ORDER BY
       inst_id
';
END;
/
@@tunas360_9a_pre_one.sql


DEF title = 'Modified Parameters';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$system_parameter2
 WHERE ismodified = ''MODIFIED''
 ORDER BY
       name,
       inst_id,
       ordinal
';
END;
/
@@tunas360_9a_pre_one.sql

DEF title = 'Non-default Parameters';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$system_parameter2
 WHERE isdefault = ''FALSE''
 ORDER BY
       name,
       inst_id,
       ordinal
';
END;
/
@@tunas360_9a_pre_one.sql

DEF title = 'All Parameters';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM gv$system_parameter2
 ORDER BY
       name,
       inst_id,
       ordinal
';
END;
/
@@tunas360_9a_pre_one.sql

DEF title = 'Parameter File';
DEF main_table = 'V$SPPARAMETER';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */
       *
  FROM v$spparameter
 WHERE isspecified = ''TRUE''
 ORDER BY
       name,
       sid,
       ordinal
';
END;
/
@@tunas360_9a_pre_one.sql

DEF title = 'System Stats';
DEF main_table = 'SYS.AUX_STATS$';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ 
       *
  FROM sys.aux_stats$
';
END;
/
@@tunas360_9a_pre_one.sql


DEF title = 'IO Calibration';
DEF main_table = 'DBA_RSRC_IO_CALIBRATE';
BEGIN
  :sql_text := '
SELECT /*+ &&top_level_hints. */ 
       *
  FROM dba_rsrc_io_calibrate
';
END;
/
@@tunas360_9a_pre_one.sql

DEF title = 'System Parameters Change Log';
DEF main_table = 'GV$SYSTEM_PARAMETER2';
BEGIN
  :sql_text := '
WITH 
all_parameters AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       snap_id,
       dbid,
       instance_number,
       parameter_name,
       value,
       isdefault,
       ismodified,
       lag(value) OVER (PARTITION BY dbid, instance_number, parameter_hash ORDER BY snap_id) prior_value
  FROM dba_hist_parameter
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&tunas360_dbid.
)
SELECT /*+ &&top_level_hints. */
       TO_CHAR(s.begin_interval_time, ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(s.end_interval_time, ''YYYY-MM-DD HH24:MI'') end_time,
       p.snap_id,
       --p.dbid,
       p.instance_number,
       p.parameter_name,
       p.value,
       p.isdefault,
       p.ismodified,
       p.prior_value
  FROM all_parameters p,
       dba_hist_snapshot s
 WHERE p.value != p.prior_value
   AND s.snap_id = p.snap_id
   AND s.dbid = p.dbid
   AND s.instance_number = p.instance_number
 ORDER BY
       s.begin_interval_time DESC,
       --p.dbid,
       p.instance_number,
       p.parameter_name
';
END;
/
@@&&tunas360_skip_awr.tunas360_9a_pre_one.sql

SPO &&tunas360_main_report..html APP;
PRO </ol>
SPO OFF;