$packageName = 'spf13.vim'
$installerType = 'EXE'
$vimUrl = 'http://ftp.vim.org/pub/vim/pc/gvim74.exe'
$spfUrl = 'https://github.com/spf13/spf13-vim/raw/3.0/spf13-vim-windows-install.cmd'
$silentArgs = '/S' 
$validExitCodes = @(0,1) 
Install-ChocolateyPackage "$packageName" "$installerType" "$silentArgs" "$vimUrl" -validExitCodes $validExitCodes
try { 
  $scriptPath = $(Split-Path -parent $MyInvocation.MyCommand.Definition)
  $cmdPath = Join-Path $scriptPath 'spf13-vim-windows-install.cmd'
  Get-ChocolateyWebFile "$packageName" "$cmdPath" "$spfUrl"
  Start-ChocolateyProcessAsAdmin $cmdPath -validExitCodes $validExitCodes
  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw
}