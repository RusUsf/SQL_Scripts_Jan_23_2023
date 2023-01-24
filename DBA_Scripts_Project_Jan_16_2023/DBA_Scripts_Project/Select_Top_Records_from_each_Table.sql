DECLARE @sql nvarchar(max) = N'';

SELECT @sql += N'

SELECT TOP (10) [table] = N''' + REPLACE(name, '''','') + ''', * 
    FROM ' + QUOTENAME(SCHEMA_NAME([schema_id]))
  + '.' + QUOTENAME(name) + ';'
FROM sys.tables AS t;

PRINT @sql;
-- EXEC sys.sp_executesql @sql;