#import "png.h"

#import "ccUtils.h"
#import "CCImage_Private.h"
#import "CCFile_Private.h"

#import "CCSetup.h"

extern NSString * const CCImageOptionFlipVertical;


static void
Premultiply(png_structp png, png_row_infop row_info, png_bytep row)
{
	int width = row_info->width;
	
	// Could be easily vectorized, but doesn't seem to show up in the profiler.
	if(row_info->channels == 4){
		for(int i=0; i<width; i++){
			png_byte alpha = row[i*4 + 3];
			row[i*4 + 0] = row[i*4 + 0]*alpha/255;
			row[i*4 + 1] = row[i*4 + 1]*alpha/255;
			row[i*4 + 2] = row[i*4 + 2]*alpha/255;
		}
	} else {
		for(int i=0; i<width; i++){
			png_byte alpha = row[i*2 + 1];
			row[i*2 + 0] = row[i*2 + 0]*alpha/255;
		}
	}
}

struct ProgressiveInfo {
	BOOL flip, rgb, alpha, premultiply;
	png_uint_32 scale;
	
	// Original image width
	png_uint_32 width;
	
	// Accumulation buffer used when downscaling.
	png_uint_16p accumulated_row;
	png_size_t accumulated_row_bytes;
	
	// Final rescaled image.
	png_uint_32 scaled_width, scaled_height;
	png_bytep scaled_pixels;
	png_size_t scaled_row_bytes;
};

static void
ProgressiveInfo(png_structp png, png_infop png_info)
{
	struct ProgressiveInfo *info = png_get_progressive_ptr(png);
	
	info->width = png_get_image_width(png, png_info);
	
	png_uint_32 scale = info->scale;
	info->scaled_width = (info->width + scale - 1)/scale;
	info->scaled_height = (png_get_image_height(png, png_info) + scale - 1)/scale;
	
	png_uint_32 bit_depth, color_type;
	bit_depth = png_get_bit_depth(png, png_info);
	color_type = png_get_color_type(png, png_info);
	
	if(color_type == PNG_COLOR_TYPE_GRAY && bit_depth < 8){
		png_set_expand_gray_1_2_4_to_8(png);
	}
	
	if (bit_depth == 16){
		png_set_strip_16(png);
	}
	
	if(info->rgb){
		if(color_type == PNG_COLOR_TYPE_PALETTE){
			png_set_palette_to_rgb(png);
		} else if(color_type == PNG_COLOR_TYPE_GRAY || color_type == PNG_COLOR_TYPE_GRAY_ALPHA){
			png_set_gray_to_rgb(png);
		}
	} else {
		NSCAssert(color_type != PNG_COLOR_TYPE_PALETTE, @"Paletted PNG to grayscale conversion not supported.");
		
		if(color_type == PNG_COLOR_TYPE_RGB || color_type == PNG_COLOR_TYPE_RGB_ALPHA){
			png_set_rgb_to_gray_fixed(png, 1, -1, -1);
		}
	}
	
	if(info->alpha){
		if(png_get_valid(png, png_info, PNG_INFO_tRNS)){
			png_set_tRNS_to_alpha(png);
		} else {
			png_set_filler(png, 0xff, PNG_FILLER_AFTER);
		}
	} else 	{
		if(color_type & PNG_COLOR_MASK_ALPHA){
			png_set_strip_alpha(png);
		}
	}
	
	if(info->premultiply){
		png_set_read_user_transform_fn(png, Premultiply);
	}
  
	png_read_update_info(png, png_info);
	
	png_size_t bpp = png_get_rowbytes(png, png_info)/info->width;
	info->accumulated_row_bytes = bpp*2*info->scaled_width;
	
	if(info->scale > 1){
		info->accumulated_row = calloc(info->scaled_width, 2*bpp);
	}
	
	// Rescaled image rows are tightly packed.
	info->scaled_row_bytes = bpp*info->scaled_width;
	info->scaled_pixels = malloc(info->scaled_row_bytes*info->scaled_height);
}

static png_bytep
GetScaledRowPixels(struct ProgressiveInfo *info, png_uint_32 row)
{
    png_uint_32 scaled_row = row/info->scale;
    
    if(!info->flip){
        scaled_row = info->scaled_height - scaled_row - 1;
    }
    
    return info->scaled_pixels + (scaled_row)*info->scaled_row_bytes;
}

static void
ProgressiveRow(png_structp png, png_bytep rowPixels, png_uint_32 row, int pass)
{
	struct ProgressiveInfo *info = png_get_progressive_ptr(png);
	
	NSUInteger scale = info->scale;
	png_size_t row_bytes = info->scaled_row_bytes;
	NSUInteger width = info->width;
	png_uint_16p accumulated = info->accumulated_row;
	
    png_bytep row_pixels = GetScaledRowPixels(info, row);
	if(scale == 1){
		memcpy(row_pixels, rowPixels, row_bytes);
	} else {
		for(int i=0; i<width; i++){
			accumulated[(i/scale)*4 + 0] += rowPixels[i*4 + 0];
			accumulated[(i/scale)*4 + 1] += rowPixels[i*4 + 1];
			accumulated[(i/scale)*4 + 2] += rowPixels[i*4 + 2];
			accumulated[(i/scale)*4 + 3] += rowPixels[i*4 + 3];
		}
		
		NSUInteger mask = info->scale - 1;
		if((row & mask) == mask){
			for(int i=0; i<row_bytes; i++){
				// Divde and copy the accumulated value
				row_pixels[i] = (accumulated[i] >> scale);
				// Clear the accumulated value
				accumulated[i] = 0;
			}
		}
	}
}

static NSMutableData *
LoadPNG(CCFile *file, BOOL flip, BOOL rgb, BOOL alpha, BOOL premultiply, NSUInteger scale, CGSize *size)
{
	NSCAssert(scale == 1 || scale == 2 || scale == 4, @"Scale must be 1, 2 or 4.");
	
    NSInputStream *stream = [file openInputStream];
    
//	const NSUInteger PNG_SIG_BYTES = 8;
//	png_byte header[PNG_SIG_BYTES];
//    [stream read:header maxLength:PNG_SIG_BYTES];
//	NSCAssert(!png_sig_cmp(header, 0, PNG_SIG_BYTES), @"Bad PNG header on %@", file.name);
	
	png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
	NSCAssert(png, @"Error creating PNG read struct");
	
	png_infop png_info = png_create_info_struct(png);
	NSCAssert(png_info, @"libPNG error");
	
	png_infop end_info = png_create_info_struct(png);
	NSCAssert(end_info, @"libPNG error");
	
	NSCAssert(!setjmp(png_jmpbuf(png)), @"PNG file %@ could not be loaded.", file.name);
	
//	png_init_io(png, file);
//	png_set_sig_bytes(png, PNG_SIG_BYTES);
//	png_read_info(png, info);
	
	struct ProgressiveInfo info = {};
    info.flip = flip;
	info.rgb = rgb;
	info.alpha = alpha;
	info.premultiply = premultiply;
	info.scale = (png_uint_32)scale;
	
	png_set_progressive_read_fn(png, &info, ProgressiveInfo, ProgressiveRow, NULL);
	
	const png_size_t buffer_size = 32*1024;
	png_byte buffer[buffer_size];
	
	while([stream hasBytesAvailable]){
		png_size_t buffered = [stream read:buffer maxLength:buffer_size];
		png_process_data(png, png_info, buffer, buffered);
	}
	
	png_destroy_read_struct(&png, &png_info, &end_info);
	free(info.accumulated_row);
	[stream close];
	
    size->width = info.scaled_width;
    size->height = info.scaled_height;
    return [NSMutableData dataWithBytesNoCopy:info.scaled_pixels length:info.scaled_height*info.scaled_row_bytes freeWhenDone:YES];
}


@implementation CCImage(PNG)

-(instancetype)initWithPNGFile:(CCFile *)file options:(NSDictionary *)options;
{
    options = NormalizeCCImageOptions(options);
    CGFloat rescale = file.autoScaleFactor*[options[CCImageOptionRescaleFactor] doubleValue];
    
    CGSize size = {};
    BOOL flip = [options[CCImageOptionFlipVertical] boolValue];
    BOOL premultiply = [options[CCImageOptionPremultiply] boolValue];
    NSMutableData *data = LoadPNG(file, flip, TRUE, TRUE, premultiply, 1.0/rescale, &size);
    
    return [self initWithPixelSize:size contentScale:file.contentScale*rescale pixelData:data options:options];
}

@end
