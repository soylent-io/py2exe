. .\write_junit.ps1

$testfailed = 0
$MyResults = New-Object -TypeName "System.Collections.ArrayList"
$header = @{ TestFileName = 'runner.ps1' }
$out = Join-Path -Path $pwd -ChildPath "out.xml"

Get-ChildItem -Recurse -Directory | ForEach-Object {
    $testname = $_.Name
    Write-Host "Running $testname..."
    cd $testname
    if (Test-Path -path .\requirements.txt -PathType Leaf) {
        pip install -r requirements.txt
    }
    python setup.py py2exe
    cd dist
    & ".\$testname.exe"
    $testfailed = $LastExitcode
    Write-Host "$testname exited with $testfailed"

    cd ..
    Remove-Item -LiteralPath "dist" -Force -Recurse
    if (Test-Path -path .\requirements.txt -PathType Leaf) {
        pip uninstall -r requirements.txt -y
    }
    cd ..

    if ($testfailed -ne 0) {
        Write-Host "$testname FAILED!!!"
        $res = @{ Result = 'FAIL'; Test = $testname; Time = 28; Reason = $testfailed}
        $MyResults.add($res)
        exit $testfailed
    }

    $res = @{ Result = 'PASS'; Test = $testname; Time = 20; Reason = ''}
    $MyResults.add($res)
    Write-Host "----------------- $testname PASS -------------------------"
}

Write-JunitXml $MyResults $header $out
