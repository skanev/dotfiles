Set-StrictMode -Version Latest

$dotfilesDir = ($MyInvocation.MyCommand.Path | Split-Path | Split-Path)

function Expand-Path
{
    param (
        [string] $FileName
    )

    $FileName = Resolve-Path $FileName -ErrorAction SilentlyContinue -ErrorVariable _eperror

    if (-not($FileName))
    {
        $FileName = $_eperror[0].TargetObject
    }

    return $FileName
}

function Establish-Link
{
    param (
        [string]
        $source,

        [string]
        $target
    )


    $target = Join-Path $dotfilesDir $target
    $source = Expand-Path $source

    if (! (Test-Path $target))
    {
        throw "file $target does not exit"
    }

    $target = Resolve-Path $target

    if (! (Test-Path $source))
    {

        Write-Host "$source -> $target"
        $null = New-Item -ItemType SymbolicLink -Path $source -Target $target
	return
    }

    $file = Get-Item $source

    if ($file.LinkType -eq "SymbolicLink" -and $file.LinkTarget -eq $target)
    {
        Write-Host "already linked: $source"
    }
    else
    {
        throw "file $source already exists, but it's not linked to $target"
    }
}

function Establish-Path
{
    param(
        [string] $path
    )

    $null = New-Item -Path $path -ItemType Directory -Force
}


function Setup-AutoHotKeyEditor
{
    $editors = "neovide.exe", "gvim.exe", "notepad.exe"

    foreach ($editor in $editors)
    {
        $item = Get-Command $editor -ErrorAction SilentlyContinue

        if ($item)
        {
            $fullPath = $item.Source
            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\AutoHotkeyScript\Shell\Edit\Command" -Name "(default)" -Value "$fullPath %1"
            break
        }
    }
}


Establish-Path ~\AppData\Local\nvim
Establish-Path ~\Documents\PowerShell

Establish-Link ~\.vimrc             vimrc
Establish-Link ~\.vim               vim
Establish-Link ~\.gitconfig         gitconfig
Establish-Link ~\.config\powershell powershell

Establish-Link ~\Documents\PowerShell\profile.ps1 powershell\profile.ps1

Establish-Link ~\AppData\Local\nvim\init.vim nvim\init.vim

Establish-Link '~\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\Main.ahk' ahk\Main.ahk
