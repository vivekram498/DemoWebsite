param([String]$path,
      [String]$WebSiteName,
      [String]$ip,
      [Switch]$local
)

#Check if script is being run as administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-NOT $isAdmin) {
	Write-Warning "This script must be run as Administrator. Re-run under Administrator context."
    Break
}

if($local)
{
    #Add redirect to hosts use this if deploying locally
    Write-Host "Adding host header for MVCDemoWebsite.com ..." -nonewline
    $ecuxRedirectPath = "127.100.100.1 MVCDemoWebsite.com"
    $hostpath = "C:\Windows\System32\Drivers\Etc\Hosts"

    if(!(Select-String $hostpath -Pattern $ecuxRedirectPath)){
	        Add-Content $hostpath $ecuxRedirectPath
    }
    Write-Host "Done."
}

#Copy files to IIS directory
$IISDir = "C:\inetpub\wwwroot\$WebSiteName"
robocopy $path $IISDir /MIR /PURGE

#region setting up IIS
Import-Module WebAdministration
$iisAppPoolName = $WebSiteName
$iisAppPoolDotNetVersion = "v4.0"
$iisPipelineMode = "Integrated"
$iisAppName = $WebSiteName
$directoryPath = $path

$poolUser = "mydomain\user1"
$poolUserPass = "RFVTGByhn#12122016" 

#navigate to the app pools root
cd IIS:\AppPools\

#check if the app pool exists
if (!(Test-Path $iisAppPoolName -pathType container))
{
    #create the app pool
    $appPool = New-WebAppPool -Name $iisAppPoolName
    $appPool | Set-ItemProperty -Name "managedRuntimeVersion" -Value $iisAppPoolDotNetVersion
	$appPool | Set-ItemProperty -Name "managedPipelineMode" -Value $iisPipelineMode
	
	Set-ItemProperty $iisAppPoolName -name processModel -value @{userName=$poolUser;password=$poolUserPass;identitytype=3}
}

#navigate to the sites root
cd IIS:\Sites\

#check if the site exists
if (Test-Path $iisAppName -pathType container)
{
    return
}

#create the site

Write-Host "Creating Web Site..." -nonewline

if($local)
{
    $ip = "127.100.100.1"
}

$iisApp = New-Website -Name "MVCDemoWebsite.com" -ApplicationPool $iisAppPoolName -IP $ip -HostHeader $WebSiteName -PhysicalPath $directoryPath -Port 80 
New-WebBinding -name "MVCDemoWebsite.com" -Protocol https -HostHeader "MVCDemoWebsite.com" -Port 80
Write-Host "Done."


