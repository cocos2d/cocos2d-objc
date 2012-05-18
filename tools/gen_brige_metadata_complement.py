#!/usr/bin/python # ----------------------------------------------------------------------------
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


class ObjC(object):
    def __init__(self, filenames ):
        self.filenames = filenames
        self.entries = {}

    def parse( self ):
        for filename in self.filenames:
            f = open( filename, 'r' )
            l = f.readlines()

            regex_objc_class = "^@interface\s+([\S]+)\s+:\s+([\S]+)\s+(<.*>)*"
    #        regex_objc_class = "^@interface ([a-zA-Z]+)[[:space:]]*:[[:space:]]*([a-zA-Z0-9_]+)[[:space:]]*(<(.*)>)*"
    #       regex_objc_class_no_super = "^@interface ([a-zA-Z]+)[[:space:]]*<(.*)>[[:space:]]*"
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
                            regexp =  '<\s*(\S+)\s*((?:[,\s*])\S+)*>'
                            protocol =  re.search(regexp, protocols )
                            print protocol.groups()
                        self.entries[ classname ] = { 'subclass' : subclass, 'protocols' : protocols }
            f.close()

#        print self.entries

def help():
    print "%s v1.0 - An utility to obtain superclass and protocols from an Objective-C interface" % sys.argv[0]
    print "Usage:"
    print "\tfiles_to_parse"
    print "\nExample:"
    print "\t%s cocos2d/*.h" % sys.argv[0]
    sys.exit(-1)

if __name__ == "__main__":
    if len( sys.argv ) == 1:
        help()

    argv = sys.argv[1:]
    try:                                
        opts, args = getopt.getopt(argv, "", [])

        if len(args) == 0:
            help()
    except getopt.GetoptError,e:
        print e

    if args == None:
        help()


    instance = ObjC( args )
    instance.parse()

#	var $regex_objc_class = "^@interface ([a-zA-Z]+)[[:space:]]*:[[:space:]]*([a-zA-Z0-9_]+)[[:space:]]*(<(.*)>)*";
#	var $regex_objc_class_no_super = "^@interface ([a-zA-Z]+)[[:space:]]*<(.*)>[[:space:]]*";
