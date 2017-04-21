<#
.SYNOPSIS

Program: EncDecFiles.ps1
Author:  QDBA
Version: 1.0
Date:    April 19, 2017

.DESCRIPTION

Encrypt / Decrypt a File with AES

.PARAMETER In

Filename of the Input file

.PARAMETER Out

Filename of the Output File

.PARAMETER Encrypt

The In file AES Encrypted and will save to the Out file

.PARAMETER Decrypt

The In file was decrypted and will be saved to the Out File

.PARAMETER Pass

The Password for Encryption / Decryption default: hak5bunny

.EXAMPLE
encdecfiles.ps1 -In c:\test.ps1 -encrypt

Encrypts File c:\test.ps1 with password "hak5bunny" encrypted file is c:\test.enc 

.EXAMPLE
encdecfiles.ps1 -In c:\test.ps1 -encrypt

Encrypts File c:\test.ps1 with password "hak5bunny" encrypted file is c:\test.enc 

.EXAMPLE
encdecfiles.ps1 -In c:\test.ps1 -encrypt -Out c:\encrypted-file.aes -pass Secret

Encrypt a File c:\Test.ps1 with password "Secret" encrypted file is c:\encrypted-file.aes

.EXAMPLE
encdecfiles.ps1 -In c:\Test.enc -decrypt

Decrypt a encrypted file c:\test1.enc to c:\test1.ps1 with default password "hak5bunny"

#>



# EncDecFiles.ps1
# Author: QDBA
# Version: 1.0
# Date April 19, 2017
# Description: Encrypt /Decrypt a File with AES 
# Example:
#         encdecfiles.ps1 -In c:\test.ps1 -encrypt          
#                    :: Encrypts File c:\test.ps1 with password "hak5bunny" encrypted file is c:\test.enc 
#
#         encdecfiles.ps1 -In c:\test.ps1 -encrypt -Out c:\encrypted-file.aes -pass Secret
#                   :: Encrypt a File c:\Test.ps1 with password "Secret" encrypted file is c:\encrypted-file.aes
#
#         encdecfiles.ps1 -In c:\Test.enc -decrypt 
#                   :: Decrypt a encrypted file c:\test1.enc to c:\test1.ps1 with password "hak5bunny"
#
#
#
# 
# Functions Write-EncryptedString and Read-EncryptedString from 
# Library-StringCrypto.ps1
# Author: Lunatic Experimentalist
# Version: 2.1
# Date: October 22, 2009

param ([String]$In, [String]$Pass="hak5bunny", [String]$Out ,[Switch]$Encrypt,[Switch]$Decrypt)


function Write-EncryptedString {
param ([Parameter(Mandatory=$True)][String]$InputString, [String]$Password, [Switch]$Compress, [Switch]$GnuPG, [String]$Recipient)

if (($args -contains '-?') -or (-not $InputString) -or (-not $Password -and -not $GnuPG)) {
'NAME'
'    Write-EncryptedString'
''
'SYNOPSIS'
'    Encrypts a string using another string as a password.'
''
'SYNTAX'
'    Write-EncryptedString [-inputString] <string> [-password] <string>'
'                          [-compress]'
'    Write-EncryptedString [-inputString] <string> [[-password] <string>] -gnupg'
'    Write-EncryptedString [-inputString] <string> -gnupg -recipient <string>'
''
'PARAMETERS'
'    -inputString <string>'
'        The string to be encrypted.'
''
'    -password <string>'
'        The password to use for encryption.'
''
'    -compress'
'        Compress data before encryption.'
'        Is not used with GnuPG.'
''
'    -gnupg'
'        Perform encryption using GnuPG. Requires gpg.exe to alias as gpg.'
'        Can only use one single line passphrase.'
''
'    -recipient'
'        Available only with GnuPG. This is the UID search string to be used'
'        with asymmetric encryption.'
'RETURN TYPE'
'    string'
return
}

	if ($GnuPG) {
		if ($Recipient) {
			$InputString | gpg --encrypt --recipient $Recipient --armor --quiet --batch | Join-String -newline
		}
		elseif ($Password) {
			$Password, $InputString | gpg --symmetric --armor --quiet --batch --passphrase-fd 0 | Join-String -newline
		}
		else {
			$InputString | gpg --symmetric --armor | Join-String -newline
		}
	}
	else {
		$Rfc2898 = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Password,32)
		$Salt = $Rfc2898.Salt
		$AESKey = $Rfc2898.GetBytes(32)
		$AESIV = $Rfc2898.GetBytes(16)
		$Hmac = New-Object System.Security.Cryptography.HMACSHA1(,$Rfc2898.GetBytes(20))
		
		$AES = New-Object Security.Cryptography.RijndaelManaged
		$AESEncryptor = $AES.CreateEncryptor($AESKey, $AESIV)
		
		$InputDataStream = New-Object System.IO.MemoryStream
		if ($Compress) { $InputEncodingStream = (New-Object System.IO.Compression.GZipStream($InputDataStream,  [IO.Compression.CompressionMode]::Compress)) }
		else { $InputEncodingStream = $InputDataStream }
		$StreamWriter = New-Object System.IO.StreamWriter($InputEncodingStream, (New-Object System.Text.Utf8Encoding($true)))
		$StreamWriter.Write($InputString)
		$StreamWriter.Flush()
		if ($Compress) { $InputEncodingStream.Close() }
		$InputData = $InputDataStream.ToArray()
		
		$EncryptedEncodedInputString = $AESEncryptor.TransformFinalBlock($InputData, 0, $InputData.Length)
		
		$AuthCode = $Hmac.ComputeHash($EncryptedEncodedInputString)
		
		$OutputData = New-Object Byte[](52 + $EncryptedEncodedInputString.Length)
		[Array]::Copy($Salt, 0, $OutputData, 0, 32)
		[Array]::Copy($AuthCode, 0, $OutputData, 32, 20)
		[Array]::Copy($EncryptedEncodedInputString, 0, $OutputData, 52, $EncryptedEncodedInputString.Length)
		
		$OutputDataAsString = [Convert]::ToBase64String($OutputData)
		
		$OutputDataAsString
	}
}

function Read-EncryptedString {
param ([String]$InputString, [String]$Password)

if (($args -contains '-?') -or (-not $InputString) -or (-not $Password -and -not $InputString.StartsWith('-----BEGIN PGP MESSAGE-----'))) {
'NAME'
'    Read-EncryptedString'
''
'SYNOPSIS'
'    Decrypts a string using another string as a password.'
''
'SYNTAX'
'    Read-EncryptedString [-inputString] <string> [-password] <string>'
''
'PARAMETERS'
'    -inputString <string>'
'        The string to be decrypted.'
''
'    -password <string>'
'        The password to use for decryption.'
''
'RETURN TYPE'
'    string'
return
}

	if ($InputString.StartsWith('-----BEGIN PGP MESSAGE-----')) {
		# Decrypt with GnuPG
		if ($Password) {
			$Password, $InputString | gpg --decrypt --quiet --batch --passphrase-fd 0 | Join-String -newline
		}
		else {
			$InputString | gpg --decrypt | Join-String -newline
		}
	}
	else {
		# Decrypt with custom algo
		$InputData = [Convert]::FromBase64String($InputString)
		
		$Salt = New-Object Byte[](32)
		[Array]::Copy($InputData, 0, $Salt, 0, 32)
		$Rfc2898 = New-Object System.Security.Cryptography.Rfc2898DeriveBytes($Password,$Salt)
		$AESKey = $Rfc2898.GetBytes(32)
		$AESIV = $Rfc2898.GetBytes(16)
		$Hmac = New-Object System.Security.Cryptography.HMACSHA1(,$Rfc2898.GetBytes(20))
		
		$AuthCode = $Hmac.ComputeHash($InputData, 52, $InputData.Length - 52)
		
		if (Compare-Object $AuthCode ($InputData[32..51]) -SyncWindow 0) {
			throw 'Checksum failure.'
		}
		
		$AES = New-Object Security.Cryptography.RijndaelManaged
		$AESDecryptor = $AES.CreateDecryptor($AESKey, $AESIV)
		
		$DecryptedInputData = $AESDecryptor.TransformFinalBlock($InputData, 52, $InputData.Length - 52)
		
		$DataStream = New-Object System.IO.MemoryStream($DecryptedInputData, $false)
		if ($DecryptedInputData[0] -eq 0x1f) {
			$DataStream = New-Object System.IO.Compression.GZipStream($DataStream, [IO.Compression.CompressionMode]::Decompress)
		}
		
		$StreamReader = New-Object System.IO.StreamReader($DataStream, $true)
		$StreamReader.ReadToEnd()
	}
}

#################################################


Function Base64Encode($textIn) 
{
    $b  = [System.Text.Encoding]::unicode.GetBytes($textIn)
    $encoded = [System.Convert]::ToBase64String($b)
    return $encoded    
}

Function Base64Decode($textBase64In) 
{
    $b  = [System.Convert]::FromBase64String($textBase64In)
    $decoded = [System.Text.Encoding]::unicode.GetString($b)
    return $decoded
}

#######################################################################################
### File Convert (c) by QDBA
#######################################################################################



if ( $Decrypt -or $Encrypt ) {
    if ( $Encrypt ) {
        #$decscript = Get-Content $In -raw
        $decscript = [IO.File]::ReadAllText("$In")
        $mimedecscript = base64encode($decscript)
        $encscript = Write-EncryptedString -InputString $mimedecscript -Password $pass -Compress
        if ( $out -eq "" ) {
            $out = (Get-Item $in).BaseName + ".enc"
        }
        $encscript | Out-file -FilePath $Out
    }
    if ( $Decrypt ) {
        $encscript = Get-Content -Path $In
        $mimedecscript = Read-EncryptedString -InputString $encscript -Password $pass
        $decscript = base64decode($mimedecscript)
        if ( $out -eq "" ) {
            $out = (Get-Item $in).BaseName + ".ps1"
        }
        $decscript | Out-file -FilePath $Out
    }

} else {

    echo 'Usage: EncDecFiles.ps1  < -Encrypt | -Decrypt >      # encrypt or decrypt a file'
    echo '                        < -In Filename >             # Input File'
    echo '                        [ -Out Filename ]            # Output File'
    echo '                        [ -Pass Password ]           # Password'

}

exit
