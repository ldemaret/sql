----------------------------------------------------------------------------------------------------
-- Copyright (c) 2008, Cernatis corp. All rights reserved.
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

set termout off
col spoolref new_value spoolref noprint
select '/tmp/sqlplus_settings'||abs(dbms_random.random) spoolref from dual;
STORE SET &spoolref REPLACE
set termout on

set lines 160 pages 1000

column username format a25 trunc heading SCHEMA
column ta format 99999 heading TABLE
column ix format 99999 heading INDEX
column vi format 99999 heading VIEWS
column mv format 99999 heading MVIEW
column se format 99999 heading SEQS
column pl format 99999 heading PLSQL
column ja format 99999 heading JAVA
column tr format 99999 heading TRIGS
column cl format 99999 heading CLSTR
column lo format 99999 heading LOBS
column ty format 99999 heading TYPES
column di format 99999 heading DIRS
column pa format 99999 heading PARTI
column sy format 99999 heading SYNYM
column dl format 99999 heading DBLNK
column ot format 99999 heading OTHER

break on report
compute sum of ta ix vi mv se pl ja tr cl lo ty di pa sy dl ot on report

select u.username,
sum(decode(o.object_type, 'TABLE', o.nbr))              ta,
sum(decode(o.object_type, 'INDEX', o.nbr))              ix,
sum(decode(o.object_type, 'VIEW', o.nbr))               vi,
sum(decode(o.object_type, 'MATERIALIZED VIEW', o.nbr))  mv,
sum(decode(o.object_type, 'SEQUENCE', o.nbr))           se,
sum(decode(o.object_type, 'PLSQL', o.nbr))              pl,
sum(decode(o.object_type, 'JAVA', o.nbr))               ja,
sum(decode(o.object_type, 'TRIGGER', o.nbr))            tr,
sum(decode(o.object_type, 'CLUSTER', o.nbr))            cl,
sum(decode(o.object_type, 'LOB', o.nbr))                lo,
sum(decode(o.object_type, 'TYPE', o.nbr))               ty,
sum(decode(o.object_type, 'DIRECTORY', o.nbr))          di,
sum(decode(o.object_type, 'PARTITION', o.nbr))          pa,
sum(decode(o.object_type, 'SYNONYM', o.nbr))            sy,
sum(decode(o.object_type, 'DATABASE LINK', o.nbr))      dl,
sum(decode(o.object_type, 'TABLE', NULL,
                          'INDEX', NULL,
                          'VIEW', NULL,
                          'MATERIALIZED VIEW', NULL,
                          'SEQUENCE', NULL,
                          'PLSQL', NULL,
                          'JAVA', NULL,
                          'TRIGGER', NULL,
                          'CLUSTER', NULL,
                          'LOB', NULL,
                          'TYPE', NULL,
                          'DIRECTORY', NULL,
                          'PARTITION', NULL,
                          'SYNONYM', NULL,
                          'DATABASE LINK', NULL,
                          o.nbr))                       ot
from
   (select owner,
           decode (object_type,
                   'FUNCTION', 'PLSQL',
                   'PROCEDURE', 'PLSQL',
                   'PACKAGE','PLSQL',
                   'PACKAGE BODY','PLSQL',
                   'JAVA DATA','JAVA',
                   'JAVA CLASS','JAVA',
                   'JAVA RESOURCE','JAVA',
                   'JAVA SOURCE','JAVA',
                   'TABLE PARTITION','PARTITION',
                   'INDEX PARTITION','PARTITION',
                   'LOB PARTITION','PARTITION',
                   'TYPE','TYPE',
                   'TYPE BODY','TYPE',
                   object_type) object_type,
           count(*) nbr
    from dba_objects
    group by owner, object_type
   ) o,
   dba_users u
where u.username = o.owner
and u.username not in
     ('XS$NULL', 'ORACLE_OCM', 'OJVMSYS', 'SYSKM', 'GSMCATUSER', 'MDDATA', 'SYSBACKUP', 'DIP', 'SYSDG', 'APEX_PUBLIC_USER', 'SPATIAL_CSW_ADMIN_USR', 'SYS', 'SPATIAL_WFS_ADMIN_USR',
      'GSMUSER', 'AUDSYS', 'PDBADMIN', 'FLOWS_FILES', 'DVF', 'MDSYS', 'ORDSYS', 'DBSNMP', 'WMSYS', 'APEX_040200', 'APPQOSSYS', 'GSMADMIN_INTERNAL', 'ORDDATA', 'CTXSYS', 'ANONYMOUS',
      'XDB', 'ORDPLUGINS', 'DVSYS', 'SI_INFORMTN_SCHEMA', 'OLAPSYS', 'LBACSYS', 'OUTLN', 'SYSTEM', 'DEVOPS_PROXY_SU_USER', 'DBA_PROXY_SU_USER')
group by u.username
order by 1
/

clear columns breaks computes


@&spoolref
set termout on
host rm &spoolref..sql
undefine spoolref
