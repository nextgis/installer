@echo off
rem %1 http://put_url

set /p firstline=<%cd%\.meta-ngq
set installername=%firstline%

echo %installername%
echo %~dp0\curl.exe
echo %1/%installername%
echo %cd%\%installername%
call %~dp0\curl.exe %1/%installername% --upload-file %cd%\%installername%