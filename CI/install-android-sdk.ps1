$AndroidToolPath = "${env:ProgramFiles(x86)}\Android\android-sdk\tools\android" 
#$AndroidToolPath = "$env:localappdata\Android\android-sdk\tools\android"

Function Get-AndroidSDKs() { 
    $output = & $AndroidToolPath list sdk --all 
    $sdks = $output |% { 
        if ($_ -match '(?<index>\d+)- (?<sdk>.+), revision (?<revision>[\d\.]+)') { 
            $sdk = New-Object PSObject 
            Add-Member -InputObject $sdk -MemberType NoteProperty -Name Index -Value $Matches.index 
            Add-Member -InputObject $sdk -MemberType NoteProperty -Name Name -Value $Matches.sdk 
            Add-Member -InputObject $sdk -MemberType NoteProperty -Name Revision -Value $Matches.revision 
            $sdk 
        } 
    } 
    $sdks 
}

Function Install-AndroidSDK() { 
    [CmdletBinding()] 
    Param( 
        [Parameter(Mandatory=$true, Position=0)] 
        [PSObject[]]$sdks 
    )

    $sdkIndexes = $sdks |% { $_.Index } 
    $sdkIndexArgument = [string]::Join(',', $sdkIndexes) 
    echo "trying to update sdk"
    $responses = 'y','y'
    #Echo 'y' | & $AndroidToolPath update sdk -u -a -t $sdkIndexArgument 
    $responses | foreach-object -Process { Start-Sleep -s 2; $_ } | & $AndroidToolPath update sdk -u -a -t $sdkIndexArgument
    echo "updated sdk"
}

$sdks = Get-AndroidSDKs |? { $_.name -like 'sdk platform*API 15*' -or $_.name -like 'google apis*api 15' } 
Install-AndroidSDK -sdks $sdks