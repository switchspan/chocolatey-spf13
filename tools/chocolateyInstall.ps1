# Install script for spf13
$packageName = 'spf13-vim'
$validExitCodes = @(0,1) 

# Download and install spf13
try { 
  $scriptPath = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
  $cmdPath = Join-Path $scriptPath 'spf13-vim-windows-install.ps1'

  Start-ChocolateyProcessAsAdmin $cmdPath -validExitCodes $validExitCodes
  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw
}