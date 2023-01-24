

--use master;select name 'Logical Name',physical_name 'File Location' from sys.master_files


use master
DECLARE @backupPath nvarchar(400);
DECLARE @sourceDb nvarchar(50);
DECLARE @sourceDb_log nvarchar(50);
DECLARE @destDb nvarchar(50);
DECLARE @destMdf nvarchar(100);
DECLARE @destLdf nvarchar(100);
DECLARE @sqlServerDbFolder nvarchar(100);

SET @sourceDb = 'OnMedDBNew'
SET @sourceDb_log = @sourceDb + '_log'
SET @backupPath = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\Backup\' + @sourceDb + '.bak'    --ATTENTION: file must already exist and SQL Server must have access to it
SET @sqlServerDbFolder = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\DATA\'
SET @destDb = 'OnMedDBNew_copy'
SET @destMdf = @sqlServerDbFolder + @destDb + '.mdf'
SET @destLdf = @sqlServerDbFolder + @destDb + '_log' + '.ldf'

BACKUP DATABASE @sourceDb TO DISK = @backupPath

RESTORE DATABASE @destDb FROM DISK = @backupPath
WITH REPLACE,
   MOVE @sourceDb     TO @destMdf,
   MOVE @sourceDb_log TO @destLdf


--exec sp_renamedb 'db1','db2'