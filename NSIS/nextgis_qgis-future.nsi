!define PROGRAM_NAME "NextGIS QGIS future" ; good
!define PROGRAM_VERSION "2.7.0.19" ; good where 2.5.0 - version of qgis, 13 - NextGIS QGIS build

!define PUBLISHER "NextGIS" ; good
!define WEB_SITE "http://www.nextgis.ru" ; good

!define DEFAULT_INSTALL_DIR "c:\NextGIS_QGIS_future" ; good

!define INSTALLER_NAME "NextGIS-QGIS-future-${PROGRAM_VERSION}.exe" ; good

!define QGIS_DEFAULT_OPTIONS_PATH "..\NextGIS QGIS\NextGIS QGIS future\qgis_default_options\" ; good

!define WIKI_PAGE ""

!define SHORTNAME "qgis" ; good

!define OSGEO4W_SRC_DIR "D:\builds\osgeo4w" ;good
!define QGIS_SRC_DIR "D:\builds\nextgis-qgis-future" ;good
!define GRASS_SRC_DIR "D:\builds\grass-fromOSGEO4W" ;good
!define SAGA_SRC_DIR "D:\builds\saga-fromOSGEO4W" ;good
!define GDAL_SRC_DIR "D:\builds\gdal-2.0.0-dev-with-ags" ;good
!define ICONV_SRC_DIR "D:\builds\libiconv-1.14" ;

!define NextGIS_QGIS_RUN_LNK_NAME "NextGIS QGIS future (${PROGRAM_VERSION}).lnk" ; good
!define NextGIS_QGIS_RUN_LNK_ICO_FileName "QGIS_dev.ico" ; good
!define NextGIS_QGIS_RUN_LNK_ICO_Path "..\Installer-Files\${NextGIS_QGIS_RUN_LNK_ICO_FileName}" ; good

!define QGIS_RUN_BAT "..\NextGIS QGIS\NextGIS QGIS future\qgis.bat"  ; good
!define QGIS_PRE_RUN_BAT "..\NextGIS QGIS\NextGIS QGIS future\qgis_preruner.bat"  ; good

!define QGIS_POSTINSTALL_BAT "..\Installer-Files\postinstall.bat" ; good
!define QGIS_PREREMOVE_BAT "..\Installer-Files\preremove.bat" ;  good

!define NextGIS_QGIS_UNINSTALLER_FileName "Uninstall-NextGIS_QGIS_future.exe" ; good
!define NextGIS_QGIS_UNINSTALL_LNK_NAME_SUFFIX "NextGIS QGIS future (${PROGRAM_VERSION})" ; good

!define QGIS_MANUAL_FILE_NAME_RU "QGIS-2.6-UserGuide-ru.pdf"; good
!define QGIS_MANUAL_FILE_NAME_EN "QGIS-2.6-UserGuide-en.pdf"; good

!define PLUGINS "d:\builds\plugins\identifyplus"; good 

!define FONTS_DIR "d:\builds\fonts"

!include "nextgis_qgis-base.nsh"