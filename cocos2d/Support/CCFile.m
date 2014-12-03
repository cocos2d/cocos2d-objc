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


#import "CCFile.h"


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

-(NSInputStream *)openInputStream
{
    NSInputStream *stream = [NSInputStream inputStreamWithURL:_url];
    
    if(stream == nil){
        CCLOG(@"Error opening stream for %@", _name);
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
        CCLOG(@"Error reading property list from %@: %@", _name, err);
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
        CCLOG(@"Error reading data from from %@: %@", _name, err);
        return nil;
    } else {
        return data;
    }
}

@end
