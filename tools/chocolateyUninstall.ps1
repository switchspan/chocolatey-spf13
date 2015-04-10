# Uninstall for spf13-vim
$packageName = 'spf13-vim'
$installDir = Join-Path $HOME '.spf13-vim-3'

# Test whether path is a symlink, from http://stackoverflow.com/a/818054/
function Test-ReparsePoint([string]$path) {
  $file = Get-Item $path -Force -ea 0
  return [bool]($file.Attributes -band [IO.FileAttributes]::ReparsePoint)
}

function Test-SymLinkTargetsSpf13Directory([string]$Path)
{
    # PowerShell can't deal with symlinks. Call cmd.exe's dir, parse the output
    # and return true if there are any objects returned.
    # The regular expression checks if the symlink points to the .spf13-vim
    # directory in the user's directory, i.e. the symlink is from when the user
    # installed spf13-vim.
    # For example, a .vimrc symlink that still points to the .spf13-vim
    # directory looks like the following:
    # 10/04/2015  18:39    <SYMLINK>      .vimrc [C:\Users\john\.spf13-vim-3\.vimrc]
    return (cmd /c dir $Path `
                | Select-String -Pattern "\[$([regex]::Escape($HOME))\\\.spf13\-vim\-3.+\]$" `
                | Measure `
                | select -ExpandProperty Count) `
            -gt 0
}

function Remove-SymLink([string]$path)
{
    # If the symlink doesn't target the spf13-vim directory the user might have
    # repurposed it, so we shouldn't delete it.
    If ((Test-ReparsePoint $path) -and (Test-SymLinkTargetsSpf13Directory $path))
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
