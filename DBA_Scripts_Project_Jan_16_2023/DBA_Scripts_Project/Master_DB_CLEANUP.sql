USE [master];
GO
DECLARE @sql nvarchar(max) = N'';

SELECT @sql += N'BEGIN TRY
  EXEC sys.sp_executesql N''DROP TABLE ' + objectname + N';'';
END TRY
BEGIN CATCH
  SELECT N''Table ' + objectname + N' failed - run the script again.'',
    ERROR_MESSAGE();
END CATCH
' FROM
(
  SELECT QUOTENAME(s.[name]) + N'.' + QUOTENAME(o.[name])
  FROM sys.tables AS o
  INNER JOIN sys.schemas AS s 
  ON o.[schema_id] = s.[schema_id]
  WHERE o.is_ms_shipped = 0
) AS src(objectname);

SELECT @sql;
EXEC sys.sp_executesql @sql;



USE [master];
GO
SET NOCOUNT ON;
DECLARE @sql nvarchar(max) = N'';

SELECT @sql += N'BEGIN TRY
  ALTER TABLE ' + objectname + N'
    DROP CONSTRAINT ' + fkname + N';
END TRY
BEGIN CATCH
  SELECT N''FK ' + fkname + N' failed. Run the script again.'', 
    ERROR_MESSAGE();
END CATCH
' FROM 
(
  SELECT fkname = QUOTENAME(fk.[name]), 
    objectname = QUOTENAME(s.[name]) + N'.' + QUOTENAME(t.[name])
  FROM sys.foreign_keys AS fk
  INNER JOIN sys.objects AS t
  ON fk.parent_object_id = t.[object_id]
  INNER JOIN sys.schemas AS s
  ON t.[schema_id] = s.[schema_id]
) AS src;

SELECT @sql;
EXEC sys.sp_executesql @sql;