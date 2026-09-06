<#
  Tokenizes and runs the VIC-20 graphing demo reel (sine, cos, sinecos, tan,
  unitcircle) in VICE.

  - reads VICE's location from paths.ini
  - tokenizes every listing in the chain to a .prg via petcat, into a work
    directory mounted as VICE's device #8 filesystem
  - boots xvic and types LOAD"sine",8,1 + RUN to kick off the reel

  Each listing ends with LOAD"<next>",8,1 - executing LOAD from a *running*
  BASIC program (as opposed to typing it at the READY prompt) auto-RUNs
  whatever it just loaded, so the reel chains sine -> cos -> sinecos -> tan
  -> unitcircle -> sine forever without ever holding more than one demo's
  code in memory at once. All five .prg files just sit on the mounted
  "disk" - that's host storage, not VIC-20 RAM.

.PARAMETER Commented
  Run the *-commented.bas companions instead of the plain listings. They're
  roughly double the size (a REM before nearly every line), which busts the
  unexpanded VIC-20's ~3583-byte BASIC workspace - this switches petcat's
  load address from $1001 to $0401 and adds VICE's -memory 3k expander so
  the bigger listings fit, the same trick vice-background-creator's
  New-ViceScreenshot.ps1 uses for the same reason.

.PARAMETER Warp
  Run VICE in warp mode (full host speed) instead of real VIC-20 speed.

.EXAMPLE
  .\Run-GraphingDemos.ps1
  .\Run-GraphingDemos.ps1 -Commented
#>
param(
    [switch]$Commented,
    [switch]$Warp
)

$root = $PSScriptRoot
$ini  = Get-Content (Join-Path $root 'paths.ini') -Raw

function Get-IniPath([string]$section, [string]$content) {
    $pattern = '(?ims)\[{0}\].*?RootPath\s*=\s*"([^"]+)"' -f [regex]::Escape($section)
    if ($content -match $pattern) { return $Matches[1] }
    throw "RootPath not found for [$section] in paths.ini"
}

$vicePath = Get-IniPath 'VICE' $ini
$binDir   = Join-Path $vicePath 'bin'
$petcat   = Join-Path $binDir 'petcat.exe'
$xvic     = Join-Path $binDir 'xvic.exe'

# chain order - first entry is what -keybuf types at boot; each demo loads
# the next one itself from here on
$chain = @('sine', 'cos', 'sinecos', 'tan', 'unitcircle')

$workDir = Join-Path $env:TEMP ("vic20graphingdemos_" + [guid]::NewGuid().ToString("N"))
New-Item -ItemType Directory -Path $workDir | Out-Null

try {
    $suffix = if ($Commented) { '-commented.bas' } else { '.bas' }
    $loadAddr = if ($Commented) { '0401' } else { '1001' }

    foreach ($name in $chain) {
        $src = Join-Path $root "$name$suffix"
        if (-not (Test-Path $src)) { throw "Missing source file: $src" }
        # host filename is what the chain's LOAD"name",8,1 statements resolve
        # against on VICE's fs-device - uppercase, matching real CBM disk names
        $prg = Join-Path $workDir $name.ToUpper()
        & $petcat -w2 -l $loadAddr -o $prg -- $src
        if ($LASTEXITCODE -ne 0 -or -not (Test-Path $prg)) { throw "petcat failed to tokenize $src" }
    }

    $argList = @(
        # fs-device: serve $workDir as a real 1541 would a disk, so the
        # chain's own LOAD"next",8,1 calls resolve against it directly -
        # +drive8truedrive turns OFF cycle-exact drive emulation (which
        # would need an actual .d64 image) in favor of that, and
        # -trapdevice8 is what actually makes the KERNAL see a device
        # present on #8 in that mode (confirmed live: without it every
        # LOAD fails "DEVICE NOT PRESENT" even with the directory and
        # drive type set correctly)
        '+drive8truedrive', '-trapdevice8', '-drive8type', '1541', '-fs8', $workDir,
        '-keybuf', 'load\"sine\",8,1\nrun\n'
    )
    if ($Commented) { $argList += @('-memory', '3k') }
    if ($Warp) { $argList += '-warp' }

    Start-Process $xvic -ArgumentList $argList -Wait
} finally {
    Remove-Item -Recurse -Force $workDir -ErrorAction SilentlyContinue
}
