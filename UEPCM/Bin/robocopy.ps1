$source = $args[0]
$destination = $args[1]

# Get total number of files in source directory
$fileCount = (Get-ChildItem -Path $source -Recurse -File).Count

# Define parameters for robocopy command
$robocopyParams = "/move /s /e `"$source`" `"$destination`" /njh /njs /ndl"

# Execute robocopy command and display progress bar
$index = 0
$lastProgress = 0
$progressBarWidth = 50
Start-Process -FilePath robocopy -ArgumentList $robocopyParams -NoNewWindow -Wait -PassThru | ForEach-Object {
    if ($_ -match "\d+") {
        try {
            $index++
            $progress = [int]($_ -split '\s+')[-2] / $fileCount * 100
            if ($progress -gt $lastProgress) {
                $lastProgress = $progress
                $bar = "-" * [int]($progress / 100 * $progressBarWidth)
                Write-Host "`r$($progress.ToString("0"))% [$bar] $($progressBarWidth - $bar.Length) files remaining"
            }
        } catch {
            # Ignore any lines that can't be converted to an integer
        }
    }
}

# Remove progress bar once robocopy command completes
Write-Host "`r100% [$("-" * $progressBarWidth)] 0 files remaining"
