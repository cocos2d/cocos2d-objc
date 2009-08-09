#!/usr/bin/python
# ----------------------------------------------------------------------------
# TMX / TSX: embeded images to individual png files
#
# Parses a TMX or TSX file. If it has embeded images, it generates indiviaul .PNG files
# After running this script is suggested that you run the mkatlas.pl script to
#  generate the atlas.
#
# ----------------------------------------------------------------------------
'''
TMX: embeded images to indivial png files
'''

__docformat__ = 'restructuredtext'


# python
import sys
import os
import getopt
import xml.dom.minidom
import base64
import gzip
from cStringIO import StringIO


def decompress_data(data):
    """Decompresses a string of gzipped layer data."""
    data_buffer = StringIO(data)
    gzip_file = gzip.GzipFile('', 'rb', 9, data_buffer)
    data = gzip_file.read()
    gzip_file.close()
    data_buffer.close()
    return data

def get_text_contents(node, preserve_whitespace=False):
    """Returns the text contents for a particular node. By default discards
    leading and trailing whitespace."""
    result = ''.join([node.data for node in node.childNodes if node.nodeType == node.TEXT_NODE])
    
    if not preserve_whitespace:
        result = result.strip()
    
    return result

def load_map(filename):
    print "parsing %s" % filename
    doc = xml.dom.minidom.parse(filename)

    suffix = filename[-3:]

    if suffix == 'tsx':
        tiles = load_tilesets(doc)
    elif suffix == 'tmx':
        map_node = doc.documentElement
        tiles = load_tilesets(map_node )

    

def load_tilesets(map_node):

    # <tileset>
    tileset_nodes = map_node.getElementsByTagName('tileset')
    tiles = {}
    for tileset_node in tileset_nodes:

        tileset_name = tileset_node.getAttribute('name')
        # <tile>
        tile_nodes= tileset_node.getElementsByTagName('tile')

        for tile_node in tile_nodes:

            # <image>
            name = '%s_%s' % (tileset_name, tile_node.getAttribute('id') )
            image_node = tile_node.getElementsByTagName('image')[0]
            if image_node.hasAttribute('format'):
                format = image_node.getAttribute('format')
                if format == 'png':
                    load_tile( image_node, name )
                else:
                    print 'load_tilesets: unkown image format: %s' % format
            else:
                print 'load_tilesets: unkown tile'

def load_tile( node, name ):
    data_nodes = node.getElementsByTagName('data')
    data_node = data_nodes[0]

    encoding = ''
    compression = ''

    encoding = data_node.getAttribute('encoding')
    compression = data_node.getAttribute('compression')

    if encoding == 'base64':
        data = base64.b64decode(get_text_contents(data_node))
       
        if compression == 'gzip':
            data = decompress_data(data)
     
        file = open('%s.png' % name, 'wb')
        file.write( data )
        file.close()
#        p = ImageFile.Parser()
#        p.feed( data )
#        im = p.close()
        print 'saving: %s.png' % name
#        im.save("%s.png" % name )



def help():
    print "%s v1.0 - An utility to convert embedded images to individual files" % sys.argv[0]
    print "Usage:"
    print "\t-f image_file_name"
    print "\nExample:"
    print "\t%s -f water.tsx" % sys.argv[0]
    print "\t%s -f iso-map.tmx" % sys.argv[0]
    sys.exit(-1)

if __name__ == "__main__":
    if len( sys.argv ) == 1:
        help()

    filename = None

    argv = sys.argv[1:]
    try:                                
        opts, args = getopt.getopt(argv, "f:", ["filename="])
        for opt, arg in opts:
            if opt in ("-f","--filename"):
                filename = arg
    except getopt.GetoptError,e:
        print e

    if filename == None:
        help()

    load_map( filename )
