# -*- coding: utf-8 -*-
import os
import sys
import argparse
import json
import shutil
import tempfile
import subprocess
import re

import pprint

from PyQt4.QtCore import QSettings

def processConfiguratorTemplate(vars, src_filename, dst_filename):
    f = open( src_filename, 'r')
    lines = f.readlines()
    f.close()

    new_lines = []
    for line in lines:
        for var_name in vars.keys():
            var_value = vars[var_name]
            var_value.encode("utf-8")
            line = line.replace("{%s}"%var_name, var_value)
            
        new_lines.append(str(line.encode("utf-8")))
    
    f = open( dst_filename,'w')
    f.writelines(new_lines)
    f.close()

def prepareRunScripts(templates_scripts_dir, prog_name):
    scripts_dir = tempfile.mkdtemp('', 'ngq_run_scripts_')
    vars = {"PROGRAM_NAME": prog_name}
    processConfiguratorTemplate( vars, os.path.join(templates_scripts_dir, "qgis.bat.in"), os.path.join(scripts_dir, "qgis.bat") )
    processConfiguratorTemplate( vars, os.path.join(templates_scripts_dir, "qgis_preruner.bat.in"), os.path.join(scripts_dir, "qgis_preruner.bat") )
    return scripts_dir
    
def prepareQGISSettings(default_settings_dir, plugins):
    settings_dir = tempfile.mktemp('','ngq_settings_')
    
    shutil.copytree(default_settings_dir, settings_dir)
    
    ini_file = os.path.join(settings_dir, "QGIS2.ini")
    #config = ConfigParser.RawConfigParser()
    #config.read(ini_file)
    config = QSettings(ini_file, QSettings.IniFormat)
    
    # activate python plugin in settings
    #if config.has_section('PythonPlugins') == False:
    #    config.add_section('PythonPlugins')
    for plugin in plugins:
        #config.set('PythonPlugins', os.path.basename(plugin), 'true')
        config.setValue("PythonPlugins/%s"%os.path.basename(plugin), True)
        
    #with open(ini_file, 'wb') as configfile:
    #    config.write(configfile)
        
    return settings_dir
    
# consts ====
currnet_dir = os.path.dirname( os.path.abspath(__file__) )
currnet_working_dir = os.getcwd()

nsis_script_dir = os.path.join(currnet_dir, "nsis")
nsis_script_name = "nextgis_qgis.nsi"
default_scripts_dir = os.path.join(currnet_dir, "ngq_run_scripts")

ngq_install_utils_dir = os.path.join(nsis_script_dir, "ngq-utils")
ngq_install_fonts_bat_template = os.path.join(ngq_install_utils_dir, "install_fonts.bat.in")
ngq_install_fonts_bat = os.path.join(ngq_install_utils_dir, "install_fonts.bat")

# ===========
parser = argparse.ArgumentParser(description='Script for make NGQ installer')

parser.add_argument('--customization_zip', dest='configuration_zip', help='customization settings as zip archive')
parser.add_argument('--customization_dir', dest='configuration_dir', help='customization settings as directory')
parser.add_argument('--build_num', dest='build_num', help='build number ')
parser.add_argument('--qgis_output', dest='qgis_output', help='qgis build install dir')
parser.add_argument('--installer_dir_dst', dest='installer_dir_dst', help='where put installer')
args = parser.parse_args()

ngq_customization_dir = None
if args.configuration_dir is not None:
    if not os.path.exists(args.configuration_dir):
        sys.exit("Configuration dir not found")
    ngq_customization_dir = args.configuration_dir
elif args.configuration_zip is not None:
    if not os.path.exists(args.configuration_zip):
        sys.exit("Configuration zip file not found")

    ngq_customization_dir = tempfile.mkdtemp('','ngq_configuration_')

    zipf = zipfile.ZipFile(args.configuration_zip, 'r')
    zipf.extractall(ngq_customization_dir)

if ngq_customization_dir is None:
    sys.exit("Configuration not set!")
    
ngq_customization_conf = {}
config_file= os.path.join(ngq_customization_dir, "settings.txt")
if not os.path.exists(config_file):
    sys.exit("Not found settings.txt in configuration")
try:
    with open(config_file) as data_file:    
        ngq_customization_conf = json.load(data_file)
except Exception as e:
    sys.exit("Parsing settings.txt error: %s"%str(e))

#TODO Validate - configuration
print "\n=== Make installer configuration: ==="
print "ngq_customization_dir: ", ngq_customization_dir

pp = pprint.PrettyPrinter(indent=4)
print "ngq_customization_conf: "
pp.pprint(ngq_customization_conf)

print "==========================="
# make installer ==========
cwd = os.getcwd()
os.chdir(nsis_script_dir)
make_installer_command = ["makensis.exe"]

'''
PROGRAM_NAME

if [ngq_customization_conf] not contain u'prog_name', that
NSIS options: PROGRAM_NAME, QGIS_RUN_SCRIPTS_DIR, NextGIS_QGIS_RUN_LNK_NAME will be set by default
see nsis\nextgis_qgis.nsi
'''
ngq_run_scripts_dir = None
if ngq_customization_conf.has_key(u'prog_name'):
    make_installer_command.append( "/DPROGRAM_NAME=%s"%ngq_customization_conf[u'prog_name'] )
    
    '''QGIS_RUN_SCRIPTS_DIR'''
    ngq_run_scripts_dir = prepareRunScripts(default_scripts_dir, ngq_customization_conf[u'prog_name'])
    make_installer_command.append( "/DQGIS_RUN_SCRIPTS_DIR=%s"%ngq_run_scripts_dir )
    
    '''NextGIS_QGIS_RUN_LNK_NAME'''
    if ngq_customization_conf.has_key(u'ngq_shortcut_name'):
        make_installer_command.append( "/DNextGIS_QGIS_RUN_LNK_NAME=%s"%ngq_customization_conf[u'ngq_shortcut_name'])
    else:
        make_installer_command.append( "/DNextGIS_QGIS_RUN_LNK_NAME=%s"%ngq_customization_conf[u'prog_name'] )

'''INSTALLER_NAME'''
if ngq_customization_conf.has_key(u'installer_name'):
    make_installer_command.append( "/DINSTALLER_NAME=%s"%ngq_customization_conf[u'installer_name'])

'''NextGIS_QGIS_RUN_LNK_ICO_FileName'''
if ngq_customization_conf.has_key(u'ngq_icon'):
    make_installer_command.append( "/DNextGIS_QGIS_RUN_LNK_ICO_FileName=%s"%ngq_customization_conf[u'ngq_icon'] )
    make_installer_command.append( "/DNextGIS_QGIS_RUN_LNK_ICO_Path=%s"%os.path.join(ngq_customization_dir,ngq_customization_conf[u'ngq_icon']) )
    
'''OSGEO4W_SRC_DIR'''
make_installer_command.append( "/DOSGEO4W_SRC_DIR=%s"%os.getenv("OSGEO_ENV_FOR_INSTALLER", "").strip('"') )

'''QGIS_SRC_DIR'''
make_installer_command.append( "/DQGIS_SRC_DIR=%s"%args.qgis_output )

'''GRASS_SRC_DIR'''
make_installer_command.append( "/DGRASS_SRC_DIR=%s"%os.getenv("GRASS_SRC_DIR", "").strip('"') )

'''SAGA_SRC_DIR'''
make_installer_command.append( "/DSAGA_SRC_DIR=%s"%os.getenv("SAGA_SRC_DIR", "").strip('"') )

'''QGIS_MANUAL_FILE_NAME_RU'''
make_installer_command.append( "/DQGIS_MANUAL_FILE_NAME_RU=QGIS-2.6-UserGuide-ru.pdf" )

'''QGIS_MANUAL_FILE_NAME_EN'''
make_installer_command.append( "/DQGIS_MANUAL_FILE_NAME_EN=QGIS-2.6-UserGuide-en.pdf" )

'''PLUGINS'''
plugins = []
if ngq_customization_conf.has_key(u'ngq_plugins'):
    for pl in ngq_customization_conf[u'ngq_plugins']:
        plugins.append( os.path.join(ngq_customization_dir, "plugins", pl[u'name']) )

    plugins_str = " ".join(plugins)
    if len(plugins) > 0:
        make_installer_command.append( "/DPLUGINS=%s"%plugins_str )

'''NGQ_BUILD_NUM'''
if args.build_num is not None:
    make_installer_command.append( "/DNGQ_BUILD_NUM=%s"%str(args.build_num) )
    
'''INSTALLER_OUTPUT_DIR'''
make_installer_command.append( "/DINSTALLER_OUTPUT_DIR=%s"%args.installer_dir_dst )

'''DEFAULT_PROJECT'''
if ngq_customization_conf.has_key(u'def_project'):
    make_installer_command.append( "/DDEFAULT_PROJECT=%s"%ngq_customization_conf[u'def_project'] )

'''QGIS_DEFAULT_OPTIONS'''
#qgis_options_dir = default_qgis_options_dir
#print "plugins: ", plugins
qgis_options_dirs_tmp = []
if ngq_customization_conf.has_key(u'default_qgis_options_dirs'):
    qgis_options_dirs = ngq_customization_conf[u'default_qgis_options_dirs']
    counter = 0
    for dir in qgis_options_dirs.items():
        qgis_options_name = dir[0]
        qgis_options_dir = os.path.join(ngq_customization_dir, dir[1])
        #print "qgis_options_dir: ",qgis_options_dir
        qgis_options_dir = prepareQGISSettings(qgis_options_dir, plugins)
        counter +=1
        make_installer_command.append( "/DQGIS_DEFAULT_OPTIONS_%d_NAME=%s"%(counter, qgis_options_name) )
        make_installer_command.append( "/DQGIS_DEFAULT_OPTIONS_%d_PATH=%s"%(counter, qgis_options_dir) )
        
        qgis_options_dirs_tmp.append(qgis_options_dir)
    #print "qgis_options_dirs_tmp: ", qgis_options_dirs_tmp
    make_installer_command.append( "/DQGIS_DEFAULT_OPTIONS_COUNT=%d"%counter )

'''FONTS_DIR'''
if os.path.exists(ngq_install_fonts_bat):
    os.remove(ngq_install_fonts_bat)
    
if ngq_customization_conf.has_key(u'fonts'):
    make_installer_command.append( "/DFONTS_DIR=%s"%os.path.join(ngq_customization_dir, "fonts") )
    f = open(ngq_install_fonts_bat_template, "r")
    content = f.readlines()
    f.close()
    for font in ngq_customization_conf[u'fonts']:
        content.append('call "install_font.bat" "%s" "%s"\n'%(font[u'name'], font[u'file']))
    f = open(ngq_install_fonts_bat, "w")
    f.writelines(content)
    f.close()

'''EXAMPLES_DIR'''
if ngq_customization_conf.has_key(u'examples'):
    make_installer_command.append( "/DEXAMPLES_DIR=%s"%os.path.join(ngq_customization_dir, ngq_customization_conf[u'examples']) )

'''NGQ_STYLES_DIR'''
if ngq_customization_conf.has_key(u'symbology_styles'):
    make_installer_command.append( "/DNGQ_STYLES_DIR=%s"%os.path.join(ngq_customization_dir, ngq_customization_conf[u'symbology_styles']) )
    
'''NGQ_PRINT_TEMPLATES_DIR'''
if ngq_customization_conf.has_key(u'print_templates'):
    make_installer_command.append( "/DNGQ_PRINT_TEMPLATES_DIR=%s"%os.path.join(ngq_customization_dir, ngq_customization_conf[u'print_templates']) )
    
make_installer_command.append(nsis_script_name)
try:
    #print "make_installer_command: ", make_installer_command
    for i in range(0, len(make_installer_command)):
        make_installer_command[i] = make_installer_command[i].encode('cp1251')
    res = subprocess.check_output(make_installer_command)
    #res = subprocess.check_call(make_installer_command)
    print res
    
    output_desc_line = re.search('Output: ".+"', res).group()
    print " output_desc_line: ",output_desc_line
    installer_name = re.search('".+"', output_desc_line).group()
    installer_name = installer_name.strip('"')
    print " installer_name: ",installer_name
    
    with open(os.path.join(args.installer_dir_dst, ".meta-ngq"), 'w') as f:
        f.write(os.path.basename(installer_name))
    
except subprocess.CalledProcessError as ex:
    sys.exit("ERROR! Make installer error: %s\n"%str(ex))
except:
    sys.exit("ERROR! Make installer error: Unexpected error: %s\n"%sys.exc_info()[0])
        
os.chdir(cwd)

# clear ==========
for qgis_options_dir in qgis_options_dirs_tmp:
    shutil.rmtree(qgis_options_dir)
    
if ngq_run_scripts_dir is not None:
    shutil.rmtree(ngq_run_scripts_dir)
    
if args.configuration_zip is not None:    
    shutil.rmtree(ngq_customization_dir)