
--Last Restore Date & Time
declare @DB sysname = 'OnMedDBNew';
select * from msdb.dbo.restorehistory where destination_database_name = @DB order by 2 desc;