!define PROGRAM_NAME "NextGIS QGIS dev" ; good
!define PROGRAM_VERSION "2.7.0.17" ; good where 2.7.0 - version of qgis, 17 - NextGIS QGIS build

!define PUBLISHER "NextGIS" ; good
!define WEB_SITE "http://www.nextgis.ru" ; good

!define DEFAULT_INSTALL_DIR "c:\NextGIS_QGIS_dev" ; good

!define INSTALLER_NAME "NextGIS-QGIS-dev-${PROGRAM_VERSION}.exe" ; good

!define QGIS_DEFAULT_OPTIONS_PATH "..\NextGIS QGIS\qgis_default_options\" ; good

!define WIKI_PAGE ""

!define SHORTNAME "qgis" ; good

!define OSGEO4W_SRC_DIR "D:\builds\osgeo4w-env" ;good
!define QGIS_SRC_DIR "D:\builds\nextgis-qgis-dev" ;good
!define GRASS_SRC_DIR "D:\builds\grass-fromOSGEO4W" ;good
!define SAGA_SRC_DIR "D:\builds\saga-fromOSGEO4W" ;good
!define GDAL_SRC_DIR "D:\builds\gdal-1.11.0-fromOSGEO4W" ;good

!define NextGIS_QGIS_RUN_LNK_NAME "NextGIS QGIS dev (${PROGRAM_VERSION}).lnk" ; good
!define NextGIS_QGIS_RUN_LNK_ICO_FileName "QGIS_dev.ico" ; good
!define NextGIS_QGIS_RUN_LNK_ICO_Path "..\Installer-Files\${NextGIS_QGIS_RUN_LNK_ICO_FileName}" ; good

!define QGIS_RUN_BAT "..\NextGIS QGIS\NextGIS QGIS dev\qgis.bat"  ; good
#!define QGIS_PRE_RUN_BAT "..\NextGIS QGIS\NextGIS QGIS dev\qgis_preruner.bat"  ; good

!define QGIS_POSTINSTALL_BAT "..\Installer-Files\postinstall.bat" ; good
!define QGIS_PREREMOVE_BAT "..\Installer-Files\preremove.bat" ;  good

!define NextGIS_QGIS_UNINSTALLER_FileName "Uninstall-NextGIS_QGIS_dev.exe" ; good
!define NextGIS_QGIS_UNINSTALL_LNK_NAME_SUFFIX "NextGIS QGIS dev (${PROGRAM_VERSION})" ; good

!define QGIS_MANUAL_FILE_NAME "QGIS-2.2-UserGuide-ru.pdf"; good

;!define PLUGINS "d:\builds\plugins\identifyplus d:\builds\plugins\reporter"; good ! not define becose no need plugins

!include "nextgis_qgis-base.nsh"
