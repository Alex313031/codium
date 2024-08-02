# powershell -ExecutionPolicy ByPass -File .\build\build.ps1

# first so `bash` is the one installed with `git`, avoid conflict with WSL
$env:Path = "C:\Program Files\Git\bin;" + $env:Path

set CFLAGS="-DNDEBUG -msse3 -O3 -g0 -s"
set CXXFLAGS="-DNDEBUG -msse3 -O3 -g0 -s"
set CPPFLAGS="-DNDEBUG -msse3 -O3 -g0 -s"
set LDFLAGS="-Wl,-O3 -msse3 -s"

bash ./build/build.sh
