# spf13-vim Copyright 2014 Steve Francia
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Check to see if we are running as admin
If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Warning "You do not have Administrator rights to run this script!`nPlease re-run this script as an Administrator!"
    Break
}

# Script Functions
Function New-SymLink
{
    Param(
        [parameter(Mandatory=$true)]
        [String]
        $Link,

        [parameter(Mandatory=$true)]
        [String]
        $Target,

        [parameter(Mandatory=$false)]
        [ValidateSet("File", "Directory")]
        [String]
        $Type = "File"
    )

    # This function isn't compatible with pipeline input, so execute only once.
    # Defining only the End block is equivalent to not defining any of the
    # Begin, Process or End blocks.
    End
    {
        If ($Type -eq "File")
        {
            $command = "cmd /c mklink"
        }
        # Parameter was validated as either "File" or "Directory", so it's
        # definitely a Directory symlink.
        Else
        {

            $command = "cmd /c mklink /d"
        }

        Try 
        {
            $ErrorActionPreference = "Stop"
            invoke-expression "$command $link $target"
        } 
        Catch [System.Exception]
        {
            Write-Warning "Symbolic link '$link' already exists for '$target'"
        }
    }
}

Function Get-ApplicationPath ($appName, $errorMessage, $errorCode)
{
    Try 
    {
        $ErrorActionPreference = "Stop"
        $applicationPath = (Get-Command ($appName)).Path
        Write-Host "$appName installed in `"$applicationPath`"."
        Return $applicationPath
    } 
    Catch
    {
        Write-Error $errorMessage
        Exit $errorCode
    }
}


# Main Script Execution
$appDirectory = Join-Path $HOME ".spf13-vim-3"
$bundleDirectory = Join-Path $appDirectory ".vim/bundle"
$bundleLink = Join-Path $appDirectory ".vimrc.bundles"
$vundleDirectory = Join-Path $HOME ".vim/bundle/vundle"

Try {

    Write-Host "-= Installing spf13-vim =-"
    Write-Host "Checking for installation dependencies:"
    $gitCommand = Get-ApplicationPath "git" "Git not found! The git commandline must be installed before running this script" -1
    $curlCommand = Get-ApplicationPath "curl" "Curl not found! The curl commandline must be installed before running this script" -3
    $gvimCommand = Get-ApplicationPath "vim" "Gvim not found! The gvim 7.4 or greater must be installed before running this script" -2

    If (-Not (Test-Path $appDirectory))
    {
        Write-Host "The spf13 application directory '$appDirectory' was not found."
        Set-Location $HOME
        & $gitCommand clone --recursive -b 3.0 https://github.com/spf13/spf13-vim.git "$appDirectory"
    } 
    Else
    {
        Write-Host "The spf13 application directory '$appDirectory' was found."
        Set-Location $appDirectory
        Write-Host "Updating spf13-vim"
        & $gitCommand pull
        Set-Location $HOME
    }

    # Create the symbolic links
    New-SymLink "$HOME\.vimrc" "$appDirectory\.vimrc"
    New-SymLink "$HOME\_vimrc" "$appDirectory\.vimrc"
    New-SymLink "$HOME\_vimrc" "$appDirectory\.vimrc"
    New-SymLink "$HOME\.vimrc.fork" "$appDirectory\.vimrc.fork"
    New-SymLink "$HOME\.vimrc.bundles" "$appDirectory\.vimrc.bundles"
    New-SymLink "$HOME\.vimrc.bundles.fork" "$appDirectory\.vimrc.bundles.fork"
    New-SymLink "$HOME\.vimrc.before" "$appDirectory\.vimrc.before"
    New-SymLink "$HOME\.vimrc.before.fork" "$appDirectory\.vimrc.before.fork"
    New-SymLink "$HOME\.vim" "$appDirectory\.vim" "Directory"

    # Check to see If the bundle directory exists, if not, create it
    If (-Not (Test-Path $bundleDirectory))
    {
        Write-Host "Creating vim bundle directory: $bundelDirectory"
        New-Item -ItemType directory -Path $bundleDirectory
    }

    # Check for vundle
    If (-Not (Test-Path $vundleDirectory))
    {
        & $gitCommand clone https://github.com/gmarik/vundle.git "$vundleDirectory"
   
    } 
    Else
    {
        Set-Location $vundleDirectory
        & $gitCommand pull
        Set-Location $HOME
    }

    # Run vim and install the bundles
    Write-Host "Launching another process to finish installing the spf13-vim bundles..."
    Write-Host "HAVE PATIENCE: This could take a while!"
    Start-Process -FilePath $gvimCommand -ArgumentList "-u `"$bundleLink`" +BundleInstall! +BundleClean +qall"
}
Catch 
{
    Write-Warning "Could not install spf13-vim!"
    Write-Warning $_
} 
