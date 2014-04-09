!define QGIS_BASE "NextGIS QGIS dev"
!define DISPLAYED_NAME "NextGIS QGIS dev"
!define VERSION_NUMBER "2.3.0"
!define VERSION_NAME ""
!define COMPLETE_NAME "${QGIS_BASE} ${VERSION_NUMBER} ${VERSION_NAME}"
!define CHECK_INSTALL_NAME "${QGIS_BASE}"
!define INSTALLER_DISPLAYED_NAME "${DISPLAYED_NAME}"
!define PUBLISHER "NextGIS"
!define WEB_SITE "http://www.nextgis.ru"
!define WIKI_PAGE ""

!define SHORTNAME "qgis-dev"

!define SRC_DIR "D:\builds\qgis-master-nextgis-with-env"
!define GRASS_SRC_DIR "D:\builds\osgeo4w_grass"
!define SAGA_SRC_DIR "D:\builds\saga"

!define QGIS_RUN_ICO_NAME "QGIS_dev.ico"
!define QGIS_RUN_ICO_PATH "..\Installer-Files\${QGIS_RUN_ICO_NAME}"
!define QGIS_RUN_LNK_NAME "NextGIS QGIS dev (${VERSION_NUMBER}).lnk"

!define QGIS_POSTINSTALL_BAT "..\Installer-Files\for_devel\postinstall.bat"
!define QGIS_PREREMOVE_BAT "..\Installer-Files\for_devel\preremove.bat"

!define QGIS_UNINSTALL_FILE_NAME "Uninstall-NextGIS_QGIS_dev.exe"
!define QGIS_UNINSTALL_LNK_NAME_SUFFIX "NextGIS QGIS dev (${VERSION_NUMBER})"

!define QGIS_MANUAL_FILE_NAME "QGIS-2.0-UserGuide-ru.pdf"

Name "NextGIS QGIS dev"
OutFile "NextGIS-QGIS-dev-${VERSION_NUMBER}-bld.6.exe"
InstallDir "C:\NextGIS_QGIS_DEV"

!macro Section_Install_Plugin

!macroend

!include "nextgis_qgis-base.nsh"