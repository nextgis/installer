for %%f in ("%TEMP%") do call set TEMPDRIVE=%%~df
cd %TEMP%

"%OSGEO4W_ROOT%\bin\vcredist_2005_x86.exe" /q /t:%TEMPDRIVE%
if errorlevel 3010 echo>%OSGEO4W_ROOT%\etc\reboot
del "%OSGEO4W_ROOT%\bin\vcredist_2005_x86.exe"

"%OSGEO4W_ROOT%\bin\vcredist_2008_x86.exe" /q
if errorlevel 3010 echo>%OSGEO4W_ROOT%\etc\reboot
del "%OSGEO4W_ROOT%\bin\vcredist_2008_x86.exe"

"%OSGEO4W_ROOT%\bin\vcredist_2010_x86.exe" /q
if errorlevel 3010 echo>%OSGEO4W_ROOT%\etc\reboot
del "%OSGEO4W_ROOT%\bin\vcredist_2010_x86.exe"
