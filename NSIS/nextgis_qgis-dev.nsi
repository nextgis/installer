SetCompressor /SOLID lzma
RequestExecutionLevel admin

!include "MUI.nsh"
!include "LogicLib.nsh"
!include "utils.nsh"

!define QGIS_BASE "NextGIS QGIS dev"
!define DISPLAYED_NAME "NextGIS QGIS dev"
!define VERSION_NUMBER "2.1.0"
!define VERSION_NAME ""
!define COMPLETE_NAME "${QGIS_BASE} ${VERSION_NUMBER} ${VERSION_NAME}"
!define CHECK_INSTALL_NAME "${QGIS_BASE}"
!define INSTALLER_DISPLAYED_NAME "${DISPLAYED_NAME}"
!define PUBLISHER "NextGIS"
!define WEB_SITE "http://www.nextgis.ru"
!define WIKI_PAGE ""

!define SHORTNAME "qgis-dev"

!define SRC_DIR "D:\builds\qgis-trunk-with-env"

!addplugindir ../osgeo4w/untgz
!addplugindir ../osgeo4w/nsis

Name "NextGIS QGIS dev"
OutFile "NextGIS-QGIS-dev-${VERSION_NUMBER}.exe"
InstallDir "C:\NextGIS_QGIS_DEV"

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
                ;MessageBox MB_OK $uninstaller_path
                ExecWait '$uninstaller_path _?=$installer_path' $0
                ;ExecWait '$uninstaller_path' $0
                
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

Section "Quantum GIS"

	SectionIn RO
	Var /GLOBAL INSTALL_DIR
	StrCpy $INSTALL_DIR "$INSTDIR"
	
	SetOverwrite try
	SetShellVarContext current
	Var /GLOBAL GIS_DATABASE
	StrCpy $GIS_DATABASE "$DOCUMENTS\GIS DataBase"
	CreateDirectory "$GIS_DATABASE"

	SetOutPath "$INSTALL_DIR\icons"
	File ..\Installer-Files\QGIS_dev.ico
    
	SetOutPath "$INSTALL_DIR"
	File ..\Installer-Files\for_devel\postinstall.bat
	File ..\Installer-Files\for_devel\preremove.bat
	
	SetOutPath "$INSTALL_DIR"
	File /r "${SRC_DIR}\*.*"
	
    !include "plugins.nsh"
    
	WriteUninstaller "$INSTALL_DIR\Uninstall-QGIS.exe"
	
	WriteRegStr HKLM "Software\${QGIS_BASE}" "Name" "${QGIS_BASE}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "VersionNumber" "${VERSION_NUMBER}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "VersionName" "${VERSION_NAME}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "Publisher" "${PUBLISHER}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "WebSite" "${WEB_SITE}"
	WriteRegStr HKLM "Software\${QGIS_BASE}" "InstallPath" "$INSTALL_DIR"
	
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "DisplayName" "${COMPLETE_NAME}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "UninstallString" "$INSTALL_DIR\Uninstall-QGIS.exe"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "DisplayVersion" "${VERSION_NUMBER}"
	WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}" "DisplayIcon" "$INSTALL_DIR\icons\QGIS.ico"
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
        Delete "$DESKTOP\NextGIS QGIS dev (${VERSION_NUMBER}).lnk"
        CreateShortCut "$DESKTOP\NextGIS QGIS dev (${VERSION_NUMBER}).lnk" "$INSTALL_DIR\bin\nircmd.exe" 'exec hide "$INSTALL_DIR\bin\${SHORTNAME}.bat"' \
        "$INSTALL_DIR\icons\QGIS_dev.ico" "" SW_SHOWNORMAL "" "Launch ${COMPLETE_NAME}"

        Delete "$SMPROGRAMS\${QGIS_BASE}\NextGIS QGIS dev (${VERSION_NUMBER}).lnk"
        CreateShortCut "$SMPROGRAMS\${QGIS_BASE}\NextGIS QGIS dev (${VERSION_NUMBER}).lnk" "$INSTALL_DIR\bin\nircmd.exe" 'exec hide "$INSTALL_DIR\bin\${SHORTNAME}.bat"' \
        "$INSTALL_DIR\icons\QGIS_dev.ico" "" SW_SHOWNORMAL "" "Launch ${COMPLETE_NAME}"
        
        Delete "$SMPROGRAMS\${QGIS_BASE}\Удалить NextGIS QGIS dev (${VERSION_NUMBER}).lnk"
        CreateShortCut "$SMPROGRAMS\${QGIS_BASE}\Удалить NextGIS QGIS dev (${VERSION_NUMBER}).lnk" "$INSTALL_DIR\Uninstall-QGIS.exe" "" \
        "$INSTALL_DIR\Uninstall-QGIS.exe" "" SW_SHOWNORMAL "" "Удалить NextGIS QGIS dev (${VERSION_NUMBER})"
        
        Delete "$SMPROGRAMS\${QGIS_BASE}\Руководство пользователя QGIS.lnk"
        CreateShortCut "$SMPROGRAMS\${QGIS_BASE}\Руководство пользователя QGIS.lnk" "$INSTALL_DIR\manual\qgis-1.8.0_user_guide_ru.pdf" "" "" "" "" "" "Открыть руководство пользователя QGIS"
SectionEnd

Section "Uninstall"
	GetFullPathName /SHORT $0 $INSTDIR
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_ROOT", "$0").r0'
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("OSGEO4W_STARTMENU", "$SMPROGRAMS\${QGIS_BASE}").r0'

	ReadEnvStr $0 COMSPEC
	nsExec::ExecToLog '"$0" /c "$INSTALL_DIR\preremove.bat"'

	RMDir /r "$INSTDIR"

	SetShellVarContext all
	Delete "$DESKTOP\NextGIS QGIS dev (${VERSION_NUMBER}).lnk"
    
	SetShellVarContext all
	RMDir /r "$SMPROGRAMS\${QGIS_BASE}"

	DeleteRegKey HKLM "Software\${QGIS_BASE}"
	DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\${QGIS_BASE}"
SectionEnd
