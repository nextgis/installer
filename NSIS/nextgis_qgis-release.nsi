!define QGIS_BASE "NextGIS QGIS"
!define DISPLAYED_NAME "NextGIS QGIS"
!define VERSION_NUMBER "2.2.0"
!define VERSION_NAME ""
!define COMPLETE_NAME "${QGIS_BASE} ${VERSION_NUMBER} ${VERSION_NAME}"
!define CHECK_INSTALL_NAME "${QGIS_BASE}"
!define INSTALLER_DISPLAYED_NAME "${DISPLAYED_NAME}"
!define PUBLISHER "NextGIS"
!define WEB_SITE "http://www.nextgis.ru"
!define WIKI_PAGE ""

!define SHORTNAME "qgis"

!define SRC_DIR "D:\builds\qgis-final-2_2_0-nextgis-with-env"
!define GRASS_SRC_DIR "D:\builds\osgeo4w_grass"
!define SAGA_SRC_DIR "D:\builds\saga"

!define QGIS_RUN_ICO_NAME "QGIS.ico"
!define QGIS_RUN_ICO_PATH "..\Installer-Files\${QGIS_RUN_ICO_NAME}"
!define QGIS_RUN_LNK_NAME "NextGIS QGIS (${VERSION_NUMBER}).lnk"

!define QGIS_POSTINSTALL_BAT "..\Installer-Files\for_release\postinstall.bat"
!define QGIS_PREREMOVE_BAT "..\Installer-Files\for_release\preremove.bat"

!define QGIS_UNINSTALL_FILE_NAME "Uninstall-NextGIS_QGIS.exe"
!define QGIS_UNINSTALL_LNK_NAME_SUFFIX "NextGIS QGIS (${VERSION_NUMBER})"

!define QGIS_MANUAL_FILE_NAME "QGIS-2.0-UserGuide-ru.pdf"

Name "NextGIS QGIS"
OutFile "NextGIS-QGIS-release-${VERSION_NUMBER}-bld.6.exe"
InstallDir "C:\NextGIS_QGIS"

!macro Section_Install_Plugin

!macroend

!include "nextgis_qgis-base.nsh"