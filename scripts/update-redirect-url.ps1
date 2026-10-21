#Requires -Version 5.1
param(
  [Parameter(Mandatory = $true)][string]$App,
  [string]$Url = "",
  [switch]$ReadOnly
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location -LiteralPath $root

$config = Join-Path $root (Join-Path $App "redirect.config.js")
if (-not (Test-Path -LiteralPath $config)) {
  throw "找不到 $config"
}

$raw = Get-Content -LiteralPath $config -Raw -Encoding UTF8
$m = [regex]::Match($raw, 'TARGET_URL:\s*"([^"]*)"')
if (-not $m.Success) {
  throw "TARGET_URL not found in $config"
}

$current = $m.Groups[1].Value
if ($ReadOnly) {
  Write-Output $current
  exit 0
}

$url = $Url.Trim().Trim('"')
if ($url -notmatch '^https?://') {
  throw "網址必須以 http:// 或 https:// 開頭"
}
if ($url -eq $current) {
  Write-Output "UNCHANGED|$current"
  exit 0
}

$updated = [regex]::Replace($raw, 'TARGET_URL:\s*"[^"]*"', ('TARGET_URL: "' + $url + '"'), 1)
[System.IO.File]::WriteAllText(
  $config,
  $updated.TrimEnd() + [Environment]::NewLine,
  [System.Text.UTF8Encoding]::new($false)
)
Write-Output "UPDATED|$url"
