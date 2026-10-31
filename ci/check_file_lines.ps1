# File Line Count Checker Script (Governance G-1)
# Ceiling: Max 250 lines (Exit code 1 if violated)
# Warning: > 100 lines

param(
    [string]$TargetDir = "."
)

$maxLimit = 250
$warnLimit = 100
$violations = @()
$warnings = @()
$totalFiles = 0

$files = Get-ChildItem -Path $TargetDir -Recurse -Include *.go, *.dart | Where-Object {
    $_.FullName -notmatch "(\.dart_tool|\\build\\|\\canvaskit\\|node_modules|vendor)"
}

Write-Host "Checking $($files.Count) source files in $TargetDir..."

foreach ($f in $files) {
    $totalFiles++
    $lines = (Get-Content $f.FullName).Count
    $relPath = $f.FullName.Replace((Get-Location).Path + "\", "")

    if ($lines -gt $maxLimit) {
        $violations += [PSCustomObject]@{ Path = $relPath; Lines = $lines }
    } elseif ($lines -gt $warnLimit) {
        $warnings += [PSCustomObject]@{ Path = $relPath; Lines = $lines }
    }
}

if ($violations.Count -gt 0) {
    Write-Host "`n[FAIL] Found $($violations.Count) files exceeding $maxLimit lines:" -ForegroundColor Red
    $violations | Sort-Object Lines -Descending | Format-Table -AutoSize
    exit 1
} else {
    Write-Host "`n[PASS] 0 files exceed $maxLimit lines! (Total checked: $totalFiles)" -ForegroundColor Green
    if ($warnings.Count -gt 0) {
        Write-Host "[INFO] $($warnings.Count) files exceed $warnLimit lines (warning threshold):" -ForegroundColor Yellow
        $warnings | Sort-Object Lines -Descending | Format-Table -AutoSize
    }
    exit 0
}

