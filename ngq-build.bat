@echo off
rem %1 - ngq build dir
rem %2 - project file

call %CONFIGURE_ENV_WIN32%

set start_work_dir=%cd%

if not exist %1 exit /B 1

cd /D %1

echo "======== Build ngq  Start==========="

msbuild /p:Configuration=Release %2
msbuild /p:Configuration=Release INSTALL.vcproj

echo "======== Build ngq  Finish==========="

cd /D %start_work_dir%