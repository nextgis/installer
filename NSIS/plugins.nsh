!define PLUGIN_DIR "D:\builds\plugins"

WriteRegStr HKEY_CURRENT_USER "Software\QGIS\QGIS2\PythonPlugins" "reporter" "true"
WriteRegStr HKEY_CURRENT_USER "Software\QGIS\QGIS2\PythonPlugins" "identifyplus" "true"
WriteRegStr HKEY_CURRENT_USER "Software\QGIS\QGIS2\PythonPlugins" "simplereports" "true"

SetOutPath "$INSTALL_DIR\apps\${SHORTNAME}\python\plugins\"
File /r "${PLUGIN_DIR}\reporter"
File /r "${PLUGIN_DIR}\identifyplus"
File /r "${PLUGIN_DIR}\simplereports"