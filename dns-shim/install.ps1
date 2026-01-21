## DNS Shim Install Script
# Appends or updates the hosts contents into the machine's hosts file.

$ErrorActionPreference = "Stop"
$startToken = "# <robotics>"
$endToken = "# </robotics>"
$shimToken = "{SHIM_PLACEHOLDER}"

$etcPath = if ($IsWindows -or $env:OS -match "Windows") {
    Join-Path $env:SystemRoot "System32\drivers\etc"
} else {
    "/etc"
}

$hostsFile = [System.IO.Path]::Join($etcPath, "hosts")
$hostsContent = Get-Content -Path $hostsFile | Out-String

$startTokenIndex = $hostsContent.IndexOf($startToken)
$endTokenIndex = $hostsContent.IndexOf($endToken)

if ($startTokenIndex -eq -1) {
    $hostsContent += "`n`n$shimToken"
} else {
    $hostsContent = ($hostsContent.SubString(0, $startTokenIndex)) `
        + $shimToken `
        + ($hostsContent.SubString($endTokenIndex + $endToken.Length))
}

$hostsShimContent = (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/First8612/.github/refs/heads/support/dns-shim/hosts" -UseBasicParsing).Content
$hostsContent = $hostsContent.Replace($shimToken, $hostsShimContent)

Set-Content -Path $hostsFile -Value $hostsContent