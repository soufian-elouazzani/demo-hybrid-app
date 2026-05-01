@echo off
echo [1/4] Generating version...
powershell -ExecutionPolicy Bypass -File "scripts\generate_version.ps1"

echo [2/4] Building .NET API...
cd dotnet
dotnet restore
dotnet publish -c Release -o ..\publish\dotnet
cd ..

echo [3/4] Building Delphi App...
rem Assumes RAD Studio command line is available
msbuild delphi\Project1.dproj /p:Config=Release /p:OutDir=..\publish\delphi\

echo [4/4] Packaging...
powershell Compress-Archive -Path publish\* -DestinationPath DemoApp_%VERSION%.zip -Force

echo Build complete!
