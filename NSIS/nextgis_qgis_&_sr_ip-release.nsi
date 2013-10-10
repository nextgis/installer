!define QGIS_BASE "NextGIS QGIS"
!define DISPLAYED_NAME "NextGIS QGIS"
!define VERSION_NUMBER "2.0.1"
!define VERSION_NAME ""
!define COMPLETE_NAME "${QGIS_BASE} ${VERSION_NUMBER} ${VERSION_NAME}"
!define CHECK_INSTALL_NAME "${QGIS_BASE}"
!define INSTALLER_DISPLAYED_NAME "${DISPLAYED_NAME}"
!define PUBLISHER "NextGIS"
!define WEB_SITE "http://www.nextgis.ru"
!define WIKI_PAGE ""

!define SHORTNAME "qgis"

!define SRC_DIR "D:\builds\qgis-release-2_0-with-env"

!define QGIS_RUN_ICO_NAME "QGIS.ico"
!define QGIS_RUN_ICO_PATH "..\Installer-Files\${QGIS_RUN_ICO_NAME}"
!define QGIS_RUN_LNK_NAME "NextGIS QGIS (${VERSION_NUMBER}).lnk"

!define QGIS_POSTINSTALL_BAT "..\Installer-Files\for_release\postinstall.bat"
!define QGIS_PREREMOVE_BAT "..\Installer-Files\for_release\preremove.bat"

!define QGIS_UNINSTALL_FILE_NAME "Uninstall-NextGIS_QGIS.exe"
!define QGIS_UNINSTALL_LNK_NAME "Удалить NextGIS QGIS (${VERSION_NUMBER}).lnk"

!define QGIS_MANUAL_FILE_NAME "qgis-1.8.0_user_guide_ru.pdf"

Name "NextGIS QGIS"
OutFile "NextGIS-QGIS-release-${VERSION_NUMBER}-with_sr_ip.exe"
InstallDir "C:\NextGIS_QGIS"

!macro install_plugin_macro
    !define PLUGIN_DIR "D:\builds\plugins"

    WriteRegStr HKEY_CURRENT_USER "Software\QGIS\QGIS2\PythonPlugins" "identifyplus" "true"
    WriteRegStr HKEY_CURRENT_USER "Software\QGIS\QGIS2\PythonPlugins" "simplereports" "true"

    SetOutPath "$INSTALL_DIR\apps\${SHORTNAME}\python\plugins\"
    File /r "${PLUGIN_DIR}\identifyplus"
    File /r "${PLUGIN_DIR}\simplereports"
!macroend


!include "nextgis_qgis-base.nsh"