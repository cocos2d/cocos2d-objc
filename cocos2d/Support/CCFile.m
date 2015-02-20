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

#import "CCFile_Private.h"


#pragma mark Wrapped Streams

#define BUFFER_SIZE 32*1024

@implementation CCWrappedInputStream {
    @protected
    NSInputStream *_inputStream;
    BOOL _hasBytesAvailable;
    
    NSError *_error;
}

// Make the designated initializer warnings go away.
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wall"
-(instancetype)initWithInputStream:(NSInputStream *)inputStream
{
    if((self = [super init])){
        _inputStream = inputStream;
        _hasBytesAvailable = YES;
    }
    
    return self;
}
#pragma clang diagnostic pop

-(instancetype)initWithURL:(NSURL *)url
{
    return [self initWithInputStream:[NSInputStream inputStreamWithURL:url]];
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

-(NSStreamStatus)streamStatus {
    if(_error){
        return NSStreamStatusError;
    } else {
        return _inputStream.streamStatus;
    }
}

-(NSError *)streamError {
    return (_error ?: _inputStream.streamError);
}

-(BOOL)getBuffer:(uint8_t **)buffer length:(NSUInteger *)len
{
    return NO;
}

-(BOOL)hasBytesAvailable
{
    return _hasBytesAvailable;
}

-(NSData *)loadDataWithSizeHint:(NSUInteger)sizeHint error:(NSError **)error;
{
    NSMutableData *data = [NSMutableData dataWithLength:(sizeHint ?: BUFFER_SIZE)];
    NSUInteger totalBytesRead = 0;
    
    for(;;){
        totalBytesRead += [self read:data.mutableBytes + totalBytesRead maxLength:data.length - totalBytesRead];
        if(!self.hasBytesAvailable) break;
        
        [data increaseLengthBy:data.length*0.5];
    }
    
    if(self.streamStatus == NSStreamStatusError){
        CCLOG(@"Error loading compressed data: %@", self.streamError);
        if(error) *error = self.streamError;
    }
    
    data.length = totalBytesRead;
    return data;
}

@end


@implementation CCGZippedInputStream {
    z_stream _zStream;
    BOOL _needsInit;
    
    uint8_t _inBuffer[BUFFER_SIZE];
}

-(instancetype)initWithInputStream:(NSInputStream *)inputStream
{
    if((self = [super initWithInputStream:inputStream])){
        _needsInit = YES;
    }
    
    return self;
}

-(void)dealloc
{
    inflateEnd(&_zStream);
}

-(NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    _zStream.next_out = buffer;
    _zStream.avail_out = (unsigned int)len;
    
    for(;;){
        // Check if the input buffer needs to be filled.
        if(_zStream.avail_in == 0){
            _zStream.next_in = _inBuffer;
            _zStream.avail_in = (unsigned int)[_inputStream read:_inBuffer maxLength:BUFFER_SIZE];
        }
        
        if(_needsInit){
            // 32 + [0-15] is zlib's magic flag to tell it we want to automatically detect gzip/zlib data.
            int result = inflateInit2(&_zStream, 32 + 15);
            if(result != Z_OK){
                _error = [[NSError alloc] initWithDomain:@"ZLib Error" code:result userInfo:@{
                    NSLocalizedDescriptionKey: [NSString stringWithFormat:@"ZLib failed to initialize (%d)", result],
                }];
                CCLOG(@"%@", _error);
                
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
                _error = [[NSError alloc] initWithDomain:@"ZLib Error" code:result userInfo:@{
                    NSLocalizedDescriptionKey: [NSString stringWithFormat:@"ZLib decompression error (%d)", result],
                }];
                CCLOG(@"%@", _error);
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

@end


static uint32_t CCFILE_ENCRYPTION_KEY[4] = {};

// Block size in 4 byte words.
#define BLOCK_SIZE 1024

@implementation CCEncryptedInputStream {
    // Most recently decompressed block.
    uint8_t _buffer[BLOCK_SIZE*4];
    
    // Pointer to the next available byte in the current block.
    uint8_t *_readCursor;
    
    // How many remaining bytes are available in the current block.
    NSUInteger _availableBytes;
    
    // YES when the stream runs out of compressed blocks to read.
    BOOL _eof;
}

// Public domain XXTEA algorithm
// Source http://en.wikipedia.org/wiki/XXTEA
#define DELTA 0x9e3779b9
#define MX (((z>>5^y<<2) + (y>>3^z<<4)) ^ ((sum^y) + (key[(p&3)^e] ^ z)))
static void TEA_decrypt(uint32_t *v, int n, uint32_t const key[4]) {
    uint32_t y, z, sum;
    unsigned p, rounds, e;
	rounds = 6 + 52/n;
	sum = rounds*DELTA;
	y = v[0];
	do {
		e = (sum >> 2) & 3;
		for (p=n-1; p>0; p--) {
			z = v[p-1];
			y = v[p] -= MX;
		}
		z = v[n-1];
		y = v[0] -= MX;
		sum -= DELTA;
	} while (--rounds);
}

// The first word of each block is the block's length.
// All blocks except the last should be 4*(BLOCK_SIZE - 1) in length.
-(void)readBlock
{
    NSUInteger bytesPerBlock = BLOCK_SIZE*4;
    NSUInteger bytesRead = [_inputStream read:_buffer maxLength:bytesPerBlock];
    
    if(bytesRead != bytesPerBlock){
        _error = [[NSError alloc] initWithDomain:@"CCFile Encryption Error" code:0 userInfo:@{
            NSLocalizedDescriptionKey: @"Error reading encrypted file: Truncated stream.",
        }];
        CCLOG(@"%@", _error);
        goto fail;
    }
    
    // TODO Should this handle endian swapping?
    uint32_t *buff = (uint32_t *)_buffer;
    TEA_decrypt(buff, BLOCK_SIZE, CCFILE_ENCRYPTION_KEY);
    
    // The size of each block in bytes is stored in the first word.
    _availableBytes = buff[0];
    _readCursor = (uint8_t *)(buff + 1);
    
    // 0 for a full block, negative for the final block, positive for a corrupt block.
    NSInteger compare = _availableBytes - (bytesPerBlock - 4);
    if(compare < 0){
       _eof = YES; 
    } else if(compare > 0){
        _error = [[NSError alloc] initWithDomain:@"CCFile Encryption Error" code:0 userInfo:@{
            NSLocalizedDescriptionKey: @"Error reading encrypted file: Corrupt stream.",
        }];
        CCLOG(@"%@", _error);
        goto fail;
    }
    
    return;
    
    fail:
    _availableBytes = 0;
    _eof = YES;
}

-(NSInteger)read:(uint8_t *)buffer maxLength:(NSUInteger)len
{
    NSUInteger readBytes = 0;
    
    while(readBytes < len){
        if(_availableBytes == 0){
            if(_eof){
                // No more compressed data to read.
                _hasBytesAvailable = NO;
                goto finish;
            } else {
                [self readBlock];
            }
        }
        
        NSUInteger bytesToRead = MIN(len - readBytes, _availableBytes);
        memcpy(buffer + readBytes, _readCursor, bytesToRead);
        
        readBytes += bytesToRead;
        _readCursor += bytesToRead;
        _availableBytes -= bytesToRead;
    }
    
    finish:
    return readBytes;
}

@end


@interface CCEncryptedGZippedInputStream : CCGZippedInputStream @end
@implementation CCEncryptedGZippedInputStream

-(instancetype)initWithURL:(NSURL *)url
{
    return [self initWithInputStream:[CCEncryptedInputStream inputStreamWithURL:url]];
}

@end

//MARK CCFileCGDataProvider

@implementation CCStreamedImageSource{
    CCStreamedImageSourceStreamBlock _streamBlock;
    NSInputStream *_inputStream;
}

-(instancetype)initWithStreamBlock:(CCStreamedImageSourceStreamBlock)streamBlock
{
    if((self = [super init])){
        _streamBlock = streamBlock;
    }
    
    return self;
}

-(NSInputStream *)inputStream
{
    if(_inputStream == nil){
        _inputStream = _streamBlock();
    }
    
    return _inputStream;
}

static size_t
DataProviderGetBytesCallback(void *info, void *buffer, size_t count)
{
    CCStreamedImageSource *provider = (__bridge CCStreamedImageSource *)info;
    return [provider.inputStream read:buffer maxLength:count];
}

static off_t
DataProviderSkipForwardCallback(void *info, off_t count)
{
    CCStreamedImageSource *provider = (__bridge CCStreamedImageSource *)info;
    
    // Skip forward in 32 kb chunks.
    const NSUInteger bufferSize = 32*1024;
    uint8_t buffer[bufferSize];
    
    NSUInteger skipped = 0;
    while(skipped < count){
        NSUInteger skip = MIN(bufferSize, (NSUInteger)count - skipped);
        skipped += [provider.inputStream read:buffer maxLength:skip];
        if(!provider.inputStream.hasBytesAvailable) break;
    }
    
    return skipped;
}

static void
DataProviderRewindCallback(void *info)
{
    CCStreamedImageSource *provider = (__bridge CCStreamedImageSource *)info;
    [provider->_inputStream close];
    provider->_inputStream = nil;
}

static void
DataProviderReleaseInfoCallback(void *info)
{
    //Close and discard the current input stream.
    DataProviderRewindCallback(info);
    
    CFRelease(info);
}

static const CGDataProviderSequentialCallbacks callbacks = {
    .version = 0,
    .getBytes = DataProviderGetBytesCallback,
    .skipForward = DataProviderSkipForwardCallback,
    .rewind = DataProviderRewindCallback,
    .releaseInfo = DataProviderReleaseInfoCallback,
};

-(CGDataProviderRef)createCGDataProvider
{
    return CGDataProviderCreateSequential((__bridge_retained void *)self, &callbacks);
}

-(CGImageSourceRef)createCGImageSource
{
    CGDataProviderRef provider = [self createCGDataProvider];
    CGImageSourceRef source = CGImageSourceCreateWithDataProvider(provider, NULL);
    
    CGDataProviderRelease(provider);
    return source;
}

@end

#pragma mark CCFile

@implementation CCFile {
    Class _inputStreamClass;
    BOOL _loadDataFromStream;
}

+(void)setEncryptionKey:(NSString *)key
{
    [[NSScanner scannerWithString:[key substringWithRange:NSMakeRange( 0, 8)]] scanHexInt:CCFILE_ENCRYPTION_KEY + 0];
    [[NSScanner scannerWithString:[key substringWithRange:NSMakeRange( 8, 8)]] scanHexInt:CCFILE_ENCRYPTION_KEY + 1];
    [[NSScanner scannerWithString:[key substringWithRange:NSMakeRange(16, 8)]] scanHexInt:CCFILE_ENCRYPTION_KEY + 2];
    [[NSScanner scannerWithString:[key substringWithRange:NSMakeRange(24, 8)]] scanHexInt:CCFILE_ENCRYPTION_KEY + 3];
}

-(instancetype)initWithName:(NSString *)name url:(NSURL *)url contentScale:(CGFloat)contentScale
{
    if((self = [super init])){
        _name = [name copy];
        _url = [url copy];
        _contentScale = contentScale;
        
        if([url.lastPathComponent hasSuffix:@".gz.ccp"]){
            _inputStreamClass = [CCEncryptedGZippedInputStream class];
            _loadDataFromStream = YES;
        } else if([url.lastPathComponent hasSuffix:@".ccp"]){
            _inputStreamClass = [CCEncryptedInputStream class];
            _loadDataFromStream = YES;
        } else if([url.lastPathComponent hasSuffix:@".gz"]){
            _inputStreamClass = [CCGZippedInputStream class];
            _loadDataFromStream = YES;
        } else {
            _inputStreamClass = [NSInputStream class];
            _loadDataFromStream = NO;
        }
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

-(NSInputStream *)openInputStream
{
    NSInputStream *stream = [_inputStreamClass inputStreamWithURL:self.url];
    
    if(stream == nil){
        CCLOG(@"Error opening stream for %@", self.name);
    }
    
    [stream open];
    return stream;
}

-(id)loadPlist:(NSError *__autoreleasing *)error
{
    NSInputStream *stream = [self openInputStream];
    id plist = [NSPropertyListSerialization propertyListWithStream:stream options:0 format:NULL error:error];
    
    [stream close];
    
    if(error && *error){
        CCLOG(@"Error reading property list from %@: %@", self.name, *error);
        return nil;
    } else {
        return plist;
    }
}

-(NSData *)loadData:(NSError *__autoreleasing *)error
{
    if(_loadDataFromStream){
       CCWrappedInputStream *stream = (CCWrappedInputStream *)[self openInputStream];
       NSData *data = [stream loadDataWithSizeHint:0 error:error];
       [stream close];
       
        return data; 
    } else {
        NSData *data = [NSData dataWithContentsOfURL:_url options:NSDataReadingMappedIfSafe error:error];
        
        if(error && *error){
            CCLOG(@"Error reading data from from %@: %@", self.name, *error);
            return nil;
        } else {
            return data;
        }
    }
}

-(NSString *)loadString:(NSError **)error;
{
    return [[NSString alloc] initWithData:[self loadData:error] encoding:NSUTF8StringEncoding];
}

-(CGImageSourceRef)createCGImageSource
{
    if(_loadDataFromStream){
        CCStreamedImageSource *source = [[CCStreamedImageSource alloc] initWithStreamBlock:^{return [self openInputStream];}];
        return [source createCGImageSource];
    } else {
        return CGImageSourceCreateWithURL((__bridge CFURLRef)self.url, NULL);
    }
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; Absolute path: '%@', UIScale: %d, scale %.2f>", [self class], (void *) self, self.absoluteFilePath, _useUIScale, _contentScale];
}

@end
