/*****************************************************************************************
   
    TUNAs360 - Oracle Active Session(s) 360-degree View
    ASH-like session diagnostic without dependencies on Oracle Diagnostic Pack
    Copyright (C) 2016  Mauro Pagano

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

*****************************************************************************************/

PRO If TUNAs360 disconnects right after this message it means the user executing it
PRO owns a table called PLAN_TABLE that is not the Oracle seeded GTT plan table
PRO owned by SYS (PLAN_TABLE$ table with a PUBLIC synonym PLAN_TABLE).
PRO TUNAs360 requires the Oracle seeded PLAN_TABLE, consider dropping the one in this schema.

WHENEVER SQLERROR EXIT;
DECLARE
 is_plan_table_in_usr_schema NUMBER; 
BEGIN
 SELECT COUNT(*)
   INTO is_plan_table_in_usr_schema
   FROM user_tables
  WHERE table_name = 'PLAN_TABLE';

  -- user has a physical table called PLAN_TABLE, abort
  IF is_plan_table_in_usr_schema > 0 THEN
    RAISE_APPLICATION_ERROR(-20100, 'PLAN_TABLE physical table present in user schema. ');
  END IF;

END;
/
WHENEVER SQLERROR CONTINUE;

@sql/tunas360_main.sql