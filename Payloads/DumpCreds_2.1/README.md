# DumpCreds 2.2
* Author: QDBA
* Version: Version 2.2.0 Build 1005
* Target: Windows 10

## Description

** !!!!! works only at Bash Bunny with FW 1.1+ !!!!! **

Dumps the usernames & plaintext passwords from 
 * Browsers (Crome, IE, FireFox)
 * Wifi 
 * SAM Hashes (only if AdminMode=True)
 * Mimimk@tz Dump (only if AdminMode=True)
 * Computerinformation (Hardware Info, Windows ProductKey, Hotfixes, Software, Local, AD Userlist)
 
 without 
 * Use of USB Storage (Because USB Storage ist mostly blocked by USBGuard or DriveLock)
 * Internet connection (becaus Firewall ContentFilter Blocks the download sites)
 
 
# Problems
- if you first use the payload on a computer, it will take some time and tries until the drivers are successfully loaded.
- If the payload doesnt work. (Red LED or Yellow LED blinks 2 or 4 times) plug off the BB  and try it once more (can take 3 or 4 times)
- If the payload stops working yellow LED blinks very fast longer than 2min. You get no white LED. Your run in a time out. 
  If you plugin the BB every payload has 1min 30sfor doing the job. At 1min 30s every payload stops. (Thats a FW 1.1 issue)  
 
# Debug 
If you want some debug information, create a file with name "DEBUG" in the payload folder
you got the debug information in \loot\DumpCred_2.1\log.txt Folder
 

## Configuration

None needed. 

## Requirements

impacket must be installed
https://github.com/qdba/MyBashBunny/tree/master/tools

## Download


https://github.com/qdba/bashbunny-payloads/tree/master/payloads/library/DumpCreds_2.0


## Install

copy all files and folders to your favorite payloads switch folder

## STATUS

| LED                     | Status                                       |
| ----------------------- | -------------------------------------------- |
| Magenta Solid           | Setup                                        |
| Red slow blink          | Impacket not found                           |
| Red fast blink          | Target did not acquire IP address            |
| Yellow single blink     | Initialization                               |
| Yellow double blink     | HID Stage                                    |
| Yellow triple blink     | Wait for IP coming up                        |
| Yellow very fast blink  | Powershell scripts running                   |
| White fast blink        | Cleanup, copy Files to <root>/loot           |
| Green              	  | Finished                                     |
| ----------------------- | -------------------------------------------- |


## Discussion

https://forums.hak5.org/index.php?/topic/40582-payload-drumpcreds-20-wo-internet-wo-usb-storage

## Credits

to...... 

https://github.com/EmpireProject/Empire         Get-FoxDump.ps1, Invoke-M1m1k@tz.ps1, Invoke-PowerDump.ps1, Get-ChromeCreds.ps1

## Changelog

- Complete new payload.txt code for BashBunny 1.1
- Added a lot of debug cod into the payload 
