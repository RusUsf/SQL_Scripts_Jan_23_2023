--BACKUP & RESTORE PROCEDURE

--Step 1: Check Recover Model
select name, recovery_model_desc from sys.databases where name = 'OnMedDbNew'

--Step 2: Find Default MDF, LDF & Backup file locations
--MDF & LDF:
select serverproperty ('InstanceDefaultDataPath') as Default_Data_Path
,serverproperty('InstanceDefaultLogPath') as Default_log_path;
go

--Backup:
EXEC  master.dbo.xp_instance_regread  
 N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer',N'BackupDirectory';
 Go

--Query the logical and physical names of the Backup File:
restore filelistonly from disk = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\Backup\OnMedDBNew_1000_Sep_20_2022_3_00PM.bak'


--Step 3: Make Full Database Backup
use master
backup database OnMedDBnew_1000 to disk = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\Backup\OnMedDBNew_1000_Sep_20_2022_3_00PM.bak'

--Step 4: Restore Database
restore database OnMedDBNew_1000 from disk = 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQL2017\MSSQL\Backup\OnMedDBNew_1000_Sep_20_2022_3_00PM.bak' with replace



