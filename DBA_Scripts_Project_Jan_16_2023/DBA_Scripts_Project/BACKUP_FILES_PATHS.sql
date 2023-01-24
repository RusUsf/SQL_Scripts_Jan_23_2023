SELECT physical_device_name, backup_start_date,
    backup_finish_date, left(round((backup_size/1024.0)/1024.0,4),5) AS BackupSizeMB
FROM msdb.dbo.backupset b
JOIN msdb.dbo.backupmediafamily m ON b.media_set_id = m.media_set_id
WHERE database_name = 'OnMedDBNew'
ORDER BY backup_finish_date DESC