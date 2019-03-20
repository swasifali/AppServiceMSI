@echo off

set /p password=Enter the SQL admin password: 
echo %password%
IF %password%X==X GOTO INPUT_ERROR:

REM login to azure
CALL az login

REM set subscription to POC environment
REM change this as per requirement
CALL az account set --subscription "EMEA-UK-POSTERSCOPE-ECOS"

REM show current subscription account details
REM make sure this is the one you want to use
CALL az account show

REM  this is where the POC code is hosted
REM  the code is generic so no issue with public hosting
SET gitrepo=https://github.com/swasifali/AppServiceMSI

SET resource_group_name=AppServiceSQLMSI%RANDOM%
SET webappname=SampleAppWithMSI%RANDOM%

REM  Create a resource group.
CALL az group create --location westeurope --name %resource_group_name%

REM  Create an App Service plan in FREE tier
CALL az appservice plan create --name %webappname% --resource-group %resource_group_name% --sku FREE

REM  Create a web app.
CALL az webapp create --name %webappname% --resource-group %resource_group_name% --plan %webappname%

REM deploy web app through config-src (required if using local project)
REM CALL az webapp deployment source config-zip --resource-group %resource_group_name% --name %webappname% --src ./path-to/DotNetAppSqlDb.zip

REM deploy web app through git repo
CALL az webapp deployment source config --name %webappname% --resource-group %resource_group_name% --repo-url %gitrepo% --branch master --manual-integration

REM enable/assign managed identity on webapp
CALL az webapp identity assign --resource-group %resource_group_name% --name %webappname%

REM  NOW SETUP SQL DATABASE #
SET adminlogin=ServerAdmin
REM  The logical server name has to be unique in the system
SET servername=server-%RANDOM%
REM database name
SET dbname=DotNetAppSqlDb-MSI
REM  The ip address range that you want to allow to access your DB
SET startip=0.0.0.0
SET endip=0.0.0.0

CALL az sql server create --name %servername% --resource-group %resource_group_name% --location westeurope  --admin-user %adminlogin% --admin-password %password%

REM  Configure a firewall rule for the server
REM  This switches "Allow access to Azure Services" setting to ON.
CALL az sql server firewall-rule create --resource-group %resource_group_name% --server %servername% -n AllowAzureServices --start-ip-address %startip% --end-ip-address %endip%

REM  Create database for the app service app in the server 
CALL az sql db create --resource-group %resource_group_name% --server %servername% --name %dbname% --service-objective Basic

REM give your own AD account admin access to SQL DB
 REM get Service Principal for your own (signed-in) account

FOR /F "tokens=*" %%g IN ('az ad signed-in-user show --query objectId -o tsv') do (SET signedInUserSPID=%%g)
echo %signedInUserSPID%

FOR /F "tokens=*" %%g IN ('az ad signed-in-user show --query userPrincipalName -o tsv') do (SET signedInUserName=%%g)
echo %signedInUserName%


REM make it ad-admin on the sql server
CALL az sql server ad-admin create --resource-group %resource_group_name% --server %servername% --display-name %signedInUserName% --object-id %signedInUserSPID%

REM get connection string from sql db
REM get fully qualified domain name of the sql server
FOR /F "tokens=*" %%g IN ('az sql server show --resource-group %resource_group_name% --name %servername% --query fullyQualifiedDomainName -o tsv') do (SET SqlServerFQDN=%%g)
echo %SqlServerFQDN%

REM build web app connection string for MSI
SET webapp_connection_string='Server=tcp:%SqlServerFQDN%,1433;Database=%dbname%;'

REM set connection string in the web app settings
CALL az webapp config connection-string set --resource-group %resource_group_name% --name %webappname% --settings MyDbConnection=%webapp_connection_string% --connection-string-type SQLAzure


FOR /F "tokens=*" %%g IN ('curl https://api.ipify.org/') do (SET MyPublicIP=%%g)
echo %MyPublicIP%

CALL az sql server firewall-rule create --resource-group %resource_group_name% --server %ServerName% -n AllowMyPublicIp --start-ip-address %MyPublicIP% --end-ip-address %MyPublicIP%

CALL sqlcmd.exe -S %SqlServerFQDN% -d %dbname% -U %signedInUserName% -G -l 30 -v ServicePrincipalName=%webappname% -i "./AppServicePermissions.sql"

REM  Open the web app in browser
start "" http://%webappname%.azurewebsites.net

GOTO END

:INPUT_ERROR
echo Please provide a valid password for the SQL database.

:END