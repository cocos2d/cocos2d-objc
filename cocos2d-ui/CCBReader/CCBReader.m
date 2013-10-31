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

@synthesize actionManager;
@synthesize ownerOutletNames;
@synthesize ownerOutletNodes;
@synthesize ownerCallbackNames;
@synthesize ownerCallbackNodes;
@synthesize nodesWithAnimationManagers;
@synthesize animationManagersForNodes;

+ (void) configureCCFileUtils
{
    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
    
    // Setup file utils for use with SpriteBuilder
    [sharedFileUtils setEnableFallbackSuffixes:NO];
    
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
    self.actionManager = [[CCBAnimationManager alloc] init];
    
    // Setup set of loaded sprite sheets
    loadedSpriteSheets = [[NSMutableSet alloc] init];
    
    // Setup resolution scale and default container size
    actionManager.rootContainerSize = [[CCDirector sharedDirector] viewSize];
    
    return self;
}

- (void) dealloc
{
    bytes = NULL;
}

- (unsigned char) readByte
{
    unsigned char byte = bytes[currentByte];
    currentByte++;
    return byte;
}

- (BOOL) readBool
{
    return [self readByte];
}

- (NSString*) readUTF8
{
    int b0 = [self readByte];
    int b1 = [self readByte];
    
    int numBytes = b0 << 8 | b1;
    
    NSString* str = [[NSString alloc] initWithBytes:bytes+currentByte length:numBytes encoding:NSUTF8StringEncoding];
    
    currentByte += numBytes;
    
    return str;
}

- (BOOL) getBit
{
    BOOL bit;
    unsigned char byte = *(bytes+currentByte);
    if (byte & (1 << currentBit)) bit = YES;
    else bit = NO;
    
    currentBit++;
    if (currentBit >= 8)
    {
        currentBit = 0;
        currentByte++;
    }
    
    return bit;
}

- (void) alignBits
{
    if (currentBit)
    {
        currentBit = 0;
        currentByte++;
    }
}

- (int) readIntWithSign:(BOOL)sign
{
    // Read encoded int
    int numBits = 0;
    while (![self getBit])
    {
        numBits++;
    }
    
    long long current = 0;
    for (int a=numBits-1; a >= 0; a--)
    {
        if ([self getBit])
        {
            current |= 1 << a;
        }
    }
    current |= 1 << numBits;
    
    int num;
    if (sign)
    {
        int s = current%2;
        if (s) num = (int)(current/2);
        else num = (int)(-current/2);
    }
    else
    {
        num = (int)(current-1);
    }
    
    [self alignBits];
    
    return num;
}

- (float) readFloat
{
    unsigned char type = [self readByte];

    switch (type) {
        case kCCBFloat0:
            return 0;
        case kCCBFloat1:
            return 1;
        case kCCBFloatMinus1:
            return -1;
        case kCCBFloat05:
            return 0.5f;
        case kCCBFloatInteger:
            return [self readIntWithSign:YES];
        default: {
            // Copy the float byte by byte
            // memcpy dosn't work on latest Xcode (4.6)
            union {
                float f;
                int i;
            } t;
            t.i = *(int *)(bytes + currentByte);
            currentByte += 4;
            return t.f;
        }
    }
}

- (NSString*) readCachedString
{
    int n = [self readIntWithSign:NO];
    return [stringCache objectAtIndex:n];
}

- (void) readPropertyForNode:(CCNode*) node parent:(CCNode*)parent isExtraProp:(BOOL)isExtraProp
{
    // Read type and property name
    int type = [self readIntWithSign:NO];
    NSString* name = [self readCachedString];
    
    // Check if the property can be set for this platform
    BOOL setProp = NO;
    
    int platform = [self readByte];
    if (platform == kCCBPlatformAll) setProp = YES;
#ifdef __CC_PLATFORM_IOS
    if (platform == kCCBPlatformIOS) setProp = YES;
#elif defined(__CC_PLATFORM_MAC)
    if (platform == kCCBPlatformMac) setProp = YES;
#endif
    
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
    else if (isExtraProp && node == actionManager.rootNode)
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
        float x = [self readFloat];
        float y = [self readFloat];
        int corner = [self readByte];
        int xUnit = [self readByte];
        int yUnit = [self readByte];

        if (setProp)
        {
#ifdef __CC_PLATFORM_IOS
            [node setValue:[NSValue valueWithCGPoint:ccp(x,y)] forKey:name];
#elif defined (__CC_PLATFORM_MAC)
            [node setValue:[NSValue valueWithPoint:ccp(x,y)] forKey:name];
#endif
            CCPositionType type = CCPositionTypeMake(xUnit, yUnit, corner);
            [node setValue:[NSValue valueWithBytes:&type objCType:@encode(ccColor4B)] forKey:[name stringByAppendingString:@"Type"]];
            
            
            if ([animatedProps containsObject:name])
            {
                id baseValue = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:x],
                                [NSNumber numberWithFloat:y],
                                [NSNumber numberWithInt:corner],
                                [NSNumber numberWithInt:xUnit],
                                [NSNumber numberWithInt:yUnit],
                                nil];
                [actionManager setBaseValue:baseValue forNode:node propertyName:name];
            }
        }
    }
    else if(type == kCCBPropTypePoint
            || type == kCCBPropTypePointLock)
    {
        float x = [self readFloat];
        float y = [self readFloat];
        
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
        float w = [self readFloat];
        float h = [self readFloat];
        int xUnit = [self readByte];
        int yUnit = [self readByte];
        
        if (setProp)
        {
            CGSize size = CGSizeMake(w, h);
#ifdef __CC_PLATFORM_IOS
            [node setValue:[NSValue valueWithCGSize:size] forKey:name];
#elif defined (__CC_PLATFORM_MAC)
            [node setValue:[NSValue valueWithSize:size] forKey:name];
#endif
            
            CCContentSizeType sizeType = CCContentSizeTypeMake(xUnit, yUnit);
            [node setValue:[NSValue valueWithBytes:&sizeType objCType:@encode(CCContentSizeType)] forKey:[name stringByAppendingString:@"Type"]];
        }
    }
    else if (type == kCCBPropTypeScaleLock)
    {
        float x = [self readFloat];
        float y = [self readFloat];
        int type = [self readByte];
        
        if (setProp)
        {
            [node setValue:[NSNumber numberWithFloat:x] forKey:[name stringByAppendingString:@"X"]];
            [node setValue:[NSNumber numberWithFloat:y] forKey:[name stringByAppendingString:@"Y"]];
            [node setValue:[NSNumber numberWithInt:type] forKey:[name stringByAppendingString:@"Type"]];
            
            if ([animatedProps containsObject:name])
            {
                id baseValue = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:x],
                                [NSNumber numberWithFloat:y],
                                [NSNumber numberWithInt:type],
                                nil];
                [actionManager setBaseValue:baseValue forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeFloatXY)
    {
        float xFloat = [self readFloat];
        float yFloat = [self readFloat];
        
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
        float f = [self readFloat];
        
        if (setProp)
        {
            id value = [NSNumber numberWithFloat:f];
            [node setValue:value forKey:name];
            
            if ([animatedProps containsObject:name])
            {
                [actionManager setBaseValue:value forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeFloatScale)
    {
        float f = [self readFloat];
        int type = [self readIntWithSign:NO];
        
        if (setProp)
        {
            if (type == 1) f *= [CCDirector sharedDirector].positionScaleFactor;
            [node setValue:[NSNumber numberWithFloat:f] forKey:name];
        }
    }
    else if (type == kCCBPropTypeInteger
             || type == kCCBPropTypeIntegerLabeled)
    {
        int d = [self readIntWithSign:YES];
        
        if (setProp)
        {
            [node setValue:[NSNumber numberWithInt:d] forKey:name];
        }
    }
    else if (type == kCCBPropTypeFloatVar)
    {
        float f = [self readFloat];
        float fVar = [self readFloat];
        
        if (setProp)
        {
            NSString* nameVar = [NSString stringWithFormat:@"%@Var",name];
            [node setValue:[NSNumber numberWithFloat:f] forKey:name];
            [node setValue:[NSNumber numberWithFloat:fVar] forKey:nameVar];
        }
    }
    else if (type == kCCBPropTypeCheck)
    {
        BOOL b = [self readBool];
        
        if (setProp)
        {
            id value = [NSNumber numberWithBool:b];
            [node setValue:value forKey:name];
            
            if ([animatedProps containsObject:name])
            {
                [actionManager setBaseValue:value forNode:node propertyName:name];
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
                [actionManager setBaseValue:spriteFrame forNode:node propertyName:name];
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
        int byte = [self readByte];
        
        if (setProp)
        {
            id value = [NSNumber numberWithInt:byte];
            [node setValue:value forKey:name];
            
            if ([animatedProps containsObject:name])
            {
                [actionManager setBaseValue:value forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeColor3)
    {
        int r = [self readByte];
        int g = [self readByte];
        int b = [self readByte];
        
        if (setProp)
        {
            ccColor3B c = ccc3(r,g,b);
            NSValue* cVal = [NSValue value:&c withObjCType:@encode(ccColor3B)];
            [node setValue:cVal forKey:name];
            
            if ([animatedProps containsObject:name])
            {
                [actionManager setBaseValue:cVal forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeColor4)
    {
        int r = [self readByte];
        int g = [self readByte];
        int b = [self readByte];
        int a = [self readByte];
        
        if (setProp)
        {
            ccColor4B c = ccc4(r,g,b,a);
            NSValue* cVal = [NSValue value:&c withObjCType:@encode(ccColor4B)];
            [node setValue:cVal forKey:name];
            
            if ([animatedProps containsObject:name])
            {
                [actionManager setBaseValue:cVal forNode:node propertyName:name];
            }
        }
    }
    else if (type == kCCBPropTypeColor4FVar)
    {
        float r = [self readFloat];
        float g = [self readFloat];
        float b = [self readFloat];
        float a = [self readFloat];
        float rVar = [self readFloat];
        float gVar = [self readFloat];
        float bVar = [self readFloat];
        float aVar = [self readFloat];
        
        if (setProp)
        {
            ccColor4F c = ccc4f(r, g, b, a);
            ccColor4F cVar = ccc4f(rVar, gVar, bVar, aVar);
            NSValue* cVal = [NSValue value:&c withObjCType:@encode(ccColor4F)];
            NSValue* cVarVal = [NSValue value:&cVar withObjCType:@encode(ccColor4F)];
            NSString* nameVar = [NSString stringWithFormat:@"%@Var",name];
            [node setValue:cVal forKey:name];
            [node setValue:cVarVal forKey:nameVar];
        }
    }
    else if (type == kCCBPropTypeFlip)
    {
        BOOL xFlip = [self readBool];
        BOOL yFlip = [self readBool];
        
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
        int src = [self readIntWithSign:NO];
        int dst = [self readIntWithSign:NO];
        
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
        BOOL localized = [self readBool];
        
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
        int selectorTarget = [self readIntWithSign:NO];
        
        if (setProp)
        {
            // Objective C callbacks
            if (selectorTarget)
            {
                id target = NULL;
                if (selectorTarget == kCCBTargetTypeDocumentRoot) target = actionManager.rootNode;
                else if (selectorTarget == kCCBTargetTypeOwner) target = owner;
                
                if (target)
                {
                    SEL selector = NSSelectorFromString(selectorName);
                    __unsafe_unretained id t = target;
                    
                    void (^block)(id sender);
                    block = ^(id sender) {
                        objc_msgSend(t, selector, sender);
                    };
                    
                    NSString* setSelectorName = [NSString stringWithFormat:@"set%@:",[name capitalizedString]];
                    SEL setSelector = NSSelectorFromString(setSelectorName);
                    
                    if ([node respondsToSelector:setSelector])
                    {
                        objc_msgSend(node, setSelector, block);
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
        
        CCBReader* reader = [[CCBReader alloc] init];
        reader.actionManager.rootContainerSize = parent.contentSize;
        
        // Setup byte array & owner
        reader->data = d;
        reader->bytes = (unsigned char*)[d bytes];
        reader->currentByte = 0;
        reader->currentBit = 0;
        
        reader->owner = owner;
        
        reader->ownerOutletNames = ownerOutletNames;
        reader->ownerOutletNodes = ownerOutletNodes;
        reader->ownerCallbackNames = ownerCallbackNames;
        reader->ownerCallbackNodes = ownerCallbackNodes;
        
        reader.actionManager.owner = owner;
        
        CCNode* ccbFile = [reader readFileWithCleanUp:NO actionManagers:actionManagers];
        
        if (ccbFile && reader.actionManager.autoPlaySequenceId != -1)
        {
            // Auto play animations
            [reader.actionManager runAnimationsForSequenceId:reader.actionManager.autoPlaySequenceId tweenDuration:0];
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
    
    keyframe.time = [self readFloat];
    
    int easingType = [self readIntWithSign:NO];
    float easingOpt = 0;
    id value = NULL;
    
    if (easingType == kCCBKeyframeEasingCubicIn
        || easingType == kCCBKeyframeEasingCubicOut
        || easingType == kCCBKeyframeEasingCubicInOut
        || easingType == kCCBKeyframeEasingElasticIn
        || easingType == kCCBKeyframeEasingElasticOut
        || easingType == kCCBKeyframeEasingElasticInOut)
    {
        easingOpt = [self readFloat];
    }
    keyframe.easingType = easingType;
    keyframe.easingOpt = easingOpt;
    
    if (type == kCCBPropTypeCheck)
    {
        value = [NSNumber numberWithBool:[self readBool]];
    }
    else if (type == kCCBPropTypeByte)
    {
        value = [NSNumber numberWithInt:[self readByte]];
    }
    else if (type == kCCBPropTypeColor3)
    {
        int r = [self readByte];
        int g = [self readByte];
        int b = [self readByte];
        
        ccColor3B c = ccc3(r,g,b);
        value = [NSValue value:&c withObjCType:@encode(ccColor3B)];
    }
    else if (type == kCCBPropTypeDegrees)
    {
        value = [NSNumber numberWithFloat:[self readFloat]];
    }
    else if (type == kCCBPropTypeScaleLock
             || type == kCCBPropTypePosition
             || type == kCCBPropTypeFloatXY)
    {
        float a = [self readFloat];
        float b = [self readFloat];
        
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
    int memberVarAssignmentType = [self readIntWithSign:NO];
    NSString* memberVarAssignmentName = NULL;
    if (memberVarAssignmentType)
    {
        memberVarAssignmentName = [self readCachedString];
    }
    
    Class class = NSClassFromString(className);
    if (!class)
    {
        NSLog(@"CCBReader: Could not create class of type %@",className);
        return NULL;
    }
    CCNode* node = [[class alloc] init];
    
    // Set root node
    if (!actionManager.rootNode) actionManager.rootNode = node;
    
    // Read animated properties
    NSMutableDictionary* seqs = [NSMutableDictionary dictionary];
    animatedProps = [[NSMutableSet alloc] init];
    
    int numSequences = [self readIntWithSign:NO];
    for (int i = 0; i < numSequences; i++)
    {
        int seqId = [self readIntWithSign:NO];
        NSMutableDictionary* seqNodeProps = [NSMutableDictionary dictionary];
        
        int numProps = [self readIntWithSign:NO];
        
        for (int j = 0; j < numProps; j++)
        {
            CCBSequenceProperty* seqProp = [[CCBSequenceProperty alloc] init];
            
            seqProp.name = [self readCachedString];
            seqProp.type = [self readIntWithSign:NO];
            [animatedProps addObject:seqProp.name];
            
            int numKeyframes = [self readIntWithSign:NO];
            
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
        [actionManager addNode:node andSequences:seqs];
    }
    
    // Read properties
    int numRegularProps = [self readIntWithSign:NO];
    int numExtraProps = [self readIntWithSign:NO];
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
        //embeddedNode.anchorPoint = ccbFileNode.anchorPoint;
        embeddedNode.rotation = ccbFileNode.rotation;
        embeddedNode.scale = ccbFileNode.scale;
        embeddedNode.name = ccbFileNode.name;
        embeddedNode.visible = YES;
        //embeddedNode.ignoreAnchorPointForPosition = ccbFileNode.ignoreAnchorPointForPosition;
        
        [actionManager moveAnimationsFromNode:ccbFileNode toNode:embeddedNode];
        
        ccbFileNode.ccbFile = NULL;
        
        node = embeddedNode;
    }
    
    // Assign to variable (if applicable)
    if (memberVarAssignmentType)
    {
        id target = NULL;
        if (memberVarAssignmentType == kCCBTargetTypeDocumentRoot) target = actionManager.rootNode;
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
    BOOL hasPhysicsBody = [self readBool];
    if (hasPhysicsBody)
    {
        // Read body shape
        int bodyShape = [self readIntWithSign:NO];
        float cornerRadius = [self readFloat];
        
        // Read points
        int numPoints = [self readIntWithSign:NO];
        CGPoint* points = malloc(sizeof(CGPoint)*numPoints);
        for (int i = 0; i < numPoints; i++)
        {
            float x = [self readFloat];
            float y = [self readFloat];
            
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
            body = [CCPhysicsBody bodyWithCircleOfRadius:cornerRadius andCenter:points[0]];
        }
        
        BOOL dynamic = [self readBool];
        BOOL affectedByGravity = [self readBool];
        BOOL allowsRotation = [self readBool];
        
        if (dynamic) body.type = CCPhysicsBodyTypeDynamic;
        else body.type = CCPhysicsBodyTypeStatic;
        
        float density = [self readFloat];
        float friction = [self readFloat];
        float elasticity = [self readFloat];
        
        //body.affectedByGravity = affectedByGravity;
        //body.allowsRotation = allowsRotation;
        
        //body.density = density;
        body.friction = friction;
        body.elasticity = elasticity;
        
        node.physicsBody = body;
#endif
    }
    
    // Read and add children
    int numChildren = [self readIntWithSign:NO];
    for (int i = 0; i < numChildren; i++)
    {
        CCNode* child = [self readNodeGraphParent:node];
        [node addChild:child];
    }
    
    return node;
}

- (BOOL) readCallbackKeyframesForSeq:(CCBSequence*)seq
{
    int numKeyframes = [self readIntWithSign:0];
    
    if (!numKeyframes) return YES;
    
    CCBSequenceProperty* channel = [[CCBSequenceProperty alloc] init];
    
    for (int i = 0; i < numKeyframes; i++)
    {
        float time = [self readFloat];
        NSString* callbackName = [self readCachedString];
        int callbackType = [self readIntWithSign:NO];
        
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
    int numKeyframes = [self readIntWithSign:0];
    
    if (!numKeyframes) return YES;
    
    CCBSequenceProperty* channel = [[CCBSequenceProperty alloc] init];
    
    for (int i = 0; i < numKeyframes; i++)
    {
        float time = [self readFloat];
        NSString* soundFile = [self readCachedString];
        float pitch = [self readFloat];
        float pan = [self readFloat];
        float gain = [self readFloat];
        
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
    NSMutableArray* sequences = actionManager.sequences;
    
    int numSeqs = [self readIntWithSign:NO];
    
    for (int i = 0; i < numSeqs; i++)
    {
        CCBSequence* seq = [[CCBSequence alloc] init];
        seq.duration = [self readFloat];
        seq.name = [self readCachedString];
        seq.sequenceId = [self readIntWithSign:NO];
        seq.chainedSequenceId = [self readIntWithSign:YES];
        
        if (![self readCallbackKeyframesForSeq:seq]) return NO;
        if (![self readSoundKeyframesForSeq:seq]) return NO;
        
        [sequences addObject:seq];
    }
    
    actionManager.autoPlaySequenceId = [self readIntWithSign:YES];
    return YES;
}

- (BOOL) readStringCache
{
    int numStrings = [self readIntWithSign:NO];
    
    stringCache = [[NSMutableArray alloc] initWithCapacity:numStrings];
    
    for (int i = 0; i < numStrings; i++)
    {
        [stringCache addObject:[self readUTF8]];
    }
    
    return YES;
}

- (BOOL) readHeader
{
	// if no bytes loaded, don't crash about it.
	if( bytes == nil) return NO;
    // Read magic
    int magic = *((int*)(bytes+currentByte));
    currentByte+=4;
    if (magic != 'ccbi') return NO;
    
    // Read version
    int version = [self readIntWithSign:NO];
    if (version != kCCBVersion)
    {
        NSLog(@"CCBReader: Incompatible ccbi file version (file: %d reader: %d)",version,kCCBVersion);
        return NO;
    }
    
    // Read JS check (ignored)
    [self readBool];
    
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
    
    [actionManagers setObject:self.actionManager forKey:[NSValue valueWithPointer:(__bridge const void *)(node)]];
    
    if (cleanUp)
    {
        [self cleanUpNodeGraph:node];
    }
    
    return node;
}

+ (void) callDidLoadFromCCBForNodeGraph:(CCNode*)nodeGraph
{
    if ([nodeGraph respondsToSelector:@selector(didLoadFromCCB)])
    {
        [nodeGraph performSelector:@selector(didLoadFromCCB)];
    }
    
    for (CCNode* child in nodeGraph.children)
    {
        [CCBReader callDidLoadFromCCBForNodeGraph:child];
    }
}

- (CCNode*) nodeGraphFromData:(NSData*)d owner:(id)o parentSize:(CGSize) parentSize
{
    // Setup byte array
    data = d;
    bytes = (unsigned char*)[d bytes];
    currentByte = 0;
    currentBit = 0;
    
    owner = o;
    
    self.actionManager.rootContainerSize = parentSize;
    self.actionManager.owner = owner;
    
    ownerOutletNames = [[NSMutableArray alloc] init];
    ownerOutletNodes = [[NSMutableArray alloc] init];
    ownerCallbackNames = [[NSMutableArray alloc] init];
    ownerCallbackNodes = [[NSMutableArray alloc] init];
    
    NSMutableDictionary* animationManagers = [NSMutableDictionary dictionary];
    CCNode* nodeGraph = [self readFileWithCleanUp:YES actionManagers:animationManagers];
    
    if (nodeGraph && self.actionManager.autoPlaySequenceId != -1)
    {
        // Auto play animations
        [self.actionManager runAnimationsForSequenceId:self.actionManager.autoPlaySequenceId tweenDuration:0];
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
    
    return [self nodeGraphFromData:d owner:(id)o parentSize:parentSize];
}

- (CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)o
{
    return [self nodeGraphFromFile:file owner:o parentSize:[[CCDirector sharedDirector] viewSize]];
}

- (CCNode*) nodeGraphFromFile:(NSString*) file
{
    return [self nodeGraphFromFile:file owner:NULL parentSize:[[CCDirector sharedDirector] viewSize]];
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

+ (CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)owner
{
    return [CCBReader nodeGraphFromFile:file owner:owner parentSize:[[CCDirector sharedDirector] viewSize]];
}

+ (CCNode*) nodeGraphFromData:(NSData*) data owner:(id)owner parentSize:(CGSize)parentSize
{
    return [[CCBReader reader] nodeGraphFromData:data owner:owner parentSize:parentSize];
}

+ (CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)owner parentSize:(CGSize)parentSize
{
    return [[CCBReader reader] nodeGraphFromFile:file owner:owner parentSize:parentSize];
}

+ (CCNode*) nodeGraphFromFile:(NSString*) file
{
    return [CCBReader nodeGraphFromFile:file owner:NULL];
}

+ (CCScene*) sceneWithNodeGraphFromFile:(NSString *)file owner:(id)owner
{
    return [CCBReader sceneWithNodeGraphFromFile:file owner:owner parentSize:[[CCDirector sharedDirector] viewSize]];
}

+ (CCScene*) sceneWithNodeGraphFromFile:(NSString *)file owner:(id)owner parentSize:(CGSize)parentSize
{
    CCNode* node = [CCBReader nodeGraphFromFile:file owner:owner parentSize:parentSize];
    CCScene* scene = [CCScene node];
    [scene addChild:node];
    return scene;
}

+ (CCScene*) sceneWithNodeGraphFromFile:(NSString*) file
{
    return [CCBReader sceneWithNodeGraphFromFile:file owner:NULL]; 
}

+ (NSString*) ccbDirectoryPath
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    return [[searchPaths objectAtIndex:0] stringByAppendingPathComponent:@"ccb"];
}

#ifdef CCB_ENABLE_UNZIP
+ (BOOL) unzipResources:(NSString*)resPath
{
    NSString* fullResPath = [[CCFileUtils sharedFileUtils] fullPathForFilenameIgnoringResolutions:resPath];
    
    NSString* dstPath = [CCBReader ccbDirectoryPath];
    
    return [SSZipArchive unzipFileAtPath:fullResPath toDestination:dstPath overwrite:YES password:NULL error:NULL];
}
#endif
@end



@implementation CCBFile
@synthesize ccbFile;
@end

