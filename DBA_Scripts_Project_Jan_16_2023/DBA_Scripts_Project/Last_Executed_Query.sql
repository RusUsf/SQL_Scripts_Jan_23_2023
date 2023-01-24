--Test Query
select * from OnMedDBNew.dbo.Addresses

--Last Executed Query
--NOTE:sys.dm_exec_qury_stats DMV works based on the query plan in the cache
SELECT
    deqs.last_execution_time AS [Time], 
    dest.TEXT AS [Query]
 FROM 
    sys.dm_exec_query_stats AS deqs
    CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
ORDER BY 
    deqs.last_execution_time DESC


