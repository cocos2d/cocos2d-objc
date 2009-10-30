/* 
 public domain BASE64 code
 
 modified for cocos2d-iphone
 http://www.cocos2d-iphone.org
 */

#include <stdio.h>
#include <stdlib.h>

unsigned char alphabet[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

int _base64Decode( unsigned char *input, unsigned int input_len, unsigned char *output, unsigned int *output_len )
{
    static char inalphabet[256], decoder[256];
    int i, bits, c, char_count, errors = 0;
	unsigned int input_idx = 0;
	unsigned int output_idx = 0;

    for (i = (sizeof alphabet) - 1; i >= 0 ; i--) {
		inalphabet[alphabet[i]] = 1;
		decoder[alphabet[i]] = i;
    }

    char_count = 0;
    bits = 0;
	for( input_idx=0; input_idx < input_len ; input_idx++ ) {
		c = input[ input_idx ];
		if (c == '=')
			break;
		if (c > 255 || ! inalphabet[c])
			continue;
		bits += decoder[c];
		char_count++;
		if (char_count == 4) {
			output[ output_idx++ ] = (bits >> 16);
			output[ output_idx++ ] = ((bits >> 8) & 0xff);
			output[ output_idx++ ] = ( bits & 0xff);
			bits = 0;
			char_count = 0;
		} else {
			bits <<= 6;
		}
    }
	
	if( c == '=' ) {
		switch (char_count) {
			case 1:
				fprintf(stderr, "base64Decode: encoding incomplete: at least 2 bits missing");
				errors++;
				break;
			case 2:
				output[ output_idx++ ] = ( bits >> 10 );
				break;
			case 3:
				output[ output_idx++ ] = ( bits >> 16 );
				output[ output_idx++ ] = (( bits >> 8 ) & 0xff);
				break;
			}
	} else if ( input_idx < input_len ) {
		if (char_count) {
			fprintf(stderr, "base64 encoding incomplete: at least %d bits truncated",
					((4 - char_count) * 6));
			errors++;
		}
    }
	
	*output_len = output_idx;
	return errors;
}

int base64Decode(unsigned char *in, unsigned int inLength, unsigned char **out)
{
	unsigned int outLength = 0;
	
	//should be enough to store 6-bit buffers in 8-bit buffers
	*out = malloc( inLength * 3.0f / 4.0f + 1 );
	if( *out ) {
		int ret = _base64Decode(in, inLength, *out, &outLength);
		
		if (ret > 0 )
		{
			printf("Base64Utils: error decoding");
			free(*out);
			*out = NULL;			
			outLength = 0;
		}
	}
    return outLength;
}
