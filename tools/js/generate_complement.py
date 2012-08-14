#!/usr/bin/python
# ----------------------------------------------------------------------------
# Simple regular expression that obtains super class, protocols
# and properties from Obj-C header files
# ----------------------------------------------------------------------------
'''
Obtains
'''

__docformat__ = 'restructuredtext'


# python
import sys
import os
import re
import getopt
import glob
import ast


class ObjC(object):
    def __init__(self, filenames, exception_file, output_file, verbose ):
        self.filenames = filenames
        self.entries = {}
        self.output = output_file
        self.exception = exception_file
        self.verbose = verbose

    def log( self, what ):
        if self.verbose:
            print what
    def parse_exception_file( self ):
        if self.exception:
            f = open( self.exception )
            self.entries = ast.literal_eval( f.read() )
            f.close()

    def parse( self ):

        self.parse_exception_file()

        for filename in self.filenames:
            f = open( filename, 'r' )
            l = f.readlines()

            # regexp based on Objective Pascal parser ( http://www.objectivepascal.com/ )
            regex_objc_class = r"^\s*@interface\s+([\S]+)\s*:\s*([\w]+)\s*(<.*>)*"
            regex_objc_class_extension = r"^\s*@interface\s+([\S]+)\s*\(\s*([\w]+)\s*\)\s*"
            regex_objc_property_attributes = r"^@property\s*\(([^)]*)\)\s*([a-zA-Z_0-9]+)\s*(<.*>)?(\bint\b|\blong\b|\bchar\b)?(\*)*\s*(.*)\s*;"
            regex_obj_end = r"^\s*@end\s*$"

            current_class = None
            for line in l:
                interface = re.match( regex_objc_class, line )
                interface_ext = re.match( regex_objc_class_extension, line )
                property_attribs = re.match( regex_objc_property_attributes, line )
                end = re.match( regex_obj_end, line )

                if interface:
                    classname = interface.group(1)
                    subclass = interface.group(2)
                    protocols = interface.group(3)

                    if classname in self.entries:
                        self.log( 'Key already on dictionary %s\n' % classname )
                    else:
                        if protocols:
                            # strip '<>'
                            protocols = protocols.strip('<> ')

                            # remove spaces
                            protocols = protocols.replace(' ', '')

                            # split by ','
                            protocols = protocols.split(',')
                        else:
                            protocols = []

                        self.entries[ classname ] = { 'subclass' : subclass, 'protocols' : protocols }

                    current_class = classname
                    self.log( '--> %s' % current_class )
                elif interface_ext:
                    classname = interface_ext.group(1)
                    current_class = classname
                    self.log( '--> %s' % current_class )
                elif property_attribs:
                    if not current_class:
                        raise Exception("Fatal: Unparented attrib: %s (%s)" % (str(property_attribs.groups()), filename ) )
                    if not 'properties' in self.entries[ current_class ]:
                        self.entries[ current_class ]['properties'] = {}
                    l = []
                    # 1: attributes
                    # 2: type
                    # 3: type protocol (optional)
                    # 4: type 2nd word like int, long, char (optinal)
                    # 5: type pointer '*' (optional)
                    # 6: property name
                    l.append( property_attribs.group(1) )

                    if property_attribs.group(4):
                        l.append( "%s %s%s%s" % ( property_attribs.group(2), property_attribs.group(3), property_attribs.group(4), property_attribs.group(5) ) )
                    else:
                        l.append( "%s%s%s%s" % ( property_attribs.group(2), property_attribs.group(3), property_attribs.group(4), property_attribs.group(5) ) )

                    if ' ' in property_attribs.group(6) or property_attribs.group(6) == None:
                        sys.stderr.write('Error. Could not add property. File:%s line:%s\n' % (filename, line ) )
                        print property_attribs.groups()
                    else:
                        self.entries[ current_class ]['properties'][ property_attribs.group(6) ] = l

                elif end:
                    self.log( '<-- %s (%s)' % (current_class, filename ) )
                    current_class = None
                else:
                    # ignore
                    pass
            f.close()

        self.write_output()

    def write_output( self ):
        if not self.output:
            fd = sys.stdout
        else:
            fd = open( self.output, 'w' )

        fd.write( str(self.entries) )

def help():
    print "%s v1.0 - An utility to obtain superclass and protocols from an Objective-C interface" % sys.argv[0]
    print "Usage:"
    print "\t-o --output\tFile that will have the output. Default: stdout"
    print "\t-e --exception\tFile that contains the exception rules for the parser. Exception rules have precedence over the parsed data"
    print "\t\t\tUseful if the parser generates invalid or wrong info for certain classes."
    print "\t-v --verbose\tVerbose output. Useful to find possible errors."
    print "\nExample:"
    print "\t%s -o cocos2d-mac-class_hierarchy-protocols.txt -e cocos2d-mac-class_hierarchy-protocols-exceptions.txt *.h Support/*.h Platforms/*.h Platforms/Mac/*.h " % sys.argv[0]
    sys.exit(-1)

if __name__ == "__main__":
    if len( sys.argv ) == 1:
        help()

    input_file = None
    output_file = None
    verbose = False

    argv = sys.argv[1:]
    try:
        opts, args = getopt.getopt(argv, "e:o:v", ["exception=","output=", "verbose"])

        for opt, arg in opts:
            if opt in ("-e","--exception"):
                input_file = arg
            if opt in  ("-o", "--output"):
                output_file = arg
            if opt in  ("-v", "--verbose"):
                verbose = True

    except getopt.GetoptError,e:
        print e
        opts, args = getopt.getopt(argv, "", [])

    if args == None:
        help()

    instance = ObjC( args, input_file, output_file, verbose )
    instance.parse()
    print 'Ok'
