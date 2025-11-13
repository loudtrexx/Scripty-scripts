@echo off
set outputFile="\\10.6.128.12\Ohjelmat\Automaattiset mac osoitteet\output.txt"
wmic computersystem get name /format:list >> %outputFile%
wmic nic where "NetConnectionID='Wi-Fi'" get MACAddress /format:list >> %outputFile%
:: Formatointi on hieman huonosti tehty, muuten toimii