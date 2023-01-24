--Clear backup history just in case I have ran this demo before.

--USE MSDB;
--GO
--DECLARE @DATE DATETIME
--SET @DATE = GETDATE()+1
--EXEC SP_DELETE_BACKUPHISTORY @DATE;
--GO


--Backup History
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

--SQL AGENT JOBS
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