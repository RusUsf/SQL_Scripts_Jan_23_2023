--USER MANAGEMENT
--Step1: Create
CREATE LOGIN LearnerOne WITH PASSWORD = N'LearnerOne!'

use OnMedDBNew
create user LearnerOne for login LearnerOne
with default_schema = guest