-- add seq to one_spool_filename
EXEC :file_seq := :file_seq + 1;
SELECT LPAD(:file_seq, 5, '0')||'_&&spool_filename.' one_spool_filename FROM DUAL;

-- display
SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;
SET TERM ON;
SPO &&tunas360_log..txt APP;
PRO &&hh_mm_ss. col:&&column_number.of&&max_col_number. "&&one_spool_filename..txt"
SPO OFF;
SET TERM OFF;

-- update main report
SPO &&tunas360_main_report..html APP;
PRO <a href="&&one_spool_filename..txt">text</a>
SPO OFF;

-- get time t0
EXEC :get_time_t0 := DBMS_UTILITY.get_time;

-- get sql
GET &&common_tunas360_prefix._query.sql

-- header
SPO &&one_spool_filename..txt;
PRO &&section_id..&&report_sequence.. &&title.&&title_suffix. (&&main_table.) 
PRO
PRO &&abstract.
PRO &&abstract2.
PRO

-- added to make the plan easier to read
SET HEA OFF;
COL ROW_NUM NOPRI
-- body
/
COL ROW_NUM PRI

-- footer
PRO &&foot.
SET LIN 80;
--DESC &&main_table.
SET HEA OFF;
SET LIN 32767;
--PRINT sql_text_display;
SET HEA ON;
--PRO &&row_num. rows selected.

PRO 
--PRO &&tunas360_prefix.&&tunas360_copyright. Version &&tunas360_vrsn.. Report executed on &&tunas360_time_stamp. for database &&db_version. dbmod &&tunas360_dbmod. from host &&host_hash..
SPO OFF;

-- get time t1
EXEC :get_time_t1 := DBMS_UTILITY.get_time;

-- update log2
SET HEA OFF;
SPO &&tunas360_log2..txt APP;
SELECT TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS')||' , '||
       TO_CHAR((:get_time_t1 - :get_time_t0)/100, '999999990.00')||' , '||
       '&&row_num. , &&main_table. , &&title_no_spaces., text , &&one_spool_filename..txt'
  FROM DUAL
/
SPO OFF;
SET HEA ON;

-- zip
HOS zip -mq &&tunas360_main_filename._&&tunas360_file_time. &&one_spool_filename..txt
