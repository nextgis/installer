@echo off
rem %1 working dir
rem %2 build number
cd /d %1

call ms-windows\ngq\env-example.bat
python ms-windows\ngq\scripts\ngqbuild.py --customization_dir E:\ngq_configuration_default -b --build_num %2 -i