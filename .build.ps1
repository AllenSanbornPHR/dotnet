# Synopsis: Build the solution
task build _ensure-dotnet, {
    dotnet build
}

# Synopsis: Clean the solution
task clean _ensure-dotnet, {
    dotnet clean
}

# Synopsis: Test the solution
task test _ensure-dotnet, build, {
    dotnet test
}

# Synopsis: Update dependencies to latest patch version
task update-patch _ensure-dotnet-outdated, libyear, {
    dotnet outdated --recursive --upgrade --version-lock Minor
}

# Synopsis: Update dependencies to latest minor version
task update-minor _ensure-dotnet-outdated, libyear, {
    dotnet outdated --recursive --upgrade --version-lock Major
}

# Synopsis: Update dependencies to latest version
task update-major _ensure-dotnet-outdated, libyear, {
    dotnet outdated --recursive --upgrade
}

# Synopsis: Generate libyear report for old dependencies
task libyear _ensure-libyear, {
    dotnet-libyear
}

Function Test-CommandExists {
    Param ($command)
    # https://devblogs.microsoft.com/scripting/use-a-powershell-function-to-see-if-a-command-exists/
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try { if (Get-Command $command) { $true } }
    Catch { $false }
    Finally { $ErrorActionPreference = $oldPreference }
}

# Synopsis:
task _ensure-dotnet-outdated _ensure-dotnet, {
    if (-not(Test-CommandExists dotnet-outdated)) {
        dotnet tool install --global dotnet-outdated-tool
    }

    if (Test-CommandExists dotnet-outdated) {
        Write-Host "Dotnet Outdated is installed."
    }
    else {
        Write-Host "Dotnet Outdated installation failed."
        exit
    }
}

# Synopsis: Ensure that dotnet libyear is installed
task _ensure-libyear _ensure-dotnet, {
    if (-not(Test-CommandExists dotnet-libyear)) {
        throw "dotnet libyear is not installed"
    }
    if (-not(Test-CommandExists dotnet-libyear)) {
        dotnet tool install --global libyear
    }

    if (Test-CommandExists dotnet-libyear) {
        Write-Host "Dotnet libyear is installed."
    }
    else {
        Write-Host "Dotnet libyear installation failed."
        exit
    }
}

# Synopsis: Ensure that dotnet is installed
task _ensure-dotnet {
    if (-not(Test-CommandExists "dotnet")) {
        throw "dotnet is not installed"

        # Download the dotnet installer
        $installerUrl = "https://dot.net/v1/dotnet-install.ps1"
        $installerPath = "$env:TEMP\dotnet-install.ps1"
        Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath

        # Run the installer
        & $installerPath -InstallDir "$env:ProgramFiles\dotnet"

        # Add dotnet to the PATH environment variable
        $env:PATH += ";$env:ProgramFiles\dotnet"
    }
    if (Test-CommandExists dotnet) {
        Write-Host "Dotnet is installed."
    }
    else {
        Write-Host "Dotnet installation failed."
        exit
    }
}