$required_version = '24.2.1'
Write-Output 'Installing module'
Install-Module MilestonePSTools -RequiredVersion $required_version -Force -SkipPublisherCheck -Scope CurrentUser
Write-Output 'Installing Module done'