SPO &&tunas360_main_report..html APP;
@@tunas360_0d_html_footer.sql
SPO OFF;

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- turing trace off
ALTER SESSION SET SQL_TRACE = FALSE;

-- tkprof for trace from execution of tool in case someone reports slow performance in tool, one of the two execs will fail
HOS tkprof &&tunas360_udump_path.*ora_&&tunas360_spid._&&tunas360_tracefile_identifier..trc &&tunas360_tkprof._sort.txt sort=prsela exeela fchela
HOS tkprof &&tunas360_diagtrace_path.*ora_&&tunas360_spid._&&tunas360_tracefile_identifier..trc &&tunas360_tkprof._sort.txt sort=prsela exeela fchela

PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-- readme
SPO 00000_readme_first.txt
PRO 1. Unzip &&tunas360_main_filename._&&tunas360_file_time..zip into a directory
PRO 2. Review &&tunas360_main_report..html
SPO OFF;

-- cleanup
SET HEA ON; 
SET LIN 80; 
SET NEWP 1; 
SET PAGES 14; 
SET LONG 80; 
SET LONGC 80; 
SET WRA ON; 
SET TRIMS OFF; 
SET TRIM OFF; 
SET TI OFF; 
SET TIMI OFF; 
SET ARRAY 15; 
SET NUM 10; 
SET NUMF ""; 
SET SQLBL OFF; 
SET BLO ON; 
SET RECSEP WR;
UNDEF 1 2 3 4 5 6

-- alert log (3 methods)
COL db_name_upper NEW_V db_name_upper;
COL db_name_lower NEW_V db_name_lower;
COL background_dump_dest NEW_V background_dump_dest;
SELECT UPPER(SYS_CONTEXT('USERENV', 'DB_NAME')) db_name_upper FROM DUAL;
SELECT LOWER(SYS_CONTEXT('USERENV', 'DB_NAME')) db_name_lower FROM DUAL;
SELECT value background_dump_dest FROM v$parameter WHERE name = 'background_dump_dest';
HOS cp &&background_dump_dest./alert_&&db_name_upper.*.log .
HOS cp &&background_dump_dest./alert_&&db_name_lower.*.log .
HOS cp &&background_dump_dest./alert_&&_connect_identifier..log .
HOS rename alert_ 00005_&&common_tunas360_prefix._alert_ alert_*.log

-- zip 
HOS zip -mq &&tunas360_main_filename._&&tunas360_file_time. &&common_tunas360_prefix._query.sql
HOS zip -dq &&tunas360_main_filename._&&tunas360_file_time. &&common_tunas360_prefix._query.sql
HOS zip -mq &&tunas360_main_filename._&&tunas360_file_time. 00005_&&common_tunas360_prefix._alert_*.log
HOS zip -mq &&tunas360_main_filename._&&tunas360_file_time. &&tunas360_log2..txt
HOS zip -mq &&tunas360_main_filename._&&tunas360_file_time. &&tunas360_tkprof._sort.txt
HOS zip -mq &&tunas360_main_filename._&&tunas360_file_time. &&tunas360_log..txt
HOS zip -mq &&tunas360_main_filename._&&tunas360_file_time. &&tunas360_main_report..html
HOS zip -mq &&tunas360_main_filename._&&tunas360_file_time. 00000_readme_first.txt 
HOS unzip -l &&tunas360_main_filename._&&tunas360_file_time.

SET TERM ON;
