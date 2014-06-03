!define QGIS_BASE "NextGIS QGIS test"
!define DISPLAYED_NAME "NextGIS QGIS test"
!define VERSION_NUMBER "x.x.x"
!define NEXTGIS_QGIS_BUILD_NUMBER "7"
!define VERSION_NAME ""
!define COMPLETE_NAME "${QGIS_BASE} ${VERSION_NUMBER} ${VERSION_NAME}"
!define CHECK_INSTALL_NAME "${QGIS_BASE}"
!define INSTALLER_DISPLAYED_NAME "${DISPLAYED_NAME}(bld.${NEXTGIS_QGIS_BUILD_NUMBER})"
!define PUBLISHER "NextGIS"
!define WEB_SITE "http://www.nextgis.ru"
!define WIKI_PAGE ""

!define SHORTNAME "qgis-dev"

!define OSGEO4W_SRC_DIR "D:\builds\for_test"
!define QGIS_SRC_DIR "D:\builds\for_test"
!define GRASS_SRC_DIR "D:\builds\for_test"
!define SAGA_SRC_DIR "D:\builds\for_test"
!define GDAL_SRC_DIR "D:\builds\for_test"

!define QGIS_RUN_ICO_NAME "QGIS_dev.ico"
!define QGIS_RUN_ICO_PATH "..\Installer-Files\${QGIS_RUN_ICO_NAME}"
!define QGIS_RUN_LNK_NAME "NextGIS QGIS dev (${VERSION_NUMBER}).lnk"

!define QGIS_POSTINSTALL_BAT "..\Installer-Files\for_devel\postinstall.bat"
!define QGIS_PREREMOVE_BAT "..\Installer-Files\for_devel\preremove.bat"

!define QGIS_UNINSTALL_FILE_NAME "Uninstall-NextGIS_QGIS_test.exe"
!define QGIS_UNINSTALL_LNK_NAME_SUFFIX "NextGIS QGIS test (${VERSION_NUMBER})"

!define QGIS_MANUAL_FILE_NAME "QGIS-2.0-UserGuide-ru.pdf"

Name "${INSTALLER_DISPLAYED_NAME}"
OutFile "NextGIS-QGIS-test-${VERSION_NUMBER}-bld.${NEXTGIS_QGIS_BUILD_NUMBER}.exe"
InstallDir "C:\NextGIS_QGIS_TEST"

!macro Section_Install_Plugin
Section "-QGIS_PLUGINS" QGIS_PLUGINS
    SectionIn RO
    
    !define PLUGIN_DIR "D:\builds\plugins"
    WriteRegStr HKEY_CURRENT_USER "Software\QGIS\QGIS2\PythonPlugins" "identifyplus" "true"
    WriteRegStr HKEY_CURRENT_USER "Software\QGIS\QGIS2\PythonPlugins" "simplereports" "true"
    SetOutPath "$INSTALL_DIR\apps\${SHORTNAME}\python\plugins\"
    File /r "${PLUGIN_DIR}\identifyplus"
    File /r "${PLUGIN_DIR}\simplereports"
SectionEnd
!macroend

!include "nextgis_qgis-base.nsh"