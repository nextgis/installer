SetCompressor /SOLID lzma
RequestExecutionLevel admin

!include "MUI.nsh"
!include "LogicLib.nsh"
!include "utils.nsh"

!addplugindir ../osgeo4w/untgz
!addplugindir ../osgeo4w/nsis

Function .onInit

    Var /GLOBAL uninstaller_path
    Var /GLOBAL installer_path
    
    !insertmacro IfKeyExists HKLM "Software" "${QGIS_BASE}"
    Pop $R0
       
    ${If} $R0 = 1
        ReadRegStr $0 HKLM "Software\${QGIS_BASE}" "VersionNumber"
        MessageBox MB_OKCANCEL|MB_ICONEXCLAMATION \
          "${DISPLAYED_NAME} is already installed on your system. \
          $\n$\nThe installed release is $0 \
          $\n$\nPress `OK` to reinstall ${DISPLAYED_NAME} or Cancel to quit." \
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

ShowInstDetails show
ShowUnInstDetails show

!define MUI_ABORTWARNING
!define MUI_ICON "..\Installer-Files\Install_QGIS.ico"
!define MUI_UNICON "..\Installer-Files\Uninstall_QGIS.ico"
!define MUI_HEADERIMAGE_BITMAP_NOSTETCH "..\Installer-Files\InstallHeaderImage.bmp"
!define MUI_HEADERIMAGE_UNBITMAP_NOSTRETCH "..\Installer-Files\UnInstallHeaderImage.bmp"
!define MUI_WELCOMEFINISHPAGE_BITMAP "..\Installer-Files\WelcomeFinishPage.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "..\Installer-Files\UnWelcomeFinishPage.bmp"

!define MUI_WELCOMEPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "..\Installer-Files\LICENSE.txt"

!insertmacro MUI_PAGE_DIRECTORY

!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_INSTFILES
!define MUI_FINISHPAGE_TITLE_3LINES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_WELCOME
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "Russian"

Section "QGIS"

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
	
    SetOutPath "$INSTALL_DIR"
	File /r "${SRC_DIR}\*.*"
	
    ;!include /NONFATAL "${QGIS_PLUGINS_CONF}"
    !insertmacro install_plugin_macro
    
	WriteUninstaller "$INSTALL_DIR\${QGIS_UNINSTALL_FILE_NAME}"
	
	WriteRegStr HKLM "Software\${QGIS_BASE}" "Name" "${QGIS_BASE}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "VersionNumber" "${VERSION_NUMBER}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "VersionName" "${VERSION_NAME}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "WebSite" "${WEB_SITE}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "InstallPath" "$INSTALL_DIR"
	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "DisplayName" "${COMPLETE_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "UninstallString" "$INSTALL_DIR\${QGIS_UNINSTALL_FILE_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "DisplayVersion" "${VERSION_NUMBER}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "DisplayIcon" "$INSTALL_DIR\icons\${QGIS_RUN_ICO_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "EstimatedSize" 1
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "HelpLink" "${WIKI_PAGE}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "URLInfoAbout" "${WEB_SITE}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "Publisher" "${PUBLISHER}"
	
    WriteRegStr HKCU "Software\QGIS\QGIS2\Qgis\plugin-repos\Репозиторий NextGIS" "url" "http://nextgis.ru/programs/qgis/qgis-repo.xml"
    WriteRegStr HKCU "Software\QGIS\QGIS2\Qgis\plugin-repos\Репозиторий NextGIS" "enabled" "true"
    
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
        "$INSTALL_DIR\icons\${QGIS_RUN_ICO_NAME}" "" SW_SHOWNORMAL "" "Запустить ${COMPLETE_NAME}"

        Delete "$SMPROGRAMS\${QGIS_BASE}\${QGIS_RUN_LNK_NAME}"
        CreateShortCut "$SMPROGRAMS\${QGIS_BASE}\${QGIS_RUN_LNK_NAME}" "$INSTALL_DIR\bin\nircmd.exe" 'exec hide "$INSTALL_DIR\bin\${SHORTNAME}.bat"' \
        "$INSTALL_DIR\icons\${QGIS_RUN_ICO_NAME}" "" SW_SHOWNORMAL "" "Запустить ${COMPLETE_NAME}"
        
        Delete "$SMPROGRAMS\${QGIS_BASE}\${QGIS_UNINSTALL_LNK_NAME}"
        CreateShortCut "$SMPROGRAMS\${QGIS_BASE}\${QGIS_UNINSTALL_LNK_NAME}" "$INSTALL_DIR\${QGIS_UNINSTALL_FILE_NAME}" "" \
        "$INSTALL_DIR\${QGIS_UNINSTALL_FILE_NAME}" "" SW_SHOWNORMAL "" "Удалить ${COMPLETE_NAME}"
        
        Delete "$SMPROGRAMS\${QGIS_BASE}\Руководство пользователя QGIS.lnk"
        CreateShortCut "$SMPROGRAMS\${QGIS_BASE}\Руководство пользователя QGIS.lnk" "$INSTALL_DIR\manual\${QGIS_MANUAL_FILE_NAME}" "" "" "" "" "" "Открыть руководство пользователя QGIS"
SectionEnd

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
