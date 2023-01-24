-- Returns a list of all columns in current database
-- where the column's value is null for all records.
declare @tempTable TABLE
(
    TableSchema nvarchar(256),
    TableName nvarchar(256),
    ColumnName sysname,
    NotNullCnt bigint
);

declare @sql nvarchar(4000);
declare @tableSchema nvarchar(256);
declare @tableName nvarchar(256);
declare @columnName sysname;
declare @cnt bigint;

declare columnCursor cursor FOR
    SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS
    WHERE IS_NULLABLE = 'YES';

open columnCursor;

fetch next FROM columnCursor INTO @tableSchema, @tableName, @columnName;

while @@FETCH_STATUS = 0
begin
    -- use dynamic sql to get count of records where column is not null
    SET @sql = 'select @cnt = COUNT(*) from [' + @tableSchema + '].[' + @tableName +
        '] where [' + @columnName + '] is not null';
    -- print @sql; --uncomment for debugging
    exec sp_executesql @sql, N'@cnt bigint output', @cnt = @cnt output;

    INSERT INTO @tempTable SELECT @tableSchema, @tableName, @columnName, @cnt;

    fetch next FROM columnCursor INTO @tableSchema, @tableName, @columnName;
end

close columnCursor;
deallocate columnCursor;

SELECT * FROM @tempTable WHERE NotNullCnt = 0;