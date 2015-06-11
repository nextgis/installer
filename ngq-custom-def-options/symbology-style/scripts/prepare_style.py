# -*- coding: utf-8 -*-
import os
import sys
import argparse

import xml.etree.ElementTree as ET

parser = argparse.ArgumentParser(description='Prepare style for qgis script')

parser.add_argument('-p', '--package-name', dest='package_name', help='Package (group) name for identification style')
parser.add_argument('-x', '--xml', dest='xml_filename', help='Import xml filename')
parser.add_argument('-q', '--qml', dest='qml_filename', help='Import qml filename')
parser.add_argument('-o', '--output', dest='output_filename', help='When use -q or -x script create xml file with name -o')

if len(sys.argv) <= 2:
    parser.print_usage()
    sys.exit(1)

args = parser.parse_args()

if args.package_name is None:
    parser.print_usage()
    sys.exit(1)

if args.xml_filename:
    tree = ET.parse(args.xml_filename)
    root = tree.getroot()
    
    for layer_tag in root.iter('layer'):
        if layer_tag.attrib["class"] in ["SvgMarker", "SVGFill"]:
            for prop_tag in layer_tag.iter('prop'):
                if prop_tag.attrib["k"] in ["name", "svgFile"]:
                   prop_tag.attrib["v"] = "/" + args.package_name + prop_tag.attrib["v"]                   
                   
    tree.write(args.output_filename, encoding="utf-8")

if args.qml_filename:
    pure_filename = os.path.splitext(os.path.basename(args.qml_filename))[0]
    tree_qml = ET.parse(args.qml_filename)
    root_qml = tree_qml.getroot()
    
    for symbols_element in root_qml.iter('symbols'):
        for symbol_element in symbols_element.iter('symbol'):
            symbol_element.attrib["name"] = pure_filename + "_" + symbol_element.attrib["name"]
            for layer_tag in symbol_element.iter('layer'):
                if layer_tag.attrib["class"] == "SvgMarker":
                    for prop_tag in layer_tag.iter('prop'):
                        if prop_tag.attrib["k"] == "name":
                            prop_tag.attrib["v"] = "/" + args.package_name + prop_tag.attrib["v"]
    
        root_element = ET.Element("qgis_style", attrib={"version":"0"})
        root_element.append(symbols_element)
        tree = ET.ElementTree(element=root_element)
        tree.write(args.output_filename, encoding="utf-8")