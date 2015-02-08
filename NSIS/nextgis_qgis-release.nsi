!define PROGRAM_NAME "NextGIS QGIS" ; good

; define by auto build system ======
;!define PROGRAM_VERSION "2.6.1.18" ; good
; ==================================

!define PUBLISHER "NextGIS" ; good
!define WEB_SITE "http://www.nextgis.ru" ; good

!define DEFAULT_INSTALL_DIR "c:\NextGIS_QGIS" ; good

; define by auto build system ======
;!define INSTALLER_DST_DIR "./" ; good
;!define INSTALLER_NAME "${INSTALLER_DST_DIR}\NextGIS-QGIS-release-${PROGRAM_VERSION}.exe" ; good
; ==================================

!define QGIS_DEFAULT_OPTIONS_PATH "..\NextGIS QGIS\qgis_default_options\" ; good

!define WIKI_PAGE ""

!define SHORTNAME "qgis" ; good

; define by auto build system ======
;!define OSGEO4W_SRC_DIR "D:\builds\osgeo4w" ;good
;!define QGIS_SRC_DIR "D:\builds\nextgis-qgis-release" ;good
;!define GRASS_SRC_DIR "D:\builds\grass-fromOSGEO4W" ;good
;!define SAGA_SRC_DIR "D:\builds\saga-fromOSGEO4W" ;good
;!define GDAL_SRC_DIR "D:\builds\gdal-1.11.0-fromOSGEO4W" ;good
;!define ICONV_SRC_DIR "D:\builds\libiconv-fromOSGEO4W" ;
; ==================================

!define NextGIS_QGIS_RUN_LNK_NAME "NextGIS QGIS (${PROGRAM_VERSION}).lnk" ; good
!define NextGIS_QGIS_RUN_LNK_ICO_FileName "QGIS.ico" ; good
!define NextGIS_QGIS_RUN_LNK_ICO_Path "..\Installer-Files\${NextGIS_QGIS_RUN_LNK_ICO_FileName}" ; good

!define QGIS_RUN_BAT "..\NextGIS QGIS\NextGIS QGIS\qgis.bat"  ; good
!define QGIS_PRE_RUN_BAT "..\NextGIS QGIS\NextGIS QGIS\qgis_preruner.bat"  ; good

!define QGIS_POSTINSTALL_BAT "..\Installer-Files\postinstall.bat" ; good
!define QGIS_PREREMOVE_BAT "..\Installer-Files\preremove.bat" ;  good

!define NextGIS_QGIS_UNINSTALLER_FileName "Uninstall-NextGIS_QGIS_release.exe" ; good
!define NextGIS_QGIS_UNINSTALL_LNK_NAME_SUFFIX "NextGIS QGIS (${PROGRAM_VERSION})" ; good

; define by auto build system ======
;!define QGIS_MANUAL_FILE_NAME_RU "QGIS-2.6-UserGuide-ru.pdf"; good
;!define QGIS_MANUAL_FILE_NAME_EN "QGIS-2.6-UserGuide-en.pdf"; good
;!define PLUGINS "d:\builds\plugins\identifyplus"; good 
; ==================================
!define EXAMPLES_DIR "..\ngq-examples"
!define FONTS_DIR "..\fonts"

!include "nextgis_qgis-base.nsh"