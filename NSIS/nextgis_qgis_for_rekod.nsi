; ------------------- устанавливаются в python скрипте ---------------------
;!define PROGRAM_NAME "NextGIS QGIS Rekod TMSforRES" ; для идентификации установленного ПО
;!define PROGRAM_NAME "NextGIS QGIS Rekod TMSforDH" ; для идентификации установленного ПО 

;!define PROGRAM_VERSION "0.0.10" ; для идентификации установленного ПО

;!define PROGRAM_INSTALLER_HEADER "ЦСМ РЭС"
;!define PROGRAM_INSTALLER_HEADER "ЦСМ ДХ"

;!define PROGRAM_INSTALLER_OUTPUT_FILENAME "d:\builds\Rekod_TMSforRES_0.0.10"
;!define PROGRAM_INSTALLER_OUTPUT_FILENAME "d:\builds\Rekod_TMSforDH_0.0.10"

;!define PROGRAM_INSTALL_DEFAULT_INSTALL_DIR "c:\NextGIS_QGIS_Rekod_TMSforRES"
;!define PROGRAM_INSTALL_DEFAULT_INSTALL_DIR "c:\NextGIS_QGIS_Rekod_TMSforDH"

;!define PROGRAM_RUN_LNK_NAME "Целевая система мониторинга РЭС"
;!define PROGRAM_RUN_LNK_NAME "ЦСМ ДХ"
;!define PROGRAM_UNINSTALL_FILE_NAME "Uninstall-TMSforRES-${PROGRAM_VERSION}"
;!define PROGRAM_UNINSTALL_FILE_NAME "Uninstall-TMSforDH-${PROGRAM_VERSION}"
;!define PROGRAM_UNINSTALL_LNK_NAME "Удалить ${PROGRAM_RUN_LNK_NAME} (${PROGRAM_VERSION})"

#!define OSGEO4W_SRC_DIR "d:\\builds\\osgeo4w-env\\"
#!define QGIS_SRC_DIR "d:\\builds\\nextgis-qgis-rekod\\"
#!define GRASS_SRC_DIR "d:\\builds\\grass-fromOSGEO4W\\"
#!define SAGA_SRC_DIR "d:\\builds\\saga-fromOSGEO4W\\"
#!define GDAL_SRC_DIR "d:\\builds\\gdal-1.11.0-fromOSGEO4W\\"

;!define DEFAULT_PROJECT "d:\Development\NextGIS\installer\Rekod\TMSforRES\project_default.qgs"
;!define DEFAULT_PROJECT "d:\Development\NextGIS\installer\Rekod\TMSforDH\project_default.qgs"

;!define PROGRAM_RUN_LNK_ICO_PATH "d:\Development\NextGIS\installer\Rekod\Rekod.ico"
;!define PROGRAM_RUN_LNK_ICO_FILENAME "Rekod.ico"

;!define QGIS_RUN_BAT "..\Rekod\TMSforRES\qgis.bat"
;!define QGIS_RUN_BAT "..\Rekod\TMSforDH\qgis.bat"
;!define QGIS_PRE_RUN_BAT "..\Rekod\TMSforRES\qgis_preruner.bat"
;!define QGIS_PRE_RUN_BAT "..\Rekod\TMSforDH\qgis_preruner.bat"

;!define NEXTGIS_QGIS_INSTALLER_DEST "d:\\builds"

;!define REKOD_QGIS_DOCS "d:\Development\NextGIS\installer\Rekod\common_changes\doc\Rekod"
;!define NEXTGIS_QGIS_CUSTOMIZATION_LIGHT "d:\Development\NextGIS\installer\Rekod\customization\LIGHT"
;!define NEXTGIS_QGIS_CUSTOMIZATION_FULL "d:\Development\NextGIS\installer\Rekod\customization\FULL"

!define PROGRAM_NAME_FOR_START_MENU "${PROGRAM_NAME}"
;------------------------------------------------------------------------------

!define SHORTNAME "qgis"

!define QGIS_POSTINSTALL_BAT "..\Installer-Files\postinstall.bat"
!define QGIS_PREREMOVE_BAT "..\Installer-Files\preremove.bat"

Name "${PROGRAM_INSTALLER_HEADER}"
OutFile "${PROGRAM_INSTALLER_OUTPUT_FILENAME}.exe"
InstallDir "${PROGRAM_INSTALL_DEFAULT_INSTALL_DIR}"

SetCompressor /SOLID lzma
RequestExecutionLevel admin

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "utils.nsh"
!include "Sections.nsh"

!addplugindir ../osgeo4w/untgz
!addplugindir ../osgeo4w/nsis

ShowInstDetails show
ShowUnInstDetails show

!define MUI_ABORTWARNING
!define MUI_ICON "${PROGRAM_RUN_LNK_ICO_PATH}"
!define MUI_UNICON "${PROGRAM_RUN_LNK_ICO_PATH}"
;!define MUI_WELCOMEFINISHPAGE_BITMAP "..\Installer-Files\WelcomeFinishPage_ru.bmp"
;!define MUI_UNWELCOMEFINISHPAGE_BITMAP "..\Installer-Files\UnWelcomeFinishPage_ru.bmp"

!define MUI_WELCOMEPAGE_TITLE_3LINES

;--------------------------------
!insertmacro MUI_PAGE_WELCOME
;!insertmacro MUI_PAGE_LICENSE "..\Installer-Files\LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages
    !insertmacro MUI_LANGUAGE "Russian"
;--------------------------------
;Installer Sections
Section "-NextGIS_QGIS" NextGIS_QGIS
	SectionIn RO
	Var /GLOBAL INSTALL_DIR
	StrCpy $INSTALL_DIR "$INSTDIR"
	
	SetOverwrite try
	SetShellVarContext current
	Var /GLOBAL GIS_DATABASE ; TODO check this state
	StrCpy $GIS_DATABASE "$DOCUMENTS\GIS DataBase"
	CreateDirectory "$GIS_DATABASE"

	SetOutPath "$INSTALL_DIR"
	File "${QGIS_POSTINSTALL_BAT}"
	File "${QGIS_PREREMOVE_BAT}"
	
	WriteUninstaller "$INSTALL_DIR\${PROGRAM_UNINSTALL_FILE_NAME}.exe"
	
	WriteRegStr HKLM "Software\${PROGRAM_NAME}" "Name" "${PROGRAM_RUN_LNK_NAME}"
	WriteRegStr HKLM "Software\${PROGRAM_NAME}" "VersionNumber" "${PROGRAM_VERSION}"
	WriteRegStr HKLM "Software\${PROGRAM_NAME}" "InstallPath" "$INSTALL_DIR"
	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "DisplayName" "${PROGRAM_RUN_LNK_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "UninstallString" "$INSTALL_DIR\${PROGRAM_UNINSTALL_FILE_NAME}.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "DisplayVersion" "${PROGRAM_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "DisplayIcon" "$INSTALL_DIR\images\${PROGRAM_RUN_LNK_ICO_FILENAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "EstimatedSize" 1
SectionEnd

Section "-OSGEO4W_ENV" OSGEO4W_ENV
    SetOutPath "$INSTALL_DIR\"
	File /r "${OSGEO4W_SRC_DIR}\*.*"
SectionEnd

Section "-QGIS" QGIS
    SetOutPath "$INSTALL_DIR\apps\qgis\"
	File /r "${QGIS_SRC_DIR}\*.*"
    
    SetOutPath "$INSTALL_DIR\bin\"
	File /r "${QGIS_SRC_DIR}\bin\qgis.exe"

    SetOutPath "$INSTALL_DIR\defalut_options\"
    File /r "${DEFAULT_PROJECT}"

    SetOutPath "$INSTALL_DIR\bin"
    File /r "${QGIS_RUN_BAT}"
    File /r "${QGIS_PRE_RUN_BAT}"
    File /r "..\qgis_preruner.py"
    
    SetOutPath "$INSTALL_DIR"
    File /r "..\nextgis_qgis.ini"
    
    SetOutPath "$INSTALL_DIR\images"
    File /r "${PROGRAM_RUN_LNK_ICO_PATH}"
SectionEnd

Section "Customization - FULL" c_full
    SetOutPath "$INSTALL_DIR\defalut_options\QGIS\"
    File /r "${NEXTGIS_QGIS_CUSTOMIZATION_FULL}\*.*"
SectionEnd

Section /o "Customization - LIGHT" c_light
    SetOutPath "$INSTALL_DIR\defalut_options\QGIS\"
    File /r "${NEXTGIS_QGIS_CUSTOMIZATION_LIGHT}\*.*"
SectionEnd

Section "-RekodDocs" RekodDocs
    SetOutPath "$INSTALL_DIR\apps\qgis\doc\"
    File /r "${REKOD_QGIS_DOCS}"
SectionEnd

!ifdef ${PLUGINS}
    Section "-QGIS_PLUGINS" QGIS_PLUGINS  
        SetOutPath "$INSTALL_DIR\apps\${SHORTNAME}\python\plugins\"
        File /r ${PLUGINS}
    SectionEnd
!endif

Section "-GRASS" GRASS
    SetOutPath "$INSTALL_DIR\"
	File /r "${GRASS_SRC_DIR}\*.*"
SectionEnd

Section "-SAGA" SAGA
    SetOutPath "$INSTALL_DIR\"
	File /r "${SAGA_SRC_DIR}\*.*"
SectionEnd

Section "-GDAL" GDAL
    SetOutPath "$INSTALL_DIR\"
	File /r "${GDAL_SRC_DIR}\*.*"
SectionEnd
;--------------------------------
Section "-DONE"
    SetShellVarContext current
	SetShellVarContext all
	CreateDirectory "$SMPROGRAMS\${PROGRAM_NAME_FOR_START_MENU}"
	GetFullPathName /SHORT $0 $INSTALL_DIR
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_ROOT", "$0").r0'
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_STARTMENU", "$SMPROGRAMS\${PROGRAM_NAME_FOR_START_MENU}").r0'
    
    ReadEnvStr $0 COMSPEC
	nsExec::ExecToLog '"$0" /c "$INSTALL_DIR\postinstall.bat"'
	IfFileExists "$INSTALL_DIR\etc\reboot" RebootNecessary NoRebootNecessary

RebootNecessary:
	SetRebootFlag true

NoRebootNecessary:
    Delete "$DESKTOP\${PROGRAM_RUN_LNK_NAME}.lnk"
    CreateShortCut \
        "$DESKTOP\${PROGRAM_RUN_LNK_NAME}.lnk" \
        "$INSTALL_DIR\bin\nircmd.exe" 'exec hide "$INSTALL_DIR\bin\${SHORTNAME}.bat" "$INSTALL_DIR\defalut_options"' \
        "$INSTALL_DIR\images\${PROGRAM_RUN_LNK_ICO_FILENAME}" \
        "" \
        SW_SHOWNORMAL \
        "" \
        "Запустить ${PROGRAM_RUN_LNK_NAME}"

    Delete "$SMPROGRAMS\${PROGRAM_NAME_FOR_START_MENU}\${PROGRAM_RUN_LNK_NAME}.lnk"
    CreateShortCut \
        "$SMPROGRAMS\${PROGRAM_NAME_FOR_START_MENU}\${PROGRAM_RUN_LNK_NAME}.lnk" \
        "$INSTALL_DIR\bin\nircmd.exe" 'exec hide "$INSTALL_DIR\bin\${SHORTNAME}.bat" "$INSTALL_DIR\defalut_options"' \
        "$INSTALL_DIR\images\${PROGRAM_RUN_LNK_ICO_FILENAME}" \
        "" \
        SW_SHOWNORMAL \
        "" \
        "Запустить ${PROGRAM_RUN_LNK_NAME}"
        
    Delete "$SMPROGRAMS\${PROGRAM_NAME_FOR_START_MENU}\Установить настройки по-умолчанию.lnk"
    CreateShortCut \
        "$SMPROGRAMS\${PROGRAM_NAME_FOR_START_MENU}\Установить настройки по-умолчанию.lnk" \
        "$INSTALL_DIR\bin\nircmd.exe" 'exec hide "$INSTALL_DIR\bin\${SHORTNAME}_preruner.bat"' \
        "$INSTALL_DIR\images\${PROGRAM_RUN_LNK_ICO_FILENAME}" \
        "" \
        SW_SHOWNORMAL \
        "" \
        "Установить настройки по-умолчанию"

    Delete "$SMPROGRAMS\${PROGRAM_NAME_FOR_START_MENU}\${PROGRAM_UNINSTALL_LNK_NAME}.lnk"
    CreateShortCut \
        "$SMPROGRAMS\${PROGRAM_NAME_FOR_START_MENU}\${PROGRAM_UNINSTALL_LNK_NAME}.lnk" \
        "$INSTALL_DIR\${PROGRAM_UNINSTALL_FILE_NAME}.exe" \
        "" \
        "$INSTALL_DIR\${PROGRAM_UNINSTALL_FILE_NAME}.exe" \
        "" \
        SW_SHOWNORMAL \
        "" \
        "Удалить ${PROGRAM_RUN_LNK_NAME}"

SectionEnd

;--------------------------------
;Descriptions

;--------------------------------
;Installer Functions

LangString ALREADY_INSTALL_MSG ${LANG_RUSSIAN} "\
    ${PROGRAM_RUN_LNK_NAME} уже установлен на вашем компьютере. \
    $\n$\nУстановленная версия: $0 $1\
    $\n$\nНажмите `OK` для удаления текущей версии и установки ${PROGRAM_RUN_LNK_NAME} (${PROGRAM_VERSION}) или 'Отмена' для выхода."

Function .onInit
    StrCpy $9 ${c_full}
    
    !insertmacro MUI_LANGDLL_DISPLAY
    
    Var /GLOBAL uninstaller_path
    Var /GLOBAL installer_path
    
    !insertmacro IfKeyExists HKLM "Software" "${PROGRAM_NAME}"
    Pop $R0
       
    ${If} $R0 = 1
        ReadRegStr $0 HKLM "Software\${PROGRAM_NAME}" "Name"
        ReadRegStr $1 HKLM "Software\${PROGRAM_NAME}" "VersionNumber"
        
        MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
          $(ALREADY_INSTALL_MSG) \
          IDOK uninst  IDCANCEL  quit_uninstall
    
            uninst:  
                ReadRegStr $uninstaller_path HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "UninstallString"
                ReadRegStr $installer_path HKLM "Software\${PROGRAM_NAME}" "InstallPath"
                ExecWait '$uninstaller_path _?=$installer_path' $0
                
                ${If} $0 = 0
                    Goto continue_uninstall
                ${Else}
                    Goto quit_uninstall
                ${EndIf}
                
            quit_uninstall:
                Abort
                
            continue_uninstall:
                RMDir /r "$installer_path"
    ${EndIf}
    
FunctionEnd

Function .onSelChange
  !insertmacro StartRadioButtons $9
    !insertmacro RadioButton ${c_full}
    !insertmacro RadioButton ${c_light}
  !insertmacro EndRadioButtons
    
FunctionEnd

;--------------------------------
;Uninstaller Section
Section "Uninstall"
	GetFullPathName /SHORT $0 $INSTDIR
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_ROOT", "$0").r0'
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_STARTMENU", "$SMPROGRAMS\${PROGRAM_NAME_FOR_START_MENU}").r0'

	ReadEnvStr $0 COMSPEC
	nsExec::ExecToLog '"$0" /c "$INSTALL_DIR\preremove.bat"'

	RMDir /r "$INSTDIR"

	SetShellVarContext all
	Delete "$DESKTOP\${PROGRAM_RUN_LNK_NAME}.lnk"
    
	SetShellVarContext all
	RMDir /r "$SMPROGRAMS\${PROGRAM_NAME_FOR_START_MENU}"

	DeleteRegKey HKLM "Software\${PROGRAM_NAME}"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}"
SectionEnd

;--------------------------------
;Uninstaller Functions

Function un.onInit

  !insertmacro MUI_UNGETLANGUAGE
  
FunctionEnd