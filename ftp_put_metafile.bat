@echo off
rem %1 ftp://user:password@server
rem %2 ngqmake_result file
rem %3 file_dest with new name

call %~dp0\ftp_put.bat %1 %~f2 %3

if %ERRORLEVEL% == 0 goto :next
echo "Errors encountered during execution.  Exited with status: %errorlevel%"
goto :endofscript

:next
del %~f2

:endofscript
echo "Script complete"