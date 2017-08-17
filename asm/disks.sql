----------------------------------------------------------------------------------------------------
-- Copyright (c) 2011-2017, Cernatis corp. All rights reserved.
-- Author : Laurent DEMARET
-- Version : v1.03
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
select '/tmp/sqlplus_settings'||to_char(SYSTIMESTAMP,'FF') spoolref from dual;
STORE SET &spoolref REPLACE
col p1 new_value 1
col p2 new_value 2
select null p1, null p2 from dual where 1=2;
select nvl('&1','%') p1 from dual;
select nvl('&2','%') p2 from dual;
set termout on


set lines 237
set pages 1000
set ver off
col diskgroup for a20
col disk for 9999
col disk_name for a23
col failgroup for a23
col mount_status for a12
col header_status for a13
col mode_status for a11
col state for a8
col path for a64
col size_display for a9 head "SIZE" JUSTIFY RIGHT
col used_display for a9 head "USED" JUSTIFY RIGHT
col free_display for a9 head "AVAIL" JUSTIFY RIGHT
col used_pct for a9 head "USE%" JUSTIFY RIGHT

prompt Usage: @asm/disk <search_cond> <header_status>
prompt search_cond => "&1"
prompt search_cond => "&2"
prompt


select dg.name diskgroup,
       d.disk_number disk,
       d.name disk_name,
       d.failgroup,
       d.mount_status,
       d.header_status,
       d.mode_status,
       d.state,
       d.path,
       case
          when decode(d.header_status,'MEMBER',d.total_mb,d.os_mb) < 1024 then to_char(round(decode(d.header_status,'MEMBER',d.total_mb,d.os_mb),2),'9999d99')||'M'
          when decode(d.header_status,'MEMBER',d.total_mb,d.os_mb) < 1024*1024 then to_char(round(decode(d.header_status,'MEMBER',d.total_mb,d.os_mb)/1024,2),'9999d99')||'G'
          when decode(d.header_status,'MEMBER',d.total_mb,d.os_mb) < 1024*1024*1024 then to_char(round(decode(d.header_status,'MEMBER',d.total_mb,d.os_mb)/1024/1024,2),'9999d99')||'T'
          when decode(d.header_status,'MEMBER',d.total_mb,d.os_mb) < 1024*1024*1024*1024 then to_char(round(decode(d.header_status,'MEMBER',d.total_mb,d.os_mb)/1024/1024/1024,2),'9999d99')||'P'
       end size_display,
       case
          when d.total_mb-d.free_mb < 1024 then to_char(round(d.total_mb-d.free_mb,2),'9999d99')||'M'
          when d.total_mb-d.free_mb < 1024*1024 then to_char(round((d.total_mb-d.free_mb)/1024,2),'9999d99')||'G'
          when d.total_mb-d.free_mb < 1024*1024*1024 then to_char(round((d.total_mb-d.free_mb)/1024/1024,2),'9999d99')||'T'
          when d.total_mb-d.free_mb < 1024*1024*1024*1024 then to_char(round((d.total_mb-d.free_mb)/1024/1024/1024,2),'9999d99')||'P'
       end used_display,
       case
          when d.free_mb < 1024 then to_char(round(d.free_mb,2),'9999d99')||'M'
          when d.free_mb < 1024*1024 then to_char(round(d.free_mb/1024,2),'9999d99')||'G'
          when d.free_mb < 1024*1024*1024 then to_char(round(d.free_mb/1024/1024,2),'9999d99')||'T'
          when d.free_mb < 1024*1024*1024*1024 then to_char(round(d.free_mb/1024/1024/1024,2),'9999d99')||'P'
       end free_display,
       -- dbms_rcvman.num2displaysize doesn't work in asm instance
       -- sys.dbms_rcvman.num2displaysize(d.total_mb*1024*1024) size_display,
       -- sys.dbms_rcvman.num2displaysize(d.total_mb-d.free_mb*1024*1024) used_display,
       -- sys.dbms_rcvman.num2displaysize(d.free_mb*1024*1024) free_display,
       to_char(round((d.total_mb-d.free_mb)*100/decode(d.total_mb,0,1,d.total_mb),2),'9999d99')||'%' used_pct,
       d.preferred_read
from v$asm_disk d left outer join v$asm_diskgroup dg on d.group_number = dg.group_number and d.group_number <> 0
where
regexp_like(header_status, regexp_replace('&2', '&2', case when lower('&2')='free' then 'CANDIDATE|FORMER'
                                                           when lower('&2')='candidate' then 'CANDIDATE'
                                                           when lower('&2')='former' then 'FORMER'
                                                           when lower('&2')='member' then 'MEMBER'
                                                           else '[[:graph:]]*'
                                                       end))
and (regexp_like(d.path, regexp_replace('&1', '%', '[[:graph:]]*'), 'i')
or regexp_like(dg.name, regexp_replace('&1', '%', '[[:graph:]]*'), 'i')
)
order by dg.name,d.header_status,reverse(d.path);
--regexp_like(header_status, regexp_replace('&1', 'free', 'CANDIDATE|FORMER', 1, 0, 'i'))


clear columns

@&spoolref
set termout on
host rm &spoolref..sql
undefine spoolref
undef 1
undef 2
