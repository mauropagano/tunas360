DEF section_id = '5a';
DEF section_name = 'Top Objects - Details';
EXEC DBMS_APPLICATION_INFO.SET_MODULE('&&tunas360_prefix.','&&section_id.');
SPO &&tunas360_main_report..html APP;
PRO <h2>&&section_id.. &&section_name.</h2>
PRO <ol start="&&report_sequence.">
SPO OFF;

SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;

-- log
SPO &&tunas360_log..txt APP;
PRO
PRO ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
PRO
PRO &&hh_mm_ss.
PRO Extracting table list

VAR tables_list CLOB; 
VAR num_tables NUMBER;
EXEC :tables_list := NULL;
EXEC :num_tables := 0;

DECLARE
  l_pair VARCHAR2(32767);
BEGIN
  DBMS_LOB.CREATETEMPORARY(:tables_list, TRUE, DBMS_LOB.SESSION);
  FOR i IN (WITH object AS (
                 SELECT /*+ MATERIALIZE */
                        object_owner owner, object_name name
                   FROM gv$sql_plan
                  WHERE sql_id IN (SELECT sql_id 
                                     FROM (SELECT COUNT(*) num_samples, remarks sql_id
                                             FROM plan_table  
                                            WHERE statement_id = 'TUNAS360_DATA'
                                              AND remarks IS NOT NULL
                                            GROUP BY remarks
                                            ORDER BY 1 DESC) 
                                     WHERE ROWNUM <= &&tunas360_num_top_sqls_plan.)
                    AND object_owner IS NOT NULL
                    AND object_name IS NOT NULL
                  UNION
                 SELECT o.owner, o.object_name name
                   FROM (SELECT object_id 
                           FROM (SELECT COUNT(*) num_samples, object_instance object_id
                                   FROM plan_table
                                  WHERE statement_id = 'TUNAS360_DATA'
                                    AND object_instance > 0
                                  GROUP BY object_instance
                                  ORDER BY 1 DESC)
                           WHERE ROWNUM <= 15) top_o,
                        dba_objects o
                  WHERE o.object_id = top_o.object_id
                 )
         SELECT 'TABLE', o.owner, o.name table_name
           FROM dba_tables t,
                object o
          WHERE t.owner = o.owner
            AND t.table_name = o.name
          UNION
         SELECT 'TABLE', i.table_owner, i.table_name
           FROM dba_indexes i,
                object o
          WHERE i.owner = o.owner
            AND i.index_name = o.name)
  LOOP
    IF l_pair IS NULL THEN
      DBMS_LOB.WRITEAPPEND(:tables_list, 1, '(');
    ELSE
      DBMS_LOB.WRITEAPPEND(:tables_list, 1, ',');
    END IF;
    l_pair := '('''''||i.owner||''''','''''||i.table_name||''''')';
    DBMS_LOB.WRITEAPPEND(:tables_list, LENGTH(l_pair), l_pair);
    :num_tables := :num_tables + 1;
  END LOOP;

  IF l_pair IS NULL THEN
    l_pair := '((''''DUMMY'''',''''DUMMY''''))';
    DBMS_LOB.WRITEAPPEND(:tables_list, LENGTH(l_pair), l_pair);
  ELSE
    DBMS_LOB.WRITEAPPEND(:tables_list, 1, ')');
  END IF;

END;
/

COL tables_list NEW_V tables_list FOR A32767 NOPRI;
SELECT :tables_list tables_list FROM DUAL;

SELECT TO_CHAR(SYSDATE, 'HH24:MI:SS') hh_mm_ss FROM DUAL;  

PRO Done extracting table list
PRO &&hh_mm_ss.
SPO OFF


DEF title = 'Tables';
DEF main_table = 'DBA_TABLES';
BEGIN
  :sql_text := '
SELECT *
  FROM dba_tables
 WHERE (owner, table_name) in &&tables_list.
 ORDER BY owner, table_name
';
END;
/
@@tunas360_9a_pre_one.sql

DEF title = 'Indexes';
DEF main_table = 'DBA_INDEXES';
BEGIN
  :sql_text := '
SELECT *
  FROM dba_indexes
 WHERE (table_owner, table_name) in &&tables_list.
 ORDER BY table_owner, table_name, index_name
';
END;
/
@@tunas360_9a_pre_one.sql


DEF title = 'Index Columns';
DEF main_table = 'DBA_INDEXES';
BEGIN
  :sql_text := '
SELECT *
  FROM dba_ind_columns
 WHERE (table_owner, table_name) in &&tables_list.
 ORDER BY table_owner, table_name, index_name, column_position
';
END;
/
@@tunas360_9a_pre_one.sql

DEF title = 'Columns';
DEF main_table = 'DBA_TAB_COLS';
BEGIN
  :sql_text := '
SELECT *
  FROM dba_tab_cols 
 WHERE (owner, table_name) in &&tables_list.
 ORDER BY owner, table_name, column_id
';
END;
/
@@tunas360_9a_pre_one.sql


DEF title = 'Partition Key Columns';
DEF main_table = 'DBA_PART_KEY_COLUMNS';
BEGIN
  :sql_text := '
SELECT *
  FROM dba_part_key_columns
 WHERE (owner, name) in &&tables_list.
 ORDER BY owner, name, column_position
';
END;
/
@@tunas360_9a_pre_one.sql

DEF title = 'Table Partitions';
DEF main_table = 'DBA_TAB_PARTITIONS';
BEGIN
  :sql_text := '
SELECT *
  FROM dba_tab_partitions
 WHERE (table_owner, table_name) in &&tables_list.
 ORDER BY table_owner, table_name, partition_position
';
END;
/
@@tunas360_9a_pre_one.sql


SPO &&tunas360_main_report..html APP;
PRO </ol>
SPO OFF;