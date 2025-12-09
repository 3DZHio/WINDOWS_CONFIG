### VARIABLES ###
$APP_EXE_DIR = "A:\EXE"
$APP_DATA_DIR = "A:\DATA"
$APPEARANCE_DIR = "$PSScriptRoot\APPEARANCE"



### MAIN ###
## EXECUTION POLICY ##
Set-ExecutionPolicy "RemoteSigned" –Force


## PARTITION ##
Set-Partition -DriveLetter (Get-Volume -FileSystemLabel "SERVICE").DriveLetter -NewDriveLetter "S"
Set-Partition -DriveLetter (Get-Volume -FileSystemLabel "APP").DriveLetter -NewDriveLetter "A"
Set-Partition -DriveLetter (Get-Volume -FileSystemLabel "GAME").DriveLetter -NewDriveLetter "G"
Set-Partition -DriveLetter (Get-Volume -FileSystemLabel "BOOT").DriveLetter -NewDriveLetter "B"


## SYSTEM RESTORE ##
Disable-ComputerRestore -Drive "C:\", "S:\", "A:\", "G:\"


## ANTIVIRUS EXCLUSIONS ##
Add-MpPreference -ExclusionPath "S:\", "A:\", "G:\"


## SYMBOLIC LINKS ##
$SYMBOLIC_LINKS = @{
    "$env:SYSTEMROOT\Web\BACKGROUND" = "$APPEARANCE_DIR\BACKGROUND"
    "$env:LOCALAPPDATA\Microsoft\Windows\Cursors" = "$APPEARANCE_DIR\Cursors"
    "$env:APPDATA\DBeaverData" = "$APP_DATA_DIR\DBeaverData"
    "$env:SYSTEMROOT\OEM\TaskbarLayoutModification.xml" = "$APPEARANCE_DIR\TaskbarLayoutModification.xml"
}
foreach ($S_L in $SYMBOLIC_LINKS.GetEnumerator()) {
    Remove-Item -Path $S_L.Key -Recurse -Force -ErrorAction "SilentlyContinue"
    New-Item -ItemType "SymbolicLink" -Path $S_L.Key -Target $S_L.Value -Force
}


## REGISTRY ##
reg import "$PSScriptRoot\REGISTRY.reg"


## PATH ##
$CURRENT_PATH = [Environment]::GetEnvironmentVariable("PATH", "Machine")
$PYTHON_DIR = "$APP_EXE_DIR\PYTHON"
$PYTHON_SCRIPTS_DIR = "$PYTHON_DIR\Scripts"
[Environment]::SetEnvironmentVariable("PATH", "$CURRENT_PATH;$PYTHON_DIR;$PYTHON_SCRIPTS_DIR", "Machine")


## EXPLORER ## 
$SHELL = New-Object -ComObject Shell.Application

# UNPIN #
$CURRENT_ITEMS = $SHELL.Namespace("shell:::{679f85cb-0220-4080-b29b-5540cc05aab6}").Items()

foreach ($I in $CURRENT_ITEMS) {
    foreach ($V in $I.Verbs()) {
        if ($V.Name -match "unpin") { $V.DoIt() } 
    }
}

# PIN #
$ITEMS_TO_PIN = @( "$env:USERPROFILE\Desktop", "$env:USERPROFILE\Documents", "$env:USERPROFILE\Pictures", "$env:USERPROFILE\Downloads", "shell:::{645FF040-5081-101B-9F08-00AA002F954E}" )

foreach ($I in $ITEMS_TO_PIN) { $SHELL.Namespace($I).Self.InvokeVerb("pintohome") }

# CLEAN #
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($SHELL) | Out-Null


## THEME ##
& "$APPEARANCE_DIR\THEME.theme"


## SERVICES ##
$SERVICES = "WSearch", "DiagTrack"
foreach ($S in $SERVICES) {
    Stop-Service -Name "$S" -Force
    Set-Service -Name "$S" -StartupType "Disabled"
}


## POWER PLAN ##
powercfg /duplicatescheme "e9a42b02-d5df-448d-aa00-03f14749eb61" "ABCD1234-A123-B123-C123-ABCDEF123456"
powercfg /setactive "ABCD1234-A123-B123-C123-ABCDEF123456"


## NETWORK ##
# MTU #
netsh int ipv4 set subinterface "Ethernet" mtu=1492 store=persistent

# DYNAMIC PORT #
netsh int ipv4 set dynamicport tcp start=1025 num=64510
netsh int ipv4 set dynamicport udp start=1025 num=64510

# TCP #
netsh int tcp set heuristics disabled
netsh int tcp set global autotuninglevel=disabled dca=enabled rss=enabled rsc=disabled ecncapability=enabled
netsh int tcp set supplemental Internet congestionprovider=CUBIC



# DNS Reset #
netsh winsock reset
netsh int ip reset
ipconfig /release
ipconfig /renew
ipconfig /registerdns
ipconfig /flushdns

# IPv6 #
Disable-NetAdapterBinding -Name "*" -ComponentID "ms_tcpip6" -ErrorAction "SilentlyContinue"
"teredo", "6to4", "isatap" | ForEach-Object { netsh interface "$_" set state "disabled" }

# Disable LSO #
Disable-NetAdapterLso -Name "*" -ErrorAction "SilentlyContinue"


## OTHER ##
fsutil behavior set DisableLastAccess "1"



### RESTART ###
$PROMPT = @"
+---------------------------------------------------------------+
|                                                               |
|                     RESTART COMPUTER ???                      |
|                                                               |
+---------------------------------------------------------------+

"@
Write-Host "$PROMPT" -ForegroundColor "DarkRed"
if ((Read-Host ">>> (y/n)") -match "^[yYнН]$") { Restart-Computer }