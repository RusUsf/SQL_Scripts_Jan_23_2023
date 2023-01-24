--Ola Hallengren DatabaseBackup Stored Procedure with Encryption Options
--Step 1: Create Master Key & Server Certificate
use master
create master key encryption by password = 'RuslanDBA1985!'
create certificate BackupEncryptionCert with subject = 'Database Backup Encryption Certificate'

--Step 2: Specify Encryption, EncryptionAlgorithm and ServerCertificate options in SP
use AdminDB
EXECUTE [dbo].[DatabaseBackup]
@Databases = 'USER_DATABASES',
@Directory = N'D:\BACKUP_SHARE',
@BackupType = 'FULL',
@Verify = 'Y',
@CleanupTime = 168,
@CheckSum = 'Y',
@LogToTable = 'Y',
@Compress ='Y',
@Encrypt = 'Y',
@EncryptionAlgorithm ='AES_256',
@ServerCertificate = 'BackupEncryptionCert'
use master

--Step 3: Restore Database from Encrypted Backup File (no ServerCertificate or Master Key options needs to be specified on the same SQL Instance where they were created)

--***use Tim Radney Restore Script with replace option***


--NOTE: To restore Encrypted Database on the new SQL Instance, Certificate which was used to encrypt database must be restored first

--Step 4: Backup Master Key & Server Certificate
backup master key to file = N'D:\BACKUP_SHARE\ONMED_RUS$SQL2017\Securables\MS_ServiceMasterKey' encryption by password = 'RuslanDBA1985!';
GO

backup certificate BackupEncryptionCert to file = N'D:\BACKUP_SHARE\ONMED_RUS$SQL2017\Securables\BackupEncryptionCert' with private key( file = N'D:\BACKUP_SHARE\ONMED_RUS$SQL2017\Securables\BackupEncryptionCertKey', encryption by password = 'RuslanDBA1985!');
GO

--Drop BackupEncryptionCert & MS_ServiceMasterKey; try to restore AdminDB from the encrypted backup file
drop certificate BackupEncryptionCert
drop master key
--Try to restore AdminDB use code from the Step 3 and read the error message

--Step 4: Restore AdminDB from encrypted Backup file
--a: Restore Master Key and then Open Master Key 
use master
restore master key from file = N'D:\BACKUP_SHARE\ONMED_RUS$SQL2017\Securables\MS_ServiceMasterKey' decryption by password = 'RuslanDBA1985!' encryption by password = 'RuslanDBA1985!' force;
GO

open master key decryption by password = 'RuslanDBA1985!'
--b: after dropping Master Key and re-creating it the option encryption by service master key needs to be added
--also, when restoring Master Key to new SQL Server Instance 
alter master key add encryption by service master key
close master key;
GO

--c: Restore BackupEncryptionCert and BackupEncryptionCertKey from backup files 

--IMPORTANT: if restoring to new SQL Instance replace Certificate and Certificate Key files 
--in the new backup folder after making backups first from Old SQL Instance to New SQL Instance 
--have same paths for backup and restore 

create certificate BackupEncryptionCert from file = N'D:\BACKUP_SHARE\ONMED_RUS$SQL2017\Securables\BackupEncryptionCert' with private key (file=N'D:\BACKUP_SHARE\ONMED_RUS$SQL2017\Securables\BackupEncryptionCertKey', decryption by password = 'RuslanDBA1985!');
GO

--d: use code from step 3 - SUCCESS!


RESTORE DATABASE AdminDB FROM DISK = 'D:\BACKUP_SHARE\ONMED_RUS$SQL2017\AdminDB\FULL\ONMED_RUS$SQL2017_AdminDB_FULL_20221026_163906.bak' WITH NORECOVERY, replace
RESTORE LOG AdminDB FROM DISK = 'D:\BACKUP_SHARE\ONMED_RUS$SQL2017\AdminDB\LOG\ONMED_RUS$SQL2017_AdminDB_LOG_20221026_163922.trn' WITH NORECOVERY
RESTORE DATABASE AdminDB WITH RECOVERY