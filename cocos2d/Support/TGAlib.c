//
// TGA lib for cocos2d-iphone
//
// sources from: http://www.lighthouse3d.com/opengl/terrain/index.php3?tgasource
//

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "TGAlib.h"

#if 1
// load the image header fields. We only keep those that matter!
void tgaLoadHeader(FILE *file, tImageTGA *info) {
	unsigned char cGarbage;
	short int iGarbage;

	fread(&cGarbage, sizeof(unsigned char), 1, file);
	fread(&cGarbage, sizeof(unsigned char), 1, file);

	// type must be 2 or 3
	fread(&info->type, sizeof(unsigned char), 1, file);

	fread(&iGarbage, sizeof(short int), 1, file);
	fread(&iGarbage, sizeof(short int), 1, file);
	fread(&cGarbage, sizeof(unsigned char), 1, file);
	fread(&iGarbage, sizeof(short int), 1, file);
	fread(&iGarbage, sizeof(short int), 1, file);

	fread(&info->width, sizeof(short int), 1, file);
	fread(&info->height, sizeof(short int), 1, file);
	fread(&info->pixelDepth, sizeof(unsigned char), 1, file);

	fread(&cGarbage, sizeof(unsigned char), 1, file);
}

// loads the image pixels. You shouldn't call this function directly
void tgaLoadImageData(FILE *file, tImageTGA *info) {
	
	int mode,total,i;
	unsigned char aux;
	
	// mode equal the number of components for each pixel
	mode = info->pixelDepth / 8;
	// total is the number of unsigned chars we'll have to read
	total = info->height * info->width * mode;
	
	fread(info->imageData,sizeof(unsigned char),total,file);
	
	// mode=3 or 4 implies that the image is RGB(A). However TGA
	// stores it as BGR(A) so we'll have to swap R and B.
	if (mode >= 3)
		for (i=0; i < total; i+= mode) {
			aux = info->imageData[i];
			info->imageData[i] = info->imageData[i+2];
			info->imageData[i+2] = aux;
		}
}	

// this is the function to call when we want to load an image
tImageTGA * tgaLoad(const char *filename) {
	
	FILE *file;
	tImageTGA *info;
	int mode,total;
	
	// allocate memory for the info struct and check!
	info = (tImageTGA *)malloc(sizeof(tImageTGA));
	if (info == NULL)
		return(NULL);
	
	
	// open the file for reading (binary mode)
	file = fopen(filename, "rb");
	if (file == NULL) {
		info->status = TGA_ERROR_FILE_OPEN;
		return(info);
	}
	
	// load the header
	tgaLoadHeader(file,info);
	
	// check for errors when loading the header
	if (ferror(file)) {
		info->status = TGA_ERROR_READING_FILE;
		fclose(file);
		return(info);
	}
	
	// check if the image is color indexed
	if (info->type == 1) {
		info->status = TGA_ERROR_INDEXED_COLOR;
		fclose(file);
		return(info);
	}
	// check for other types (compressed images)
	if ((info->type != 2) && (info->type !=3)) {
		info->status = TGA_ERROR_COMPRESSED_FILE;
		fclose(file);
		return(info);
	}
	
	// mode equals the number of image components
	mode = info->pixelDepth / 8;
	// total is the number of unsigned chars to read
	total = info->height * info->width * mode;
	// allocate memory for image pixels
	info->imageData = (unsigned char *)malloc(sizeof(unsigned char) * 
											  total);
	
	// check to make sure we have the memory required
	if (info->imageData == NULL) {
		info->status = TGA_ERROR_MEMORY;
		fclose(file);
		return(info);
	}
	// finally load the image pixels
	tgaLoadImageData(file,info);
	
	// check for errors when reading the pixels
	if (ferror(file)) {
		info->status = TGA_ERROR_READING_FILE;
		fclose(file);
		return(info);
	}
	fclose(file);
	info->status = TGA_OK;
	return(info);
}		

// converts RGB to greyscale
void tgaRGBtogreyscale(tImageTGA *info) {
	
	int mode,i,j;
	
	unsigned char *newImageData;
	
	// if the image is already greyscale do nothing
	if (info->pixelDepth == 8)
		return;
	
	// compute the number of actual components
	mode = info->pixelDepth / 8;
	
	// allocate an array for the new image data
	newImageData = (unsigned char *)malloc(sizeof(unsigned char) * 
										   info->height * info->width);
	if (newImageData == NULL) {
		return;
	}
	
	// convert pixels: greyscale = o.30 * R + 0.59 * G + 0.11 * B
	for (i = 0,j = 0; j < info->width * info->height; i +=mode, j++)
		newImageData[j] =	
		(unsigned char)(0.30 * info->imageData[i] + 
						0.59 * info->imageData[i+1] +
						0.11 * info->imageData[i+2]);
	
	
	//free old image data
	free(info->imageData);
	
	// reassign pixelDepth and type according to the new image type
	info->pixelDepth = 8;
	info->type = 3;
	// reassing imageData to the new array.
	info->imageData = newImageData;
}

// releases the memory used for the image
void tgaDestroy(tImageTGA *info) {
	
	if (info != NULL) {
		if (info->imageData != NULL)
			free(info->imageData);
		free(info);
	}
}

#else

tImageTGA *tgaLoad(const char *filename)
{
	tImageTGA *pImageData = NULL;		// This stores our important image data
	unsigned int width = 0, height = 0;			// The dimensions of the image
	unsigned char length = 0;					// The length in unsigned chars to the pixels
	unsigned char imageType = 0;					// The image type (RLE, RGB, Alpha...)
	unsigned char bits = 0;						// The bits per pixel for the image (16, 24, 32)
	FILE *pFile = NULL;					// The file pointer
	int channels = 0;					// The channels of the image (3 = RGA : 4 = RGBA)
	int stride = 0;						// The stride (channels * width)
	int i = 0;							// A counter
	
	// This function loads in a TARGA (.TGA) file and returns its data to be
	// used as a texture or what have you.  This currently loads in a 16, 24
	// and 32-bit targa file, along with RLE compressed files.  Eventually you
	// will want to do more error checking to make it more robust.  This is
	// also a perfect start to go into a modular class for an engine.
	// Basically, how it works is, you read in the header information, then
	// move your file pointer to the pixel data.  Before reading in the pixel
	// data, we check to see the if it's an RLE compressed image.  This is because
	// we will handle it different.  If it isn't compressed, then we need another
	// check to see if we need to convert it from 16-bit to 24 bit.  24-bit and
	// 32-bit textures are very similar, so there's no need to do anything special.
	// We do, however, read in an extra bit for each color.
	
	// Open a file pointer to the targa file and check if it was found and opened 
	if((pFile = fopen(filename, "rb")) == NULL) 
	{
		return NULL;
	}
	
	// Allocate the structure that will hold our eventual image data (must free it!)
	pImageData = (tImageTGA*)malloc(sizeof(tImageTGA));
	
	// Read in the length in unsigned chars from the header to the pixel data
	fread(&length, sizeof(unsigned char), 1, pFile);
	
	// Jump over one unsigned char
	fseek(pFile,1,SEEK_CUR); 
	
	// Read in the imageType (RLE, RGB, etc...)
	fread(&imageType, sizeof(unsigned char), 1, pFile);
	
	// Skip past general information we don't care about
	fseek(pFile, 9, SEEK_CUR); 
	
	// Read the width, height and bits per pixel (16, 24 or 32)
	fread(&width,  sizeof(unsigned int), 1, pFile);
	fread(&height, sizeof(unsigned int), 1, pFile);
	fread(&bits,   sizeof(unsigned char), 1, pFile);
	
	// Now we move the file pointer to the pixel data
	fseek(pFile, length + 1, SEEK_CUR); 
	
	// Check if the image is RLE compressed or not
	if(imageType != TGA_RLE)
	{
		// Check if the image is a 24 or 32-bit image
		if(bits == 24 || bits == 32)
		{
			// Calculate the channels (3 or 4) - (use bits >> 3 for more speed).
			// Next, we calculate the stride and allocate enough memory for the pixels.
			channels = bits / 8;
			stride = channels * width;
			pImageData->imageData = malloc( stride * height);
			
			// Load in all the pixel data line by line
			for(int y = 0; y < height; y++)
			{
				// Store a pointer to the current line of pixels
				unsigned char *pLine = &(pImageData->imageData[stride * y]);
				
				// Read in the current line of pixels
				fread(pLine, stride, 1, pFile);
				
				// Go through all of the pixels and swap the B and R values since TGA
				// files are stored as BGR instead of RGB (or use GL_BGR_EXT verses GL_RGB)
				for(i = 0; i < stride; i += channels)
				{
					int temp     = pLine[i];
					pLine[i]     = pLine[i + 2];
					pLine[i + 2] = temp;
				}
			}
		}
		// Check if the image is a 16 bit image (RGB stored in 1 unsigned short)
		else if(bits == 16)
		{
			unsigned short pixels = 0;
			int r=0, g=0, b=0;
			
			// Since we convert 16-bit images to 24 bit, we hardcode the channels to 3.
			// We then calculate the stride and allocate memory for the pixels.
			channels = 3;
			stride = channels * width;
			pImageData->imageData = malloc( stride * height );
			
			// Load in all the pixel data pixel by pixel
			for(int i = 0; i < width*height; i++)
			{
				// Read in the current pixel
				fread(&pixels, sizeof(unsigned short), 1, pFile);
				
				// To convert a 16-bit pixel into an R, G, B, we need to
				// do some masking and such to isolate each color value.
				// 0x1f = 11111 in binary, so since 5 bits are reserved in
				// each unsigned short for the R, G and B, we bit shift and mask
				// to find each value.  We then bit shift up by 3 to get the full color.
				b = (pixels & 0x1f) << 3;
				g = ((pixels >> 5) & 0x1f) << 3;
				r = ((pixels >> 10) & 0x1f) << 3;
				
				// This essentially assigns the color to our array and swaps the
				// B and R values at the same time.
				pImageData->imageData[i * 3 + 0] = r;
				pImageData->imageData[i * 3 + 1] = g;
				pImageData->imageData[i * 3 + 2] = b;
			}
		}	
		// Else return a NULL for a bad or unsupported pixel format
		else
			return NULL;
	}
	// Else, it must be Run-Length Encoded (RLE)
	else
	{
		// First, let me explain real quickly what RLE is.  
		// For further information, check out Paul Bourke's intro article at: 
		// http://astronomy.swin.edu.au/~pbourke/dataformats/rle/
		// 
		// Anyway, we know that RLE is a basic type compression.  It takes
		// colors that are next to each other and then shrinks that info down
		// into the color and a integer that tells how much of that color is used.
		// For instance:
		// aaaaabbcccccccc would turn into a5b2c8
		// Well, that's fine and dandy and all, but how is it down with RGB colors?
		// Simple, you read in an color count (rleID), and if that number is less than 128,
		// it does NOT have any optimization for those colors, so we just read the next
		// pixels normally.  Say, the color count was 28, we read in 28 colors like normal.
		// If the color count is over 128, that means that the next color is optimized and
		// we want to read in the same pixel color for a count of (colorCount - 127).
		// It's 127 because we add 1 to the color count, as you'll notice in the code.
		
		// Create some variables to hold the rleID, current colors read, channels, & stride.
		unsigned char rleID = 0;
		int colorsRead = 0;
		channels = bits / 8;
		stride = channels * width;
		
		// Next we want to allocate the memory for the pixels and create an array,
		// depending on the channel count, to read in for each pixel.
		pImageData->imageData = malloc( stride * height );
		unsigned char *pColors = malloc( channels );
		
		// Load in all the pixel data
		while(i < width*height)
		{
			// Read in the current color count + 1
			fread(&rleID, sizeof(unsigned char), 1, pFile);
			
			// Check if we don't have an encoded string of colors
			if(rleID < 128)
			{
				// Increase the count by 1
				rleID++;
				
				// Go through and read all the unique colors found
				while(rleID)
				{
					// Read in the current color
					fread(pColors, sizeof(unsigned char) * channels, 1, pFile);
					
					// Store the current pixel in our image array
					pImageData->imageData[colorsRead + 0] = pColors[2];
					pImageData->imageData[colorsRead + 1] = pColors[1];
					pImageData->imageData[colorsRead + 2] = pColors[0];
					
					// If we have a 4 channel 32-bit image, assign one more for the alpha
					if(bits == 32)
						pImageData->imageData[colorsRead + 3] = pColors[3];
					
					// Increase the current pixels read, decrease the amount
					// of pixels left, and increase the starting index for the next pixel.
					i++;
					rleID--;
					colorsRead += channels;
				}
			}
			// Else, let's read in a string of the same character
			else
			{
				// Minus the 128 ID + 1 (127) to get the color count that needs to be read
				rleID -= 127;
				
				// Read in the current color, which is the same for a while
				fread(pColors, sizeof(unsigned char) * channels, 1, pFile);
				
				// Go and read as many pixels as are the same
				while(rleID)
				{
					// Assign the current pixel to the current index in our pixel array
					pImageData->imageData[colorsRead + 0] = pColors[2];
					pImageData->imageData[colorsRead + 1] = pColors[1];
					pImageData->imageData[colorsRead + 2] = pColors[0];
					
					// If we have a 4 channel 32-bit image, assign one more for the alpha
					if(bits == 32)
						pImageData->imageData[colorsRead + 3] = pColors[3];
					
					// Increase the current pixels read, decrease the amount
					// of pixels left, and increase the starting index for the next pixel.
					i++;
					rleID--;
					colorsRead += channels;
				}
				
			}
			
		}
		
		// Free up pColors
		free( pColors );
	}
	
	// Close the file pointer that opened the file
	fclose(pFile);
	
	// Fill in our tImageTGA structure to pass back
	pImageData->channels = channels;
	pImageData->width    = width;
	pImageData->height    = height;
	
	// Return the TGA data (remember, you must free this data after you are done)
	return pImageData;
}
#endif
