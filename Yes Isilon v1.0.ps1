<#
    Title: Yes Isilon v1.0
    Copyright© 2024 Magdy Aloxory. All rights reserved.
    Contact: maloxory@gmail.com
#>

# Check if the script is running with administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Relaunch the script with administrator privileges
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    exit
}

# Function to center text
function CenterText {
    param (
        [string]$text,
        [int]$width
    )
    
    $textLength = $text.Length
    $padding = ($width - $textLength) / 2
    return (" " * [math]::Max([math]::Ceiling($padding), 0)) + $text + (" " * [math]::Max([math]::Floor($padding), 0))
}

# Function to create a border
function CreateBorder {
    param (
        [string[]]$lines,
        [int]$width
    )

    $borderLine = "+" + ("-" * $width) + "+"
    $borderedText = @($borderLine)
    foreach ($line in $lines) {
        $borderedText += "|$(CenterText $line $width)|"
    }
    $borderedText += $borderLine
    return $borderedText -join "`n"
}

# Display script information with border
$title = "Yes Isilon v1.0"
$copyright = "Copyright 2024 Magdy Aloxory. All rights reserved."
$contact = "Contact: maloxory@gmail.com"
$maxWidth = 60

$infoText = @($title, $copyright, $contact)
$borderedInfo = CreateBorder -lines $infoText -width $maxWidth

Write-Host $borderedInfo -ForegroundColor Cyan



# Define the URL for AutoHotkey download
$ahkDownloadUrl = "https://www.autohotkey.com/download/ahk-v2.exe"
$tempInstallerPath = "$env:TEMP\ahk-v2.exe"
$ahkInstallPath = "C:\Program Files\AutoHotkey\v2"
$ahkExecutable = "$ahkInstallPath\AutoHotkey64.exe"

# Function to download and install AutoHotkey if not installed
function Install-AutoHotkey {
    # Download the AutoHotkey installer
    Write-Host "Downloading YesIsilon..."
    Invoke-WebRequest -Uri $ahkDownloadUrl -OutFile $tempInstallerPath

    # Install AutoHotkey silently
    Write-Host "Installing YesIsilon..."
    Start-Process -FilePath $tempInstallerPath -ArgumentList "/SILENT" -Wait -NoNewWindow

    Write-Host "YesIsilon installed successfully."

    # Clean up the installer
    Remove-Item $tempInstallerPath -Force
}

# Check if AutoHotkey is installed
if (-Not (Test-Path $ahkExecutable)) {
    # Run the script as Administrator if it's not already
    if (-Not [System.Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544') {
        Write-Host "Running script as administrator..."
        $arguments = "& '" + $myinvocation.mycommand.definition + "'"
        Start-Process powershell -ArgumentList $arguments -Verb runAs
        exit
    }

    Install-AutoHotkey
}

# Define the AutoHotkey script as a string
$ahkScript = @"
F8:: {
    Loop {
        SendInput("yes{Enter}")
        Sleep(100)  ; Adjust the sleep time if needed
    }
}

F9::ExitApp
"@

# Define the path for the temporary AutoHotkey script
$tempScriptPath = "$env:TEMP\YesLoop.ahk"

# Write the AutoHotkey script to the temporary file
Set-Content -Path $tempScriptPath -Value $ahkScript

# Run the AutoHotkey script
if (Test-Path $ahkExecutable) {
    Start-Process -FilePath $ahkExecutable -ArgumentList $tempScriptPath
} else {
    Write-Host "AutoHotkey executable not found."
}

# Create a simple instruction window
Add-Type -AssemblyName PresentationFramework

[System.Windows.MessageBox]::Show("Press F8 to start typing 'yes' repeatedly.`nPress F9 to stop.", "Instructions")
