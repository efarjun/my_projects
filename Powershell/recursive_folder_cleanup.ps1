.Deletes everything under each target folder but keeps the folder itself. It uses Get-ChildItem + Remove-Item, logs actions, and handles errors without stopping the whole run.


$TargetFolders = @(
)

foreach ($Folder in $TargetFolders) {
    if (-not (Test-Path -LiteralPath $Folder -PathType Container)) {
        Write-Warning "Folder not found: $Folder"
        continue
    }

    Write-Host "Cleaning contents of: $Folder" -ForegroundColor Cyan

    try {
        # Remove all subdirectories first
        Get-ChildItem -LiteralPath $Folder -Directory -Force -ErrorAction Stop |
            ForEach-Object {
                Write-Host "  Deleting directory: $($_.FullName)"
                Remove-Item -LiteralPath $_.FullName -Recurse -Force -ErrorAction Stop
            }

        # Then remove files in the root of the folder
        Get-ChildItem -LiteralPath $Folder -File -Force -ErrorAction Stop |
            ForEach-Object {
                Write-Host "  Deleting file: $($_.FullName)"
                Remove-Item -LiteralPath $_.FullName -Force -ErrorAction Stop
            }

        Write-Host "Completed: $Folder" -ForegroundColor Green
    }
    catch {
        Write-Warning "Error cleaning '$Folder': $($_.Exception.Message)"
    }
}
