@echo off
rem %1 - customization_zip
rem %2 - ngq source

call %CONFIGURE_ENV_WIN32%

echo "======== Make ngq installer Start==========="

%OSGEO4W_ROOT%\bin\python.exe %~dp0\patch_ngq.py --customization_zip %1 --ngq_src %2

echo "======== Make ngq installer Finish==========="