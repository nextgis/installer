@rem  ..\configure_qgis.bat d:\builds\qgis-master-nextgis d:\builds\gdal-1.11.0 d:\Development\NextGIS\qgis
@rem  ..\configure_qgis.bat d:\builds\qgis-master-nextgis c:\OSGeo4W\ d:\Development\NextGIS\qgis
@rem  ..\configure_qgis.bat d:\builds\qgis-master-nextgis d:\builds\gdal-1.11.0-fromOSGEO4W d:\Development\NextGIS\qgis

cmake -G "Visual Studio 9 2008" ^
	-D PEDANTIC=TRUE ^
	-D WITH_QSPATIALITE=TRUE ^
	-D WITH_MAPSERVER=TRUE ^
	-D MAPSERVER_SKIP_ECW=TRUE ^
	-D WITH_GLOBE=TRUE ^
	-D WITH_TOUCH=TRUE ^
	-D WITH_ORACLE=TRUE ^
	-D CMAKE_BUILD_TYPE=Release ^
	-D GRASS_PREFIX=C:/OSGeo4W/apps/grass/grass-6.4.3 ^
	-D CMAKE_INSTALL_PREFIX=%1 ^
    -D BISON_EXECUTABLE=C:/Progra~1/GnuWin32/bin/bison.exe ^
    -D FLEX_EXECUTABLE=C:/Progra~1/GnuWin32/bin/flex.exe ^
    -D GDAL_INCLUDE_DIR=%2/include ^
    -D GDAL_LIBRARY=%2/lib/gdal_i.lib ^
    %3

