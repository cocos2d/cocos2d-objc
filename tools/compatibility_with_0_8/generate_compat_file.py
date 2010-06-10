

import sys
import os

copyright = """
/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2008-2010 Ricardo Quesada
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 */

// AUTOMATICALLY GENERATED. DO NOT EDIT
"""

pre_header = """

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#if CC_COMPATIBILITY_WITH_0_8

"""

post_header = """
#endif // CC_COMPATIBILITY_WITH_0_8
"""

pre_m = """
#include "CCCompatibility.h"
#if CC_COMPATIBILITY_WITH_0_8
"""

post_m = """
#endif // CC_COMPATIBILITY_WITH_0_8
"""


def purge_dict( d ):

    # Sprite updates
    d['AtlasSprite'] = 'CCSprite'
    d['AtlasSpriteManager'] = 'CCSpriteSheet'
    d['AtlasAnimation'] = 'CCAnimation'
    d['AtlasSpriteFrame'] = 'CCSpriteFrame'
    d['CocosNode'] = 'CCNode'
    d['TextureMgr'] = 'CCTextureCache'
    d['TextureNode'] = 'CCSprite'

    # deleted classes
    classes_to_delete = ['MenuItemAtlasSprite', 'FileUtils', 'EAGLView' ]
    for i in classes_to_delete:
        del( d[i] )

def write_to_file():
    import classes_0_8

    class_dict = classes_0_8.classes

    purge_dict( class_dict)

    file_h = open('CCCompatibility.h','w+')
    file_m = open('CCCompatibility.m','w+')

    keys = []

    # sort keys
    for k in class_dict:
        keys.append( k )
    keys = sorted( keys )
    
    # header file
    file_h.write( copyright )
    file_h.write( pre_header )

    for k in keys:
        old = k
        new = class_dict[k]
        if new == '':
            new = 'CC' + old

        file_h.write('DEPRECATED_ATTRIBUTE ')
        file_h.write('@interface %s : %s {} @end\n' % (old, new) )
    file_h.write( post_header )
    file_h.close()

    # implementation file
    file_m.write( copyright )
    file_m.write( pre_m )
    for k in keys:
        old = k

        file_m.write('@implementation %s\n@end\n\n' % old )
    file_m.write( post_m )
    file_m.close()

def class_parser():
    import re
    f = open('cocos2d_8_classes.txt')
    out = open('classes_0_8.py','w+')
    lines = f.readlines()

    s = set()
    for l in lines:
        a = re.findall('@interface\s+(\w+)',l)
        if len(a) > 0:
            s.add( a[0] )

    s = sorted(s)
    out.write( "classes = {" )
    for i in s:
        out.write( '\t"%s" : "",' % i )
    out.write( "}" )

if __name__ == '__main__':
    # to generate the data needed for the next step)
#    class_parser()

    # to generate to CCCompatibility files
    write_to_file()

