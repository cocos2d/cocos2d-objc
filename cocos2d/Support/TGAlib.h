//
// TGA lib for cocos2d-iphone
//
// sources from: http://www.lighthouse3d.com/opengl/terrain/index.php3?tgasource
//

#ifndef TGA_LIB
#define TGA_LIB


#if 1

enum {
	TGA_OK,
	TGA_ERROR_FILE_OPEN,
	TGA_ERROR_READING_FILE,
	TGA_ERROR_INDEXED_COLOR,
	TGA_ERROR_MEMORY,
	TGA_ERROR_COMPRESSED_FILE,
};

/** TGA format */
typedef struct sImageTGA {
	int status;
	unsigned char type, pixelDepth;
	
	/** map width */
	short int width;
	
	/** map height */
	short int height;
	
	/** raw data */
	unsigned char *imageData;
	int flipped;
} tImageTGA;

// load the image header fields. We only keep those that matter!
void tgaLoadHeader(FILE *file, tImageTGA *info);

// loads the image pixels. You shouldn't call this function directly
void tgaLoadImageData(FILE *file, tImageTGA *info);

// this is the function to call when we want to load an image
tImageTGA * tgaLoad(const char *filename);

// converts RGB to greyscale
void tgaRGBtogreyscale(tImageTGA *info);

// releases the memory used for the image
void tgaDestroy(tImageTGA *info);

#else 

#define TGA_RGB		 2		// This tells us it's a normal RGB (really BGR) file
#define TGA_A		 3		// This tells us it's a ALPHA file
#define TGA_RLE		10		// This tells us that the targa is Run-Length Encoded (RLE)

typedef struct sImageTGA
{
	int channels;				// The channels in the image (3 = RGB : 4 = RGBA)
	int width;					// The width of the image in pixels
	int height;					// The height of the image in pixels
	unsigned char *imageData;	// The image pixel data
} tImageTGA;

tImageTGA *tgaLoad(const char *filename);

#endif


#endif // TGA_LIB
