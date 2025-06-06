$required_version = 24.2.1
Write-Host 'Installing MilestonePSTools'
Install-Module MilestonePSTools -RequiredVersion $required_version -Scope CurrentUser -Force -ErrorAction Stop -SkipPublisherCheck -AllowClobber
Write-Host 'Installing Module done'