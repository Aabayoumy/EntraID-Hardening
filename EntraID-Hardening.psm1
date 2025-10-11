# Dot-source all public functions
Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
    . $_.FullName
}

# Dot-source all private functions
Get-ChildItem -Path "$PSScriptRoot/Private/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
    . $_.FullName
}

# Export all public functions
$publicFunctions = Get-ChildItem -Path "$PSScriptRoot/Public/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object {
    (Get-Content $_.FullName | Select-String -Pattern '^function\s+([^\s{(]+)' | ForEach-Object { $_.Matches[0].Groups[1].Value })
} | Where-Object { $_ }
Export-ModuleMember -Function $publicFunctions
