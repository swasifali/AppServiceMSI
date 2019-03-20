@echo off

FOR /F "tokens=*" %%g IN ('curl https://api.ipify.org/') do (SET MyPublicIP=%%g)
echo %MyPublicIP%

REM Make sure to use v14 of SqlCmd.exe that supports Azure AD authentication
SET resource_group_name=AppServiceSQLMSI31795
SET ServerName=server-4155
SET SqlServerFQDN=server-4155.database.windows.net
SET dbname=DotNetAppSqlDb-MSI
SET signedInUserName=Wasif.Ali@dentsuaegis.com
SET webappname=SampleAppWithMSI10688

echo %resource_group_name%
echo %ServerName%
echo %SqlServerFQDN%
echo %dbname%
echo %signedInUserName%
echo %webappname%

REM login to az cli separately if needed
REM az login

REM Make sure to select the correct subscription - change as required
REM az account set --subscription "EMEA-UK-POSTERSCOPE-ECOS"

CALL az sql server firewall-rule create --resource-group %resource_group_name% --server %ServerName% -n AllowMyPublicIp --start-ip-address %MyPublicIP% --end-ip-address %MyPublicIP%

sqlcmd.exe -S %SqlServerFQDN% -d %dbname% -U %signedInUserName% -G -l 30 -v ServicePrincipalName=%webappname% -i ".\AppServicePermissions.sql"
