@echo off
rem %1 - qgis build number
rem %2 - qgis build install
rem %3 - installer dest dir

call %CONFIGURE_ENV_WIN32%

echo "======== Make ngq installer Start==========="

%OSGEO4W_ROOT%\bin\python.exe make-installer.py --customization_dir %~dp0\ngq-custom-def-options --build_num %1 --qgis_output %2 --installer_dir_dst %3

echo "======== Make ngq installer Finish==========="