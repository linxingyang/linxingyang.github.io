$p = 'd:\linxingyang\workspace\me-2017-07-14-linxingyang.github.io\copy-assets.ps1'
$c = [System.IO.File]::ReadAllText($p, [System.Text.Encoding]::UTF8)
[System.IO.File]::WriteAllText($p, $c, [System.Text.UTF8Encoding]::new($true))
Write-Host 'converted to UTF-8 BOM'
