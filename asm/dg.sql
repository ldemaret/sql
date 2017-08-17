----------------------------------------------------------------------------------------------------
-- Copyright (c) 2011-2017, Cernatis corp. All rights reserved.
-- Author : Laurent DEMARET
-- Version : v1.04
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
select null p1 from dual where 1=2;
select nvl('&1','%') p1 from dual;
set termout on

set lines 234 pages 9999 ver off
col group_number for 999  head "Group"
col name         for a20  head "Group|Name"
col state        for a10  head "State"
col type         for a10  head "Diskgroup|Redundancy"
col size_display for a9   head "Total|Size" JUSTIFY RIGHT
col used_display for a9   head "Used|Size" JUSTIFY RIGHT
col free_display for a9   head "Avail|Size" JUSTIFY RIGHT
col used_pct     for a9   head "Percent|Used" JUSTIFY RIGHT
col imbalance    for 999.9 head "Percent|Imbalance"
col variance     for 999.9 head "Percent|Disk Size|Variance"
col minfree      for 999.9 head "Minimum|Percent|Free"
col maxfree      for 999.9 head "Maximum|Percent|Free"
col diskcnt      for 9999 head "Disk|Count"

prompt Usage: @asm/dg <search_cond>
prompt search_cond => "&1"
prompt
prompt ASM Disk Groups
prompt ===============

select * from (
select group_number
,      name
,      state
,      type
,      case
          when total_mb < 1024 then to_char(round(total_mb,2),'9999d99')||'M'
          when total_mb < 1024*1024 then to_char(round(total_mb/1024,2),'9999d99')||'G'
          when total_mb < 1024*1024*1024 then to_char(round(total_mb/1024/1024,2),'9999d99')||'T'
          when total_mb < 1024*1024*1024*1024 then to_char(round(total_mb/1024/1024/1024,2),'9999d99')||'P'
       end size_display
,      case
          when total_mb-usable_free_mb < 1024 then to_char(round(total_mb-usable_free_mb,2),'9999d99')||'M'
          when total_mb-usable_free_mb < 1024*1024 then to_char(round((total_mb-usable_free_mb)/1024,2),'9999d99')||'G'
          when total_mb-usable_free_mb < 1024*1024*1024 then to_char(round((total_mb-usable_free_mb)/1024/1024,2),'9999d99')||'T'
          when total_mb-usable_free_mb < 1024*1024*1024*1024 then to_char(round((total_mb-usable_free_mb)/1024/1024/1024,2),'9999d99')||'P'
       end used_display
,      case
          when usable_free_mb < 1024 then to_char(round(usable_free_mb,2),'9999d99')||'M'
          when usable_free_mb < 1024*1024 then to_char(round(usable_free_mb/1024,2),'9999d99')||'G'
          when usable_free_mb < 1024*1024*1024 then to_char(round(usable_free_mb/1024/1024,2),'9999d99')||'T'
          when usable_free_mb < 1024*1024*1024*1024 then to_char(round(usable_free_mb/1024/1024/1024,2),'9999d99')||'P'
       end free_display
,      to_char(round((total_mb-usable_free_mb)*100/decode(total_mb,0,1,total_mb),2),'9999d99')||'%' used_pct
,      imbalance
,      variance
,      minfree
,      maxfree
from (
   select /* EXTERNAL REDUNDANCY */
           g.group_number
   ,       g.name
   ,       g.state
   ,       g.type
   ,       sum(d.total_mb) / decode(g.type, 'EXTERN', 1, 'NORMAL', 2, 'HIGH', 3, 1) as total_mb
   ,       sum(d.total_mb) * min(d.free_mb / d.total_mb) / decode(g.type, 'EXTERN', 1, 'NORMAL', 2, 'HIGH', 3, 1) as usable_free_mb
   ,       100*(max((d.total_mb-d.free_mb)/d.total_mb)-min((d.total_mb-d.free_mb)/d.total_mb))/max((d.total_mb-d.free_mb)/d.total_mb) as imbalance
   ,       100*(max(d.total_mb)-min(d.total_mb))/max(d.total_mb) as variance
   ,       100*(min(d.free_mb/d.total_mb)) as minfree
   ,       100*(max(d.free_mb/d.total_mb)) as maxfree
   ,       count(*) as diskcnt
   from v$asm_disk d,
        v$asm_diskgroup g
   where d.group_number = g.group_number
   and   g.type = 'EXTERN'
   group by g.group_number, g.name, g.state, g.type
   union
   select /* NON EXTERNAL REDUNDANCY WITH SYMMETRIC FG */
           g.group_number
   ,       g.name
   ,       g.state
   ,       g.type
   ,       sum(d.total_mb) / decode(g.type, 'EXTERN', 1, 'NORMAL', 2, 'HIGH', 3, 1) as total_mb
   ,       sum(d.total_mb) * min(d.free_mb / d.total_mb) / decode(g.type, 'EXTERN', 1, 'NORMAL', 2, 'HIGH', 3, 1) as usable_free_mb
   ,       100*(max((d.total_mb-d.free_mb)/d.total_mb)-min((d.total_mb-d.free_mb)/d.total_mb))/max((d.total_mb-d.free_mb)/d.total_mb) as imbalance
   ,       100*(max(d.total_mb)-min(d.total_mb))/max(d.total_mb) as variance
   ,       100*(min(d.free_mb/d.total_mb)) as minfree
   ,       100*(max(d.free_mb/d.total_mb)) as maxfree
   ,       count(*) as diskcnt
   from v$asm_disk d,
        v$asm_diskgroup g
   where d.group_number = g.group_number
   and   g.group_number not in /* KEEP SYMMETRIC*/
                              (select distinct (group_number)
                               from (select group_number,
                                            failgroup,
                                            TOTAL_MB,
                                            count_dsk,
                                            greatest( lag(count_dsk, 1, 0) over(partition by TOTAL_MB, group_number order by TOTAL_MB,FAILGROUP),
                                                     lead(count_dsk, 1, 0) over(partition by TOTAL_MB, group_number order by TOTAL_MB,FAILGROUP)) as max_lag_lead,
                                            count(distinct(failgroup)) over(partition by group_number, TOTAL_MB) as nb_fg_per_size,
                                            count_fg
                                     from (select group_number,
                                                  failgroup,
                                                  TOTAL_MB,
                                                  count(*) over(partition by group_number, failgroup, TOTAL_MB) as count_dsk,
                                                  count(distinct(failgroup)) over(partition by group_number) as count_fg
                                           from v$asm_disk)
                                    )
                               where count_dsk <> max_lag_lead or nb_fg_per_size <> count_fg)
   and   g.type <> 'EXTERN'
   group by g.group_number, g.name, g.state, g.type
)
) where regexp_like(name, regexp_replace('&1', '%', '[[:graph:]]*'), 'i');

clear columns

@&spoolref
set termout on
host rm &spoolref..sql
undefine spoolref
undef 1
