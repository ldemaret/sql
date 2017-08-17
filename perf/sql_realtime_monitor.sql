----------------------------------------------------------------------------------------------------
-- Copyright (c) 2011-2013, Cernatis corp. All rights reserved.
-- Author : Laurent DEMARET
-- Version : v1.02
--
-- Redistribution and use in source and binary forms, with or without modification, are permitted
-- provided that the following conditions are met:
--
--    1. Redistributions of source code must retain the above copyright notice, this list of
--       conditions and the following disclaimer.
--    2. Redistributions in binary form must reproduce the above copyright notice, this list
--       of conditions and the following disclaimer in the documentation and/or other materials
--       provided with the distribution.
--    3. Neither the name of Cernatis Corp nor the names of its contributors may be used to
--       endorse or promote products derived from this software without specific prior written
--       permission.
--
-- THIS SOFTWARE IS PROVIDED BY CERNATIS CORP AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
-- WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
-- FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL CERNATIS CORP OR CONTRIBUTORS BE
-- LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA,
-- OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
-- CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
-- OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
----------------------------------------------------------------------------------------------------
--
set termout off
col spoolref new_value spoolref noprint
select '/tmp/sqlplus_settings'||abs(dbms_random.random) spoolref from dual;
STORE SET &spoolref REPLACE
col p1 new_value 1
col p2 new_value 2
col p3 new_value 3
col p4 new_value 4
select null p1, null p2, null p3, null p4 from dual where 1=2;
select nvl('&1','%') p1 from dual;
select nvl('&2','%') p2 from dual;
select nvl('&3','%') p3 from dual;
select nvl('&4','EXEC') p4 from dual;
set termout on

set pages 100 lines 200 ver off
col key format 999999999999
col sql_exec_start for a20
col etime for 999999.9999
col cputime for 999999.9999
col iowait for 999999.9999
col otwait for 999999.9999
col gets for 999999999
col phr for 999999999
col status for a6

prompt Usage: @sql_realtime_monitor <sid> <session_serial#> <sql_id> <status>
prompt sid             => "&1"
prompt session_serial# => "&2"
prompt sql_id          => "&3"
prompt status          => "&4"
prompt

select sid,
       session_serial# serial#,
       sql_id,
       sql_exec_id,
       to_char(sql_exec_start,'YYYY-MON-DD HH24:MI:SS') sql_exec_start,
       sql_plan_hash_value plan_hash_value,
       elapsed_time/1000000 etime,
       cpu_time/1000000 cputime,
       user_io_wait_time/1000000 iowait,
       (concurrency_wait_time+cluster_wait_time+application_wait_time)/1000000 otwait,
       buffer_gets gets,
       disk_reads phr,
       px_server#,
       REGEXP_SUBSTR(status,'^[[:alpha:]]{4}') status
from gv$sql_monitor
where sid like '&1'
and session_serial# like '&2'
and sql_id like '&3'
and REGEXP_SUBSTR(status,'^[[:alpha:]]{4}') like '&4'
order by sql_exec_start, sid, serial#
/

clear columns

@&spoolref
set termout on
host rm &spoolref..sql
undefine spoolref
undef 1
undef 2
undef 3
undef 4
