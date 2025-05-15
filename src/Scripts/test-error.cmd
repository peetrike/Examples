@echo off
powershell.exe -noninteractive -ExecutionPolicy RemoteSigned -command "%~dpn0.ps1 -Action %1"
