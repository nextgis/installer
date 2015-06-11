@echo off
rem %1 - ngq build dir
rem %2 - ngq install dir
rem %3 - ngq src dir

call %CONFIGURE_ENV_WIN32%

set start_work_dir=%cd%

if not exist %1 mkdir %1

cd /D %1

echo "======== Configurate ngq  Start==========="

cmake -G "Visual Studio 9 2008" ^
-D PEDANTIC=TRUE ^
-D WITH_QSPATIALITE=TRUE ^
-D WITH_MAPSERVER=TRUE ^
-D MAPSERVER_SKIP_ECW=TRUE ^
-D WITH_GLOBE=TRUE ^
-D WITH_TOUCH=TRUE ^
-D WITH_ORACLE=TRUE ^
-D CMAKE_BUILD_TYPE=Release ^
-D CMAKE_INSTALL_PREFIX=%2 ^
%3

echo "======== Configurate ngq  Finish==========="

cd /D %start_work_dir%