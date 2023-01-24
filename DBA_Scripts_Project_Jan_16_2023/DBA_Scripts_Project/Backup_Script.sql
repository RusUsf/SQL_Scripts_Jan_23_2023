BACKUP DATABASE [AdventureWorks2012] 
TO  DISK = N'<location\filename here>'
WITH NOFORMAT,
     		INIT,
     		NAME = N'AdventureWorks2012-Full Database Backup',
     		SKIP,
     		NOREWIND,
     		NOUNLOAD,
     		COMPRESSION,
     		STATS = 10,
     		CHECKSUM;
GO
DECLARE @backupSetId AS INT;
SELECT @backupSetId = position
FROM msdb..backupset
WHERE database_name = N'AdventureWorks2012'
      		AND backup_set_id =
      		(
          		SELECT MAX(backup_set_id)
          		FROM msdb..backupset
          		WHERE database_name = N'AdventureWorks2012'
      		);
IF @backupSetId IS NULL
BEGIN
RAISERROR(N'Verify failed. Backup information for database ''AdventureWorks2012'' not found.', 16, 1);
END;
RESTORE VERIFYONLY
FROM DISK = N'<location\filename here>'
WITH FILE = @backupSetId,
     		NOUNLOAD,
     		NOREWIND;
GO