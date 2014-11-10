# Uninstall for spf13-vim
$packageName = 'spf13-vim'
$installDir = Join-Path $HOME '.spf13-vim-3'

try {
  Remove-Item -Recurse -Force $installDir

  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw
}