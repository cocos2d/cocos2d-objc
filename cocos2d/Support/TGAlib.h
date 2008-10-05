//
// TGA lib for cocos2d-iphone
//
// sources from: http://www.lighthouse3d.com/opengl/terrain/index.php3?tgasource
//

#ifndef TGA_LIB
#define TGA_LIB


enum {
	TGA_OK,
	TGA_ERROR_FILE_OPEN,
	TGA_ERROR_READING_FILE,
	TGA_ERROR_INDEXED_COLOR,
	TGA_ERROR_MEMORY,
	TGA_ERROR_COMPRESSED_FILE,
};

typedef struct {
	int status;
	unsigned char type, pixelDepth;
	short int width, height;
	unsigned char *imageData;
} tTgaInfo;


// load the image header fields. We only keep those that matter!
void tgaLoadHeader(FILE *file, tTgaInfo *info);

// loads the image pixels. You shouldn't call this function directly
void tgaLoadImageData(FILE *file, tTgaInfo *info);

// this is the function to call when we want to load an image
tTgaInfo * tgaLoad(const char *filename);

// converts RGB to greyscale
void tgaRGBtogreyscale(tTgaInfo *info);

// releases the memory used for the image
void tgaDestroy(tTgaInfo *info);



#endif // TGA_LIB