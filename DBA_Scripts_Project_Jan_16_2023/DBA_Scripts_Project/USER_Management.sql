--USER MANAGEMENT
--Step1: Create
CREATE LOGIN LearnerOne WITH PASSWORD = N'LearnerOne!'

use OnMedDBNew
create user LearnerOne for login LearnerOne
with default_schema = guest

-- UserManagement.sql-- This script creates a new SQL Server login and user, and grants comprehensive privileges-- Step 1: Create a new SQL Server loginCREATE LOGIN [NewUser] WITH PASSWORD ='YourStrongPassword';
GO

-- Step 2: Create a new user in a specific database
USE [YourDatabaseName];
GO
CREATEUSER [NewUser] FOR LOGIN [NewUser];
GO

-- Step 3: Grant server-level roles-- Grants the sysadmin role, which provides full control over the SQL Server instance
ALTER SERVER ROLE sysadmin ADDMEMBER [NewUser];
GO

-- Step 4: Grant database-level roles-- Switch to the specific database
USE [Florida_Flippers];
GO

-- Grants the db_owner role, which provides full control over the database
ALTER ROLE db_owner ADDMEMBER [NewUser];
GO

 GRANT SELECT, INSERT, UPDATE, DELETE TO [LearnerOne];
-- Step 5: Grant explicit permissions (optional)-- Uncomment the following lines if you need to grant specific permissions-- Example: Grant specific permissions to a table (e.g., select, insert, update, delete)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[YourTable] TO [NewUser];-- GO-- Example: Grant execute permissions on all stored procedures
-- GRANT EXECUTE ON SCHEMA::[dbo] TO [NewUser];-- GO-- Step 6: Review permissions (optional)-- Uncomment the following lines to review the permissions granted to the user-- Review server-level permissions-- SELECT * FROM sys.server_permissions WHERE grantee_principal_id = SUSER_ID('NewUser');-- GO-- Review database-level roles and permissions-- USE [YourDatabaseName];-- GO-- SELECT * FROM sys.database_permissions WHERE grantee_principal_id = USER_ID('NewUser');-- GO-- End of script