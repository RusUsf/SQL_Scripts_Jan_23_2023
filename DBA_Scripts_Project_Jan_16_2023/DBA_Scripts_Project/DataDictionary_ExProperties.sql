--Updating Extended Properties

EXEC sp_addextendedproperty
	@name = 'Employee Pay History Rate',
	@value = 'An employees pay rate.  This will contain up to 4 decimal places and can never be NULL.',
	@level0type = 'Schema', @level0name = 'HumanResources',
	@level1type = 'Table', @level1name = 'EmployeePayHistory',
	@level2type = 'Column', @level2name = 'Rate';

--Reviewing Exteneded Properties
SELECT
	*
FROM sys.extended_properties
INNER JOIN sys.objects
ON extended_properties.major_id = objects.object_id
INNER JOIN sys.columns
ON columns.object_id = objects.object_id
AND columns.column_id = extended_properties.minor_id
--WHERE objects.name = 'EmployeePayHistory'
--AND columns.name = 'Rate'