//
// TGA lib for cocos2d-iphone
//
// sources from: http://www.lighthouse3d.com/opengl/terrain/index.php3?tgasource
//
// TGA RLE compression support by Ernesto Corvi

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#import "TGAlib.h"


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
	
	info->flipped = 0;
	if ( cGarbage & 0x20 ) info->flipped = 1;
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

// loads the RLE encoded image pixels. You shouldn't call this function directly
void tgaLoadRLEImageData(FILE *file, tImageTGA *info)
{
	unsigned int mode,total,i, index = 0;
	unsigned char aux[4], runlength = 0;
	unsigned int skip = 0, flag = 0;
	
	// mode equal the number of components for each pixel
	mode = info->pixelDepth / 8;
	// total is the number of unsigned chars we'll have to read
	total = info->height * info->width;
	
	for( i = 0; i < total; i++ )
	{
		// if we have a run length pending, run it
		if ( runlength != 0 )
		{
			// we do, update the run length count
			runlength--;
			skip = (flag != 0);
		}
		else
		{
			// otherwise, read in the run length token
			if ( fread(&runlength,sizeof(unsigned char),1,file) != 1 )
				return;
			
			// see if it's a RLE encoded sequence
			flag = runlength & 0x80;
			if ( flag ) runlength -= 128;
			skip = 0;
		}
		
		// do we need to skip reading this pixel?
		if ( !skip )
		{
			// no, read in the pixel data
			if ( fread(aux,sizeof(unsigned char),mode,file) != mode )
				return;
			
			// mode=3 or 4 implies that the image is RGB(A). However TGA
			// stores it as BGR(A) so we'll have to swap R and B.
			if ( mode >= 3 )
			{
				unsigned char tmp;
				
				tmp = aux[0];
				aux[0] = aux[2];
				aux[2] = tmp;
			}
		}
		
		// add the pixel to our image
		memcpy(&info->imageData[index], aux, mode);
		index += mode;
	}
}

void tgaFlipImage( tImageTGA *info )
{
	// mode equal the number of components for each pixel
	int mode = info->pixelDepth / 8;
	int rowbytes = info->width*mode;
	unsigned char *row = (unsigned char *)malloc(rowbytes);
	int y;
	
	if (row == NULL) return;
	
	for( y = 0; y < (info->height/2); y++ )
	{
		memcpy(row, &info->imageData[y*rowbytes],rowbytes);
		memcpy(&info->imageData[y*rowbytes], &info->imageData[(info->height-(y+1))*rowbytes], rowbytes);
		memcpy(&info->imageData[(info->height-(y+1))*rowbytes], row, rowbytes);
	}
	
	free(row);
	info->flipped = 0;
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
	if ((info->type != 2) && (info->type !=3) && (info->type !=10) ) {
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
	if ( info->type == 10 )
		tgaLoadRLEImageData(file, info);
	else
		tgaLoadImageData(file,info);
	
	// check for errors when reading the pixels
	if (ferror(file)) {
		info->status = TGA_ERROR_READING_FILE;
		fclose(file);
		return(info);
	}
	fclose(file);
	info->status = TGA_OK;
	
	if ( info->flipped )
	{
		tgaFlipImage( info );
		if ( info->flipped ) info->status = TGA_ERROR_MEMORY;
	}
	
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
