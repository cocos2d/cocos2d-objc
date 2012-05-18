#!/usr/bin/python
# ----------------------------------------------------------------------------
# Simple regular expression that obtains super class and protocols from Obj-C
# interfaces
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
    def __init__(self, filenames, exception_file, output_file ):
        self.filenames = filenames
        self.entries = {}
        self.output = output_file
        self.exception = exception_file

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

            regex_objc_class = "^@interface\s+([\S]+)\s+:\s+([\S]+)\s+(<.*>)*"
            for line in l:
                a = re.search( regex_objc_class, line )
                if a:
                    classname = a.group(1)
                    subclass = a.group(2)
                    protocols = a.group(3)

                    if classname in self.entries:
                        print 'Key already on dictionary %s\n' % classname
                    else:
                        if protocols:
                            # strip '<>'
                            protocols = protocols.strip('<> ')

                            # remove spaces
                            protocols = protocols.replace(' ', '')

                            # split by ','
                            list_of_protocols = protocols.split(',')
                        else:
                            protocols = []

                        self.entries[ classname ] = { 'subclass' : subclass, 'protocols' : protocols }
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
    print "\t-e --exceptions\tFile that contains rules for the parser."
    print "\t\t\tUseful if the parser generates invalid or wrong info for certain classes."
    print "\nExample:"
    print "\t%s -o output.txt -e particle_override_rules.txt cocos2d/*.h" % sys.argv[0]
    sys.exit(-1)

if __name__ == "__main__":
    if len( sys.argv ) == 1:
        help()

    exception_file = None
    output_file = None

    argv = sys.argv[1:]
    try:                                
        opts, args = getopt.getopt(argv, "e:o:", ["exceptions=","output="])

        for opt, arg in opts:
            if opt in ("-e","--exceptions"):
                exception_file = arg
            if opt in  ("-o", "--output"):
                output_file = arg
    except getopt.GetoptError,e:
        print e
        opts, args = getopt.getopt(argv, "", [])

    if args == None:
        help()

    instance = ObjC( args, exception_file, output_file )
    instance.parse()

