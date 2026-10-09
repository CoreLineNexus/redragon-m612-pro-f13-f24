<#
.SYNOPSIS
    Adds hardware-programmable F13-F24 macros to the Redragon M612RGB-PRO macro file.
.DESCRIPTION
    Adds macros using the same text-file format confirmed to work with the
    M612RGB-PRO's Mouse Drive Beta software. Existing data is not rewritten:
    the script makes a timestamped backup and appends only missing macros.

    The macro names are PS_F13 through PS_F24. Existing PS_F14, if present,
    is left intact. After running, start the official Redragon utility and
    assign the macros to mouse buttons. Their key names may be blank in the GUI.

    Does not communicate with the mouse directly or modify firmware.
.EXAMPLE
    .\Redragon-M612Pro-F13-F24.ps1
    Adds missing PS_F13 through PS_F24 macros.
.EXAMPLE
    .\Redragon-M612Pro-F13-F24.ps1 -Keys 13,14,20
    Adds only the specified macros, skipping any that already exist.
#>
[CmdletBinding()]
param(
    [ValidateRange(13,24)]
    [int[]] $Keys = (13..24)
)

$ErrorActionPreference = 'Stop'

$macroPath = Join-Path $env:LOCALAPPDATA 'Redragon\Redragon M612RGB-PRO\MacroKey.txt'

if (-not (Test-Path -LiteralPath $macroPath -PathType Leaf)) {
    throw "Cannot find MacroKey.txt at: $macroPath`nOpen the Redragon software, create/save a test macro, close it, then try again."
}

if (Get-Process -Name 'Mouse Drive Beta' -ErrorAction SilentlyContinue) {
    throw 'Close Mouse Drive Beta.exe completely (including the system tray) before running this script.'
}

# Load the original bytes so that appending does not change the existing text,
# character encoding, BOM, or line endings. The new blocks are ASCII/CRLF.
[byte[]] $originalBytes = [System.IO.File]::ReadAllBytes($macroPath)

if (($originalBytes -contains [byte]0) -or
    ($originalBytes.Length -ge 2 -and
      (($originalBytes[0] -eq 0xFF -and $originalBytes[1] -eq 0xFE) -or
       ($originalBytes[0] -eq 0xFE -and $originalBytes[1] -eq 0xFF)))) {
    throw 'MacroKey.txt appears to use UTF-16 or another unsupported format. No changes made.'
}

$originalText = [System.Text.Encoding]::UTF8.GetString($originalBytes).TrimStart([char]0xFEFF)
if ($originalText -notmatch 'Macro Name:' -or $originalText -notmatch 'Macro Context Count:') {
    throw 'MacroKey.txt does not look like the expected M612 Pro macro format. No changes made.'
}

$existingNames = @{}
$matchesFound = [regex]::Matches($originalText, '(?m)^Macro Name:([^\r\n]+)\r?$')
foreach ($match in $matchesFound) {
    $existingNames[$match.Groups[1].Value.Trim()] = $true
}

$additions = New-Object 'System.Collections.Generic.List[string]'
$createdNames = New-Object 'System.Collections.Generic.List[string]'
$skippedNames = New-Object 'System.Collections.Generic.List[string]'

foreach ($keyNumber in @($Keys | Sort-Object -Unique)) {
    $macroName = "PS_F$keyNumber"

    if ($existingNames.ContainsKey($macroName)) {
        [void] $skippedNames.Add($macroName)
        continue
    }

    # USB HID Keyboard usage IDs: F13 = 0x68, F14 = 0x69, ... F24 = 0x73.
    $hidHex = '{0:X2}' -f (0x68 + $keyNumber - 13)

    # 0x1A (26 ms) between press and release reproduces the tested PS_F14.
    $block = @(
        "Macro Name:$macroName"
        'Macro Context Count:2'
        'Macro Cycle Times:1'
        "01 00 $hidHex 00 1A 00"
        "01 01 $hidHex 00 00 00"
    ) -join "`r`n"

    [void] $additions.Add($block)
    [void] $createdNames.Add($macroName)
}

Write-Host "`nRedragon M612RGB-PRO Extended Function Key Generator" -ForegroundColor Cyan
Write-Host "Macro file: $macroPath"

if ($skippedNames.Count -gt 0) {
    Write-Host ('Already present (left unchanged): ' + ($skippedNames -join ', ')) -ForegroundColor Yellow
}

if ($createdNames.Count -eq 0) {
    Write-Host 'All requested macro names already exist. No file changes made.' -ForegroundColor Green
    return
}

# Preserve the existing content verbatim, adding a newline only if necessary.
$separator = ''
if ($originalBytes.Length -gt 0 -and
    -not ($originalText.EndsWith("`r`n") -or $originalText.EndsWith("`n") -or $originalText.EndsWith("`r"))) {
    $separator = "`r`n"
}
$appendText = $separator + ($additions.ToArray() -join "`r`n") + "`r`n"
[byte[]] $appendBytes = [System.Text.Encoding]::ASCII.GetBytes($appendText)

# Backup before making any changes.
$backup = "$macroPath.backup-$(Get-Date -Format 'yyyyMMdd-HHmmss-fff')"
Copy-Item -LiteralPath $macroPath -Destination $backup -ErrorAction Stop

# Avoid conflicting with the configuration utility if it was reopened.
if (Get-Process -Name 'Mouse Drive Beta' -ErrorAction SilentlyContinue) {
    throw "Redragon was reopened. No changes made. Backup saved at: $backup"
}

# Append; no bytes from existing macros are rewritten.
$stream = [System.IO.File]::Open(
    $macroPath,
    [System.IO.FileMode]::Append,
    [System.IO.FileAccess]::Write,
    [System.IO.FileShare]::None
)
try {
    $stream.Write($appendBytes, 0, $appendBytes.Length)
    $stream.Flush()
}
finally {
    $stream.Dispose()
}

Write-Host ('Added: ' + ($createdNames -join ', ')) -ForegroundColor Green
Write-Host "Backup saved: $backup"
Write-Host "`nNEXT: Open Redragon, assign PS_F13 ... PS_F24 to your chosen buttons, and click Apply."
Write-Host 'Blank key labels in the Redragon macro editor are expected for F13-F24.'
Write-Host 'Avoid re-recording or modifying the key events in the editor.' -ForegroundColor Yellow
