/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2012 Zynga Inc.
 * Copyright (c) 2013 Apportable Inc.
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

#import "CCBReader.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "CCBAnimationManager.h"
#import "CCBSequence.h"
#import "CCBSequenceProperty.h"
#import "CCBKeyframe.h"
#import "CCBLocalizationManager.h"
#import "CCBReader_Private.h"

#ifdef CCB_ENABLE_UNZIP
#import "SSZipArchive.h"
#endif


@interface CCBFile : CCNode
{
    CCNode* ccbFile;
}
@property (nonatomic,strong) CCNode* ccbFile;
@end



@implementation CCBReader

@synthesize animationManager;

+ (void) configureCCFileUtils
{
    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    
    // Setup file utils for use with SpriteBuilder
    [sharedFileUtils setEnableiPhoneResourcesOniPad:NO];
    
    sharedFileUtils.directoriesDict =
    [[NSMutableDictionary alloc] initWithObjectsAndKeys:
     @"resources-tablet", CCFileUtilsSuffixiPad,
     @"resources-tablethd", CCFileUtilsSuffixiPadHD,
     @"resources-phone", CCFileUtilsSuffixiPhone,
     @"resources-phonehd", CCFileUtilsSuffixiPhoneHD,
     @"resources-phone", CCFileUtilsSuffixiPhone5,
     @"resources-phonehd", CCFileUtilsSuffixiPhone5HD,
     @"", CCFileUtilsSuffixDefault,
     nil];
    
    sharedFileUtils.searchPath =
    [NSArray arrayWithObjects:
     [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Published-iOS"],
     [[NSBundle mainBundle] resourcePath],
     nil];
    
	sharedFileUtils.enableiPhoneResourcesOniPad = YES;
    sharedFileUtils.searchMode = CCFileUtilsSearchModeDirectory;
    [sharedFileUtils buildSearchResolutionsOrder];
    
    [sharedFileUtils loadFilenameLookupDictionaryFromFile:@"fileLookup.plist"];
    [[CCSpriteFrameCache sharedSpriteFrameCache] loadSpriteFrameLookupDictionaryFromFile:@"spriteFrameFileList.plist"];
}

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    // Setup action manager
    self.animationManager = [[CCBAnimationManager alloc] init];
    
    // Setup set of loaded sprite sheets
    loadedSpriteSheets = [[NSMutableSet alloc] init];
    
    // Setup resolution scale and default container size
    animationManager.rootContainerSize = [CCDirector sharedDirector].designSize;
    
    return self;
}

- (void) dealloc
{
    bytes = NULL;
}

static inline unsigned char readByte(CCBReader *self)
{
    unsigned char byte = self->bytes[self->currentByte];
    self->currentByte++;
    return byte;
}

static inline BOOL readBool(CCBReader *self)
{
    return (BOOL)readByte(self);
}

static inline NSString *readUTF8(CCBReader *self)
{
    int b0 = readByte(self);
    int b1 = readByte(self);
    
    int numBytes = b0 << 8 | b1;
    
    NSString* str = [[NSString alloc] initWithBytes:self->bytes+self->currentByte length:numBytes encoding:NSUTF8StringEncoding];
    
    self->currentByte += numBytes;
    
    return str;
}

static inline BOOL getBit(CCBReader *self)
{
    BOOL bit;
    unsigned char byte = *(self->bytes+self->currentByte);
    if (byte & (1 << self->currentBit)) bit = YES;
    else bit = NO;
    
    self->currentBit++;
    if (self->currentBit >= 8)
    {
        self->currentBit = 0;
        self->currentByte++;
    }
    
    return bit;
}

static inline void alignBits(CCBReader *self)
{
    if (self->currentBit)
    {
        self->currentBit = 0;
        self->currentByte++;
    }
}

#define REVERSE_BYTE(b) (unsigned char)(((b * 0x0802LU & 0x22110LU) | (b * 0x8020LU & 0x88440LU)) * 0x10101LU >> 16)

static inline int readIntWithSign(CCBReader *self, BOOL sign)
{
    // Good luck groking this!
    // The basic idea is to do as little bit reading as possible and use everything in a byte contexts and avoid loops; espc ones that iterate 8 * bytes-read
    // Note: this implementation is NOT the same encoding concept as the standard Elias Gamma, instead the real encoding is a byte flipped version of it.
    // In order to optimize to little-endian devices, we have chosen to unflip the bytes before transacting upon them (excluding of course the "leading" zeros.
    
    unsigned int v = *(unsigned int *)(self->bytes + self->currentByte);
    int numBits = 32;
    int extraByte = 0;
    v &= -((int)v);
    if (v) numBits--;
    if (v & 0x0000FFFF) numBits -= 16;
    if (v & 0x00FF00FF) numBits -= 8;
    if (v & 0x0F0F0F0F) numBits -= 4;
    if (v & 0x33333333) numBits -= 2;
    if (v & 0x55555555) numBits -= 1;
    
    if ((numBits & 0x00000007) == 0)
    {
        extraByte = 1;
        self->currentBit = 0;
        self->currentByte += (numBits >> 3);
    }
    else
    {
        self->currentBit = numBits - (numBits >> 3) * 8;
        self->currentByte += (numBits >> 3);
    }
    
    static char prefixMask[] = {
        0xFF,
        0x7F,
        0x3F,
        0x1F,
        0x0F,
        0x07,
        0x03,
        0x01,
    };
    static unsigned int suffixMask[] = {
        0x00,
        0x80,
        0xC0,
        0xE0,
        0xF0,
        0xF8,
        0xFC,
        0xFE,
        0xFF,
    };
    unsigned char prefix = REVERSE_BYTE(*(self->bytes + self->currentByte)) & prefixMask[self->currentBit];
    long long current = prefix;
    int numBytes = 0;
    int suffixBits = (numBits - (8 - self->currentBit) + 1);
    if (numBits >= 8)
    {
        suffixBits %= 8;
        numBytes = (numBits - (8 - (int)(self->currentBit)) - suffixBits + 1) / 8;
    }
    if (suffixBits >= 0)
    {
        self->currentByte++;
        for (int i = 0; i < numBytes; i++)
        {
            current <<= 8;
            unsigned char byte = REVERSE_BYTE(*(self->bytes + self->currentByte));
            current += byte;
            self->currentByte++;
        }
        current <<= suffixBits;
        unsigned char suffix = (REVERSE_BYTE(*(self->bytes + self->currentByte)) & suffixMask[suffixBits]) >> (8 - suffixBits);
        current += suffix;
    }
    else
    {
        current >>= -suffixBits;
    }
    self->currentByte += extraByte;
    int num;
    
    if (sign)
    {
        int s = current % 2;
        if (s)
        {
            num = (int)(current / 2);
        }
        else
        {
            num = (int)(-current / 2);
        }
    }
    else
    {
        num = (int)current - 1;
    }
    
    alignBits(self);
    
    return num;
}

static inline float readFloat(CCBReader *self)
{
    unsigned char type = readByte(self);
    
    if (type == kCCBFloat0) return 0;
    else if (type == kCCBFloat1) return 1;
    else if (type == kCCBFloatMinus1) return -1;
    else if (type == kCCBFloat05) return 0.5f;
    else if (type == kCCBFloatInteger)
    {
        return readIntWithSign(self, YES);
    }
    else
    {
        volatile union {
            float f;
            int i;
        } t;
        t.i = *(int *)(self->bytes + self->currentByte);
        self->currentByte+=4;
        return t.f;
    }
}

- (NSString*) readCachedString
{
    int n = readIntWithSign(self, NO);
    return [stringCache objectAtIndex:n];
}

- (void) readPropertyForNode:(CCNode*) node parent:(CCNode*)parent isExtraProp:(BOOL)isExtraProp
{
    // Read type and property name
    int type = readIntWithSign(self, NO);
    NSString* name = [self readCachedString];
    
    // Check if the property can be set for this platform
    BOOL setProp = YES;
    
    // Forward properties for sub ccb files
    if ([node isKindOfClass:[CCBFile class]])
    {
        CCBFile* ccbNode = (CCBFile*) node;
        if (ccbNode.ccbFile && isExtraProp)
        {
            node = ccbNode.ccbFile;
            
            // Skip properties that doesn't have a value to override
            NSSet* extraPropsNames = node.userObject;
            setProp &= [extraPropsNames containsObject:name];
        }
    }
    else if (isExtraProp && node == animationManager.rootNode)
    {
        NSMutableSet* extraPropNames = node.userObject;
        if (!extraPropNames)
        {
            extraPropNames = [NSMutableSet set];
            node.userObject = extraPropNames;
        }
        
        [extraPropNames addObject:name];
    }
    
    if (type == kCCBPropTypePosition)
    {
        float x = readFloat(self);
        float y = readFloat(self);
        int corner = readByte(self);
        int xUnit = readByte(self);
        int yUnit = readByte(self);

        if (setProp)
        {
#ifdef __CC_PLATFORM_IOS
            [node setValue:[NSValue valueWithCGPoint:ccp(x,y)] forKey:name];
#elif defined (__CC_PLATFORM_MAC)
            [node setValue:[NSValue valueWithPoint:ccp(x,y)] forKey:name];
#endif
            CCPositionType pType = CCPositionTypeMake(xUnit, yUnit, corner);
            [node setValue:[NSValue valueWithBytes:&pType objCType:@encode(CCPositionType)] forKey:[name stringByAppendingString:@"Type"]];
            
            
            if ([animatedProps containsObject:name])
            {
                id baseValue = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:x],
                                [NSNumber numberWithFloat:y],
                                [NSNumber numberWithInt:corner],
                                [NSNumber numberWithInt:xUnit],
                                [NSNumber numberWithInt:yUnit],
                                nil];
                [animationManager setBaseValue:baseValue forNode:node propertyName:name];
            }
        }
    }
    else if(type == kCCBPropTypePoint
            || type == kCCBPropTypePointLock)
    {
        float x = readFloat(self);
        float y = readFloat(self);
        
        if (setProp)
        {
            CGPoint pt = ccp(x,y);
#ifdef __CC_PLATFORM_IOS
            [node setValue:[NSValue valueWithCGPoint:pt] forKey:name];
#else
            [node setValue:[NSValue valueWithPoint:NSPointFromCGPoint(pt)] forKey:name];
#endif
        }
    }
    else if (type == kCCBPropTypeSize)
    {
        float w = readFloat(self);
        float h = readFloat(self);
        int xUnit = readByte(self);
        int yUnit = readByte(self);
        
        if (setProp)
        {
            CGSize size = CGSizeMake(w, h);
#ifdef __CC_PLATFORM_IOS
            [node setValue:[NSValue valueWithCGSize:size] forKey:name];
#elif defined (__CC_PLATFORM_MAC)
            [node setValue:[NSValue valueWithSize:size] forKey:name];
#endif
            
            CCSizeType sizeType = CCSizeTypeMake(xUnit, yUnit);
            [node setValue:[NSValue valueWithBytes:&sizeType objCType:@encode(CCSizeType)] forKey:[name stringByAppendingString:@"Type"]];
        }
    }
    else if (type == kCCBPropTypeScaleLock)
    {
        float x = readFloat(self);
        float y = readFloat(self);
        int sType = readByte(self);
        
        if (setProp)
        {
            [node setValue:[NSNumber numberWithFloat:x] forKey:[name stringByAppendingString:@"X"]];
            [node setValue:[NSNumber numberWithFloat:y] forKey:[name stringByAppendingString:@"Y"]];
            [node setValue:[NSNumber numberWithInt:sType] forKey:[name stringByAppendingString:@"Type"]];
            
            if ([animatedProps containsObject:name])
            {
                id baseValue = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:x],
                                [NSNumber numberWithFloat:y],
                                [NSNumber numberWithInt:sType],
                                nil];
                [animationManager setBaseValue:baseValue forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeFloatXY)
    {
        float xFloat = readFloat(self);
        float yFloat = readFloat(self);
        
        if (setProp)
        {
            NSString* nameX = [NSString stringWithFormat:@"%@X",name];
            NSString* nameY = [NSString stringWithFormat:@"%@Y",name];
            [node setValue:[NSNumber numberWithFloat:xFloat] forKey:nameX];
            [node setValue:[NSNumber numberWithFloat:yFloat] forKey:nameY];
        }
    }
    else if (type == kCCBPropTypeDegrees
             || type == kCCBPropTypeFloat)
    {
        float f = readFloat(self);
        
        if (setProp)
        {
            id value = [NSNumber numberWithFloat:f];
            [node setValue:value forKey:name];
            
            if ([animatedProps containsObject:name])
            {
                [animationManager setBaseValue:value forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeFloatScale)
    {
        float f = readFloat(self);
        int sType = readIntWithSign(self, NO);
        
        if (setProp)
        {
            if (sType == 1) f *= [CCDirector sharedDirector].UIScaleFactor;
            [node setValue:[NSNumber numberWithFloat:f] forKey:name];
        }
    }
    else if (type == kCCBPropTypeInteger
             || type == kCCBPropTypeIntegerLabeled)
    {
        int d = readIntWithSign(self, YES);
        
        if (setProp)
        {
            [node setValue:[NSNumber numberWithInt:d] forKey:name];
        }
    }
    else if (type == kCCBPropTypeFloatVar)
    {
        float f = readFloat(self);
        float fVar = readFloat(self);
        
        if (setProp)
        {
            NSString* nameVar = [NSString stringWithFormat:@"%@Var",name];
            [node setValue:[NSNumber numberWithFloat:f] forKey:name];
            [node setValue:[NSNumber numberWithFloat:fVar] forKey:nameVar];
        }
    }
    else if (type == kCCBPropTypeCheck)
    {
        BOOL b = readBool(self);
        
        if (setProp)
        {
            id value = [NSNumber numberWithBool:b];
            [node setValue:value forKey:name];
            
            if ([animatedProps containsObject:name])
            {
                [animationManager setBaseValue:value forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeSpriteFrame)
    {
        NSString* spriteFile = [self readCachedString];
        
        if (setProp && ![spriteFile isEqualToString:@""])
        {
            CCSpriteFrame* spriteFrame = [CCSpriteFrame frameWithImageNamed:spriteFile];
            [node setValue:spriteFrame forKey:name];
            
            if ([animatedProps containsObject:name])
            {
                [animationManager setBaseValue:spriteFrame forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeTexture)
    {
        NSString* spriteFile = [self readCachedString];
        
        if (setProp && ![spriteFile isEqualToString:@""])
        {
            CCTexture* texture = [CCTexture textureWithFile:spriteFile];
            [node setValue:texture forKey:name];
        }
    }
    else if (type == kCCBPropTypeByte)
    {
        int byte = readByte(self);
        
        if (setProp)
        {
            id value = [NSNumber numberWithInt:byte];
            [node setValue:value forKey:name];
            
            if ([animatedProps containsObject:name])
            {
                [animationManager setBaseValue:value forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeColor4 ||
             type == kCCBPropTypeColor3)
    {
        CGFloat r = readFloat(self);
        CGFloat g = readFloat(self);
        CGFloat b = readFloat(self);
        CGFloat a = readFloat(self);
        
        if (setProp)
        {
            CCColor* cVal = [CCColor colorWithRed:r green:g blue:b alpha:a];
            
            [node setValue:cVal forKey:name];
            
            if ([animatedProps containsObject:name])
            {
                [animationManager setBaseValue:cVal forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeColor4FVar)
    {
        float r = readFloat(self);
        float g = readFloat(self);
        float b = readFloat(self);
        float a = readFloat(self);
        float rVar = readFloat(self);
        float gVar = readFloat(self);
        float bVar = readFloat(self);
        float aVar = readFloat(self);
        
        if (setProp)
        {
            CCColor* cVal = [CCColor colorWithRed:r green:g blue:b alpha:a];;
            CCColor* cVarVal = [CCColor colorWithRed:rVar green:gVar blue:bVar alpha:aVar];
            NSString* nameVar = [NSString stringWithFormat:@"%@Var",name];
            [node setValue:cVal forKey:name];
            [node setValue:cVarVal forKey:nameVar];
        }
    }
    else if (type == kCCBPropTypeFlip)
    {
        BOOL xFlip = readBool(self);
        BOOL yFlip = readBool(self);
        
        if (setProp)
        {
            NSString* nameX = [NSString stringWithFormat:@"%@X",name];
            NSString* nameY = [NSString stringWithFormat:@"%@Y",name];
            [node setValue:[NSNumber numberWithBool:xFlip] forKey:nameX];
            [node setValue:[NSNumber numberWithBool:yFlip] forKey:nameY];
        }
    }
    else if (type == kCCBPropTypeBlendmode)
    {
        int src = readIntWithSign(self, NO);
        int dst = readIntWithSign(self, NO);
        
        if (setProp)
        {
            ccBlendFunc blend;
            blend.src = src;
            blend.dst = dst;
            NSValue* blendVal = [NSValue value:&blend withObjCType:@encode(ccBlendFunc)];
            [node setValue:blendVal forKey:name];
        }
    }
    else if (type == kCCBPropTypeFntFile)
    {
        NSString* fntFile = [self readCachedString];
        [node setValue:fntFile forKey:name];
    }
    else if (type == kCCBPropTypeText
             || type == kCCBPropTypeString)
    {
        NSString* txt = [self readCachedString];
        BOOL localized = readBool(self);
        
        if (localized)
        {
            txt = CCBLocalize(txt);
        }
        
        if (setProp)
        {
            [node setValue:txt forKey:name];
        }
    }
    else if (type == kCCBPropTypeFontTTF)
    {
        NSString* fnt = [self readCachedString];
        
        if (setProp)
        {
            //if ([[fnt lowercaseString] hasSuffix:@".ttf"])
            //{
            //    fnt = [[fnt lastPathComponent] stringByDeletingPathExtension];
            //}
            [node setValue:fnt forKey:name];
        }
    }
    else if (type == kCCBPropTypeBlock)
    {
        NSString* selectorName = [self readCachedString];
        int selectorTarget = readIntWithSign(self, NO);
        
        if (setProp)
        {
            // Objective C callbacks
            if (selectorTarget)
            {
                id target = NULL;
                if (selectorTarget == kCCBTargetTypeDocumentRoot) target = animationManager.rootNode;
                else if (selectorTarget == kCCBTargetTypeOwner) target = owner;
                
                if (target)
                {
                    SEL selector = NSSelectorFromString(selectorName);
                    __unsafe_unretained id t = target;
                    
                    void (^block)(id sender);
                    block = ^(id sender) {
                        typedef void (*Func)(id, SEL, id);
                        ((Func)objc_msgSend)(t, selector, sender);
                    };
                    
                    NSString* setSelectorName = [NSString stringWithFormat:@"set%@:",[name capitalizedString]];
                    SEL setSelector = NSSelectorFromString(setSelectorName);
                    
                    if ([node respondsToSelector:setSelector])
                    {
                        typedef void (*Func)(id, SEL, id);
                        ((Func)objc_msgSend)(node, setSelector, block);
                    }
                    else
                    {
                        NSLog(@"CCBReader: Failed to set selector/target block for %@",selectorName);
                    }
                }
                else
                {
                    NSLog(@"CCBReader: Failed to find target for block");
                }
            }
        }
    }
    else if (type == kCCBPropTypeCCBFile)
    {
        NSString* ccbFileName = [self readCachedString];
        
        // Change path extension to .ccbi
        if ([ccbFileName hasSuffix:@".ccb"]) ccbFileName = [ccbFileName stringByDeletingPathExtension];
        
        ccbFileName = [NSString stringWithFormat:@"%@.ccbi", ccbFileName];
        
        // Load sub file
        NSString* path = [[CCFileUtils sharedFileUtils] fullPathForFilename:ccbFileName];
        NSData* d = [NSData dataWithContentsOfFile:path];

        NSAssert(d,@"Failed to find ccb file: %@",ccbFileName);

        CCBReader* reader = [[CCBReader alloc] init];
        reader.animationManager.rootContainerSize = parent.contentSize;
        
        // Setup byte array & owner
        reader->data = d;
        reader->bytes = (unsigned char*)[d bytes];
        reader->currentByte = 0;
        reader->currentBit = 0;
        
        reader->owner = owner;
        
        reader.animationManager.owner = owner;
        
        CCNode* ccbFile = [reader readFileWithCleanUp:NO actionManagers:actionManagers];
        
        if (ccbFile && reader.animationManager.autoPlaySequenceId != -1)
        {
            // Auto play animations
            [reader.animationManager runAnimationsForSequenceId:reader.animationManager.autoPlaySequenceId tweenDuration:0];
        }
        
        if (setProp)
        {
            [node setValue:ccbFile forKey:name];
        }
    }
    else
    {
        NSLog(@"CCBReader: Failed to read property type %d",type);
    }
}

- (CCBKeyframe*) readKeyframeOfType:(int)type
{
    CCBKeyframe* keyframe = [[CCBKeyframe alloc] init];
    
    keyframe.time = readFloat(self);
    
    int easingType = readIntWithSign(self, NO);
    float easingOpt = 0;
    id value = NULL;
    
    if (easingType == kCCBKeyframeEasingCubicIn
        || easingType == kCCBKeyframeEasingCubicOut
        || easingType == kCCBKeyframeEasingCubicInOut
        || easingType == kCCBKeyframeEasingElasticIn
        || easingType == kCCBKeyframeEasingElasticOut
        || easingType == kCCBKeyframeEasingElasticInOut)
    {
        easingOpt = readFloat(self);
    }
    keyframe.easingType = easingType;
    keyframe.easingOpt = easingOpt;
    
    if (type == kCCBPropTypeCheck)
    {
        value = [NSNumber numberWithBool:readBool(self)];
    }
    else if (type == kCCBPropTypeByte)
    {
        value = [NSNumber numberWithInt:readBool(self)];
    }
    else if (type == kCCBPropTypeColor3)
    {
        CGFloat r = readFloat(self);
        CGFloat g = readFloat(self);
        CGFloat b = readFloat(self);
        CGFloat a = readFloat(self);
        
        value = [CCColor colorWithRed:r green:g blue:b alpha:a];
    }
    else if (type == kCCBPropTypeDegrees || type == kCCBPropTypeFloat)
    {
        value = [NSNumber numberWithFloat:readFloat(self)];
    }
    else if (type == kCCBPropTypeScaleLock
             || type == kCCBPropTypePosition
             || type == kCCBPropTypeFloatXY)
    {
        float a = readFloat(self);
        float b = readFloat(self);
        
        value = [NSArray arrayWithObjects:
                 [NSNumber numberWithFloat:a],
                 [NSNumber numberWithFloat:b],
                 nil];
    }
    else if (type == kCCBPropTypeSpriteFrame)
    {
        NSString* spriteFile = [self readCachedString];
        
        CCSpriteFrame* spriteFrame = [CCSpriteFrame frameWithImageNamed:spriteFile];
        
        value = spriteFrame;
    }
    
    keyframe.value = value;
    
    return  keyframe;
}

- (void) didLoadFromCCB
{}

- (CCNode*) readNodeGraphParent:(CCNode*)parent
{
    // Read class
    NSString* className = [self readCachedString];
    
    // Read assignment type and name
    int memberVarAssignmentType = readIntWithSign(self, NO);
    NSString* memberVarAssignmentName = NULL;
    if (memberVarAssignmentType)
    {
        memberVarAssignmentName = [self readCachedString];
    }
    
    Class class = NSClassFromString(className);
    if (!class)
    {
        NSAssert(false,@"CCBReader: Could not create class of type %@",className);
        return NULL;
    }
    CCNode* node = [[class alloc] init];
    
    // Set root node
    if (!animationManager.rootNode) animationManager.rootNode = node;
    
    // Read animated properties
    NSMutableDictionary* seqs = [NSMutableDictionary dictionary];
    animatedProps = [[NSMutableSet alloc] init];
    
    int numSequences = readIntWithSign(self, NO);
    for (int i = 0; i < numSequences; i++)
    {
        int seqId = readIntWithSign(self, NO);
        NSMutableDictionary* seqNodeProps = [NSMutableDictionary dictionary];
        
        int numProps = readIntWithSign(self, NO);
        
        for (int j = 0; j < numProps; j++)
        {
            CCBSequenceProperty* seqProp = [[CCBSequenceProperty alloc] init];
            
            seqProp.name = [self readCachedString];
            seqProp.type = readIntWithSign(self, NO);
            [animatedProps addObject:seqProp.name];
            
            int numKeyframes = readIntWithSign(self, NO);
            
            for (int k = 0; k < numKeyframes; k++)
            {
                CCBKeyframe* keyframe = [self readKeyframeOfType:seqProp.type];
                
                [seqProp.keyframes addObject:keyframe];
            }
            
            [seqNodeProps setObject:seqProp forKey:seqProp.name];
        }
        
        [seqs setObject:seqNodeProps forKey:[NSNumber numberWithInt:seqId]];
    }
    
    if (seqs.count > 0)
    {
        [animationManager addNode:node andSequences:seqs];
    }
    
    // Read properties
    int numRegularProps = readIntWithSign(self, NO);
    int numExtraProps = readIntWithSign(self, NO);
    int numProps = numRegularProps + numExtraProps;
    
    for (int i = 0; i < numProps; i++)
    {
        BOOL isExtraProp = (i >= numRegularProps);
        
        [self readPropertyForNode:node parent:parent isExtraProp:isExtraProp];
    }
    
    // Handle sub ccb files (remove middle node)
    if ([node isKindOfClass:[CCBFile class]])
    {
        CCBFile* ccbFileNode = (CCBFile*)node;
        
        CCNode* embeddedNode = ccbFileNode.ccbFile;
        embeddedNode.position = ccbFileNode.position;
        embeddedNode.positionType = ccbFileNode.positionType;
        //embeddedNode.anchorPoint = ccbFileNode.anchorPoint;
        embeddedNode.rotation = ccbFileNode.rotation;
        embeddedNode.scaleX = ccbFileNode.scaleX;
        embeddedNode.scaleY = ccbFileNode.scaleY;
        embeddedNode.name = ccbFileNode.name;
        embeddedNode.visible = YES;
        //embeddedNode.ignoreAnchorPointForPosition = ccbFileNode.ignoreAnchorPointForPosition;
        
        [animationManager moveAnimationsFromNode:ccbFileNode toNode:embeddedNode];
        
        ccbFileNode.ccbFile = NULL;
        
        node = embeddedNode;
    }
    
    // Assign to variable (if applicable)
    if (memberVarAssignmentType)
    {
        id target = NULL;
        if (memberVarAssignmentType == kCCBTargetTypeDocumentRoot) target = animationManager.rootNode;
        else if (memberVarAssignmentType == kCCBTargetTypeOwner) target = owner;
        
        if (target)
        {
            Ivar ivar = class_getInstanceVariable([target class],[memberVarAssignmentName UTF8String]);
            if (ivar)
            {
                object_setIvar(target,ivar,node);
            }
            else
            {
                NSLog(@"CCBReader: Couldn't find member variable: %@", memberVarAssignmentName);
            }
        }
    }
    
    animatedProps = NULL;
    
    // Read physics
    BOOL hasPhysicsBody = readBool(self);
    if (hasPhysicsBody)
    {
#ifdef __CC_PLATFORM_IOS
			// Read body shape
        int bodyShape = readIntWithSign(self, NO);
        float cornerRadius = readFloat(self);
#endif
        // Read points
        int numPoints = readIntWithSign(self, NO);
        CGPoint* points = malloc(sizeof(CGPoint)*numPoints);
        for (int i = 0; i < numPoints; i++)
        {
            float x = readFloat(self);
            float y = readFloat(self);
            
            points[i] = ccp(x, y);
        }
        
#ifdef __CC_PLATFORM_IOS
        // Create body
        CCPhysicsBody* body = NULL;
        
        if (bodyShape == 0)
        {
            body = [CCPhysicsBody bodyWithPolygonFromPoints:points count:numPoints cornerRadius:cornerRadius];
        }
        else if (bodyShape == 1)
        {
            if (numPoints > 0)
                body = [CCPhysicsBody bodyWithCircleOfRadius:cornerRadius andCenter:points[0]];
        }
        NSAssert(body, @"Unknown body shape");
        
        BOOL dynamic = readBool(self);
        BOOL affectedByGravity = readBool(self);
        BOOL allowsRotation = readBool(self);
        
        if (dynamic) body.type = CCPhysicsBodyTypeDynamic;
        else body.type = CCPhysicsBodyTypeStatic;
        
        float density = readFloat(self);
        float friction = readFloat(self);
        float elasticity = readFloat(self);
        
        if (dynamic)
        {
            body.affectedByGravity = affectedByGravity;
            body.allowsRotation = allowsRotation;
        }
        
        body.density = density;
        body.friction = friction;
        body.elasticity = elasticity;
        
        node.physicsBody = body;
#endif
        free(points);
    }
    
    // Read and add children
    int numChildren = readIntWithSign(self, NO);
    for (int i = 0; i < numChildren; i++)
    {
        CCNode* child = [self readNodeGraphParent:node];
        [node addChild:child];
    }
    
    
    return node;
}

- (BOOL) readCallbackKeyframesForSeq:(CCBSequence*)seq
{
    int numKeyframes = readIntWithSign(self, NO);
    
    if (!numKeyframes) return YES;
    
    CCBSequenceProperty* channel = [[CCBSequenceProperty alloc] init];
    
    for (int i = 0; i < numKeyframes; i++)
    {
        float time = readFloat(self);
        NSString* callbackName = [self readCachedString];
        int callbackType = readIntWithSign(self, NO);
        
        NSMutableArray* value = [NSMutableArray arrayWithObjects:
                                 callbackName,
                                 [NSNumber numberWithInt:callbackType],
                                 nil];
        
        CCBKeyframe* keyframe = [[CCBKeyframe alloc] init];
        keyframe.time = time;
        keyframe.value = value;
        
        [channel.keyframes addObject:keyframe];
    }
    
    // Assign to sequence
    seq.callbackChannel = channel;
    
    return YES;
}

- (BOOL) readSoundKeyframesForSeq:(CCBSequence*)seq
{
    int numKeyframes = readIntWithSign(self, NO);
    
    if (!numKeyframes) return YES;
    
    CCBSequenceProperty* channel = [[CCBSequenceProperty alloc] init];
    
    for (int i = 0; i < numKeyframes; i++)
    {
        float time = readFloat(self);
        NSString* soundFile = [self readCachedString];
        float pitch = readFloat(self);
        float pan = readFloat(self);
        float gain = readFloat(self);
        
        NSMutableArray* value = [NSMutableArray arrayWithObjects:
                                 soundFile,
                                 [NSNumber numberWithFloat:pitch],
                                 [NSNumber numberWithFloat:pan],
                                 [NSNumber numberWithFloat:gain],
                                 nil];
        CCBKeyframe* keyframe = [[CCBKeyframe alloc] init];
        keyframe.time = time;
        keyframe.value = value;
        
        [channel.keyframes addObject:keyframe];
    }
    
    // Assign to sequence
    seq.soundChannel = channel;
    
    return YES;
}

- (BOOL) readSequences
{
    NSMutableArray* sequences = animationManager.sequences;
    
    int numSeqs = readIntWithSign(self, NO);
    
    for (int i = 0; i < numSeqs; i++)
    {
        CCBSequence* seq = [[CCBSequence alloc] init];
        seq.duration = readFloat(self);
        seq.name = [self readCachedString];
        seq.sequenceId = readIntWithSign(self, NO);
        seq.chainedSequenceId = readIntWithSign(self, YES);
        
        if (![self readCallbackKeyframesForSeq:seq]) return NO;
        if (![self readSoundKeyframesForSeq:seq]) return NO;
        
        [sequences addObject:seq];
    }
    
    animationManager.autoPlaySequenceId = readIntWithSign(self, YES);
    return YES;
}

- (BOOL) readStringCache
{
    int numStrings = readIntWithSign(self, NO);
    
    stringCache = [[NSMutableArray alloc] initWithCapacity:numStrings];
    
    for (int i = 0; i < numStrings; i++)
    {
        [stringCache addObject:readUTF8(self)];
    }
    
    return YES;
}

#define CHAR4(c0, c1, c2, c3) (((c0)<<24) | ((c1)<<16) | ((c2)<<8) | (c3))

- (BOOL) readHeader
{
	// if no bytes loaded, don't crash about it.
	if( bytes == nil) return NO;
    // Read magic
    int magic = *((int*)(bytes+currentByte));
    currentByte+=4;
    if (magic != CHAR4('c', 'c', 'b', 'i')) return NO;
    
    // Read version
    int version = readIntWithSign(self, NO);
    if (version != kCCBVersion)
    {
        NSLog(@"CCBReader: Incompatible ccbi file version (file: %d reader: %d)",version,kCCBVersion);
        return NO;
    }
    
    return YES;
}

- (void) cleanUpNodeGraph:(CCNode*)node
{
    node.userObject = NULL;
    
    for (CCNode* child in node.children)
    {
        [self cleanUpNodeGraph:child];
    }
}

- (CCNode*) readFileWithCleanUp:(BOOL)cleanUp actionManagers:(NSMutableDictionary*)am
{
    if (![self readHeader]) return NULL;
    if (![self readStringCache]) return NULL;
    if (![self readSequences]) return NULL;
    
    actionManagers = am;
    
    CCNode* node = [self readNodeGraphParent:NULL];
    
    [actionManagers setObject:self.animationManager forKey:[NSValue valueWithPointer:(__bridge const void *)(node)]];
    
    if (cleanUp)
    {
        [self cleanUpNodeGraph:node];
    }
    
    return node;
}

+ (void) callDidLoadFromCCBForNodeGraph:(CCNode*)nodeGraph
{
    for (CCNode* child in nodeGraph.children)
    {
        [CCBReader callDidLoadFromCCBForNodeGraph:child];
    }
    
    if ([nodeGraph respondsToSelector:@selector(didLoadFromCCB)])
    {
        [nodeGraph performSelector:@selector(didLoadFromCCB)];
    }
}

- (CCNode*) loadWithData:(NSData*)d owner:(id)o
{
    // Setup byte array
    data = d;
    bytes = (unsigned char*)[d bytes];
    currentByte = 0;
    currentBit = 0;
    
    owner = o;
    
    self.animationManager.rootContainerSize = [CCDirector sharedDirector].designSize;
    self.animationManager.owner = owner;
    
    NSMutableDictionary* animationManagers = [NSMutableDictionary dictionary];
    CCNode* nodeGraph = [self readFileWithCleanUp:YES actionManagers:animationManagers];
    
    if (nodeGraph && self.animationManager.autoPlaySequenceId != -1)
    {
        // Auto play animations
        [self.animationManager runAnimationsForSequenceId:self.animationManager.autoPlaySequenceId tweenDuration:0];
    }
    
    for (NSValue* pointerValue in animationManagers)
    {
        CCNode* node = [pointerValue pointerValue];
        
        CCBAnimationManager* manager = [animationManagers objectForKey:pointerValue];
        node.userObject = manager;
    }
    
    // Call didLoadFromCCB
    [CCBReader callDidLoadFromCCBForNodeGraph:nodeGraph];

    return nodeGraph;
}

- (CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)o parentSize:(CGSize)parentSize
{
    // Add ccbi suffix
    if (![file hasSuffix:@".ccbi"]) file = [file stringByAppendingString:@".ccbi"];
    
    NSString* path = [[CCFileUtils sharedFileUtils] fullPathForFilename:file];
    NSData* d = [NSData dataWithContentsOfFile:path];
    
    return [self loadWithData:d owner:(id)o];
}

- (CCNode*) load:(NSString*) file owner:(id)o
{
    return [self nodeGraphFromFile:file owner:o parentSize:[CCDirector sharedDirector].designSize];
}

- (CCNode*) load:(NSString*) file
{
    return [self nodeGraphFromFile:file owner:NULL parentSize:[CCDirector sharedDirector].designSize];
}

+(void) setResourcePath:(NSString *)searchPath
{
	NSMutableArray *array = [[[CCFileUtils sharedFileUtils] searchPath] mutableCopy];
	[array addObject:searchPath];
	[[CCFileUtils sharedFileUtils] setSearchPath:array];
}

+ (CCBReader*) reader
{
    return [[CCBReader alloc] init];
}

+ (CCNode*) load:(NSString*) file owner:(id)owner
{
    return [CCBReader load:file owner:owner parentSize:[CCDirector sharedDirector].designSize];
}

+ (CCNode*) nodeGraphFromData:(NSData*) data owner:(id)owner parentSize:(CGSize)parentSize
{
    return [[CCBReader reader] loadWithData:data owner:owner];
}

+ (CCNode*) load:(NSString*) file owner:(id)owner parentSize:(CGSize)parentSize
{
    return [[CCBReader reader] nodeGraphFromFile:file owner:owner parentSize:parentSize];
}

+ (CCNode*) load:(NSString*) file
{
    return [CCBReader load:file owner:NULL];
}

+ (CCScene*) loadAsScene:(NSString *)file owner:(id)owner
{
    return [CCBReader sceneWithNodeGraphFromFile:file owner:owner parentSize:[CCDirector sharedDirector].designSize];
}

+ (CCScene*) sceneWithNodeGraphFromFile:(NSString *)file owner:(id)owner parentSize:(CGSize)parentSize
{
    CCNode* node = [CCBReader load:file owner:owner parentSize:parentSize];
    CCScene* scene = [CCScene node];
    [scene addChild:node];
    return scene;
}

+ (CCScene*) loadAsScene:(NSString*) file
{
    return [CCBReader loadAsScene:file owner:NULL]; 
}

+ (NSString*) ccbDirectoryPath
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[searchPaths objectAtIndex:0] stringByAppendingPathComponent:@"ccb"];
}

@end



@implementation CCBFile
@synthesize ccbFile;
@end

