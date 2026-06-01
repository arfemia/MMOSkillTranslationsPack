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

$excludeNames = @(
    'MMOSkillTranslationsPack.zip',  # the built artifact itself
    'README.md', 'CURSEFORGE.md', 'CLAUDE.md',  # repo docs, not for players
    'LICENSE', '.gitignore'  # repo metadata
)
$files = Get-ChildItem -Path $pack -Recurse -File -Force | Where-Object {
    $_.Name -notin $excludeNames -and
    $_.FullName -notlike "$pack\tools\*" -and
    $_.FullName -notlike "$pack\.git\*" -and
    $_.FullName -notlike "$pack\.github\*"
}

# Hytale's I18nModule.loadMessagesFromPack uses Files.isDirectory(pack.getRoot()
# .resolve("Server").resolve("Languages")) before scanning. Java's ZipFileSystem
# returns false for that check when the zip has no explicit directory entries,
# so we emit one for every ancestor path of each file before writing the file
# itself. Gradle's jar builder does this automatically; the bare .NET zip API
# does not.
$createdDirs = @{}
foreach ($f in $files) {
    $rel = $f.FullName.Substring($pack.Length + 1).Replace('\', '/')

    $parts = $rel -split '/'
    for ($i = 1; $i -lt $parts.Length; $i++) {
        $dir = ($parts[0..($i - 1)] -join '/') + '/'
        if (-not $createdDirs.ContainsKey($dir)) {
            $dirEntry = $zip.CreateEntry($dir, [IO.Compression.CompressionLevel]::NoCompression)
            $dirEntry.Open().Close()
            $createdDirs[$dir] = $true
        }
    }

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
