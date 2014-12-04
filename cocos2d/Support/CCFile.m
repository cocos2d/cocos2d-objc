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


#import <zlib.h>

#import "CCFile.h"


//MARK: Basic Files

@implementation CCFile

-(instancetype)initWithName:(NSString *)name url:(NSURL *)url contentScale:(CGFloat)contentScale
{
    if((self = [super init])){
        _name = [name copy];
        _url = [url copy];
        _contentScale = contentScale;
    }
    
    return self;
}

-(NSString *)absoluteFilePath
{
    if(_url.isFileURL){
        return _url.path;
    } else {
        return nil;
    }
}

+(Class)inputStreamClass
{
    return [NSInputStream class];
}

-(NSInputStream *)openInputStream
{
    Class streamClass = [self.class inputStreamClass];
    NSInputStream *stream = [streamClass inputStreamWithURL:self.url];
    
    if(stream == nil){
        CCLOG(@"Error opening stream for %@", self.name);
    }
    
    [stream open];
    return stream;
}

-(id)loadPlist
{
    NSInputStream *stream = [self openInputStream];
    NSError *err = nil;
    id plist = [NSPropertyListSerialization propertyListWithStream:stream options:0 format:NULL error:&err];
    
    [stream close];
    
    if(err){
        CCLOG(@"Error reading property list from %@: %@", self.name, err);
        return nil;
    } else {
        return plist;
    }
}

-(NSData *)loadData
{
    NSError *err = nil;
    NSData *data = [NSData dataWithContentsOfURL:_url options:NSDataReadingMappedIfSafe error:&err];
    
    if(err){
        CCLOG(@"Error reading data from from %@: %@", self.name, err);
        return nil;
    } else {
        return data;
    }
}

@end


//MARK: GZipped Files

#define BUFFER_SIZE 32*1024

@interface CCGZippedInputStream : NSInputStream
@end


@implementation CCGZippedInputStream {
    NSInputStream *_inputStream;
    z_stream _zStream;
    BOOL _needsInit;
    
    uint8_t _inBuffer[BUFFER_SIZE];
    BOOL _hasBytesAvailable;
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wall"
// NSInputStream is an abstract class cluster.
// You cannot call [super initWithURL] because it doesn't exist yet Xcode gives you warnings for not doing it. -_-
-(instancetype)initWithURL:(NSURL *)url
{
    if((self = [super init])){
        _inputStream = [[NSInputStream alloc] initWithURL:url];
        _needsInit = YES;
        _hasBytesAvailable = YES;
    }
    
    return self;
}
#pragma clang diagnostic pop

-(void)dealloc
{
    inflateEnd(&_zStream);
}

// Forward most of the methods on to the regular input stream object.
-(void)open{[_inputStream open];}
-(void)close {[_inputStream close];}
-(id<NSStreamDelegate>)delegate {return _inputStream.delegate;}
-(void)setDelegate:(id<NSStreamDelegate>)delegate {_inputStream.delegate = delegate;}
-(void)scheduleInRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {[_inputStream scheduleInRunLoop:runLoop forMode:mode];}
-(void)removeFromRunLoop:(NSRunLoop *)runLoop forMode:(NSString *)mode {[_inputStream removeFromRunLoop:runLoop forMode:mode];}
-(id)propertyForKey:(NSString *)key {return [_inputStream propertyForKey:key];}
-(BOOL)setProperty:(id)property forKey:(NSString *)key {return [_inputStream setProperty:property forKey:key];}
-(NSStreamStatus)streamStatus {return _inputStream.streamStatus;}
-(NSError *)streamError {return _inputStream.streamError;}

-(NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    _zStream.next_out = buffer;
    _zStream.avail_out = len;
    
    for(;;){
        // Check if the input buffer needs to be filled.
        if(_zStream.avail_in == 0){
            _zStream.next_in = _inBuffer;
            _zStream.avail_in = [_inputStream read:_inBuffer maxLength:BUFFER_SIZE];
        }
        
        if(_needsInit){
            // 16 + [0-15] is zlib's magic flag to tell it we are decompressing gzip and not zlib data.
            if(inflateInit2(&_zStream, 16 + 15) != Z_OK){
                CCLOG(@"zlib init error");
                _hasBytesAvailable = NO;
                goto finish;
            }
            
            _needsInit = NO;
        }
        
        // Decompress data from the input buffer.
        int result = inflate(&_zStream, Z_SYNC_FLUSH);
        switch(result){
            case Z_OK: break;
            case Z_NEED_DICT:
            case Z_DATA_ERROR:
            case Z_STREAM_ERROR:
            case Z_MEM_ERROR:
            case Z_BUF_ERROR:
                CCLOG(@"zlib read error (%d)", result);
            case Z_STREAM_END:
                _hasBytesAvailable = NO;
                goto finish;
        }
        
        // Check if the output buffer is full.
        if(_zStream.avail_out == 0){
            break;
        }
    }
    
    // Return the number of bytes read.
    finish:
    return (len - _zStream.avail_out);
}

-(BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
    return NO;
}

-(BOOL)hasBytesAvailable
{
    return _hasBytesAvailable;
}

@end


@implementation CCGZippedFile

+(Class)inputStreamClass
{
    return [CCGZippedInputStream class];
}

-(NSData *)loadData
{
    NSInputStream *stream = [self openInputStream];
    
    NSMutableData *data = [NSMutableData dataWithLength:BUFFER_SIZE];
    NSUInteger totalBytesRead = 0;
    
    for(;;){
        totalBytesRead += [stream read:data.mutableBytes + totalBytesRead maxLength:data.length - totalBytesRead];
        
        if(stream.hasBytesAvailable){
            [data increaseLengthBy:data.length*0.5];
        } else {
            break;
        }
    }
    
    [stream close];
    
    data.length = totalBytesRead;
    return data;
}

@end
