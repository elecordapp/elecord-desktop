# script to streamline elecord-desktop local windows build process

# function to confirm and execute a command
function Confirm-And-Execute {
    param (
        [Parameter(Mandatory=$true)]
        [string]$CommandDescription,
        
        [Parameter(Mandatory=$true)]
        [ScriptBlock]$CommandBlock
    )
    
    Write-Host "`n--------------------------------------------------------`n" -ForegroundColor DarkCyan
    Write-Host "About to execute: $CommandDescription" -ForegroundColor DarkCyan
    $response = Read-Host "Do you want to proceed? (Y/N)"
    if ($response -match '^[Yy]') {
        Write-Host "`nExecuting: $CommandDescription`n" -ForegroundColor DarkCyan
        & $CommandBlock
        if ($LASTEXITCODE) {
            Write-Host "`nCommand exited with code $LASTEXITCODE`n" -ForegroundColor DarkCyan
        }
    }
    else {
        Write-Host "`nSkipping: $CommandDescription`n" -ForegroundColor DarkCyan
    }
}

# step 1: yarn install
Confirm-And-Execute -CommandDescription "yarn install" -CommandBlock { yarn install }

# step 2: yarn run fetch
Confirm-And-Execute -CommandDescription 'yarn run fetch' -CommandBlock {
    yarn run fetch --noverify --cfgdir ".\elecord.app\release\"
}

# step 3: yarn run build
Confirm-And-Execute -CommandDescription "yarn run build" -CommandBlock { yarn run build }

# step 4: Delete specified files and directories
$deleteDescription = "Delete generated files and directories"
Confirm-And-Execute -CommandDescription $deleteDescription -CommandBlock {
    # delete files
    if (Test-Path -Path "webapp.asar") {
        Remove-Item -Path "webapp.asar" -Force -ErrorAction SilentlyContinue
        Write-Host "Deleted file: webapp.asar" -ForegroundColor DarkCyan
    } else {
        Write-Host "File not found: webapp.asar" -ForegroundColor DarkCyan
    }

    # delete directories
    $directories = @("packages", "lib", "dist", "deploys")
    foreach ($dir in $directories) {
        if (Test-Path -Path $dir) {
            Remove-Item -Path $dir -Recurse -Force -ErrorAction SilentlyContinue
            Write-Host "Deleted directory: $dir" -ForegroundColor DarkCyan
        } else {
            Write-Host "Directory not found: $dir" -ForegroundColor DarkCyan
        }
    }
}

Write-Host "`n--------------------------------------------------------`n" -ForegroundColor DarkCyan
Write-Host "All commands processed." -ForegroundColor DarkCyan

