param([string]$VersionFile="version.json")

# Read or create version
if (Test-Path $VersionFile) {
    $version = Get-Content $VersionFile | ConvertFrom-Json
    $version.build = [int]$version.build + 1
} else {
    $version = @{
        major = 1
        minor = 0
        patch = 0
        build = 1
    }
}

# Generate SemVer
$semVer = "$($version.major).$($version.minor).$($version.patch).$($version.build)"
$fullVersion = "$($version.major).$($version.minor).$($version.patch)-build.$($version.build)"

# Save updated version
$version | ConvertTo-Json | Set-Content $VersionFile

# Create version headers for Delphi
$delphiVersion = "unit VersionInfo;`ninterface`nconst`n  APP_VERSION = '$fullVersion';`n  APP_BUILD = '$($version.build)';`nimplementation`nend."
$delphiVersion | Set-Content "delphi/VersionInfo.pas"

# Create for .NET
$dotnetVersion = @"
<Project>
  <PropertyGroup>
    <Version>$fullVersion</Version>
    <FileVersion>$semVer</FileVersion>
  </PropertyGroup>
</Project>
"@
$dotnetVersion | Set-Content "dotnet/Version.props"

Write-Host "Generated version: $fullVersion"
