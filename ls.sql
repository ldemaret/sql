----------------------------------------------------------------------------------------------------
-- Copyright (c) 2008-2017, Cernatis corp. All rights reserved.
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

set termout off
col spoolref new_value spoolref noprint
select '/tmp/sqlplus_settings'||abs(dbms_random.random) spoolref from dual;
STORE SET &spoolref REPLACE
set termout on

set lines 200 pages 100 ver off
col tbs_name heading TABLESPACE_NAME for a20
col file_name for a100
col file_id for 99999
col autoextensible heading AUTO for a4
col filesize heading SIZE for 999999999
col increment_size heading NEXT for 999999999
col maxsize for 999999999

select
    decode(type,'T','*','')||tablespace_name tbs_name,
    file_id,
    file_name,
    autoextensible,
    round(bytes/1024/1024,2) filesize,
    decode(autoextensible, 'YES', round(increment_by*block_size/1024/1024,2), null) increment_size,
    decode(autoextensible, 'YES', round(maxbytes/1024/1024,2), null) maxsize
from ( select 'D' type,
              d.tablespace_name,
              d.file_id,
              d.file_name,
              d.autoextensible,
              d.bytes,
              d.increment_by,
              tbs.block_size,
              d.maxbytes
       from dba_data_files d,
            dba_tablespaces tbs
       where d.tablespace_name = tbs.tablespace_name
             and upper(d.tablespace_name) like upper('%&1%')
       union all
       select 'T' type,
              t.tablespace_name,
              t.file_id,
              t.file_name,
              t.autoextensible,
              t.bytes,
              t.increment_by,
              tbs.block_size,
              t.maxbytes
       from dba_temp_files t,
            dba_tablespaces tbs
       where t.tablespace_name = tbs.tablespace_name
             and upper(t.tablespace_name) like upper('%&1%')
     )
order by
    type,
    tablespace_name,
    file_name
;

clear columns
undefine 1

@&spoolref
set termout on
host rm &spoolref..sql
undefine spoolref
