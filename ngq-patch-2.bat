@echo off
rem %1 - customization_dir
rem %2 - ngq source

call %CONFIGURE_ENV_WIN32%

echo "======== Make ngq installer Start==========="

%OSGEO4W_ROOT%\bin\python.exe patch_ngq.py --customization_dir %1 --ngq_src %2

echo "======== Make ngq installer Finish==========="