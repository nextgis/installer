textreplace -std -t bin\pyuic4.bat
set OSGEO4W_ROOT=%OSGEO4W_ROOT:\=\\%
textreplace -std -t apps\Python27\Lib\site-packages\PyQt4\pyqtconfig.py
