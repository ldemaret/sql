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

col parameter for a25
col value for a25
col order_col noprint
select decode( parameter, 'NLS_LANGUAGE', 1, 'NLS_TERRITORY', 2, 'NLS_CHARACTERSET', 3, 'NLS_NCHAR_CHARACTERSET', 4 ) order_col,
parameter,value from v$nls_parameters where parameter in ('NLS_CHARACTERSET','NLS_NCHAR_CHARACTERSET','NLS_LANGUAGE','NLS_TERRITORY')
order by 1;

@&spoolref
set termout on
host rm &spoolref..sql
