# Opens this project's AVD with process-local Qt display settings.
[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidatePattern('^[A-Za-z0-9_.-]+$')]
    [string]$AvdName = 'Abrigo_Anjos_Test_API37',
    [string]$SdkRoot = (Join-Path $env:LOCALAPPDATA 'Android\Sdk')
)
$ErrorActionPreference = 'Stop'
$emulatorPath = Join-Path $SdkRoot 'emulator\emulator.exe'
if (-not (Test-Path -LiteralPath $emulatorPath -PathType Leaf)) {
    throw 'Emulador não encontrado. Informe -SdkRoot com o diretório do Android SDK.'
}
if (-not $PSCmdlet.ShouldProcess($AvdName, 'Abrir emulador com escala Qt fixa e SwiftShader')) {
    return
}
$running = Get-CimInstance Win32_Process | Where-Object {
    $_.Name -match '^(emulator|qemu-system-x86_64|qemu-system-x86_64-headless)\.exe$' -and
    $_.CommandLine -like "*-avd $AvdName *"
}
if ($running) {
    Write-Output 'Este AVD já está em execução. Para aplicar as opções de janela, feche-o e execute este iniciador novamente.'
    return
}
$androidUserDir = $env:ANDROID_USER_HOME
if (-not $androidUserDir) { $androidUserDir = Join-Path $env:USERPROFILE '.android' }
$overrides = [ordered]@{
    ANDROID_USER_HOME = $androidUserDir
    QT_ENABLE_HIGHDPI_SCALING = '0'
    QT_AUTO_SCREEN_SCALE_FACTOR = '0'
    QT_SCALE_FACTOR = '1'
    QT_OPENGL = 'desktop'
}
$previous = @{}
try {
    foreach ($entry in $overrides.GetEnumerator()) {
        $previous[$entry.Key] = [Environment]::GetEnvironmentVariable($entry.Key, 'Process')
        [Environment]::SetEnvironmentVariable($entry.Key, $entry.Value, 'Process')
    }
    $emulatorArgs = @(
        '-avd', $AvdName, '-no-snapshot-load', '-no-snapshot-save',
        '-no-boot-anim', '-noaudio', '-gpu', 'swiftshader',
        '-feature', '-Vulkan', '-no-metrics', '-memory', '4096'
    )
    Start-Process -FilePath $emulatorPath -ArgumentList $emulatorArgs -PassThru | Out-Null
    Write-Output 'Emulador iniciado. Aguarde o Android terminar de carregar.'
} finally {
    foreach ($name in $previous.Keys) {
        [Environment]::SetEnvironmentVariable($name, $previous[$name], 'Process')
    }
}
