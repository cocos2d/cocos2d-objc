#!/usr/bin/python
# ----------------------------------------------------------------------------
# Xcode 4 template generator for cocos2d project
# (c) 2011 Ricardo Quesada
#
# LICENSE: Dual License: MIT & GNU GPL v2 Whatever suits you best.
#
# Given a directory, it generates the "Definitions" and "Nodes" elements
#
# Format taken from: http://blog.boreal-kiss.net/2011/03/11/a-minimal-project-template-for-xcode-4/
# ----------------------------------------------------------------------------
'''
Xcode 4 template generator
'''

__docformat__ = 'restructuredtext'

_template_open_body = """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Description</key>
	<string>This template provides an starting point for cocos2d for iOS.</string>
	<key>Identifier</key>
	<string>com.cocos2d.cocos2dlib</string>
	<key>Kind</key>
	<string>Xcode.Xcode3.ProjectTemplateUnitKind</string>
"""

_template_close_body = "</dict>\n</plist>"

# python
import sys
import os
import getopt
import glob

class Xcode4Template(object):
    def __init__( self, directory, group='cocos2d' ):
        self.directory = directory
        self.files_to_include = []
        self.wildcard = '*'
        self.group = group
        self.output = []

    def scandirs(self, path):
        for currentFile in glob.glob( os.path.join(path, self.wildcard) ):
            if os.path.isdir(currentFile):
                self.scandirs(currentFile)
            else:
                self.files_to_include.append( currentFile )

    def generate_definitions( self ):
        output_header = "<key>Definitions</key>"
        output_dict_open = "<dict>"
        output_dict_close = "</dict>"

        output_body = []
        for file in self.files_to_include:
#            filename = os.path.basename(file)
            filename = file
            output_body.append("  <key>%s</key>" % filename )
            output_body.append("""  <dict>
    <key>Group</key>
    <string>%s</string>
    <key>Path</key>
    <string>%s</string>
  </dict>""" % (self.group, file) )


        self.output.append( output_header )
        self.output.append( output_dict_open )
        self.output.append( "\n".join( output_body ) )
        self.output.append( output_dict_close )

    def generate_nodes( self ):
        output_header = "<key>Nodes</key>"
        output_open = "<array>"
        output_close = "</array>"

        output_body = []
        for file in self.files_to_include:
#            filename = os.path.basename(file)
            filename = file
            output_body.append("  <string>%s</string>" % filename )

        self.output.append( output_header )
        self.output.append( output_open )
        self.output.append( "\n".join( output_body ) )
        self.output.append( output_close )
       
    def generate_xml( self ):
        self.output.append( _template_open_body )
        self.generate_definitions()
        self.generate_nodes()
        self.output.append( _template_close_body )

        print "\n".join( self.output )

    def generate( self ):
        self.scandirs( self.directory )
        self.generate_xml()

def help():
    print "%s v1.0 - An utility to generate Xcode 4 templates" % sys.argv[0]
    print "Usage:"
    print "\t-d directory (directory to parse)"
    print "\t-g group (group name for Xcode template)"
    print "\nExample:"
    print "\t%s -d cocos2d -g cocos2d" % sys.argv[0]
    sys.exit(-1)

if __name__ == "__main__":
    if len( sys.argv ) == 1:
        help()

    directory = None
    group = 'cocos2d'
    argv = sys.argv[1:]
    try:                                
        opts, args = getopt.getopt(argv, "d:g:", ["directory=","group="])
        for opt, arg in opts:
            if opt in ("-d","--directory"):
                directory = arg
            if opt in ("-g","--group"):
                group = arg
    except getopt.GetoptError,e:
        print e

    if directory == None:
        help()

    gen = Xcode4Template( directory=directory, group=group )
    gen.generate()
