--select table_catalog as DbName,table_name,column_name from INFORMATION_SCHEMA.columns 

--Database Inventory Sheet
--Server Name
select @@servername

--Instance Name
select @@servicename

--SQL Server Version
select @@version 
select serverproperty('ProductVersion') as ProductVersion

--SQL Instance Install Date
SELECT 
@@SERVERNAME AS Server_Name, 
create_date AS SQL_Server_Install_Date
FROM sys.server_principals WITH (NOLOCK)
WHERE name = N'NT AUTHORITY\SYSTEM'
OR name = N'NT AUTHORITY\NETWORK SERVICE';

--Authentication Method of the Connection
SELECT net_transport, auth_scheme   
FROM sys.dm_exec_connections   
WHERE session_id = @@SPID;

--Used by (application name)
select app_name()

--Authentication Mode CHECK
EXEC master.sys.xp_loginconfig 'login mode'  

--To Change Authentication Mode (1 - Windows Only; 2 - Mixed)
USE [master]
GO
EXEC xp_instance_regwrite N'HKEY_LOCAL_MACHINE', 
     N'Software\Microsoft\MSSQLServer\MSSQLServer',
     N'LoginMode', REG_DWORD, 2
GO

--Multi/Single User Check
SELECT DATABASEPROPERTYEX('OnMedDBNew','UserAccess') 
                      AS 'Current Database Access Mode'

--Roles & Principals; User name & Role
select r.name as Role,m.name as Principal
from master.sys.server_role_members rm
join master.sys.server_principals r on r.principal_id=rm.role_principal_id and r.type='R'
join master.sys.server_principals m on m.principal_id=rm.member_principal_id

--Recovery Model
select name, recovery_model_desc from sys.databases where name like 'OnMedDBNew'

--Size of Database LOG FILE ***
dbcc sqlperf(logspace)

--Database Size

use DatabaseName;
exec sp_spaceused

--Size of the DB
exec sp_databases

--Size of the DATABASE
SELECT
    d.name AS 'Database',
    m.name AS 'File',
    m.size,
    m.size * 8/1024 'Size (MB)',
    SUM(m.size * 8/1024) OVER (PARTITION BY d.name) AS 'Database Total',
    m.max_size
FROM sys.master_files m
INNER JOIN sys.databases d ON
d.database_id = m.database_id;

--SP_WHO2 Filtered returns users in the Database
DECLARE @DatabaseName nvarchar(250)
SET @DatabaseName = 'OnMedDBNew'
CREATE TABLE #sp_who2 (SPID INT,Status VARCHAR(255),
      Login  VARCHAR(255),HostName  VARCHAR(255),
      BlkBy  VARCHAR(255),DBName  VARCHAR(255),
      Command VARCHAR(255),CPUTime INT,
      DiskIO INT,LastBatch VARCHAR(255),
      ProgramName VARCHAR(255),SPID2 INT,
      REQUESTID INT)
INSERT INTO #sp_who2 EXEC sp_who2
SELECT      *
FROM        #sp_who2
-- Add any filtering of the results here :
WHERE       DBName = @DatabaseName
-- Add any sorting of the results here :
ORDER BY    DBName ASC
DROP TABLE #sp_who2
--END of SP_WHO2 script

--Integrity Check
DBCC CHECKDB (OnMedDBNew,NOINDEX)

--Query to find size of all individual databases on SQL Server
with fs
as
(
    select database_id, type,size * 8.0 / 1024 size
    from sys.master_files
)
select
    name,
    (select sum(size) from fs where type = 0 and fs.database_id = db.database_id) DataFileSizeInMB,
    (select sum(size) from fs where type = 1 and fs.database_id = db.database_id) LogFileSizeInMB
from sys.databases db

--MDF and LDF Paths
select d.name DatabaseName, 
f.name LogicalName, f.physical_name as PhysicalName,
f.type_desc TypeofFile
from sys.master_files f
join sys.databases d on d.database_id=f.database_id;
go


--DEFAULT MDF and LDF LOCATION
select serverproperty ('InstanceDefaultDataPath') as Default_Data_Path
,serverproperty('InstanceDefaultLogPath') as Default_log_path;
go
--DEFAULT BACKUP LOCATION
EXEC  master.dbo.xp_instance_regread  
 N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer',N'BackupDirectory';
 go


 --One Script All Info above
 SELECT  
    SERVERPROPERTY('ServerName') AS ServerName,  
    SERVERPROPERTY('MachineName') AS MachineName,
    CASE 
        WHEN  SERVERPROPERTY('InstanceName') IS NULL THEN ''
        ELSE SERVERPROPERTY('InstanceName')
    END AS InstanceName,
    '' as Port, --need to update to strip from Servername. Note: Assumes Registered Server is named with Port
    SUBSTRING ( (SELECT @@VERSION),1, CHARINDEX('-',(SELECT @@VERSION))-1 ) as ProductName,
    SERVERPROPERTY('ProductVersion') AS ProductVersion,  
    SERVERPROPERTY('ProductLevel') AS ProductLevel,
    SERVERPROPERTY('ProductMajorVersion') AS ProductMajorVersion,
    SERVERPROPERTY('ProductMinorVersion') AS ProductMinorVersion,
    SERVERPROPERTY('ProductBuild') AS ProductBuild,
    SERVERPROPERTY('Edition') AS Edition,
    CASE SERVERPROPERTY('EngineEdition')
        WHEN 1 THEN 'PERSONAL'
        WHEN 2 THEN 'STANDARD'
        WHEN 3 THEN 'ENTERPRISE'
        WHEN 4 THEN 'EXPRESS'
        WHEN 5 THEN 'SQL DATABASE'
        WHEN 6 THEN 'SQL DATAWAREHOUSE'
    END AS EngineEdition,  
    CASE SERVERPROPERTY('IsHadrEnabled')
        WHEN 0 THEN 'The Always On Availability Groups feature is disabled'
        WHEN 1 THEN 'The Always On Availability Groups feature is enabled'
        ELSE 'Not applicable'
    END AS HadrEnabled,
    CASE SERVERPROPERTY('HadrManagerStatus')
        WHEN 0 THEN 'Not started, pending communication'
        WHEN 1 THEN 'Started and running'
        WHEN 2 THEN 'Not started and failed'
        ELSE 'Not applicable'
    END AS HadrManagerStatus,
    CASE SERVERPROPERTY('IsSingleUser') WHEN 0 THEN 'No' ELSE 'Yes' END AS InSingleUserMode,
    CASE SERVERPROPERTY('IsClustered')
        WHEN 1 THEN 'Clustered'
        WHEN 0 THEN 'Not Clustered'
        ELSE 'Not applicable'
    END AS IsClustered,
    '' as ServerEnvironment,
    '' as ServerStatus,
    '' as Comments

--DATABASE BACKUP HISTORY
SELECT	
  DISTINCT
        a.Name AS DatabaseName ,
        CONVERT(SYSNAME, DATABASEPROPERTYEX(a.name, 'Recovery')) RecoveryModel ,
        COALESCE(( SELECT   CONVERT(VARCHAR(12), MAX(backup_finish_date), 101)
                   FROM     msdb.dbo.backupset
                   WHERE    database_name = a.name
                            AND type = 'D'
                            AND is_copy_only = '0'
                 ), 'No Full') AS 'Full' ,
        COALESCE(( SELECT   CONVERT(VARCHAR(12), MAX(backup_finish_date), 101)
                   FROM     msdb.dbo.backupset
                   WHERE    database_name = a.name
                            AND type = 'I'
                            AND is_copy_only = '0'
                 ), 'No Diff') AS 'Diff' ,
        COALESCE(( SELECT   CONVERT(VARCHAR(20), MAX(backup_finish_date), 120)
                   FROM     msdb.dbo.backupset
                   WHERE    database_name = a.name
                            AND type = 'L'
                 ), 'No Log') AS 'LastLog' ,
        COALESCE(( SELECT   CONVERT(VARCHAR(20), backup_finish_date, 120)
                   FROM     ( SELECT    ROW_NUMBER() OVER ( ORDER BY backup_finish_date DESC ) AS 'rownum' ,
                                        backup_finish_date
                              FROM      msdb.dbo.backupset
                              WHERE     database_name = a.name
                                        AND type = 'L'
                            ) withrownum
                   WHERE    rownum = 2
                 ), 'No Log') AS 'LastLog2'
FROM    sys.databases a
        LEFT OUTER JOIN msdb.dbo.backupset b ON b.database_name = a.name
WHERE   a.name <> 'tempdb'
        AND a.state_desc = 'online'
GROUP BY a.Name ,
        a.compatibility_level
ORDER BY a.name

--DATABASE HISTORY BACKUP FILE PATHS
--Clear backup history just in case I have ran this demo before.

--USE MSDB;
--GO
--DECLARE @DATE DATETIME
--SET @DATE = GETDATE()+1
--EXEC SP_DELETE_BACKUPHISTORY @DATE;
--GO


-- Get Backup History - SIZE OF THE BACKUP (MB)
DECLARE @db_name VARCHAR(100)
SELECT @db_name = 'OnMedDBNew'
-- Get Backup History
SELECT TOP (30) s.database_name, s.name, s.description
,m.physical_device_name
,CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkSize
,CAST(DATEDIFF(second, s.backup_start_date, s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' TimeTaken
,s.backup_start_date
,CAST(s.first_lsn AS VARCHAR(50)) AS first_lsn
,CAST(s.last_lsn AS VARCHAR(50)) AS last_lsn
,CASE s.[type] WHEN 'D'
THEN 'Full'
WHEN 'I'
THEN 'Differential'
WHEN 'L'
THEN 'Transaction Log'
END AS BackupType
,s.server_name
,s.recovery_model
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE s.database_name = @db_name
ORDER BY backup_start_date DESC
,backup_finish_date


--Last Restore Date & Time
declare @DB sysname = 'OnMedDBNew';
select * from msdb.dbo.restorehistory where destination_database_name = @DB order by 2 desc;

--SQL AGENT JOBS - HISTORY
--SQL Server Agent Job Steps Execution Information
SELECT
    --[sJOB].[job_id] AS [JobIKD],
     [sJOB].[name] AS [JobName]
    --, [sJSTP].[step_uid] AS [StepID]
    --, [sJSTP].[step_id] AS [StepNo]
    , [sJSTP].[step_name] AS [StepName]
    , CASE [sJSTP].[last_run_outcome]
        WHEN 0 THEN 'Failed'
        WHEN 1 THEN 'Succeeded'
        WHEN 2 THEN 'Retry'
        WHEN 3 THEN 'Canceled'
        WHEN 5 THEN 'Unknown'
      END AS [LastRunStatus]
    , STUFF(
            STUFF(RIGHT('000000' + CAST([sJSTP].[last_run_duration] AS VARCHAR(6)),  6)
                , 3, 0, ':')
            , 6, 0, ':')
      AS [LastRunDuration (HH:MM:SS)]
    --, [sJSTP].[last_run_retries] AS [LastRunRetryAttempts]
    , CASE [sJSTP].[last_run_date]
        WHEN 0 THEN NULL
        ELSE 
            CAST(
                CAST([sJSTP].[last_run_date] AS CHAR(8))
                + ' ' 
                + STUFF(
                    STUFF(RIGHT('000000' + CAST([sJSTP].[last_run_time] AS VARCHAR(6)),  6)
                        , 3, 0, ':')
                    , 6, 0, ':')
                AS DATETIME)
      END AS [LastRunDateTime]
FROM
    [msdb].[dbo].[sysjobsteps] AS [sJSTP]
    INNER JOIN [msdb].[dbo].[sysjobs] AS [sJOB]
        ON [sJSTP].[job_id] = [sJOB].[job_id]
WHERE [sJOB].[name] not in ('syspolicy_purge_history')
ORDER BY [JobName]
--, [StepNo]


--Last Executed Query

SELECT
    deqs.last_execution_time AS [Time], 
    dest.TEXT AS [Query]
 FROM 
    sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
ORDER BY 
    deqs.last_execution_time DESC