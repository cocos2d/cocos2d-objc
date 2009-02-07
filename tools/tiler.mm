/*

Tiler is a small command line utility that tiles an arbitrary image
into a PNG texture containing tiles and a TGA image containing a tilemap.
You can specify the tile size (must be a power of 2) with the -tilesize option.

To Compile:
gcc tiler.mm -o tiler -framework Cocoa -lstdc++

*/


#import <Cocoa/Cocoa.h>

void saveTilemap( unsigned char *tilemap, int tx, int ty, const char *output )
{
	int x, y, index;
	
	typedef struct t_tgaHeader {
		unsigned char	pad0;
		unsigned char	pad1;
		unsigned char	type;
		unsigned char	pad2[9];
		short			width;
		short			height;
		unsigned char	bits;
		unsigned char	pad3;
	} tgaHeader;
	
	tgaHeader	header;
	memset( &header, 0, sizeof( tgaHeader ) );
	header.type = 2;
	header.width = tx;
	header.height = ty;
	header.bits = 24;
	
	unsigned long len = sizeof(tgaHeader) + (tx*ty*3);
	unsigned char *buffer = (unsigned char *)malloc(len);
	unsigned char *p = buffer;
	
	memset(p, 0, len);
	memcpy(p, &header, sizeof(tgaHeader));
	p += sizeof(tgaHeader);
	
	index = 0;
	for( y = (ty - 1); y >= 0; y--)
	{
		for( x = 0; x < tx; x++ )
		{
			int	i = (y*tx)+x;
			
			p[(i*3)+2] = tilemap[index];
			p[(i*3)] = tilemap[index] ? 0xff : 0;
			
			index++;
		}
	}
	
	NSData *data = [NSData dataWithBytesNoCopy:buffer length:len];
	[data writeToFile:[NSString stringWithFormat:@"%s.tga", output] atomically:NO];
}

void saveTexture( NSMutableArray *tiles, const char *output, int tilesize )
{
	int i, x, y;
	
	// Write the texture
	int stride = ((int)ceil(sqrt([tiles count]))) * tilesize;
	int	texsize = 1;
	
	while( texsize < stride )
		texsize <<= 1;
	
	int itemsPerRow = texsize / tilesize;
	
	NSImage *texture = [[NSImage alloc] initWithSize:NSMakeSize(texsize, texsize)];

	[texture lockFocus];
	
	NSRect imageRect = NSMakeRect(0, 0, texsize, texsize);
	
	NSEraseRect( imageRect );
	
	for( i = 0; i < [tiles count]; i++ )
	{
		x = (i % itemsPerRow) * tilesize;
		y = texsize - ((i / itemsPerRow) * tilesize) - tilesize;
		
		NSRect	subRect = NSMakeRect(x, y, tilesize, tilesize);
		[texture drawRepresentation:[tiles objectAtIndex:i] inRect:subRect];
	}
	
	[texture unlockFocus];
	
	NSBitmapImageRep *rep = [NSBitmapImageRep imageRepWithData:[texture TIFFRepresentation]];
	
	NSData *data = [rep representationUsingType:NSPNGFileType properties:NULL];
	[data writeToFile:[NSString stringWithFormat:@"%s.png", output] atomically:NO];
	
}

void processFile( const char *input, const char *output, int tilesize )
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSImage *in = [[NSImage alloc] initWithContentsOfFile:[NSString stringWithUTF8String:input]];
	
	if ( in == NULL )
	{
		printf( "Could not open image %s\n", input );
		return;
	}
	
	NSSize	inSize = [in size];
	
	if ( ( (int)inSize.width % tilesize ) != 0 )
		inSize.width += ( (int)inSize.width % tilesize );
	
	if ( ( (int)inSize.height % tilesize ) != 0 )
		inSize.height += ( (int)inSize.height % tilesize );
	
	[in setSize:inSize];
	
	int	ty = ((int)inSize.height / tilesize);
	int	tx = ((int)inSize.width / tilesize);
	
	NSMutableArray *tiles = [[NSMutableArray alloc] init];
	unsigned char *tilemap = (unsigned char *)malloc(tx*ty);
	
	memset( tilemap, 0, tx*ty );
	
	NSImage *empty = [[NSImage alloc] initWithSize:NSMakeSize(tilesize, tilesize)];
	[empty lockFocus];
	[[NSColor clearColor] set];
	NSRectFill(NSMakeRect(0, 0, tilesize, tilesize));
	[empty unlockFocus];
	
	NSBitmapImageRep *er = [NSBitmapImageRep imageRepWithData:[empty TIFFRepresentation]];
	[tiles addObject:er];
	
	NSBitmapImageRep *ir = [NSBitmapImageRep imageRepWithData:[in TIFFRepresentation]];
	CGImageRef	inputRef = [ir CGImage];
	
	int y, x, i, j, k = 0;
	
	for( y = 0; y < ty; y++ )
	{
		for( x = 0; x < tx; x++ )
		{
			int		tileIndex = -1;
			
			CGRect		tileRect = CGRectMake(x*tilesize, y*tilesize, tilesize, tilesize);
			CGImageRef	tileRef = CGImageCreateWithImageInRect(inputRef, tileRect);
			NSBitmapImageRep *tile = [[NSBitmapImageRep alloc] initWithCGImage:tileRef];
			
			// see if it's opaque at all
			BOOL	opaque = NO;
			for( j = 0; j < (tilesize * tilesize); j++ )
			{
				NSColor *color = [tile colorAtX:(j % tilesize) y:(j / tilesize)];
				
				if ( [color alphaComponent] != 0 )
				{
					opaque = YES;
					break;
				}
			}
			
			if ( opaque )
			{
				for( i = 1; i < [tiles count]; i++ )
				{
					NSBitmapImageRep *t = [tiles objectAtIndex:i];
					
					if ( [[t TIFFRepresentation] isEqualToData:[tile TIFFRepresentation]] )
					{
						tileIndex = i;
						break;
					}
				}
			}
			else
				tileIndex = 0;
			
			if ( tileIndex < 0 )
			{
				tileIndex = [tiles count];
				[tiles addObject:[tile retain]];
			}
			
			tilemap[k++] = tileIndex;
		}
	}
	
	[in unlockFocus];
	
	if ( [tiles count] >= 255 )
	{
		printf( "Could not reduce image to less than 255 tiles, please try a different tile size\n" );
	}
	else
	{
		saveTexture( tiles, output, tilesize );
		saveTilemap( tilemap, tx, ty, output );
	}
	
	free( tilemap );
	[pool release];
}


static int Usage( const char *name )
{
	printf( "Tiler v1.0\n" );
	printf( "Usage: %s [-tilesize {size}] input output\n", name);
	printf( "Default tile size if not specified is 16 pixels\n");
	printf( "The tile size must be a power of 2 value\n");
	return 0;
}

int main (int argc, const char * argv[])
{
	NSApplicationLoad();
	
	int			tilesize = 16, i;
	const char	*input = nil;
	const char	*output = nil;
	
	if ( argc < 3 )
		return Usage( argv[0] );
	
	for( i = 1; i < argc; i++ )
	{
		if ( strcmp( argv[i], "-tilesize" ) == 0 )
		{
			i++;
			
			if ( i < argc )
			{
				tilesize = atoi( argv[i] );
			}
		}
		else if ( input == nil )
		{
			input = argv[i];
		}
		else
		{
			output = argv[i];
			break;
		}
	}
	
	if ( input == nil || output == nil )
		return Usage( argv[0] );
	
	
	// make sure the tile size is a power of 2 value
	if ( tilesize == 0 )
		return Usage( argv[0] );
	
	int numones = 0, ts = tilesize;
	
	while( ts )
	{
		if ( ts & 1 )
			numones++;
		ts >>= 1;
	}
	
	if ( numones > 1 )
		return Usage( argv[0] );
		
	processFile( input, output, tilesize );
	
	return 0;
}
