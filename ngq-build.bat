@echo off
rem %1 - ngq build dir

call %CONFIGURE_ENV_WIN32%

set start_work_dir=%cd%

if not exist %1 exit /B 1

cd /D %1

echo "======== Build ngq  Start==========="

nmake /f Makefile
nmake /f Makefile install

echo "======== Build ngq  Finish==========="

cd /D %start_work_dir%