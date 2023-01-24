use master
--drop master key
--drop certificate CertificateNameHere
/*Backing up Master Key second time will not overwrite it, but create an error*/

--Creating Master Key
create master key encryption by password = 'RuslanDBA1985!37'

--Creating Certificate 
create certificate EncryptCert_Rus with subject = 'Database Backup Encryption Certificate'

--Backing up Master Key
backup master key to file = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Securables\MasterKey' encryption by password = 'RuslanDBA1985!37'

--Backing up Server Sertificate
backup certificate EncryptCert_Rus to file = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Securables\EncryptCert_Rus'
with private key( file = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Securables\EncryptCert_Rus_Key', encryption by  password = 'RuslanDBA1985!37');

--Backing up Database using T-SQL
backup database AdminDB to disk = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\AdminDB\FULL\AdminDB_Compressed_Encrypted.bak' with compression, encryption (algorithm = AES_256, server certificate = EncryptCert_Rus);

--Backing up Database without Encryption to test HexEditor
backup database AdminDb to disk = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\AdminDB\FULL\AdminDb_Not_Encrypted' with checksum

--Restoring Encrypted Database
/*Instance Must Have certificate or asymetric key which were used to encrypt the backup file.*/

restore database AdminDB from disk = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\AdminDB\FULL\AdminDB_Compressed_Encrypted.bak' with replace

--Dropping Certificate and Attempting to Restore Encrypted DB
drop certificate EncryptCert_Rus

restore database AdminDB from disk = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\AdminDB\FULL\AdminDB_Compressed_Encrypted.bak' with replace

--Restoring Certificate and Encrypted Database
create certificate EncryptCert_Rus from file = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Securables\EncryptCert_Rus' with private key ( file = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\Securables\EncryptCert_Rus_Key', decryption by password = 'RuslanDBA1985!37');

--Restoring Encrypted Database after restoring certificate used to encrypt Database
restore database AdminDB from disk = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\Backup\AdminDB\FULL\AdminDB_Compressed_Encrypted.bak' with replace