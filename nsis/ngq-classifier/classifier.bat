@echo off
cd /d %~dp0
call "%~dp0\o4w_env.bat"
path %PATH%;%OSGEO4W_ROOT%\apps\qgis\bin
rem Set VSI cache to be used as buffer, see #6448
set VSI_CACHE=TRUE
set VSI_CACHE_SIZE=1000000

start "dtclassifiaer" /B /WAIT "%OSGEO4W_ROOT%"\apps\qgis\bin\classifier.exe %*
