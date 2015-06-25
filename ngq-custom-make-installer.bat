@echo off
rem %1 - customization_zip
rem %2 - qgis build install
rem %3 - installer dest dir

call %CONFIGURE_ENV_WIN32%

echo "======== Make ngq installer Start==========="

%OSGEO4W_ROOT%\bin\python.exe %~dp0\make-installer.py --customization_zip %1 --build_num 0 --qgis_output %2 --installer_dir_dst %3

echo "======== Make ngq installer Finish==========="