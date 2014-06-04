SetCompressor /SOLID lzma
RequestExecutionLevel admin

;!include "MUI.nsh"
!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "utils.nsh"

!addplugindir ../osgeo4w/untgz
!addplugindir ../osgeo4w/nsis

ShowInstDetails show
ShowUnInstDetails show

!define MUI_ABORTWARNING
!define MUI_ICON "..\Installer-Files\Install_QGIS.ico"
!define MUI_UNICON "..\Installer-Files\Uninstall_QGIS.ico"
!define MUI_HEADERIMAGE_BITMAP_NOSTETCH "..\Installer-Files\InstallHeaderImage.bmp"
!define MUI_HEADERIMAGE_UNBITMAP_NOSTRETCH "..\Installer-Files\UnInstallHeaderImage.bmp"
;!define MUI_WELCOMEFINISHPAGE_BITMAP "..\Installer-Files\WelcomeFinishPage_ru.bmp"
;!define MUI_UNWELCOMEFINISHPAGE_BITMAP "..\Installer-Files\UnWelcomeFinishPage_ru.bmp"

!define MUI_WELCOMEPAGE_TITLE_3LINES

;Show all languages, despite user's codepage
!define MUI_LANGDLL_ALLLANGUAGES

;--------------------------------
;Language Selection Dialog Settings

    ;Remember the installer language
    !define MUI_LANGDLL_REGISTRY_ROOT "HKLM" 
    !define MUI_LANGDLL_REGISTRY_KEY "Software\${QGIS_BASE}" 
    !define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"
  
;--------------------------------
!define MUI_PAGE_CUSTOMFUNCTION_PRE wel_pre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW wel_show
!insertmacro MUI_PAGE_WELCOME

!insertmacro MUI_PAGE_LICENSE "..\Installer-Files\LICENSE.txt"

!insertmacro MUI_PAGE_DIRECTORY

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_FINISH

!define MUI_PAGE_CUSTOMFUNCTION_PRE un.wel_pre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW un.wel_show
!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Languages
    !insertmacro MUI_LANGUAGE "English" ;first language is the default language
    !insertmacro MUI_LANGUAGE "Russian"
;--------------------------------

Function wel_pre
    ${Switch} $LANGUAGE
    ${Case} ${LANG_ENGLISH}
        File /oname=$PLUGINSDIR\modern-wizard.bmp "..\Installer-Files\WelcomeFinishPage_en.bmp"
        File /oname=$PLUGINSDIR\modern-un-wizard.bmp "..\Installer-Files\UnWelcomeFinishPage_en.bmp"
    ${Break}
    ${Case} ${LANG_RUSSIAN}
        File /oname=$PLUGINSDIR\modern-wizard.bmp "..\Installer-Files\WelcomeFinishPage_ru.bmp"
        File /oname=$PLUGINSDIR\modern-un-wizard.bmp "..\Installer-Files\UnWelcomeFinishPage_ru.bmp"
    ${Break}
    ${Default}
        File /oname=$PLUGINSDIR\modern-wizard.bmp "..\Installer-Files\WelcomeFinishPage_en.bmp"
        File /oname=$PLUGINSDIR\modern-un-wizard.bmp "..\Installer-Files\UnWelcomeFinishPage_en.bmp"
    ${EndSwitch}
FunctionEnd
 
Function wel_show
    ${NSD_SetImage} $mui.WelcomePage.Image $PLUGINSDIR\modern-wizard.bmp $mui.WelcomePage.Image.Bitmap
FunctionEnd

Function un.wel_pre
    ${Switch} $LANGUAGE
    ${Case} ${LANG_ENGLISH}
        File /oname=$PLUGINSDIR\modern-wizard.bmp "..\Installer-Files\UnWelcomeFinishPage_en.bmp"
    ${Break}
    ${Case} ${LANG_RUSSIAN}
        File /oname=$PLUGINSDIR\modern-wizard.bmp "..\Installer-Files\UnWelcomeFinishPage_ru.bmp"
    ${Break}
    ${Default}
        File /oname=$PLUGINSDIR\modern-wizard.bmp "..\Installer-Files\UnWelcomeFinishPage_en.bmp"
    ${EndSwitch}
FunctionEnd
 
Function un.wel_show
    ${NSD_SetImage} $mui.WelcomePage.Image $PLUGINSDIR\modern-wizard.bmp $mui.WelcomePage.Image.Bitmap
FunctionEnd

;--------------------------------
;Installer Sections
Section "NextGIS_QGIS" NextGIS_QGIS
	SectionIn RO
	Var /GLOBAL INSTALL_DIR
	StrCpy $INSTALL_DIR "$INSTDIR"
	
	SetOverwrite try
	SetShellVarContext current
	Var /GLOBAL GIS_DATABASE
	StrCpy $GIS_DATABASE "$DOCUMENTS\GIS DataBase"
	CreateDirectory "$GIS_DATABASE"

	SetOutPath "$INSTALL_DIR\icons"
	File "${QGIS_RUN_ICO_PATH}"
    
	SetOutPath "$INSTALL_DIR"
	File "${QGIS_POSTINSTALL_BAT}"
	File "${QGIS_PREREMOVE_BAT}"
	
	WriteUninstaller "$INSTALL_DIR\${QGIS_UNINSTALL_FILE_NAME}"
	
	WriteRegStr HKLM "Software\${QGIS_BASE}" "Name" "${QGIS_BASE}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "VersionNumber" "${VERSION_NUMBER}"
    WriteRegStr HKLM "Software\${QGIS_BASE}" "BuildNumber" "${NEXTGIS_QGIS_BUILD_NUMBER}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "VersionName" "${VERSION_NAME}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "WebSite" "${WEB_SITE}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "InstallPath" "$INSTALL_DIR"
	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "DisplayName" "${COMPLETE_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "UninstallString" "$INSTALL_DIR\${QGIS_UNINSTALL_FILE_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "DisplayVersion" "${VERSION_NUMBER}"
    WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "BuildNumber" "${NEXTGIS_QGIS_BUILD_NUMBER}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "DisplayIcon" "$INSTALL_DIR\icons\${QGIS_RUN_ICO_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "EstimatedSize" 1
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "HelpLink" "${WIKI_PAGE}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "URLInfoAbout" "${WEB_SITE}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "Publisher" "${PUBLISHER}"
	
    WriteRegStr HKCU "Software\QGIS\QGIS2\Qgis\plugin-repos\Репозиторий NextGIS" "url" "http://nextgis.ru/programs/qgis/qgis-repo.xml"
    WriteRegStr HKCU "Software\QGIS\QGIS2\Qgis\plugin-repos\Репозиторий NextGIS" "enabled" "true"
SectionEnd

!insertmacro Section_Install_Plugin

Section "-OSGEO4W_ENV" OSGEO4W_ENV
    SetOutPath "$INSTALL_DIR\"
	File /r "${OSGEO4W_SRC_DIR}\*.*"
SectionEnd

Section "-QGIS" QGIS
    SetOutPath "$INSTALL_DIR\apps\qgis\"
	File /r "${QGIS_SRC_DIR}\*.*"
    
    SetOutPath "$INSTALL_DIR\bin\"
	File /r "${QGIS_SRC_DIR}\bin\qgis.exe"
SectionEnd

Section "GRASS" GRASS
    SetOutPath "$INSTALL_DIR\"
	File /r "${GRASS_SRC_DIR}\*.*"
SectionEnd

Section "SAGA" SAGA
    SetOutPath "$INSTALL_DIR\"
	File /r "${SAGA_SRC_DIR}\*.*"
SectionEnd

Section "-GDAL" GDAL
    SetOutPath "$INSTALL_DIR\"
	File /r "${GDAL_SRC_DIR}\*.*"
SectionEnd

;--------------------------------
;Language strings
LangString QGIS_MAN ${LANG_RUSSIAN} "Руководство пользователя QGIS"
LangString QGIS_MAN ${LANG_ENGLISH} "Manual QGIS"
LangString QGIS_MAN_HELP ${LANG_RUSSIAN} "Открыть руководство пользователя QGIS"
LangString QGIS_MAN_HELP ${LANG_ENGLISH} "Open QGIS manual"
LangString DEL_QGIS ${LANG_RUSSIAN} "Удалить"
LangString DEL_QGIS ${LANG_ENGLISH} "Delete"
LangString RUN_QGIS ${LANG_RUSSIAN} "Запустить"
LangString RUN_QGIS ${LANG_ENGLISH} "Run"
;--------------------------------

Section "-DONE"
    SetShellVarContext current
	SetShellVarContext all
	CreateDirectory "$SMPROGRAMS\${QGIS_BASE}"
	GetFullPathName /SHORT $0 $INSTALL_DIR
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_ROOT", "$0").r0'
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_STARTMENU", "$SMPROGRAMS\${QGIS_BASE}").r0'
    
    ReadEnvStr $0 COMSPEC
	nsExec::ExecToLog '"$0" /c "$INSTALL_DIR\postinstall.bat"'
	IfFileExists "$INSTALL_DIR\etc\reboot" RebootNecessary NoRebootNecessary

RebootNecessary:
	SetRebootFlag true

NoRebootNecessary:
        Delete "$DESKTOP\${QGIS_RUN_LNK_NAME}"
        CreateShortCut "$DESKTOP\${QGIS_RUN_LNK_NAME}" "$INSTALL_DIR\bin\nircmd.exe" 'exec hide "$INSTALL_DIR\bin\${SHORTNAME}.bat"' \
        "$INSTALL_DIR\icons\${QGIS_RUN_ICO_NAME}" "" SW_SHOWNORMAL "" "$(RUN_QGIS) ${COMPLETE_NAME}"

        Delete "$SMPROGRAMS\${QGIS_BASE}\${QGIS_RUN_LNK_NAME}"
        CreateShortCut "$SMPROGRAMS\${QGIS_BASE}\${QGIS_RUN_LNK_NAME}" "$INSTALL_DIR\bin\nircmd.exe" 'exec hide "$INSTALL_DIR\bin\${SHORTNAME}.bat"' \
        "$INSTALL_DIR\icons\${QGIS_RUN_ICO_NAME}" "" SW_SHOWNORMAL "" "$(RUN_QGIS) ${COMPLETE_NAME}"
        
        Delete "$SMPROGRAMS\${QGIS_BASE}\$(DEL_QGIS) ${QGIS_UNINSTALL_LNK_NAME_SUFFIX}.lnk"
        CreateShortCut "$SMPROGRAMS\${QGIS_BASE}\$(DEL_QGIS) ${QGIS_UNINSTALL_LNK_NAME_SUFFIX}.lnk" "$INSTALL_DIR\${QGIS_UNINSTALL_FILE_NAME}" "" \
        "$INSTALL_DIR\${QGIS_UNINSTALL_FILE_NAME}" "" SW_SHOWNORMAL "" "$(DEL_QGIS) ${COMPLETE_NAME}"
        
        Delete "$SMPROGRAMS\${QGIS_BASE}\$(QGIS_MAN).lnk"
        CreateShortCut "$SMPROGRAMS\${QGIS_BASE}\$(QGIS_MAN).lnk" "$INSTALL_DIR\manual\${QGIS_MANUAL_FILE_NAME}" "" "" "" "" "" "$(QGIS_MAN_HELP)"
        
SectionEnd

;--------------------------------
;Descriptions

;--------------------------------
;Installer Functions

LangString ALREADY_INSTALL_MSG ${LANG_RUSSIAN} "\
    ${DISPLAYED_NAME} уже установлен на вашем компьютере. \
    $\n$\nУстановленная версия: $0 $2\
    $\n$\nНажмите `OK` для установки ${DISPLAYED_NAME} $0 $2 или 'Отмена' для выхода."
    
LangString ALREADY_INSTALL_MSG ${LANG_ENGLISH} "\
    ${DISPLAYED_NAME} is already installed on your system. \
    $\n$\nThe installed release is $0 $2\
    $\n$\nPress `OK` to reinstall ${DISPLAYED_NAME} $0 $2 or 'Cancel' to quit."
    
Function .onInit
    
    !insertmacro MUI_LANGDLL_DISPLAY
    
    Var /GLOBAL uninstaller_path
    Var /GLOBAL installer_path
    
    !insertmacro IfKeyExists HKLM "Software" "${QGIS_BASE}"
    Pop $R0
       
    ${If} $R0 = 1
        ReadRegStr $0 HKLM "Software\${QGIS_BASE}" "VersionNumber"
        
        ;read build number info
        ReadRegStr $1 HKLM "Software\${QGIS_BASE}" "BuildNumber"
        
        StrCmp $1 "" 0 +3
          StrCpy $2 ""
          Goto +2
          StrCpy $2 "(bld. $1)"
        
            
        MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
          $(ALREADY_INSTALL_MSG) \
          IDOK uninst  IDCANCEL  quit_uninstall
    
            uninst:  
                ReadRegStr $uninstaller_path HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "UninstallString"
                ReadRegStr $installer_path HKLM "Software\${QGIS_BASE}" "InstallPath"
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

;--------------------------------
;Uninstaller Section
Section "Uninstall"
	GetFullPathName /SHORT $0 $INSTDIR
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_ROOT", "$0").r0'
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_STARTMENU", "$SMPROGRAMS\${QGIS_BASE}").r0'

	ReadEnvStr $0 COMSPEC
	nsExec::ExecToLog '"$0" /c "$INSTALL_DIR\preremove.bat"'

	RMDir /r "$INSTDIR"

	SetShellVarContext all
	Delete "$DESKTOP\${QGIS_RUN_LNK_NAME}"
    
	SetShellVarContext all
	RMDir /r "$SMPROGRAMS\${QGIS_BASE}"

	DeleteRegKey HKLM "Software\${QGIS_BASE}"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}"
SectionEnd

;--------------------------------
;Uninstaller Functions

Function un.onInit

  !insertmacro MUI_UNGETLANGUAGE
  
FunctionEnd