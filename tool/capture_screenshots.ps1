param([string]$DeviceId = 'emulator-5556')
$ErrorActionPreference = 'Stop'
$ecobiRoot = Split-Path -Parent $PSScriptRoot
Push-Location $ecobiRoot
try {
    $env:ECOBI_DEVICE_ID = $DeviceId
    flutter drive --keep-app-running --driver=test_driver/integration_test.dart --target=integration_test/screenshots_test.dart -d $DeviceId
    if ($LASTEXITCODE -ne 0) { throw 'Emulator screenshot test failed. Check the test output.' }
} finally { Pop-Location }
