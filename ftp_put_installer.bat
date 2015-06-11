@echo off
rem %1 ftp://user:password@server
rem %2 ngqmake_result file
rem %3 remote dir

set /p firstline=<%2
set installername=%~dp2%firstline%

call %~dp0\ftp_put.bat %1 %installername% %3/%firstline%

if %ERRORLEVEL% == 0 goto :next
echo "Errors encountered during execution.  Exited with status: %errorlevel%"
goto :endofscript

:next
del %installername%

:endofscript
echo "Script complete"