
--Backup History
SELECT ISNULL(d.[name], bs.[database_name]) AS [Database], d.recovery_model_desc AS [Recovery Model], 
       d.log_reuse_wait_desc AS [Log Reuse Wait Desc],
    MAX(CASE WHEN [type] = 'D' THEN bs.backup_finish_date ELSE NULL END) AS [Last Full Backup],
    MAX(CASE WHEN [type] = 'I' THEN bs.backup_finish_date ELSE NULL END) AS [Last Differential Backup],
    MAX(CASE WHEN [type] = 'L' THEN bs.backup_finish_date ELSE NULL END) AS [Last Log Backup]
FROM sys.databases AS d WITH (NOLOCK)
LEFT OUTER JOIN msdb.dbo.backupset AS bs WITH (NOLOCK)
ON bs.[database_name] = d.[name] 
AND bs.backup_finish_date > GETDATE()- 30
WHERE d.name <> N'tempdb'
GROUP BY ISNULL(d.[name], bs.[database_name]), d.recovery_model_desc, d.log_reuse_wait_desc, d.[name] 
ORDER BY d.recovery_model_desc, d.[name] OPTION (RECOMPILE);

--T-Log Size
SELECT db.[name] AS [Database Name], SUSER_SNAME(db.owner_sid) AS [Database Owner], db.recovery_model_desc AS [Recovery Model], 
db.state_desc, db.containment_desc, db.log_reuse_wait_desc AS [Log Reuse Wait Description], 
CONVERT(DECIMAL(18,2), ls.cntr_value/1024.0) AS [Log Size (MB)], CONVERT(DECIMAL(18,2), lu.cntr_value/1024.0) AS [Log Used (MB)],
CAST(CAST(lu.cntr_value AS FLOAT) / CAST(ls.cntr_value AS FLOAT)AS DECIMAL(18,2)) * 100 AS [Log Used %], 
db.[compatibility_level] AS [DB Compatibility Level], 
db.is_mixed_page_allocation_on, db.page_verify_option_desc AS [Page Verify Option], 
db.is_auto_create_stats_on, db.is_auto_update_stats_on, db.is_auto_update_stats_async_on, db.is_parameterization_forced, 
db.snapshot_isolation_state_desc, db.is_read_committed_snapshot_on, db.is_auto_close_on, db.is_auto_shrink_on, 
db.target_recovery_time_in_seconds, db.is_cdc_enabled, db.is_published, db.is_distributor,
db.group_database_id, db.replica_id,db.is_memory_optimized_elevate_to_snapshot_on, 
db.delayed_durability_desc, db.is_auto_create_stats_incremental_on,
db.is_query_store_on, db.is_sync_with_backup, db.is_temporal_history_retention_enabled,
db.is_supplemental_logging_enabled, db.is_remote_data_archive_enabled,
db.is_encrypted, de.encryption_state, de.percent_complete, de.key_algorithm, de.key_length, db.resource_pool_id      
FROM sys.databases AS db WITH (NOLOCK)
INNER JOIN sys.dm_os_performance_counters AS lu WITH (NOLOCK)
ON db.name = lu.instance_name
INNER JOIN sys.dm_os_performance_counters AS ls WITH (NOLOCK)
ON db.name = ls.instance_name
LEFT OUTER JOIN sys.dm_database_encryption_keys AS de WITH (NOLOCK)
ON db.database_id = de.database_id
WHERE lu.counter_name LIKE N'Log File(s) Used Size (KB)%' 
AND ls.counter_name LIKE N'Log File(s) Size (KB)%'
AND ls.cntr_value > 0 
ORDER BY db.[name] OPTION (RECOMPILE);

-- Returns a list of all columns in current database
-- where the column's value is null for all records.
declare @tempTable TABLE
(
    TableSchema nvarchar(256),
    TableName nvarchar(256),
    ColumnName sysname,
    NotNullCnt bigint
);

declare @sql nvarchar(4000);
declare @tableSchema nvarchar(256);
declare @tableName nvarchar(256);
declare @columnName sysname;
declare @cnt bigint;

declare columnCursor cursor FOR
    SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
    WHERE IS_NULLABLE = 'YES';

open columnCursor;

fetch next FROM columnCursor INTO @tableSchema, @tableName, @columnName;

while @@FETCH_STATUS = 0
begin
    -- use dynamic sql to get count of records where column is not null
    SET @sql = 'select @cnt = COUNT(*) from [' + @tableSchema + '].[' + @tableName +
        '] where [' + @columnName + '] is not null';
    -- print @sql; --uncomment for debugging
    exec sp_executesql @sql, N'@cnt bigint output', @cnt = @cnt output;

    INSERT INTO @tempTable SELECT @tableSchema, @tableName, @columnName, @cnt;

    fetch next FROM columnCursor INTO @tableSchema, @tableName, @columnName;
end

close columnCursor;
deallocate columnCursor;

SELECT * FROM @tempTable WHERE NotNullCnt = 0;