set OSGEO4W_ROOT=%OSGEO4W_ROOT:\=\\%
textreplace -std -t "%OSGEO4W_ROOT%"\bin\qt.conf
