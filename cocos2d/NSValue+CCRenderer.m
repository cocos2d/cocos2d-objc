/*
 * cocos2d for iPhone: http://www.cocos2d-iphone.org
 *
 * Copyright (c) 2014 Cocos2D Authors
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
 */

#import "NSValue+CCRenderer.h"

//MARK: NSValue Additions.
@implementation NSValue(CCRenderer)

+(NSValue *)valueWithGLKVector2:(GLKVector2)vector
{
	return [NSValue valueWithBytes:&vector objCType:@encode(GLKVector2)];
}

+(NSValue *)valueWithGLKVector3:(GLKVector3)vector
{
	return [NSValue valueWithBytes:&vector objCType:@encode(GLKVector3)];
}

+(NSValue *)valueWithGLKVector4:(GLKVector4)vector
{
	return [NSValue valueWithBytes:&vector objCType:@encode(GLKVector4)];
}

+(NSValue *)valueWithGLKMatrix4:(GLKMatrix4)matrix
{
	return [NSValue valueWithBytes:&matrix objCType:@encode(GLKMatrix4)];
}

static void
AdvanceUntilAfter(const char **cursor, const char c)
{
	while(**cursor != c) (*cursor)++;
	(*cursor)++;
}

static size_t
ReadValue(const char **cursor)
{
	char c = (**cursor);
	(*cursor)++;
	
	switch(c){
		case 'c': return sizeof(char); break;
		case 'i': return sizeof(int); break;
		case 's': return sizeof(short); break;
		case 'l': return sizeof(long); break;
		case 'q': return sizeof(long long); break;
		case 'C': return sizeof(unsigned char); break;
		case 'I': return sizeof(unsigned int); break;
		case 'S': return sizeof(unsigned short); break;
		case 'L': return sizeof(unsigned long); break;
		case 'Q': return sizeof(unsigned long long); break;
		case 'f': return sizeof(float); break;
		case 'd': return sizeof(double); break;
		case 'B': return sizeof(_Bool); break;
		
		case '{': {
			// struct
			AdvanceUntilAfter(cursor, '=');
			
			size_t bytes = 0;
			while(**cursor != '}'){
				bytes += ReadValue(cursor);
			}
			
			(*cursor)++;
			return bytes;
		}
		
		case '(': {
			// Union
			AdvanceUntilAfter(cursor, '=');
			
			size_t bytes = 0;
			while(**cursor != ')'){
				bytes = MAX(bytes, ReadValue(cursor));
			}
			
			(*cursor)++;
			return bytes;
		}
		
		case '[': {
			// array
			size_t count = 0;
			for(; '0' <= **cursor && **cursor <= '9'; (*cursor)++){
				count = count*10 + (**cursor - '0');
			}
			
			size_t elementSize = ReadValue(cursor);
			
			(*cursor)++;
			return count*elementSize;
		}
		
			case 'v': // void
			case '*': // char *
			case 'b': // bitfield
			case '@': // object
			case '#': // class
			case ':': // selector
			case '^': // pointer
			default:
				NSCAssert(NO, @"@encode() type %c is forbidden to use with shader uniforms.", c);
				return 0;
	}
}

// Partial implementation to calculate the size of an @encode() string.
// Doesn't handle all types, alignment, etc.
-(size_t)CCRendererSizeOf
{
	size_t bytes = 0;
	
	const char *objCType = self.objCType;
	const char **cursor = &objCType;
	
	while(**cursor != '\0'){
		bytes += ReadValue(cursor);
	}
	
	return bytes;
}


@end
