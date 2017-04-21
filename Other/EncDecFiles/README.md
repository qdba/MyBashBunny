# EncDecFiles.ps1
* Author: (c) 2017 by QDBA
* Version 1.0

# Description
EncDecFiles.ps1 is a powershell script to Encrypt / Decrypt a powershell (or any other) file with AES. 
You can use it to obfuscate your powershell script, so AV Scanner doesn't detect it.

### Usage:
* 
* EncDecFiles.ps1  
*                         < -Encrypt | -Decrypt >      # encrypt or decrypt a file
*                         < -In Filename >             # Input File
*                         [ -Out Filename ]            # Output File
*                         [ -Pass Password ]           # Password

## Example 1
	- encdecfiles.ps1 -In c:\test.ps1 -encrypt
		Encrypts File c:\test.ps1 with password "hak5bunny" encrypted file is c:\test.enc 

## Example 2
	- encdecfiles.ps1 -In c:\test.ps1 -encrypt -pass secret
		Encrypts File c:\test.ps1 with password "secret" encrypted file is c:\test.enc 

## Example 3
	- encdecfiles.ps1 -In c:\test.ps1 -encrypt -Out c:\encrypted-file.aes -pass Secret
		Encrypt a File c:\Test.ps1 with password "Secret" encrypted file is c:\encrypted-file.aes

## Example 4
	- encdecfiles.ps1 -In c:\Test.enc -decrypt
		Decrypt a encrypted file c:\test1.enc to c:\test1.ps1 with default password "hak5bunny"



# How to run the encrypted powershell script
In the Script "Run_Script_Example.ps1" you see an example how to load and execute the encrypted Script.
Load the encrypted script to a variable. Than execute the function Run with the variable and a password 



