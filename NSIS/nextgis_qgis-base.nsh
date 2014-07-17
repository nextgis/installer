SetCompressor /SOLID lzma
RequestExecutionLevel admin

Name "${PROGRAM_NAME}"
OutFile "${INSTALLER_NAME}"
InstallDir "${DEFAULT_INSTALL_DIR}"

!include "MUI2.nsh"
!include "LogicLib.nsh"
!include "utils.nsh"

!addplugindir ../osgeo4w/nsis

ShowInstDetails show
ShowUnInstDetails show

!define MUI_ABORTWARNING

;---- Only for NextGIS QGIS, NextGIS QGIS dev, NextGIS QGIS future --------------------
!define MUI_ICON "..\Installer-Files\Install_QGIS.ico"
!define MUI_UNICON "..\Installer-Files\Uninstall_QGIS.ico"
!define MUI_HEADERIMAGE_BITMAP_NOSTETCH "..\Installer-Files\InstallHeaderImage.bmp"
!define MUI_HEADERIMAGE_UNBITMAP_NOSTRETCH "..\Installer-Files\UnInstallHeaderImage.bmp"

!define MUI_WELCOMEPAGE_TITLE_3LINES

;--------------------------------
;Show all languages, despite user's codepage
!define MUI_LANGDLL_ALLLANGUAGES

;--------------------------------
;Remember the installer language
!define MUI_LANGDLL_REGISTRY_ROOT "HKLM" 
!define MUI_LANGDLL_REGISTRY_KEY "Software\${PROGRAM_NAME}" 
!define MUI_LANGDLL_REGISTRY_VALUENAME "Installer Language"

;--------------------------------
; Dependence Welcome pages images from language
!define MUI_PAGE_CUSTOMFUNCTION_PRE wel_pre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW wel_show

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\Installer-Files\LICENSE.txt"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_FINISH

;--------------------------------
; Dependence Welcome pages images from language
!define MUI_PAGE_CUSTOMFUNCTION_PRE un.wel_pre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW un.wel_show

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

;--------------------------------
;Available Languages
    !insertmacro MUI_LANGUAGE "English" ;first language is the default language
    !insertmacro MUI_LANGUAGE "Russian"

;--------------------------------
;Reserve Files
  
  ;If you are using solid compression, files that are required before
  ;the actual installation should be stored first in the data block,
  ;because this will make your installer start faster.
  
  !insertmacro MUI_RESERVEFILE_LANGDLL
  
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

	SetOutPath "$INSTALL_DIR\icons"
	File "${NextGIS_QGIS_RUN_LNK_ICO_Path}"

	SetOutPath "$INSTALL_DIR"
	File "${QGIS_POSTINSTALL_BAT}"
	File "${QGIS_PREREMOVE_BAT}"
	
	WriteUninstaller "$INSTALL_DIR\${NextGIS_QGIS_UNINSTALLER_FileName}"
	
	WriteRegStr HKLM "Software\${PROGRAM_NAME}" "Name" "${PROGRAM_NAME}"
	WriteRegStr HKLM "Software\${PROGRAM_NAME}" "VersionNumber" "${PROGRAM_VERSION}"
	WriteRegStr HKLM "Software\${PROGRAM_NAME}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKLM "Software\${PROGRAM_NAME}" "WebSite" "${WEB_SITE}"
	WriteRegStr HKLM "Software\${PROGRAM_NAME}" "InstallPath" "$INSTALL_DIR"
	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "DisplayName" "${PROGRAM_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "UninstallString" "$INSTALL_DIR\${NextGIS_QGIS_UNINSTALLER_FileName}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "DisplayVersion" "${PROGRAM_VERSION}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "DisplayIcon" "$INSTALL_DIR\icons\${NextGIS_QGIS_RUN_LNK_ICO_FileName}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "EstimatedSize" 1
	;WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "HelpLink" "${WIKI_PAGE}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "URLInfoAbout" "${WEB_SITE}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "Publisher" "${PUBLISHER}"
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
SectionEnd

Section "-QGIS_CUSTOMIZATION" QGIS_CUSTOMIZATION
    SetOutPath "$INSTALL_DIR\defalut_options"
    File /r "${QGIS_DEFAULT_OPTIONS_PATH}\*"
    
    SetOutPath "$INSTALL_DIR\bin"
    File /r "${QGIS_RUN_BAT}"
    File /r "${QGIS_PRE_RUN_BAT}"
    File /r "..\qgis_preruner.py"
    
    SetOutPath "$INSTALL_DIR"
    File /r "..\nextgis_qgis.ini"
SectionEnd

!ifdef ${PLUGINS}
    Section "-QGIS_PLUGINS" QGIS_PLUGINS  
        SetOutPath "$INSTALL_DIR\apps\${SHORTNAME}\python\plugins\"
        File /r ${PLUGINS}
    SectionEnd
!endif

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
LangString QGIS_MAN ${LANG_RUSSIAN} "����������� ������������ QGIS"
LangString QGIS_MAN ${LANG_ENGLISH} "Manual QGIS"
LangString QGIS_MAN_HELP ${LANG_RUSSIAN} "������� ����������� ������������ QGIS"
LangString QGIS_MAN_HELP ${LANG_ENGLISH} "Open QGIS manual"
LangString DEL_QGIS ${LANG_RUSSIAN} "�������"
LangString DEL_QGIS ${LANG_ENGLISH} "Delete"
LangString RUN_QGIS ${LANG_RUSSIAN} "���������"
LangString RUN_QGIS ${LANG_ENGLISH} "Run"
LangString SET_DEFAULT_SETTINGS ${LANG_RUSSIAN} "���������� ��������� ��-���������"
LangString SET_DEFAULT_SETTINGS ${LANG_ENGLISH} "Set default settings"
;--------------------------------

Section "-DONE"
    SetShellVarContext current
	SetShellVarContext all
	CreateDirectory "$SMPROGRAMS\${PROGRAM_NAME}"
	GetFullPathName /SHORT $0 $INSTALL_DIR
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_ROOT", "$0").r0'
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_STARTMENU", "$SMPROGRAMS\${PROGRAM_NAME}").r0'
    
    ReadEnvStr $0 COMSPEC
	nsExec::ExecToLog '"$0" /c "$INSTALL_DIR\postinstall.bat"'
	IfFileExists "$INSTALL_DIR\etc\reboot" RebootNecessary NoRebootNecessary

RebootNecessary:
	SetRebootFlag true

NoRebootNecessary:
        Delete "$DESKTOP\${NextGIS_QGIS_RUN_LNK_NAME}"
        CreateShortCut "$DESKTOP\${NextGIS_QGIS_RUN_LNK_NAME}" "$INSTALL_DIR\bin\nircmd.exe" 'exec hide "$INSTALL_DIR\bin\${SHORTNAME}.bat"' \
        "$INSTALL_DIR\icons\${NextGIS_QGIS_RUN_LNK_ICO_FileName}" "" SW_SHOWNORMAL "" "$(RUN_QGIS) ${PROGRAM_NAME}"

        Delete "$SMPROGRAMS\${PROGRAM_NAME}\${NextGIS_QGIS_RUN_LNK_NAME}"
        CreateShortCut "$SMPROGRAMS\${PROGRAM_NAME}\${NextGIS_QGIS_RUN_LNK_NAME}" "$INSTALL_DIR\bin\nircmd.exe" 'exec hide "$INSTALL_DIR\bin\${SHORTNAME}.bat"' \
        "$INSTALL_DIR\icons\${NextGIS_QGIS_RUN_LNK_ICO_FileName}" "" SW_SHOWNORMAL "" "$(RUN_QGIS) ${PROGRAM_NAME}"
        
        Delete "$SMPROGRAMS\${PROGRAM_NAME}\$(SET_DEFAULT_SETTINGS).lnk"
        CreateShortCut \
        "$SMPROGRAMS\${PROGRAM_NAME}\$(SET_DEFAULT_SETTINGS).lnk" \
        "$INSTALL_DIR\bin\nircmd.exe" 'exec hide "$INSTALL_DIR\bin\${SHORTNAME}_preruner.bat"' \
        "$INSTALL_DIR\icons\${NextGIS_QGIS_RUN_LNK_ICO_FileName}" \
        "" \
        SW_SHOWNORMAL \
        "" \
        "$(SET_DEFAULT_SETTINGS)"
        
        Delete "$SMPROGRAMS\${PROGRAM_NAME}\$(DEL_QGIS) ${NextGIS_QGIS_UNINSTALL_LNK_NAME_SUFFIX}.lnk"
        CreateShortCut "$SMPROGRAMS\${PROGRAM_NAME}\$(DEL_QGIS) ${NextGIS_QGIS_UNINSTALL_LNK_NAME_SUFFIX}.lnk" "$INSTALL_DIR\${NextGIS_QGIS_UNINSTALLER_FileName}" "" \
        "$INSTALL_DIR\${NextGIS_QGIS_UNINSTALLER_FileName}" "" SW_SHOWNORMAL "" "$(DEL_QGIS) ${PROGRAM_NAME}"
        
        Delete "$SMPROGRAMS\${PROGRAM_NAME}\$(QGIS_MAN).lnk"
        CreateShortCut "$SMPROGRAMS\${PROGRAM_NAME}\$(QGIS_MAN).lnk" "$INSTALL_DIR\manual\${QGIS_MANUAL_FILE_NAME}" "" "" "" "" "" "$(QGIS_MAN_HELP)"
SectionEnd

;--------------------------------
;Installer Functions
LangString ALREADY_INSTALL_MSG ${LANG_RUSSIAN} "\
    ${PROGRAM_NAME} ��� ���������� �� ����� ����������. \
    $\n$\n������������� ������: $0\
    $\n$\n������� `OK` ��� �������� ${PROGRAM_NAME} ($0) � ��������� ${PROGRAM_NAME} (${PROGRAM_VERSION}) ��� '������' ��� ������."
    
LangString ALREADY_INSTALL_MSG ${LANG_ENGLISH} "\
    ${PROGRAM_NAME} is already installed on your system. \
    $\n$\nThe installed version is $0\
    $\n$\nPress `OK` to delete ${PROGRAM_NAME} ($0) and reinstall ${PROGRAM_NAME} (${PROGRAM_VERSION}) or 'Cancel' to quit."
    
Function .onInit
    !insertmacro MUI_LANGDLL_DISPLAY
    
    Var /GLOBAL uninstaller_path
    Var /GLOBAL installer_path
    
    !insertmacro IfKeyExists HKLM "Software" "${PROGRAM_NAME}"
    Pop $R0
       
    ${If} $R0 = 1
        ReadRegStr $0 HKLM "Software\${PROGRAM_NAME}" "VersionNumber"
            
        MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
          $(ALREADY_INSTALL_MSG) \
          IDOK uninst  IDCANCEL  quit_uninstall
    
            uninst:  
                ReadRegStr $uninstaller_path HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}" "UninstallString"
                ReadRegStr $installer_path HKLM "Software\${PROGRAM_NAME}" "InstallPath"
                ExecWait '$uninstaller_path _?=$installer_path' $1
                
                ${If} $1 = 0
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
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_STARTMENU", "$SMPROGRAMS\${PROGRAM_NAME}").r0'

	ReadEnvStr $0 COMSPEC
	nsExec::ExecToLog '"$0" /c "$INSTALL_DIR\preremove.bat"'

	RMDir /r "$INSTDIR"

	SetShellVarContext all
	Delete "$DESKTOP\${NextGIS_QGIS_RUN_LNK_NAME}"
    
	SetShellVarContext all
	RMDir /r "$SMPROGRAMS\${PROGRAM_NAME}"

	DeleteRegKey HKLM "Software\${PROGRAM_NAME}"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PROGRAM_NAME}"
SectionEnd

;--------------------------------
;Uninstaller Functions
Function un.onInit
  !insertmacro MUI_UNGETLANGUAGE
FunctionEnd