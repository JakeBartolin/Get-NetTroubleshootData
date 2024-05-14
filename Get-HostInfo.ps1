Clear-Host


# |--------------------|
# | Gather Device Info |
# |--------------------|

Write-Host "Gathering device details."
$SerialNumber = (Get-WmiObject -Class Win32_BIOS).SerialNumber # Grab the SN of the computer
$IPConfigOutput = (cmd.exe /c "ipconfig") -join "`n"           # Grab the output of ipconfig
$hostname = hostname


# |----------------|
# | Run Ping Tests |
# |----------------|

function Ping-Test {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Address,
        [String]$TestMessage
    )

    if ($TestMessage -ne $null) {
        Write-Host $TestMessage
    }
    else {
        Write-Host "Pinging $Address"
    }

    try {
        return Test-Connection $Address | Format-Table | Out-String
    }
    catch {
        Write-Error "The test to $Address failed."
        return $false
    }
}

$PingOutputGoogleDomain = Ping-Test -Address "google.com" -TestMessage "Pinging google.com"
$PingOutputGoogleDNSIP = Ping-Test -Address "8.8.8.8" -TestMessage "Pinging Google's DNS Servers (8.8.8.8)"
$PingOutputCloudflareDomain  = Ping-Test -Address "cloudflare.com" -TestMessage "Pinging cloudflare.com"
$PingOutputCloudflareDNSIP = Ping-Test -Address "1.1.1.1" -TestMessage "Pinging Cloudflare's DNS Servers (1.1.1.1)"


# |--------------|
# | Trace routes |
# |--------------|

Write-Host "Tracing the route to google.com"
$TraceRouteToGoogleOutput = (cmd.exe /c "tracert google.com") -join "`n"
Write-Host "Tracing the route to cloudflare.com"
$TraceRouteToCloudflareOutput = (cmd.exe /c "tracert cloudflare.com") -join "`n"


# |--------------------------|
# | Create the Output String |
# |--------------------------|

$Output = @"
|-------------|
| Device Info |
|-------------|

Hostname: $hostname
Device Serial Number: $SerialNumber
Domain:$env:USERDOMAIN

|-----------------|
| ipconfig Output |
|-----------------|
$IPConfigOutput


|---------------------------|
| Google Connectivity Tests |
|---------------------------|
$PingOutputGoogleDomain
$PingOutputGoogleDNSIP
$TraceRouteToGoogleOutput


|-------------------------------|
| Cloudflare Connectivity Tests |
|-------------------------------|
$PingOutputCloudflareDomain
$PingOutputCloudflareDNSIP
$TraceRouteToCloudflareOutput
"@


$Output | clip
Write-Host $Output