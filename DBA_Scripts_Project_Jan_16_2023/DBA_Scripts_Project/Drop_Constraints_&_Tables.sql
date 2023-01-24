-- use database
USE [OnMedDBNew]
GO
  
-- generate sql to drop constraints
SELECT 'ALTER TABLE ' 
     + (OBJECT_SCHEMA_NAME(parent_object_id)) 
    + '.'  
    +  QUOTENAME(OBJECT_NAME(parent_object_id)) 
    + ' ' 
    + 'DROP CONSTRAINT' 
    + QUOTENAME(name)
FROM sys.foreign_keys
ORDER BY OBJECT_SCHEMA_NAME(parent_object_id), OBJECT_NAME(parent_object_id);
GO
  
-- generate sql to drop tables
SELECT 'DROP TABLE ' + '[' + TABLE_SCHEMA + '].[' + TABLE_NAME + ']'
FROM INFORMATION_SCHEMA.TABLES
ORDER BY TABLE_SCHEMA, TABLE_NAME