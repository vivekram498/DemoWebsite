#
# This is build script for MVCWebsite.
#

$msbuild = 'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe'

#testing msbuild file location
if(!Test-Path $msbuild)
    Write-Error "MSBuild not found. Please check contact build admin."

#compiling project using DemoDeploy publish profile. All the bits will be copied to Drop folder in root directory
.$msbuild ".\MvcWebSite.sln" /p:DeployOnBuild=True /p:PublishProfile=DemoDeploy

