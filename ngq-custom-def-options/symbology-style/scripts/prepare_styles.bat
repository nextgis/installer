@echo off
cd /D %~dp0\..\

echo Process styles_xml\gis-lab\all.xml
python scripts\prepare_style.py -p gis-lab -x styles_xml\gis-lab\all.xml -o styles_xml\gis-lab\gis-lab.xml

echo Process anitagraser:
for %%f in (styles_qml\anitagraser\*.qml) do (
	echo 	%%~nf
	python scripts\prepare_style.py -p anitagraser -q %%f -o "styles_xml\anitagraser\%%~nf.xml"
)
