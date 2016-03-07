@echo off
rem %1 - osgeo4w-setup-x86.exe
rem %2 - download folder
rem --site "http://download.osgeo.org"
rem %~f1 -Da -O -l %~f2 ^
%~f1 ^
    -P expat ^
    -P fcgi ^
    -P grass ^
    -P saga ^
    -P gsl-devel ^
    -P iconv ^
    -P pyqt4 ^
    -P qt4-devel ^
    -P qt4-libs ^
    -P qca-devel ^
    -P qwt-devel-qt4 ^
    -P qwt ^
    -P sip ^
    -P gdal ^
    -P gdal-python ^
    -P spatialite ^
    -P libspatialindex-devel ^
    -P python-qscintilla ^
    -P qscintilla ^
    -P psycopg2 ^
    -P oci ^
    -P oci-devel ^
    -P python-devel ^
    -P osg-dev ^
    -P osg-libs ^
    -P osgearth-dev ^
    -P osgearth-libs ^
    -P zlib-devel ^
    -P libpng-devel ^
    -P libpng-devel-vc ^
    -P opencv ^
    -P msys  
