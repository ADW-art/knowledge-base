# Kill any existing forwarder
Get-Process -Name "python" -ErrorAction SilentlyContinue | Stop-Process -Force

# Start forwarder in background
$psi = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName = "python"
$psi.Arguments = "-u E:\code\MizukiBot\components\NapCat\qq_daily_forwarder.py"
$psi.RedirectStandardOutput = $true
$psi.RedirectStandardError = $true
$psi.UseShellExecute = $false
$psi.CreateNoWindow = $true
$p = [System.Diagnostics.Process]::Start($psi)

Start-Sleep 2
$resp = try { Invoke-WebRequest -Uri "http://127.0.0.1:9999" -UseBasicParsing -TimeoutSec 3 -ErrorAction Stop } catch { $null }
if ($resp) {
    Write-Output "Forwarder OK (PID: $($p.Id))"
} else {
    $stderr = $p.StandardError.ReadToEnd()
    Write-Output "Forwarder start FAILED"
    Write-Output $stderr
}
