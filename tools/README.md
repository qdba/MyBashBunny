## Packaged tools for the Bash Bunny Firmware 1.1

## How to Install
1. Download the desired *.deb file and put it into the /tools folder of your Bash Bunny Flash drive.
2. safely eject the Bash Bunny
3. put switch into arming mode
4. reinsert the Bash Bunny and wait for the blue led

After installation you'll find the log files in the /loot folder of your Bash Bunny
Remember, that after installion the /tools folder of your Bash Bunny Flashdrive is empty. No doubt about this. 

If you want manually check the installation, ssh to your bunny,

*ls -al /tools*   # The packages were installed there
*dpkg -l*         # a List of all istalled packages

