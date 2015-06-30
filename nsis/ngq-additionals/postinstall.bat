@echo off
del postinstall.log>>postinstall.log
echo OSGEO4W_ROOT=%OSGEO4W_ROOT%>>postinstall.log 2>&1
echo OSGEO4W_STARTMENU=%OSGEO4W_STARTMENU%>>postinstall.log 2>&1
set OSGEO4W_ROOT_MSYS=%OSGEO4W_ROOT:\=/%
if "%OSGEO4W_ROOT_MSYS:~1,1%"==":" set OSGEO4W_ROOT_MSYS=/%OSGEO4W_ROOT_MSYS:~0,1%/%OSGEO4W_ROOT_MSYS:~3%
echo OSGEO4W_ROOT_MSYS=%OSGEO4W_ROOT_MSYS%>>postinstall.log 2>&1
PATH %OSGEO4W_ROOT%\bin;%PATH%>>postinstall.log 2>&1
cd %OSGEO4W_ROOT%>>postinstall.log 2>&1

for /f %%f in ('dir /b etc\postinstall') do (
    echo Running postinstall %%f...
    %COMSPEC% /c etc\postinstall\%%f>>postinstall.log 2>&1
    ren etc\postinstall\%%f %%f.done>>postinstall.log 2>&1
)

ren postinstall.bat postinstall.bat.done
