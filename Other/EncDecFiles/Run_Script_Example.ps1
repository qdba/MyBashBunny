# 




######################### Some functions ########################

function Run {
    param ([String]$InputString, [String]$Password="hak5bunny")
            
           
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
		    $OutputString = ([System.Text.Encoding]::unicode.GetString([System.Convert]::FromBase64String($StreamReader.ReadToEnd())))
            iex $Outputstring
}


# Run the ecrypted File
$DecryptedFile = Get-Content ".\Testscript.enc"                     # Red the encrypted powershell script to String Can Alo be Downloaded from HTTP Server
Run -InputString $DecryptedFile -Password "SecretWord"              # Decrypt the powershell script an execute it
