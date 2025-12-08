@echo off
set outputFile="output.txt"
wmic computersystem get name /format:list >> %outputFile%
wmic nic where "NetConnectionID='Wi-Fi'" get MACAddress /format:list >> %outputFile%

:: Bad formatting for the output. Maybe fix later
