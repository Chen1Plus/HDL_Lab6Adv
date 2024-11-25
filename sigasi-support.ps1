#Requires -Version 5

$ROOT_DIR = "C:\Users\1plus\Documents\HWD\Lab6Adv"

$SIGASI_DIR = "$ROOT_DIR\src\.sigasi-support"

Remove-Item $SIGASI_DIR -Recurse -Force
New-Item -Path "$ROOT_DIR\src" -Name ".sigasi-support" -ItemType "Directory"

$IP_DIR = "$ROOT_DIR\src\ip"

Copy-Item "$IP_DIR\Clk8MHz\Clk8MHz_stub.v" -Destination $SIGASI_DIR
