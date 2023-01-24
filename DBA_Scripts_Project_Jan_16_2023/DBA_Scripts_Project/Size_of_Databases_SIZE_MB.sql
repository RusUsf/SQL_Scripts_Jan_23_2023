
--Size of Database DB Name
use OnMedDBNew_1000;
exec sp_spaceused

--Size of the DB
exec sp_databases


--Size of the DATABASE
SELECT
    d.name AS 'Database',
    m.name AS 'File',
    m.size,
    m.size * 8/1024 'Size (MB)',
    SUM(m.size * 8/1024) OVER (PARTITION BY d.name) AS 'Database Total',
    m.max_size
FROM sys.master_files m
INNER JOIN sys.databases d ON
d.database_id = m.database_id;