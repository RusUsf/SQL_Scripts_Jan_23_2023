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


