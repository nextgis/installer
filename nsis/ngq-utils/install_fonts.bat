@echo off

cd /D %OSGEO4W_ROOT%\ngq-utils

set FONTS_FOLDER=%SYSTEMROOT%\fonts

call "install_font.bat" "OpenGost Type A TT Regular (TrueType)" "OpenGostTypeA-Regular.ttf"
call "install_font.bat" "OpenGost Type B TT Regular (TrueType)" "OpenGostTypeB-Regular.ttf"
call "install_font.bat" "GOST 2.304-81 type A (plotter)" "GOST_A.FON"
call "install_font.bat" "GOST 2.304-81 type B (plotter)" "GOST_B.FON"
call "install_font.bat" "GOST 2.304-81 (TrueType)" "Gost_1.TTF"
call "install_font.bat" "GOST 2.304-81 type A (TrueType)" "gost_2_304-81_type.ttf"
call "install_font.bat" "GOST 2.304-81 type B (TrueType)" "gost_2_304-81_type_0.ttf"
call "install_font.bat" "GOST (TrueType)" "GOST_4.TTF"
call "install_font.bat" "GOST Type AU (TrueType)" "GOST_AU.ttf"
call "install_font.bat" "GOST Type BU (TrueType)" "GOST_BU.ttf"
call "install_font.bat" "GOST Common (TrueType)" "GOST_Common.ttf"
call "install_font.bat" "GOST Common Italic (TrueType)" "GOST_Common Italic.ttf"
call "install_font.bat" "GOST 2.304 type A (TrueType)" "GOST2304A.ttf"
call "install_font.bat" "ISOCP (TrueType)" "isocp__.ttf"
call "install_font.bat" "ISOCP2 (TrueType)" "isocp2_.ttf"
call "install_font.bat" "ISOCP3 (TrueType)" "isocp3_.ttf"
call "install_font.bat" "ISOCPEUR Italic (TrueType)" "isocpeui_0.ttf"
call "install_font.bat" "ISOCPEUR (TrueType)" "isocpeur_0.ttf"
call "install_font.bat" "ISOCT (TrueType)" "isoct__.ttf"
call "install_font.bat" "ISOCT2 (TrueType)" "isoct2_.ttf"
call "install_font.bat" "ISOCT3 (TrueType)" "isoct3_.ttf"
call "install_font.bat" "ISOCTEUR Italic (TrueType)" "isocteui_0.ttf"
call "install_font.bat" "ISOCTEUR (TrueType)" "isocteur_0.ttf"
