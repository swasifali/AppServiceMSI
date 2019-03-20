DROP USER IF EXISTS $(ServicePrincipalName);    
CREATE USER $(ServicePrincipalName) FROM EXTERNAL PROVIDER;
ALTER ROLE db_datareader ADD MEMBER $(ServicePrincipalName);
ALTER ROLE db_datawriter ADD MEMBER $(ServicePrincipalName);
GO