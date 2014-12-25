@echo off

rem set PYTHONPATH=
set OSGEO4W_ROOT=d:\builds\osgeo4w
call "%OSGEO4W_ROOT%\bin\o4w_env.bat"

rem path %SYSTEMROOT%\system32;%SYSTEMROOT%;%SYSTEMROOT%\System32\Wbem;

set VS90COMNTOOLS=%PROGRAMFILES%\Microsoft Visual Studio 9.0\Common7\Tools\
call "%PROGRAMFILES%\Microsoft Visual Studio 9.0\VC\vcvarsall.bat" x86

set GRASS_PREFIX=%OSGEO4W_ROOT%\apps\grass\grass-6.4.4

set INCLUDE=%INCLUDE%;%PROGRAMFILES%\Microsoft Platform SDK for Windows Server 2003 R2\Include
set LIB=%LIB%;%PROGRAMFILES%\Microsoft Platform SDK for Windows Server 2003 R2\Lib

set INCLUDE=%INCLUDE%;%OSGEO4W_ROOT%\include
set LIB=%LIB%;%OSGEO4W_ROOT%\lib

path %PATH%;%PROGRAMFILES%\CMake 2.8\bin;
path %PATH%;%PROGRAMFILES%\Git\bin;
path %PATH%;%PROGRAMFILES%\NSIS\bin;
path %PATH%;%PROGRAMFILES%\Microsoft Visual Studio 9.0\Common7\IDE

@cmd

