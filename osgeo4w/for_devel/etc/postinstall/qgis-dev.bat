textreplace -std -t bin\qgis-dev.bat
textreplace -std -t bin\qgis-dev-browser.bat

set O4W_ROOT=%OSGEO4W_ROOT%
set OSGEO4W_ROOT=%OSGEO4W_ROOT:\=\\%
textreplace -std -t "%O4W_ROOT%\apps\qgis-dev\bin\qgis.reg"
set OSGEO4W_ROOT=%O4W_ROOT%

"%WINDIR%\regedit" /s "%O4W_ROOT%\apps\qgis-dev\bin\qgis.reg"

call "%OSGEO4W_ROOT%"\bin\o4w_env.bat
path %PATH%;%OSGEO4W_ROOT%\apps\qgis-dev\bin
set QGIS_PREFIX_PATH=%OSGEO4W_ROOT:\=/%/apps/qgis-dev
"%OSGEO4W_ROOT%"\apps\qgis-dev\crssync
