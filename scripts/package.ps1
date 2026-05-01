param([string]$Config="Release")

$version = (Get-Content version.json | ConvertFrom-Json)
$packageName = "DemoApp_$($version.major).$($version.minor).$($version.patch).$($version.build)"

# Create package structure
$packageDir = "packages\$packageName"
New-Item -ItemType Directory -Force -Path $packageDir | Out-Null

# Copy artifacts
Copy-Item "publish\dotnet\*" "$packageDir\api\" -Recurse -Force
Copy-Item "publish\delphi\*" "$packageDir\client\" -Recurse -Force
Copy-Item "database\schema.sql" "$packageDir\database\" -Force

# Create deployment script
@"
# Deploy instructions
# 1. Run database\schema.sql on SQL Server
# 2. Start API: cd api && dotnet DemoApi.dll
# 3. Run Delphi client executable
"@ | Set-Content "$packageDir\README.txt"

# Create ZIP
Compress-Archive -Path "$packageDir\*" -DestinationPath "$packageName.zip" -Force
Write-Host "Package created: $packageName.zip"
