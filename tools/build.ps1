# Rebuild MMOSkillTranslationsPack.zip from the Server/ tree.
#
# Hytale's asset loader silently drops zip entries that use backslash
# separators on Windows, which is what Compress-Archive emits. Use the
# lower-level [IO.Compression.ZipFile] API + manually rewrite each entry
# path to forward slashes. Same pattern as skill-mastery-pack/tools/.
#
# Pass "install" as an argument to also copy the built zip into the
# local Hytale mods directory for live testing.

param(
    [string]$Action = ""
)

$pack = Split-Path -Parent $PSScriptRoot
$zipPath = Join-Path $pack 'MMOSkillTranslationsPack.zip'

Remove-Item $zipPath -ErrorAction SilentlyContinue
Add-Type -A 'System.IO.Compression.FileSystem'
$zip = [IO.Compression.ZipFile]::Open($zipPath, 'Create')

$excludeNames = @('MMOSkillTranslationsPack.zip', 'README.md', 'CURSEFORGE.md', 'CLAUDE.md')
$files = Get-ChildItem -Path $pack -Recurse -File | Where-Object {
    $_.Name -notin $excludeNames -and
    $_.FullName -notlike "$pack\tools\*" -and
    $_.FullName -notlike "$pack\.git\*"
}

foreach ($f in $files) {
    $rel = $f.FullName.Substring($pack.Length + 1).Replace('\', '/')
    $entry = $zip.CreateEntry($rel, [IO.Compression.CompressionLevel]::Optimal)
    $stream = $entry.Open()
    $bytes = [IO.File]::ReadAllBytes($f.FullName)
    $stream.Write($bytes, 0, $bytes.Length)
    $stream.Close()
}
$zip.Dispose()

Write-Host "Built $zipPath"

if ($Action -eq 'install') {
    $dest = 'D:\Games\Hytale\UserData\Mods\MMOSkillTranslationsPack.zip'
    Copy-Item $zipPath $dest -Force
    Write-Host "Installed to $dest"
}
