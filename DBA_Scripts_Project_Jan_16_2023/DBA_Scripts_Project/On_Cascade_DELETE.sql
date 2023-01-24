	

use master
--Restore Script for the Testing Database


--Record Delete: easy way to archive or delete data
--Script to lookup records from UserRoles, Employees and Users tables by email address; easy way to delete records 
use OnMedDBNew
DECLARE @UserId nvarchar(450),
        @Lookup bit

SET @Lookup = 1
SET @UserId = (SELECT UserId FROM Users WHERE Email = 'adad@onmed.com')

IF @Lookup = 1
    BEGIN
        SELECT * FROM Employees WHERE UserId = @UserId
        SELECT * FROM UserRoles WHERE UserId = @UserId
        SELECT * FROM Users WHERE UserId = @UserId
    END

ELSE IF @UserId IS NOT NULL AND @Lookup = 0
    BEGIN
    DELETE FROM UserRoles WHERE UserId = @UserId
    DELETE FROM Employees WHERE UserId = @UserId
    DELETE FROM Users WHERE UserId = @UserId
    END

--
select UserId, Email, RecDelete from Users 
where RecDelete = 1 order by 2 
--Counts of Record Delete in Users table
select RecDelete, count(UserId)
from Users
group by RecDelete;




--Record Delete Review
--Dropping FK Constraints and recreating them with ON UPDATE/DELETE CASCADE OPTIONS


ALTER TABLE [dbo].[Employees] DROP CONSTRAINT [fk_Employees_Users]

ALTER TABLE [dbo].[UserRoles] DROP CONSTRAINT [fk_UserRoles_Users]


ALTER TABLE [dbo].[Employees] WITH CHECK ADD CONSTRAINT [fk_Employees_Users] FOREIGN KEY([UserId]) 
REFERENCES [dbo].[Users] ([UserId]) ON UPDATE CASCADE ON DELETE CASCADE 

ALTER TABLE [dbo].[UserRoles] WITH CHECK ADD CONSTRAINT [fk_UserRoles_Users] FOREIGN KEY([UserId]) 
REFERENCES [dbo].[Users] ([UserId]) ON UPDATE CASCADE ON DELETE CASCADE 

--OPTION A:
--Deleting RecDelete records manually with three separate DELETE statements 
	DELETE FROM UserRoles WHERE UserId in (select UserId from Users where RecDelete =1)
    DELETE FROM Employees WHERE UserId in (select UserId from Users where RecDelete =1)
    DELETE FROM Users WHERE UserId in (select UserId from Users where RecDelete =1) 

--OPTION B:    
--Delete only Record from Users table and FK with ON DELETE CASCADE options will delete records from depended tables
delete from Users where RecDelete =1





--Testing and Implimenting ON UPDATE/DELETE CASCADE options for FK constraints 
--Benefits of these options minimazing Data Anomalies when updating/deleting records;
--ability to update/delete records comprehansively

--Problem: cannot delete records from Users table because Employees and UserRoles tables have 
--FK referencing UserId in Users table
delete from Users where RecDelete =1        --will throw an error (one solution is to use three separate DELETE statements)

--Step 1: Drop existing FK constraints

ALTER TABLE [dbo].[Employees] DROP CONSTRAINT [fk_Employees_Users]

ALTER TABLE [dbo].[UserRoles] DROP CONSTRAINT [fk_UserRoles_Users]

--Step 2: Creaate new FK constraints with ON UPDATE/DELETE options 
ALTER TABLE [dbo].[Employees] WITH CHECK ADD CONSTRAINT [fk_Employees_Users] FOREIGN KEY([UserId]) 
REFERENCES [dbo].[Users] ([UserId]) ON UPDATE CASCADE ON DELETE CASCADE 

ALTER TABLE [dbo].[UserRoles] WITH CHECK ADD CONSTRAINT [fk_UserRoles_Users] FOREIGN KEY([UserId]) 
REFERENCES [dbo].[Users] ([UserId]) ON UPDATE CASCADE ON DELETE CASCADE 

--Step 3:
--Delete Records from Users table which marked for Deletion and automatically 
--delete records associcated with the UserIds in Employees and UserRoles tables!!!
delete from Users where RecDelete =1
