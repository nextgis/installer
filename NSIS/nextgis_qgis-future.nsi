!define PROGRAM_NAME "NextGIS QGIS future" ; good
!define PROGRAM_VERSION "2.7.0.17" ; good where 2.5.0 - version of qgis, 13 - NextGIS QGIS build

!define PUBLISHER "NextGIS" ; good
!define WEB_SITE "http://www.nextgis.ru" ; good

!define DEFAULT_INSTALL_DIR "c:\NextGIS_QGIS_future" ; good

!define INSTALLER_NAME "NextGIS-QGIS-future-${PROGRAM_VERSION}.exe" ; good

!define QGIS_DEFAULT_OPTIONS_PATH "..\NextGIS QGIS\qgis_default_options\" ; good

!define WIKI_PAGE ""

!define SHORTNAME "qgis" ; good

!define OSGEO4W_SRC_DIR "D:\builds\osgeo4w-env" ;good
!define QGIS_SRC_DIR "D:\builds\nextgis-qgis-future" ;good
!define GRASS_SRC_DIR "D:\builds\grass-fromOSGEO4W" ;good
!define SAGA_SRC_DIR "D:\builds\saga-fromOSGEO4W" ;good
!define GDAL_SRC_DIR "D:\builds\gdallib" ;good

!define NextGIS_QGIS_RUN_LNK_NAME "NextGIS QGIS future (${PROGRAM_VERSION}).lnk" ; good
!define NextGIS_QGIS_RUN_LNK_ICO_FileName "QGIS_dev.ico" ; good
!define NextGIS_QGIS_RUN_LNK_ICO_Path "..\Installer-Files\${NextGIS_QGIS_RUN_LNK_ICO_FileName}" ; good

!define QGIS_RUN_BAT "..\NextGIS QGIS\NextGIS QGIS future\qgis.bat"  ; good
!define QGIS_PRE_RUN_BAT "..\NextGIS QGIS\NextGIS QGIS future\qgis_preruner.bat"  ; good

!define QGIS_POSTINSTALL_BAT "..\Installer-Files\postinstall.bat" ; good
!define QGIS_PREREMOVE_BAT "..\Installer-Files\preremove.bat" ;  good

!define NextGIS_QGIS_UNINSTALLER_FileName "Uninstall-NextGIS_QGIS_future.exe" ; good
!define NextGIS_QGIS_UNINSTALL_LNK_NAME_SUFFIX "NextGIS QGIS future (${PROGRAM_VERSION})" ; good

!define QGIS_MANUAL_FILE_NAME "QGIS-2.2-UserGuide-ru.pdf"; good

;!define PLUGINS "d:\builds\plugins\identifyplus d:\builds\plugins\reporter"; good ! not define becose no need plugins

!include "nextgis_qgis-base.nsh"