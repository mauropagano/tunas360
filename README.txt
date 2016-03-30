TUNAs360 v1604 (2016-03-30) by Mauro Pagano

TUNAs360 is a "free to use" tool to perform an initial assessment of an Oracle database. 
It collects several information about the database workload. It also helps to document any findings.
TUNAs360 installs nothing and doesn't rely on any Oracle licensed option (i.e. Diagnostic Pack). 
For better results execute connected as SYS or DBA.
It takes a few minutes to execute. Output ZIP file can be large (several MBs), so
you may want to execute TUNAs360 from a system directory with at least 1 GB of free 
space. 

Steps
~~~~~
1. Unzip tunas360-master.zip, navigate to the root tunas360 directory, and connect as SYS, 
   DBA, or any User with Data Dictionary access:

   $ unzip tunas360-master.zip
   $ cd tunas360-master
   $ sqlplus dba_user/dba_pwd

2. Execute tunas360.sql passing no parameters. TUNAs360 will observe the workload for a few minutes
   and it will then report on such workload

   SQL> @tunas360.sql  
   
3. Unzip output tunas360_<dbname>_<host>_YYYYMMDD_HH24MI.zip into a directory on your PC

4. Review main html file 0001_tunas360_<dbname>_index.html

****************************************************************************************
   
    TUNAs360 - (TUN)ing with (A)ctive (s)essions
    Copyright (C) 2015  Mauro Pagano

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
