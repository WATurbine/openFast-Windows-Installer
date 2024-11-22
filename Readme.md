# Windows Installation:

## Setup:

First, we need to prepare the machine to run powershell: \

```powershell
set-executionpolicy remotesigned
```

\
Next, please to go Search -> Powershell -> (Right-click) Run as Administrator \
From this shell, run the following: \
`cd ~` \
`mkdir openFast-installation` \
`cd openFast-installation` \
`git clone git@github.com:WATurbine/openFast-Windows-Installer.git` \
if you do not have ssh set up on GitHub, you can use HTTPS: \
`git clone https://github.com/WATurbine/openFast-Windows-Installer.git` \
`cd openFast-Windows-Installer` \
`./setup.ps1` \
Execution will take a while, so feel free to minimize the shell and go do something else while it installs in the background. \
