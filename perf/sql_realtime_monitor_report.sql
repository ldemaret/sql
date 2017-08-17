----------------------------------------------------------------------------------------------------
-- Copyright (c) 2011-2013, Cernatis corp. All rights reserved.
-- Author : Laurent DEMARET
-- Version : v1.00
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
select null p1, null p2, null p3 from dual where 1=2;
select nvl('&1','is mandatory') p1 from dual;
select nvl('&2','is mandatory') p2 from dual;
select nvl('&3','is mandatory') p3 from dual;
set termout on

set pages 0 lines 500 feed off ver off long 2000000000
col report for a500 word_wrapped

prompt Usage: @sql_realtime_monitor_report <sql_id> <sql_exec_id> <sql_exec_start>
prompt sql_id         => "&1"
prompt sql_exec_id    => "&2"
prompt sql_exec_start => "&3"
prompt


select dbms_sqltune.report_sql_monitor(
   sql_id         => '&1',
   sql_exec_id    => '&2',
   sql_exec_start => to_date('&3','YYYY-MON-DD HH24:MI:SS'),
   event_detail   => 'YES',
   report_level   => 'ALL',
   type           => 'TEXT') as report
from dual;

clear columns

@&spoolref
set termout on
host rm &spoolref..sql
undefine spoolref
undef 1
undef 2
undef 3
