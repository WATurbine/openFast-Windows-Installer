# Powershell script to install OpenFast on Windows
# Date Created: November 9th, 2024
# Date Modified: November 21st, 2024
# Authored By: Alexander (Xander) Hayhoe
# email: amwhayho@uwaterloo.ca
# Release Version: 1

# Please open a GitHub Issue if you have any modification you would like made to this script.
# please run in an elevated Powershell terminal

# DESCRIPTION
# OpenFAST Installation Script using Cygwin on Windows


# Ensure the script is run as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Please run this script as an Administrator."
    exit
}

# Variables
$cygwinInstallerUrl = "https://www.cygwin.com/setup-x86_64.exe"
$cygwinInstallerPath = "$env:TEMP\setup-x86_64.exe"
$cygwinRoot = "C:\cygwin64"
$packages = @(
    # Development tools
    'gcc-core',          # C compiler
    'gcc-g++',           # C++ compiler
    'gcc-fortran',       # Fortran compiler
    'make',             
    'git',               
    'cmake',             
    # Libraries
    'liblapack0',
    'liblapack-devel',
    'libblas0',
    'libblas-devel',
    'libfftw3_3',
    'libfftw3-devel'
)

# Step 1: Download the Cygwin Installer
Write-Host "Downloading the Cygwin installer..."
Invoke-WebRequest -Uri $cygwinInstallerUrl -OutFile $cygwinInstallerPath -UseBasicParsing

# Step 2: Install Cygwin with Required Packages
Write-Host "Installing Cygwin and required packages..."
$packageList = $packages -join ','
$arguments = @(
    "--quiet-mode",
    "--root", $cygwinRoot,
    "--local-package-dir", "$env:TEMP\cygwin_packages",
    "--site", "https://mirrors.kernel.org/sourceware/cygwin/",
    "--packages", $packageList
)
Start-Process -FilePath $cygwinInstallerPath -ArgumentList $arguments -Wait

# Step 3: Verify Cygwin Installation
if (-not (Test-Path $cygwinRoot)) {
    Write-Host "Cygwin installation failed."
    exit
} else {
    Write-Host "Cygwin installed successfully."
}

# Step 4: Build OpenFAST within Cygwin
Write-Host "Building OpenFAST within Cygwin..."

# Create a script to run inside Cygwin
$cygwinScript = @"
#!/bin/bash
set -e

# Navigate to the home directory
cd /home/$env:USERNAME

# Clone OpenFAST repository if it doesn't exist
if [ ! -d "openfast" ]; then
    echo "Cloning OpenFAST repository..."
    git clone https://github.com/OpenFAST/openfast.git
else
    echo "OpenFAST repository already exists."
fi

# Navigate to OpenFAST directory
cd openfast

# Create build directory
mkdir -p build
cd build

# Run CMake to configure the build
cmake .. -DBUILD_SHARED_LIBS=ON

# Build OpenFAST using make
make -j\$(nproc)

# Verify the build
if [ -f "openfast.exe" ]; then
    echo "OpenFAST has been built successfully."
else
    echo "OpenFAST build failed."
    exit 1
fi

# Clone OpenFAST test cases if they don't exist
cd /home/$env:USERNAME
if [ ! -d "openfast-testcases" ]; then
    echo "Cloning OpenFAST test cases repository..."
    git clone https://github.com/OpenFAST/openfast-testcases.git
else
    echo "OpenFAST test cases repository already exists."
fi

# Run a sample test case
echo "Running a sample test case..."
cd openfast-testcases/r-test/glue-codes/openfast/5MW_Baseline

# Copy the openfast executable
cp /home/$env:USERNAME/openfast/build/openfast.exe .

# Run the test case
./openfast.exe 5MW_Land_BD_DLL_WTurb.inp

echo "Test case completed."

"@

# Save the script to a temporary file with Unix-style line endings
$cygwinScriptPath = "$env:TEMP\build_openfast.sh"
$cygwinScript -replace "`r`n", "`n" | Set-Content -Path $cygwinScriptPath -Encoding UTF8

# Convert the Windows path to a Unix-style path using cygpath
$cygwinScriptPathUnix = & "$cygwinRoot\bin\cygpath.exe" -u "$cygwinScriptPath"

# Run the script inside Cygwin
& "$cygwinRoot\bin\bash.exe" --login -c "/usr/bin/bash '$cygwinScriptPathUnix'"

Write-Host "OpenFAST installation and test completed."