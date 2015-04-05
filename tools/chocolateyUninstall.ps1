# Uninstall for spf13-vim
$packageName = 'spf13-vim'
$installDir = Join-Path $HOME '.spf13-vim-3'

# Test whether path is a symlink, from http://stackoverflow.com/a/818054/
function Test-ReparsePoint([string]$path) {
  $file = Get-Item $path -Force -ea 0
  return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

function Remove-SymLink([string]$path)
{
    # Only remove if it's a symlink.
    If (Test-ReparsePoint $path)
    {
        If (Test-Path -PathType Container $path)
        {
            # rmdir safely deletes the directory symlink, without deleting its
            # contents (http://superuser.com/a/306618/)
            Invoke-Expression "cmd /c rmdir $path"
        }
        Else
        {
            Invoke-Expression "cmd /c del $path"
        }
    }
}

try {
  Write-Host "Deleting symbolic links"
  # Delete the symbolic links
  Remove-Symlink "$HOME\.vimrc"
  Remove-Symlink "$HOME\_vimrc"
  Remove-Symlink "$HOME\.vimrc.fork"
  Remove-Symlink "$HOME\.vimrc.bundles"
  Remove-Symlink "$HOME\.vimrc.bundles.fork"
  Remove-Symlink "$HOME\.vimrc.before"
  Remove-Symlink "$HOME\.vimrc.before.fork"
  Remove-Symlink "$HOME\.vim"

  Remove-Item -Recurse -Force $installDir
  
  Write-ChocolateySuccess "$packageName"
} catch {
  Write-ChocolateyFailure "$packageName" "$($_.Exception.Message)"
  throw
}
