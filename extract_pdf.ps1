$docxPath = "c:\oops_folder\Project_DSA\Traffic_Flow_Optimization_Report_v2.docx"
$outputPath = "c:\oops_folder\Project_DSA\docx_text.txt"

Add-Type -AssemblyName "System.IO.Compression.FileSystem"

$zip = [System.IO.Compression.ZipFile]::OpenRead($docxPath)
$entry = $zip.Entries | Where-Object { $_.FullName -eq "word/document.xml" }
$stream = $entry.Open()
$reader = New-Object System.IO.StreamReader($stream)
$xmlContent = $reader.ReadToEnd()
$reader.Close()
$stream.Close()
$zip.Dispose()

$xmlDoc = [xml]$xmlContent

$nsMgr = New-Object System.Xml.XmlNamespaceManager($xmlDoc.NameTable)
$nsMgr.AddNamespace("w", "http://schemas.openxmlformats.org/wordprocessingml/2006/main")

$paragraphs = $xmlDoc.SelectNodes("//w:p", $nsMgr)
$lines = @()
foreach ($p in $paragraphs) {
    $texts = $p.SelectNodes(".//w:t", $nsMgr)
    $lineText = ""
    foreach ($t in $texts) {
        $lineText += $t.InnerText
    }
    if ($lineText.Trim().Length -gt 0) {
        $lines += $lineText
    }
}

$lines -join "`r`n" | Out-File -FilePath $outputPath -Encoding UTF8
Write-Host "Extracted $($lines.Count) paragraphs"
