
--STEP 1
--DEFAULT BACKUP LOCATION
EXEC  master.dbo.xp_instance_regread  
 N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer',N'BackupDirectory';
 go
--STEP 2 "Backup One Database at the time"
--BACKUP DATABASE with Date in the backup filename
DECLARE @FileName1 varchar(1000)
SELECT @FileName1 = (SELECT 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\Backup\DatabaseName' + convert(varchar(500), GetDate(),112) + '.bak')
BACKUP DATABASE DatabaseName TO DISK=@FileName1

--STEP 3 *** SCRIPT***
--BACKUP ALL DATABASES with DATE in the backup filename
DECLARE @name VARCHAR(50) -- database name 
DECLARE @path VARCHAR(256) -- path for backup files 
DECLARE @fileName VARCHAR(256) -- filename for backup 
DECLARE @fileDate VARCHAR(20) -- used for file name
 
-- specify database backup directory e.g. 'D:\backup\'
SET @path = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\Backup\'
 
-- specify filename format
SELECT @fileDate = CONVERT(VARCHAR(20),GETDATE(),112) + '_' + REPLACE(CONVERT(VARCHAR(20),GETDATE(),108),':','')
 
DECLARE db_cursor CURSOR READ_ONLY FOR 
SELECT name
FROM master.sys.databases
WHERE name NOT IN ('master','model','msdb','tempdb')  -- exclude these databases
AND state = 0 -- database is online
AND is_in_standby = 0 -- database is not read only for log shipping
 
OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @name
 
WHILE @@FETCH_STATUS = 0
BEGIN
   SET @fileName = @path + @name + '_' + @fileDate + '.BAK'
   BACKUP DATABASE @name TO DISK = @fileName
 
   FETCH NEXT FROM db_cursor INTO @name
END
 
CLOSE db_cursor
DEALLOCATE db_cursor