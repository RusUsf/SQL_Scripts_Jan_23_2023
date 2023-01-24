--create a new login
create login LearnerThree with password = 'LearnerThree';

--create new user with the login
create user LearnerThree for login LearnerThree

--grant SELECT permission on the database to the user (one table only)
use Learning_Tips; grant select on Learning_Tips.dbo.LearningTips to LearnerThree

--grant SELECT permission on the database every table
exec sp_MSforeachtable 'grant select on ? to LearnerThree'

