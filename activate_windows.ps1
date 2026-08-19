if ((Get-CimInstance SoftwareLicensingProduct -Filter "Name like 'Windows%'" | Where-Object { $\_.PartialProductKey } | Select-Object -ExpandProperty LicenseStatus) -eq 1) {
    Write-Host Windows is Activated
} else {
    $key=(Get-WmiObject -query 'select * from SoftwareLicensingService').OA3xOriginalProductKey
    slmgr /ipk $key
    slmgr /ato

    Write-Host "Windows is now activated. Please Reboot for changes to take effect."
}