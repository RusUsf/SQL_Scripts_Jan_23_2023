
--ERROR LOG REVIEW
select column_name from INFORMATION_SCHEMA.columns where table_name like 'error_log_table'

select * from error_log_table 
where error_log_id in 
(select distinct  error_source from error_log_table)

select error_source,count(error_log_id) as 'ErrorCounts'
from error_log_table 
group by error_source
order by 2 desc