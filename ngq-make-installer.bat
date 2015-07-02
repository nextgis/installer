@echo off
rem %1 - qgis build install
rem %2 - installer dest dir

call %CONFIGURE_ENV_WIN32%

echo "======== Make ngq installer Start==========="

%OSGEO4W_ROOT%\bin\python.exe %~dp0\make-installer.py --customization_dir %~dp0\ngq-custom-def-options --qgis_output %1 --installer_dir_dst %2

echo "======== Make ngq installer Finish==========="