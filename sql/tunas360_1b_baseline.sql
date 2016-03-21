DEF section_id = '1b';
DEF section_name = 'Resources Baseline';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&tunas360_prefix.','&&section_id.');
SPO &&tunas360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


COL order_by NOPRI;
COL metric FOR A16 HEA "Metric";
COL instance_number FOR 9999 HEA "Inst|Num";
COL on_cpu FOR 999990.0 HEA "Active|Sessions|ON CPU";
COL on_cpu_and_resmgr FOR 9999990.0 HEA "Active|Sessions|ON CPU|or RESMGR";
COL resmgr_cpu_quantum FOR 999999990.0 HEA "Active|Sessions|ON RESMGR|CPU quantum";
COL begin_interval_time FOR A18 HEA "Begin Interval";
COL end_interval_time FOR A18 HEA "End Interval";
COL snap_shots FOR 99999 HEA "Snap|Shots";
COL days FOR 990.0 HEA "Days|Hist";
COL avg_snaps_per_day FOR 990.0 HEA "Avg|Snaps|per|Day";
COL min_sample_time FOR A18 HEA "Begin Interval";
COL max_sample_time FOR A18 HEA "End Interval";
COL samples FOR 9999999 HEA "Samples";
COL hours FOR 9990.0 HEA "Hours|Hist";


DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Sessions on CPU or RESMGR';
DEF tit_01 = 'ON CPU + resmgr:cpu quantum';
DEF tit_02 = 'ON CPU';
DEF tit_03 = 'resmgr:cpu quantum';
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

BEGIN
  :sql_text := '
WITH 
cpu_per_inst_and_sample AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       instance_number,
       snap_id,
       sample_id,
       MIN(sample_time) sample_time,
       SUM(CASE session_state WHEN ''ON CPU'' THEN 1 ELSE 0 END) on_cpu,
       SUM(CASE event WHEN ''resmgr:cpu quantum'' THEN 1 ELSE 0 END) resmgr,
       COUNT(*) on_cpu_and_resmgr
  FROM dba_hist_active_sess_history
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&tunas360_dbid.
   AND (session_state = ''ON CPU'' OR event = ''resmgr:cpu quantum'')
 GROUP BY
       instance_number,
       snap_id,
       sample_id
),
cpu_per_inst_and_hour AS (
SELECT /*+ &&sq_fact_hints. */
       MIN(snap_id) snap_id,
       instance_number, 
       TRUNC(CAST(sample_time AS DATE), ''HH'') begin_time, 
       TRUNC(CAST(sample_time AS DATE), ''HH'') + (1/24) end_time, 
       MAX(on_cpu) on_cpu,
       MAX(resmgr) resmgr,
       MAX(on_cpu_and_resmgr) on_cpu_and_resmgr
  FROM cpu_per_inst_and_sample
 GROUP BY
       instance_number,
       TRUNC(CAST(sample_time AS DATE), ''HH'')
)
SELECT MIN(snap_id) snap_id,
       TO_CHAR(begin_time, ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') end_time,
       SUM(on_cpu_and_resmgr) on_cpu_and_resmgr,
       SUM(on_cpu) on_cpu,
       SUM(resmgr) resmgr,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM cpu_per_inst_and_hour
 GROUP BY
       begin_time,
       end_time
 ORDER BY
       end_time
';
END;
/

DEF vbaseline = 'baseline:&&sum_cpu_count.,'; 

DEF skip_lch = '';
DEF title = 'CPU Demand Series (Peak)';
DEF abstract = 'Number of Sessions demanding CPU. Based on peak demand per hour.'
DEF foot = 'Sessions "ON CPU" or "ON CPU" + "resmgr:cpu quantum"'
@@tunas360_9a_pre_one.sql


DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

DEF main_table = 'DBA_HIST_ACTIVE_SESS_HISTORY';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Sessions on CPU';
DEF tit_01 = 'Maximum (Peak)';
DEF tit_02 = '99th Percentile';
DEF tit_03 = '97th Percentile';
DEF tit_04 = '95th Percentile';
DEF tit_05 = '90th Percentile';
DEF tit_06 = '75th Percentile';
DEF tit_07 = 'Median';
DEF tit_08 = 'Average';
DEF tit_09 = '';
DEF tit_10 = '';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';

BEGIN
  :sql_text := '
WITH 
cpu_per_inst_and_sample AS (
SELECT /*+ &&sq_fact_hints. &&ds_hint. */
       instance_number,
       snap_id,
       sample_id,
       MIN(sample_time) sample_time,
       COUNT(*) on_cpu
  FROM dba_hist_active_sess_history
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&tunas360_dbid.
   AND session_state = ''ON CPU''
 GROUP BY
       instance_number,
       snap_id,
       sample_id
),
cpu_per_inst_and_hour AS (
SELECT /*+ &&sq_fact_hints. */
       MIN(snap_id) snap_id,
       instance_number, 
       TRUNC(CAST(sample_time AS DATE), ''HH'')             begin_time, 
       TRUNC(CAST(sample_time AS DATE), ''HH'') + (1/24)    end_time, 
       MAX(on_cpu)                                          on_cpu_max,
       PERCENTILE_DISC(0.99) WITHIN GROUP (ORDER BY on_cpu) on_cpu_99p,
       PERCENTILE_DISC(0.97) WITHIN GROUP (ORDER BY on_cpu) on_cpu_97p,
       PERCENTILE_DISC(0.95) WITHIN GROUP (ORDER BY on_cpu) on_cpu_95p,
       PERCENTILE_DISC(0.90) WITHIN GROUP (ORDER BY on_cpu) on_cpu_90p,
       PERCENTILE_DISC(0.75) WITHIN GROUP (ORDER BY on_cpu) on_cpu_75p,
       ROUND(MEDIAN(on_cpu), 1)                             on_cpu_med,
       ROUND(AVG(on_cpu), 1)                                on_cpu_avg
  FROM cpu_per_inst_and_sample
 GROUP BY
       instance_number,
       TRUNC(CAST(sample_time AS DATE), ''HH'')
)
SELECT MIN(snap_id) snap_id,
       TO_CHAR(begin_time, ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(end_time, ''YYYY-MM-DD HH24:MI'') end_time,
       SUM(on_cpu_max) on_cpu_max,
       SUM(on_cpu_99p) on_cpu_99p,
       SUM(on_cpu_97p) on_cpu_97p,
       SUM(on_cpu_95p) on_cpu_95p,
       SUM(on_cpu_90p) on_cpu_90p,
       SUM(on_cpu_75p) on_cpu_75p,
       SUM(on_cpu_med) on_cpu_med,
       SUM(on_cpu_avg) on_cpu_avg,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM cpu_per_inst_and_hour
 GROUP BY
       begin_time,
       end_time
 ORDER BY
       end_time
';
END;
/

DEF vbaseline = 'baseline:&&sum_cpu_count.,'; 

DEF skip_lch = '';
DEF title = 'CPU Demand Series (Percentile)';
DEF abstract = 'Number of Sessions demanding CPU. Based on percentiles per hour as per Active Session History (ASH).'
DEF foot = 'Sessions "ON CPU"'
@@tunas360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

COL mem_gb FOR 99990.0 HEA "Mem GB";
COL sga_gb FOR 99990.0 HEA "SGA GB";
COL pga_gb FOR 99990.0 HEA "PGA GB";



DEF main_table = 'DBA_HIST_SGA';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';
DEF vaxis = 'Memory in Giga Bytes (GB)';
DEF tit_01 = 'Total (SGA + PGA)';
DEF tit_02 = 'SGA';
DEF tit_03 = 'PGA';
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

BEGIN
  :sql_text := '
WITH
sga AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       SUM(value) bytes
  FROM dba_hist_sga
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&tunas360_dbid.
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
pga AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       value bytes
  FROM dba_hist_pgastat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&tunas360_dbid.
   AND name = ''total PGA allocated''
),
mem AS (
SELECT /*+ &&sq_fact_hints. */
       snp.snap_id,
       snp.dbid,
       snp.instance_number,
       snp.begin_interval_time,
       snp.end_interval_time,
       TO_CHAR(TRUNC(CAST(snp.begin_interval_time AS DATE), ''HH''), ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(TRUNC(CAST(snp.begin_interval_time AS DATE), ''HH'') + (1/24), ''YYYY-MM-DD HH24:MI'') end_time,
       sga.bytes sga_bytes,
       pga.bytes pga_bytes,
       (sga.bytes + pga.bytes) mem_bytes
  FROM sga, pga, dba_hist_snapshot snp
 WHERE pga.snap_id = sga.snap_id
   AND pga.dbid = sga.dbid
   AND pga.instance_number = sga.instance_number
   AND snp.snap_id = sga.snap_id
   AND snp.dbid = sga.dbid
   AND snp.instance_number = sga.instance_number
   AND snp.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND snp.dbid = &&tunas360_dbid.
),
hourly_inst AS (
SELECT /*+ &&sq_fact_hints. */
       MIN(snap_id) snap_id,
       dbid,
       instance_number,
       begin_time,
       end_time,
       MAX(sga_bytes) sga_bytes,
       MAX(pga_bytes) pga_bytes,
       MAX(mem_bytes) mem_bytes,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time
  FROM mem
 GROUP BY
       dbid,
       instance_number,
       begin_time,
       end_time
),
hourly AS (
SELECT /*+ &&sq_fact_hints. */
       MIN(snap_id) snap_id,
       begin_time,
       end_time,
       ROUND(SUM(sga_bytes) / POWER(2, 30), 3) sga_gb,
       ROUND(SUM(pga_bytes) / POWER(2, 30), 3) pga_gb,
       ROUND(SUM(mem_bytes) / POWER(2, 30), 3) mem_gb,
       SUM(sga_bytes) sga_bytes,
       SUM(pga_bytes) pga_bytes,
       SUM(mem_bytes) mem_bytes,
       MIN(begin_interval_time) begin_interval_time,
       MAX(end_interval_time) end_interval_time
  FROM hourly_inst
 GROUP BY
       begin_time,
       end_time
)
SELECT snap_id,
       begin_time,
       end_time,
       mem_gb,
       sga_gb,
       pga_gb,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM hourly
 ORDER BY
       end_time
';
END;
/

DEF skip_lch = '';
DEF title = 'Memory Size Series';
@@tunas360_9a_pre_one.sql


/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

DEF main_table = 'DBA_HIST_SYSSTAT';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vbaseline = '';
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

BEGIN
  :sql_text_backup := '
WITH
sysstat_io AS (
SELECT /*+ &&sq_fact_hints. */
       instance_number,
       snap_id,
       SUM(CASE WHEN stat_name = ''physical read total IO requests'' THEN value ELSE 0 END) r_reqs,
       SUM(CASE WHEN stat_name IN (''physical write total IO requests'', ''redo writes'') THEN value ELSE 0 END) w_reqs,
       SUM(CASE WHEN stat_name = ''physical read total bytes'' THEN value ELSE 0 END) r_bytes,
       SUM(CASE WHEN stat_name IN (''physical write total bytes'', ''redo size'') THEN value ELSE 0 END) w_bytes
  FROM dba_hist_sysstat
 WHERE snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&tunas360_dbid.
   AND stat_name IN (''physical read total IO requests'', ''physical write total IO requests'', ''redo writes'', ''physical read total bytes'', ''physical write total bytes'', ''redo size'')
 GROUP BY
       instance_number,
       snap_id
),
io_per_inst_and_snap_id AS (
SELECT /*+ &&sq_fact_hints. */
       s1.snap_id,
       h1.instance_number,
       TRUNC(CAST(s1.end_interval_time AS DATE), ''HH'') begin_time,
       (h1.r_reqs - h0.r_reqs) r_reqs,
       (h1.w_reqs - h0.w_reqs) w_reqs,
       (h1.r_bytes - h0.r_bytes) r_bytes,
       (h1.w_bytes - h0.w_bytes) w_bytes,
       (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 elapsed_sec
  FROM sysstat_io h0,
       dba_hist_snapshot s0,
       sysstat_io h1,
       dba_hist_snapshot s1
 WHERE s0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s0.dbid = &&tunas360_dbid.
   AND s0.snap_id = h0.snap_id
   AND s0.instance_number = h0.instance_number
   AND h1.instance_number = h0.instance_number
   AND h1.snap_id = h0.snap_id + 1
   AND s1.snap_id = h1.snap_id
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND (CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 86400 > 60 -- ignore snaps too close
),
io_per_inst_and_hr AS (
SELECT /*+ &&sq_fact_hints. */
       MIN(snap_id) snap_id,
       instance_number,
       TO_CHAR(begin_time, ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(begin_time + (1/24), ''YYYY-MM-DD HH24:MI'') end_time,
       ROUND(MAX((r_reqs + w_reqs) / elapsed_sec)) rw_iops,
       ROUND(MAX(r_reqs / elapsed_sec)) r_iops,
       ROUND(MAX(w_reqs / elapsed_sec)) w_iops,
       ROUND(MAX((r_bytes + w_bytes) / POWER(2, 20) / elapsed_sec), 3) rw_mbps,
       ROUND(MAX(r_bytes / POWER(2, 20) / elapsed_sec), 3) r_mbps,
       ROUND(MAX(w_bytes / POWER(2, 20) / elapsed_sec), 3) w_mbps
  FROM io_per_inst_and_snap_id
 GROUP BY
       instance_number,
       begin_time
)
SELECT MIN(snap_id) snap_id,
       begin_time,
       end_time,
       SUM(@column1@) @column1@,
       SUM(@column2@) @column2@,
       SUM(@column3@) @column3@,
       0 dummy_04,
       0 dummy_05,
       0 dummy_06,
       0 dummy_07,
       0 dummy_08,
       0 dummy_09,
       0 dummy_10,
       0 dummy_11,
       0 dummy_12,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM io_per_inst_and_hr
 GROUP BY
       begin_time,
       end_time
 ORDER BY
       end_time
';
END;
/

DEF tit_01 = 'RW IOPS';
DEF tit_02 = 'R IOPS';
DEF tit_03 = 'W IOPS';
DEF vaxis = 'IOPS (RW, R and W)';

DEF skip_lch = '';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) I/O Operations per Second (IOPS).'
DEF title = 'IOPS Series';
EXEC :sql_text := REPLACE(:sql_text_backup, '@column1@', 'rw_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_iops');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_iops');
@@tunas360_9a_pre_one.sql

/********************************* */

DEF tit_01 = 'RW MBPS';
DEF tit_02 = 'R MBPS';
DEF tit_03 = 'W MBPS';
DEF vaxis = 'MBPS (RW, R and W)';

DEF skip_lch = '';
DEF abstract = 'Read (R), Write (W) and Read-Write (RW) Mega Bytes per Second (MBPS).'
DEF title = 'MBPS Series';
EXEC :sql_text := REPLACE(:sql_text_backup, '@column1@', 'rw_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column2@', 'r_mbps');
EXEC :sql_text := REPLACE(:sql_text, '@column3@', 'w_mbps');
@@tunas360_9a_pre_one.sql

/*****************************************************************************************/

DEF skip_lch = 'Y';
DEF skip_pch = 'Y';

/*****************************************************************************************/

DEF main_table = 'DBA_HIST_OSSTAT';
DEF chartype = 'LineChart';
DEF stacked = '';
DEF vaxis = 'Time as a Percent of Number of CPUs';
DEF title = 'OS CPU Time Percent';
DEF vbaseline = 'baseline: 100,';
DEF tit_01 = '';
DEF tit_02 = '';
DEF tit_03 = 'Idle Time %';
DEF tit_04 = 'Busy Time %';
DEF tit_05 = 'User Time %';
DEF tit_06 = 'Nice Time %';
DEF tit_07 = 'Sys Time %';
DEF tit_08 = 'OS CPU Wait Time %';
DEF tit_09 = 'RM CPU Wait Time %';
DEF tit_10 = 'IO Time %';
DEF tit_11 = '';
DEF tit_12 = '';
DEF tit_13 = '';
DEF tit_14 = '';
DEF tit_15 = '';
COL load FOR 999990.0;
COL idle_time_perc FOR 999990.0;
COL busy_time_perc FOR 999990.0;
COL user_time_perc FOR 999990.0;
COL nice_time_perc FOR 999990.0;
COL sys_time_perc FOR 999990.0;
COL os_cpu_wait_time_secs FOR 999990.0;
COL rsrc_mgr_cpu_wait_perc FOR 999990.0;
COL iowait_perc FOR 999990.0;
BEGIN
  :sql_text := '
WITH 
osstat_denorm_2 AS (
SELECT /*+ &&sq_fact_hints. */
       snap_id,
       dbid,
       instance_number,
       SUM(CASE stat_name WHEN ''NUM_CPUS''               THEN value       ELSE 0 END) num_cpus,
       SUM(CASE stat_name WHEN ''LOAD''                   THEN value       ELSE 0 END) load,
       SUM(CASE stat_name WHEN ''IDLE_TIME''              THEN value / 100 ELSE 0 END) idle_time_secs,
       SUM(CASE stat_name WHEN ''BUSY_TIME''              THEN value / 100 ELSE 0 END) busy_time_secs,
       SUM(CASE stat_name WHEN ''USER_TIME''              THEN value / 100 ELSE 0 END) user_time_secs,
       SUM(CASE stat_name WHEN ''NICE_TIME''              THEN value / 100 ELSE 0 END) nice_time_secs,
       SUM(CASE stat_name WHEN ''SYS_TIME''               THEN value / 100 ELSE 0 END) sys_time_secs,
       SUM(CASE stat_name WHEN ''OS_CPU_WAIT_TIME''       THEN value / 100 ELSE 0 END) os_cpu_wait_time_secs,
       SUM(CASE stat_name WHEN ''RSRC_MGR_CPU_WAIT_TIME'' THEN value / 100 ELSE 0 END) rsrc_mgr_cpu_wait_time_secs,
       SUM(CASE stat_name WHEN ''IOWAIT_TIME''            THEN value / 100 ELSE 0 END) iowait_time_secs,
       SUM(CASE stat_name WHEN ''VM_IN_BYTES''            THEN value       ELSE 0 END) vm_in_bytes,
       SUM(CASE stat_name WHEN ''VM_OUT_BYTES''           THEN value       ELSE 0 END) vm_out_bytes
  FROM dba_hist_osstat
 WHERE stat_name IN (''NUM_CPUS'', ''LOAD'', ''IDLE_TIME'', ''BUSY_TIME'', ''USER_TIME'', ''NICE_TIME'', ''SYS_TIME'', ''OS_CPU_WAIT_TIME'', ''RSRC_MGR_CPU_WAIT_TIME'', ''IOWAIT_TIME'', ''VM_IN_BYTES'', ''VM_OUT_BYTES'')
   AND snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND dbid = &&tunas360_dbid.
 GROUP BY
       snap_id,
       dbid,
       instance_number
),
osstat_delta AS (
SELECT /*+ &&sq_fact_hints. */
       h1.snap_id,
       h1.dbid,
       h1.instance_number,
       s1.begin_interval_time,
       s1.end_interval_time,
       ROUND((CAST(s1.end_interval_time AS DATE) - CAST(s1.begin_interval_time AS DATE)) * 24 * 60 * 60) interval_secs,
       h1.num_cpus,
       h1.load,
       (h1.idle_time_secs - h0.idle_time_secs) idle_time_secs,
       (h1.busy_time_secs - h0.busy_time_secs) busy_time_secs,
       (h1.user_time_secs - h0.user_time_secs) user_time_secs,
       (h1.nice_time_secs - h0.nice_time_secs) nice_time_secs,
       (h1.sys_time_secs - h0.sys_time_secs) sys_time_secs,
       (h1.os_cpu_wait_time_secs - h0.os_cpu_wait_time_secs) os_cpu_wait_time_secs,
       (h1.rsrc_mgr_cpu_wait_time_secs - h0.rsrc_mgr_cpu_wait_time_secs) rsrc_mgr_cpu_wait_time_secs,
       (h1.iowait_time_secs - h0.iowait_time_secs) iowait_time_secs,
       (h1.vm_in_bytes - h0.vm_in_bytes) vm_in_bytes,
       (h1.vm_out_bytes - h0.vm_out_bytes) vm_out_bytes
  FROM osstat_denorm_2 h0,
       osstat_denorm_2 h1,
       dba_hist_snapshot s0,
       dba_hist_snapshot s1
 WHERE h1.snap_id = h0.snap_id + 1
   AND h1.dbid = h0.dbid
   AND h1.instance_number = h0.instance_number
   AND s0.snap_id = h0.snap_id
   AND s0.dbid = h0.dbid
   AND s0.instance_number = h0.instance_number
   AND s0.snap_id BETWEEN &&minimum_snap_id. AND &&maximum_snap_id.
   AND s0.dbid = &&tunas360_dbid.
   AND s1.snap_id = h1.snap_id
   AND s1.dbid = h1.dbid
   AND s1.instance_number = h1.instance_number
   AND s1.snap_id = s0.snap_id + 1
   AND s1.startup_time = s0.startup_time
   AND s1.begin_interval_time > (s0.begin_interval_time + (1 / (24 * 60))) /* filter out snaps apart < 1 min */
)
SELECT snap_id,
       TO_CHAR(MIN(begin_interval_time), ''YYYY-MM-DD HH24:MI'') begin_time,
       TO_CHAR(MIN(end_interval_time), ''YYYY-MM-DD HH24:MI'') end_time,
       SUM(num_cpus) num_cpus,
       ROUND(SUM(load), 1) load,
       ROUND(100 * SUM(idle_time_secs / num_cpus) / SUM(interval_secs), 1) idle_time_perc,
       ROUND(100 * SUM(busy_time_secs / num_cpus) / SUM(interval_secs), 1) busy_time_perc,
       ROUND(100 * SUM(user_time_secs / num_cpus) / SUM(interval_secs), 1) user_time_perc,
       ROUND(100 * SUM(nice_time_secs / num_cpus) / SUM(interval_secs), 1) nice_time_perc,
       ROUND(100 * SUM(sys_time_secs / num_cpus) / SUM(interval_secs), 1) sys_time_perc,
       ROUND(100 * SUM(os_cpu_wait_time_secs / num_cpus) / SUM(interval_secs), 1) os_cpu_wait_time_perc,
       ROUND(100 * SUM(rsrc_mgr_cpu_wait_time_secs / num_cpus) / SUM(interval_secs), 1) rsrc_mgr_cpu_wait_perc,
       ROUND(100 * SUM(iowait_time_secs / num_cpus) / SUM(interval_secs), 1) iowait_perc,
       ROUND(SUM(vm_in_bytes) / POWER(2, 30), 3) vm_in_gb,
       ROUND(SUM(vm_out_bytes) / POWER(2, 30), 3) vm_out_gb,
       0 dummy_13,
       0 dummy_14,
       0 dummy_15
  FROM osstat_delta
 GROUP BY
       snap_id
 ORDER BY
       snap_id
';
END;
/

DEF skip_lch = '';
@@tunas360_9a_pre_one.sql

/*******************************************/


SPO &&tunas360_main_report..html APP;
PRO </ol>
SPO OFF;
