Set-StrictMode -Version Latest

Set-PSReadLineOption -EditMode Emacs

if (Get-Command "nvim" -ErrorAction SilentlyContinue)
{
    $ENV:GIT_EDITOR = "nvim"
}

$aliases = @{
    gs = "git status"
    gc = "git commit"
    gp = "git push"
    gds = "git diff --staged"
}

if (Get-Command "neovide.exe" -ErrorAction SilentlyContinue)
{
    $aliases["vig"] = "neovide.exe --multigrid"
}

foreach ($alias in $aliases.Keys)
{
    $value = $aliases[$alias]
    Remove-Alias $alias -Force -ErrorAction SilentlyContinue
    Invoke-Expression "function $alias { $value `$args }"
}

function prompt()
{
    "» "
}
