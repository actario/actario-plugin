# Actario installer for Windows. In PowerShell:
#
#   irm https://actario.app/install.ps1 | iex
#
# Downloads Actario with its own Node (nothing to install first) into
# %USERPROFILE%\.actario-app\runtime, checks it against the release's
# SHA256SUMS.txt, adds the actario command to your PATH, then installs the
# plugin into Claude Code and Codex if they are on this computer.
# Run it again to update.
#
#   $env:ACTARIO_VERSION = 'v0.2.13'   a specific release instead of the latest
#   $env:ACTARIO_APP_DIR = '<dir>'      install somewhere other than ~\.actario-app
#   $env:ACTARIO_DOWNLOAD_BASE = '<url>' fetch the release files from there (a mirror, a test server)
#
# Written for Windows PowerShell 5.1 as well as PowerShell 7. Never calls
# `exit`: under `| iex` that would close the window you typed it in.

function Install-Actario {
  $ErrorActionPreference = 'Stop'
  $ProgressPreference = 'SilentlyContinue'   # the progress bar makes 5.1's downloads many times slower
  try { [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12 } catch { }

  $repo = if ($env:ACTARIO_REPO) { $env:ACTARIO_REPO } else { 'actario/actario-plugin' }
  $version = if ($env:ACTARIO_VERSION) { $env:ACTARIO_VERSION } else { 'latest' }
  $app = if ($env:ACTARIO_APP_DIR) { $env:ACTARIO_APP_DIR } else { Join-Path $HOME '.actario-app' }

  # Windows on ARM runs the x64 build under emulation.
  $asset = 'actario-runtime-win-x64.zip'
  $base = if ($env:ACTARIO_DOWNLOAD_BASE) { $env:ACTARIO_DOWNLOAD_BASE } elseif ($version -eq 'latest') { "https://github.com/$repo/releases/latest/download" } else { "https://github.com/$repo/releases/download/$version" }

  $tmp = Join-Path ([IO.Path]::GetTempPath()) ("actario-" + [Guid]::NewGuid().ToString('N'))
  New-Item -ItemType Directory -Path $tmp | Out-Null
  try {
    Write-Host 'Downloading Actario for Windows ...'
    Invoke-WebRequest -UseBasicParsing -Uri "$base/SHA256SUMS.txt" -OutFile (Join-Path $tmp 'SHA256SUMS.txt')
    Invoke-WebRequest -UseBasicParsing -Uri "$base/$asset" -OutFile (Join-Path $tmp $asset)

    $want = $null
    foreach ($line in Get-Content (Join-Path $tmp 'SHA256SUMS.txt')) {
      $cols = $line.Trim() -split '\s+'
      if ($cols.Length -ge 2 -and $cols[1] -eq $asset) { $want = $cols[0].ToLower() }
    }
    if (-not $want) { throw "SHA256SUMS.txt does not list $asset" }
    $got = (Get-FileHash -Algorithm SHA256 -Path (Join-Path $tmp $asset)).Hash.ToLower()
    if ($got -ne $want) { throw "Checksum mismatch for $asset (got $got, expected $want). Nothing was installed." }

    New-Item -ItemType Directory -Force -Path $app | Out-Null
    $new = Join-Path $app 'runtime.new'
    if (Test-Path $new) { Remove-Item -Recurse -Force $new }
    New-Item -ItemType Directory -Path $new | Out-Null
    $tar = Join-Path $env:SystemRoot 'System32\tar.exe'
    if (Test-Path $tar) {
      & $tar -xf (Join-Path $tmp $asset) -C $new
      if ($LASTEXITCODE -ne 0) { throw 'Could not unpack the download.' }
    } else {
      Expand-Archive -Path (Join-Path $tmp $asset) -DestinationPath $new -Force
    }

    # A running Actario (Claude Code or Codex open) holds node.exe; Windows
    # will not move a folder with a running program in it.
    $current = Join-Path $app 'runtime'
    if (Test-Path $current) {
      $old = Join-Path $app ('runtime.old-' + (Get-Date -Format 'yyyyMMddHHmmss'))
      try { Rename-Item -Path $current -NewName (Split-Path $old -Leaf) }
      catch { throw 'Actario is running. Close Claude Code, Codex and the Claude and ChatGPT desktop apps, then run this again.' }
    }
    Rename-Item -Path $new -NewName 'runtime'
    Get-ChildItem -Path $app -Directory -Filter 'runtime.old-*' | ForEach-Object { Remove-Item -Recurse -Force $_.FullName -ErrorAction SilentlyContinue }
  } finally {
    Remove-Item -Recurse -Force $tmp -ErrorAction SilentlyContinue
  }

  # The actario command, for this window and new ones.
  $bin = Join-Path $app 'bin'
  $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
  if (-not (($userPath -split ';') -contains $bin)) {
    [Environment]::SetEnvironmentVariable('Path', ((@($userPath, $bin) | Where-Object { $_ }) -join ';'), 'User')
  }
  if (-not (($env:Path -split ';') -contains $bin)) { $env:Path = "$env:Path;$bin" }

  $node = Join-Path $app 'runtime\node\node.exe'
  & $node (Join-Path $app 'runtime\setup.mjs')
  if ($LASTEXITCODE -ne 0) { throw 'Setup did not finish (see above).' }
}

try { Install-Actario } catch { Write-Host "actario install: $($_.Exception.Message)" -ForegroundColor Red }
