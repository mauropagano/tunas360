-- setup
SET VER OFF; 
SET FEED OFF; 
SET ECHO OFF;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') tunas360_time_stamp FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SET HEA OFF;
SET TERM ON;

-- log
SPO &&tunas360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO &&hh_mm_ss.
PRO Sampling V$SESSION data at &&tunas360_sleep_time.s sampling interval, will take up to &&tunas360_max_time minutes.

DECLARE

  -- used to determine current status
  current_time DATE;
  rows_sampled NUMBER;

  -- used to determine when to stop the collection
  stop_time DATE;
  --max_rows_sampled NUMBER;

  -- used to distinguish samples since we don't have a TIMESTAMP column in PLAN_TABLE
  sample_id NUMBER;
BEGIN

   rows_sampled := 0;
   --max_rows_sampled := &&tunas360_max_rows;
   
   current_time := sysdate; 
   stop_time := sysdate+&&tunas360_max_time/1440;

   sample_id := 1;

   INSERT INTO plan_table (statement_id,   -- 'TUNAS360_SESSTAT_START'
                           position,       -- inst_id
                           object_node,    -- v$statname.name
                           partition_id    -- gv$sesstat.value
                           )
   SELECT 'TUNAS360_SYSSTAT_START', sstat.inst_id, sname.name, sstat.value
     FROM gv$sysstat sstat,
          v$statname sname
    WHERE sstat.statistic# = sname.statistic#;   

   INSERT INTO plan_table (statement_id,   -- 'TUNAS360_SESSTAT_START'
                           position,       -- inst_id
                           cpu_cost,       -- sid
                           io_cost,        -- serial#
                           object_node,    -- v$statname.name
                           partition_id    -- gv$sesstat.value
                           )
   SELECT 'TUNAS360_SESSTAT_START', ses.inst_id, ses.sid, ses.serial#, sname.name, sstat.value
     FROM gv$session ses,
          gv$sesstat sstat,
          v$statname sname
    WHERE ses.inst_id = sstat.inst_id 
      AND ses.sid = sstat.sid
      AND sstat.statistic# = sname.statistic#;
      --AND sstat.value <> 0;  -- capture all stats  

   INSERT INTO plan_table (statement_id,   -- 'TUNAS360_TIMEMODEL_START'
                           position,       -- inst_id
                           object_node,    -- stat_name
                           partition_id    -- value
                           )
   SELECT 'TUNAS360_TIMEMODEL_START', inst_id, stat_name, value
     FROM gv$sys_time_model;

   INSERT INTO plan_table (statement_id,   -- 'TUNAS360_SEGSTAT_START'
                           position,       -- inst_id
                           cpu_cost,       -- ts#
                           io_cost,        -- obj#
                           parent_id,      -- dataobj#
                           object_node,    -- statistic_name
                           partition_id    -- value
                           )
   SELECT 'TUNAS360_SEGSTAT_START', inst_id, ts#, obj#, dataobj#, statistic_name, value
     FROM gv$segstat sstat;      

   IF '&&tunas360_diag_license.' = 'Y' THEN

      INSERT INTO plan_table (statement_id,                                 -- 'TUNAS360_DATA'
                              parent_id,                                    -- sample_id
                              timestamp,                                    -- sysdate
                              position,                                     -- inst_id
                              cpu_cost,                                     -- sid,
                              io_cost,                                      -- serial#                            
                              remarks,                                      -- sql_id
                              object_node,                                  -- event                          
                              object_type,                                  -- username
                              object_owner,                                 -- program  --> need a long column
                              object_name,                                  -- module
                              object_alias,                                 -- service_name
                              cardinality,                                  -- wait_time
                              bytes,                                        -- seconds_in_wait
                              operation,                                    -- state
                              object_instance,                              -- row_wait_obj#
                              other_tag,                                     -- wait_class
                              &&skip_10g.partition_id,                       -- sql_exec_id
                              &&skip_10g.distribution,                       -- sql_exec_start
                              partition_start,                               -- seq#,p1text,p1,p2text,p2,p3text,p3,row_wait_file#,row_wait_block#, --row_wait_row#, --tm_delta_time, 
                              partition_stop                                    -- blocking_session_status, blocking_instance, blocking_session, final_blocking_session_status, final_blocking_instance, final_blocking_session   
                             )
       SELECT 'TUNAS360_DATA',
               sample_id,
               sample_time,
               inst_id,
               session_id,
               session_serial#,
               sql_id ,
               NVL(event,'ON CPU'),
               user_id,   -- different from V$SESSION.USERNAME
               substr(program,1,30),
               substr(module,1,30),
               sh.name, -- needs joining against v$active_services as ASH only has service_hash
               wait_time,
               NULL,
               &&skip_10g.session_state,  -- not equivalent to V$SESSION.STATE
               current_obj#,
               wait_class,
               &&skip_10g.sql_exec_id,
               &&skip_10g.TO_CHAR(sql_exec_start,'YYYYMMDDHH24MISS'),
               seq#||','||p1text||','||p1||','||p2text||','||p2||','||p3text||','||p3||','||current_file#||','||current_block#||
               ','||&&skip_10g.current_row#
               ,
               blocking_session_status||
               ','||&&skip_10g.&&skip_11r1.blocking_inst_id||
               ','||blocking_session||   -- need to add blocking_session_serial# for ASH, no need for V$SESSION
               ','||NULL||','||NULL||','||NULL 
         FROM gv$active_session_history, (SELECT DISTINCT name, name_hash FROM gv$active_services) sh
        WHERE sample_time >= systimestamp - ('&&tunas360_max_time.'/1440) 
          AND sh.name_hash = gv$active_session_history.service_hash; 

   ELSE  

     WHILE (rows_sampled < &&tunas360_max_rows. AND current_time < stop_time) LOOP
         
       
      INSERT INTO plan_table (statement_id,                                 -- 'TUNAS360_DATA'
                              parent_id,                                    -- sample_id
                              timestamp,                                    -- sysdate
                              position,                                     -- inst_id
                              cpu_cost,                                     -- sid,
                              io_cost,                                      -- serial#                            
                              remarks,                                      -- sql_id
                              object_node,                                  -- event                          
                              object_type,                                  -- username
                              object_owner,                                 -- program
                              object_name,                                  -- module
                              object_alias,                                 -- service_name
                              cardinality,                                  -- wait_time
                              bytes,                                        -- seconds_in_wait
                              operation,                                    -- state
                              --search_columns,                               -- 
                              --&&skip_10g.options,                           -- 
                              object_instance,                              -- row_wait_obj#
                              --cost,                                         -- 
                              other_tag,                                     -- wait_class
                              --&&skip_10g.id,                                 -- 
                              &&skip_10g.partition_id,                       -- sql_exec_id
                              &&skip_10g.distribution,                       -- sql_exec_start
                              partition_start,                               -- seq#,p1text,p1,p2text,p2,p3text,p3,row_wait_file#,row_wait_block#, --row_wait_row#, 
                              partition_stop                                 -- blocking_session_status, blocking_instance, blocking_session, final_blocking_session_status, final_blocking_instance, final_blocking_session   
                             )
       SELECT 'TUNAS360_DATA', 
              sample_id,
              sysdate, 
              inst_id, 
              sid, 
              serial#,
              sql_id, 
              CASE WHEN state LIKE 'WAITED%' THEN 'ON CPU' ELSE event END,
              username, 
              substr(program,1,30),
              substr(module,1,30),
              service_name,
              wait_time, 
              seconds_in_wait, 
              state,
              row_wait_obj#, 
              wait_class,
              &&skip_10g.sql_exec_id,
              &&skip_10g.TO_CHAR(sql_exec_start,'YYYYMMDDHH24MISS'),
              seq#||','||p1text||','||p1||','||p2text||','||p2||','||p3text||','||p3||','||row_wait_file#||','||row_wait_block#||
              ','||&&skip_10g.row_wait_row#
              ,
              blocking_session_status||','||blocking_instance||','||blocking_session||','||final_blocking_session_status||','||final_blocking_instance||','||final_blocking_session
         FROM gv$session
        WHERE status = 'ACTIVE'
          &&tunas360_skip_background.AND type <> 'BACKGROUND'
          AND wait_class <> 'Idle';
         
        rows_sampled := rows_sampled + SQL%ROWCOUNT;
        current_time := sysdate;
        sample_id := sample_id + 1;
           
        DBMS_LOCK.SLEEP(&&tunas360_sleep_time.);
               
     END LOOP;

   END IF;  

   INSERT INTO plan_table (statement_id,   -- 'TUNAS360_SESSTAT_START'
                           position,       -- inst_id
                           object_node,    -- v$statname.name
                           partition_id    -- gv$sesstat.value
                           )
   SELECT 'TUNAS360_SYSSTAT_STOP', sstat.inst_id, sname.name, sstat.value
     FROM gv$sysstat sstat,
          v$statname sname
    WHERE sstat.statistic# = sname.statistic#; 
           
   INSERT INTO plan_table (statement_id,   -- 'TUNAS360_SESSTAT_START'
                           position,       -- inst_id
                           cpu_cost,       -- sid
                           io_cost,        -- serial#
                           object_node,    -- v$statname.name
                           partition_id    -- gv$sesstat.value
                           )
   SELECT 'TUNAS360_SESSTAT_STOP', ses.inst_id, ses.sid, ses.serial#, sname.name, sstat.value
     FROM gv$session ses,
          gv$sesstat sstat,
          v$statname sname
    WHERE ses.inst_id = sstat.inst_id 
      AND ses.sid = sstat.sid
      AND sstat.statistic# = sname.statistic#;
      --AND sstat.value <> 0;  -- capture all stats  

   INSERT INTO plan_table (statement_id,   -- 'TUNAS360_TIMEMODEL_START'
                           position,       -- inst_id
                           object_node,    -- stat_name
                           partition_id    -- value
                           )
   SELECT 'TUNAS360_TIMEMODEL_STOP', inst_id, stat_name, value
     FROM gv$sys_time_model;

   INSERT INTO plan_table (statement_id,   -- 'TUNAS360_SEGSTAT_START'
                           position,       -- inst_id
                           cpu_cost,       -- ts#
                           io_cost,        -- obj#
                           parent_id,      -- dataobj#
                           object_node,    -- statistic_name
                           partition_id    -- value
                           )
   SELECT 'TUNAS360_SEGSTAT_STOP', inst_id, ts#, obj#, dataobj#, statistic_name, value
     FROM gv$segstat sstat; 
  
END;
/

SELECT COUNT(*)||' rows extracted.' FROM plan_table WHERE statement_id LIKE 'TUNAS360%';  
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD/HH24:MI:SS') tunas360_time_stamp FROM DUAL;
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL; 

COL min_sample_time NEW_V min_sample_time
COL max_sample_time NEW_V max_sample_time
SELECT TO_CHAR(MIN(timestamp),'YYYYMMDDHH24MISS') min_sample_time, TO_CHAR(MAX(timestamp),'YYYYMMDDHH24MISS') max_sample_time FROM plan_table WHERE statement_id = 'TUNAS360_DATA'; 

PRO Done sampling V$SESSION data
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
SPO OFF