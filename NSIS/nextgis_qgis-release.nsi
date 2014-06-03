!define QGIS_BASE "NextGIS QGIS"
!define DISPLAYED_NAME "NextGIS QGIS"
!define VERSION_NUMBER "2.2.0"
!define NEXTGIS_QGIS_BUILD_NUMBER "6"
!define VERSION_NAME ""
!define COMPLETE_NAME "${QGIS_BASE} ${VERSION_NUMBER} ${VERSION_NAME}"
!define CHECK_INSTALL_NAME "${QGIS_BASE}"
!define INSTALLER_DISPLAYED_NAME "${DISPLAYED_NAME}(bld.${NEXTGIS_QGIS_BUILD_NUMBER})"
!define PUBLISHER "NextGIS"
!define WEB_SITE "http://www.nextgis.ru"
!define WIKI_PAGE ""

!define SHORTNAME "qgis"

!define OSGEO4W_SRC_DIR "D:\builds\osgeo4w-env"
!define QGIS_SRC_DIR "D:\builds\qgis-final-2_2_0-nextgis"
!define GRASS_SRC_DIR "D:\builds\grass-fromOSGEO4W"
!define SAGA_SRC_DIR "D:\builds\saga-fromOSGEO4W"
!define GDAL_SRC_DIR "D:\builds\gdal-1.10.0-fromOSGEO4W"

!define QGIS_RUN_ICO_NAME "QGIS.ico"
!define QGIS_RUN_ICO_PATH "..\Installer-Files\${QGIS_RUN_ICO_NAME}"
!define QGIS_RUN_LNK_NAME "NextGIS QGIS (${VERSION_NUMBER}).lnk"

!define QGIS_POSTINSTALL_BAT "..\Installer-Files\for_release\postinstall.bat"
!define QGIS_PREREMOVE_BAT "..\Installer-Files\for_release\preremove.bat"

!define QGIS_UNINSTALL_FILE_NAME "Uninstall-NextGIS_QGIS.exe"
!define QGIS_UNINSTALL_LNK_NAME_SUFFIX "NextGIS QGIS (${VERSION_NUMBER})"

!define QGIS_MANUAL_FILE_NAME "QGIS-2.0-UserGuide-ru.pdf"

Name "${INSTALLER_DISPLAYED_NAME}"
OutFile "NextGIS-QGIS-release-${VERSION_NUMBER}-bld.${NEXTGIS_QGIS_BUILD_NUMBER}.exe"
InstallDir "C:\NextGIS_QGIS"

!macro Section_Install_Plugin

!macroend

!include "nextgis_qgis-base.nsh"