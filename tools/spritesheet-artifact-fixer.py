#!/usr/bin/python
# ----------------------------------------------------------------------------
# SpriteSheet border adder
# (c) 2009 Ricardo Quesada
# ----------------------------------------------------------------------------
'''
SpriteSheet Margin added
'''

__docformat__ = 'restructuredtext'


# python
import sys
import os
import getopt
try:
    import Image
except Exception, e:
    print "\n"
    print "Image module not found. Downlaod it from: http://www.pythonware.com/products/pil/"
    print "\n"
    raise



class SpriteSheetMarginFix(object):
    def __init__(self, filename, tilewidth, tileheight, spacing=2, margin=0):
        self.margin = margin
        self.filename = filename
        self.spacing = spacing
        self.tilewidth = tilewidth
        self.tileheight= tileheight

        self.im = Image.open( self.filename )

        self.rects = []

    def populate_rects( self ):
        # region is a rect
        size = self.im.size
        max_x = (size[0] - self.margin * 2 + self.spacing) / ( self.tilewidth + self.spacing )
        max_y = (size[1] - self.margin * 2 + self.spacing) / ( self.tileheight + self.spacing )

        for y in range(max_y):
            for x in range(max_x):
                rect = [ x * (self.tilewidth + self.spacing) + self.margin,     # origin x
                         y * (self.tileheight + self.spacing) + self.margin,    # origin y
                        self.tilewidth,                                         # size x
                        self.tileheight]                                        # size y

                self.rects.append( rect )
        print 'Generated %d rects (%d x %d)' % (len(self.rects), max_x, max_y)

    def fix_image(self ):

        size = self.im.size
        self.populate_rects()
        for rect in self.rects:
            # left / bottom borders don't need painting
            # but they will be painted anyway
            for x in range( rect[0], rect[0] + rect[2] ):

                y = rect[1]
                if x >= 0 and x < size[0] and y > 0 and y < size[1]:
                    pixel = self.im.getpixel( (x,y) )
                    self.im.putpixel( (x,y-1), pixel )

                y = rect[1] + rect[3] - 1
                if x >= 0 and x < size[0] and y >= 0 and y < (size[1]-1):
                    pixel = self.im.getpixel( (x,y) )
                    self.im.putpixel( (x,y+1), pixel )

            for y in range( rect[1], rect[1] + rect[3] ):

                x = rect[0]
                if x > 0 and x < size[0] and y >= 0 and y < size[1]:
                    pixel = self.im.getpixel( (x,y) )
                    self.im.putpixel( (x-1,y), pixel )

                x = rect[0] + rect[2] - 1
                if x >= 0 and x < (size[0]-1) and y >= 0 and y < size[1]:
                    pixel = self.im.getpixel( (x,y) )
                    self.im.putpixel( (x+1,y), pixel )

        new_name = "fixed-%s" % self.filename
        print "saving new image: %s" % new_name
        self.im.save("%s" % new_name, "PNG")

def help():
    print "%s v1.0 - An utility to create borders in spritesheets" % sys.argv[0]
    print "Usage:"
    print "\t-f image_file_name"
    print "\t-x tile_width"
    print "\t-y tile_height"
    print "\t-m margin (default 0)"
    print "\t-s spacing (default 2)"
    print "\nExample:"
    print "\t%s -f spritesheet.png -x 32 -y 32 -m 0 -s 2" % sys.argv[0]
    sys.exit(-1)

if __name__ == "__main__":
    if len( sys.argv ) == 1:
        help()

    filename = None
    tilewidth = 0
    tileheight = 0
    margin = 0
    spacing = 2

    argv = sys.argv[1:]
    try:                                
        opts, args = getopt.getopt(argv, "f:x:y:m:s:", ["filename=","tilewidth=","tileheight=","margin=","spacing="])
        for opt, arg in opts:
            if opt in ("-f","--filename"):
                filename = arg
            elif opt in ("-x","--tilewidth"):
                tilewidth = int(arg)
            elif opt in ("-y","--tileheight"):
                tileheight = int(arg)
            elif opt in ("-m","--margin"):
                margin = int(arg)
            elif opt in ("-s","--spacing"):
                spacing = int(arg)
    except getopt.GetoptError,e:
        print e

    if filename == None or tilewidth == 0 or tileheight == 0:
        help()

    fix = SpriteSheetMarginFix( filename=filename, margin=margin, spacing=spacing, tilewidth=tilewidth, tileheight=tileheight)
    fix.fix_image()
