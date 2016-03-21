DEF section_id = '5c';
DEF section_name = 'Temp Usage';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&tunas360_prefix.','&&section_id.');
SPO &&tunas360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;


DEF title = 'Current Temporary Usage';
DEF main_table = 'GV$SESSION';
BEGIN
  :sql_text := '
-- requested by Rodrigo Righetti
SELECT /*+ NO_MERGE */
       a.tablespace_name, 
       ROUND(a.avail_size_gb,1) avail_size_gb,
       ROUND(b.tot_gbbytes_cached,1) tot_gbbytes_cached ,
       ROUND(b.tot_gbbytes_used,1) tot_gbbytes_used,
       ROUND(100*(b.tot_gbbytes_cached/a.avail_size_gb),1) perc_cached,
       ROUND(100*(b.tot_gbbytes_used/a.avail_size_gb),1) perc_used
  FROM (SELECT tablespace_name,sum(bytes)/POWER(2,30) avail_size_gb
          FROM dba_temp_files
         GROUP BY tablespace_name) a,
       (SELECT tablespace_name,
               SUM(bytes_cached)/POWER(2,30) tot_gbbytes_cached,
               SUM(bytes_used)/POWER(2,30) tot_gbbytes_used
          FROM gv$temp_extent_pool
         GROUP BY tablespace_name) b
 WHERE a.tablespace_name = b.tablespace_name
';
END;
/
@sql/tunas360_9a_pre_one.sql


SPO &&tunas360_main_report..html APP;
PRO </ol>
SPO OFF;