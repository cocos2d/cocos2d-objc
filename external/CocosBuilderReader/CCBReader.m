/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
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
#import "CCBAnimationManager.h"
#import "CCBSequence.h"
#import "CCBSequenceProperty.h"
#import "CCBKeyframe.h"
#import "CCNode+CCBRelativePositioning.h"

#ifdef CCB_ENABLE_UNZIP
#import "SSZipArchive.h"
#endif


@interface CCBFile : CCNode
{
    CCNode* ccbFile;
}
@property (nonatomic,retain) CCNode* ccbFile;
@end



@implementation CCBReader

@synthesize actionManager;
@synthesize ownerOutletNames;
@synthesize ownerOutletNodes;
@synthesize ownerCallbackNames;
@synthesize ownerCallbackNodes;
@synthesize nodesWithAnimationManagers;
@synthesize animationManagersForNodes;

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    // Setup action manager
    self.actionManager = [[[CCBAnimationManager alloc] init] autorelease];
    
    // Setup set of loaded sprite sheets
    loadedSpriteSheets = [[NSMutableSet alloc] init];
    
    // Setup resolution scale and default container size
    actionManager.rootContainerSize = [[CCDirector sharedDirector] winSize];
    
    return self;
}

- (void) dealloc
{
    [owner release];
    bytes = NULL;
    [data release];
    [stringCache release];
    [loadedSpriteSheets release];
    [ownerOutletNodes release];
    [ownerOutletNames release];
    [ownerCallbackNodes release];
    [ownerCallbackNames release];
    [nodesWithAnimationManagers release];
    [animationManagersForNodes release];
    self.actionManager = NULL;
    [super dealloc];
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
    
    NSString* str = [[[NSString alloc] initWithBytes:bytes+currentByte length:numBytes encoding:NSUTF8StringEncoding] autorelease];
    
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
            // using a memcpy since the compiler isn't
            // doing the float ptr math correctly on device.
            float * pF = (float*)(bytes+currentByte);
            float f = 0;
            memcpy(&f, pF, sizeof(float));
            currentByte+=4;
            return f;
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
        int type = [self readIntWithSign:NO];
        
        CGSize containerSize = [actionManager containerSize:parent];

        if (setProp)
        {
            CGPoint pt = ccp(x,y);
            
            [node setRelativePosition:pt type:type parentSize:containerSize propertyName:name];
            
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
        int type = [self readIntWithSign:NO];
        
        CGSize containerSize = [actionManager containerSize:parent];
        
        if (setProp)
        {
            CGSize size = CGSizeMake(w, h);
            [node setRelativeSize:size type:type parentSize:containerSize propertyName:name];
        }
    }
    else if (type == kCCBPropTypeScaleLock)
    {
        float x = [self readFloat];
        float y = [self readFloat];
        int type = [self readIntWithSign:NO];
        
        if (setProp)
        {
            [node setRelativeScaleX:x Y:y type:type propertyName:name];
            
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
            [node setRelativeFloat:f type:type propertyName:name];
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
        NSString* spriteSheet = [self readCachedString];
        NSString* spriteFile = [self readCachedString];
        
        if (setProp && ![spriteFile isEqualToString:@""])
        {
            CCSpriteFrame* spriteFrame;
            if ([spriteSheet isEqualToString:@""])
            {
                CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:spriteFile];
                CGRect bounds = CGRectMake(0, 0, texture.contentSize.width, texture.contentSize.height);
                spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:bounds];
            }
            else
            {
                CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
                
                // Load the sprite sheet only if it is not loaded
                if (![loadedSpriteSheets member:spriteSheet])
                {
                    [frameCache addSpriteFramesWithFile:spriteSheet];
                    [loadedSpriteSheets addObject:spriteSheet];
                }
                
                spriteFrame = [frameCache spriteFrameByName:spriteFile];
            }
            [node setValue:spriteFrame forKey:name];
            
            if ([animatedProps containsObject:name])
            {
                [actionManager setBaseValue:spriteFrame forNode:node propertyName:name];
            }
        }
    }
	else if(type == kCCBPropTypeAnimation)
    {
        NSString* animationFile = [self readCachedString];
        NSString* animation = [self readCachedString];
        
        if (setProp)
        {
            CCAnimation* pAnimation = nil;
            
            // Support for stripping relative file paths, since ios doesn't currently
            // know what to do with them, since its pulling from bundle.
            // Eventually this should be handled by a client side asset manager
            // interface which figured out what resources to load.
			animation = [animation lastPathComponent];
			animationFile = [animationFile lastPathComponent];
			
            if (![animation isEqualToString:@""])
            {
                CCAnimationCache* animationCache = [CCAnimationCache sharedAnimationCache];
				[animationCache addAnimationsWithFile:animationFile];
				
                pAnimation = [animationCache	animationByName:animation];;
            }
            [node setValue:pAnimation forKey:name];
        }
    }
    else if (type == kCCBPropTypeTexture)
    {
        NSString* spriteFile = [self readCachedString];
        
        if (setProp && ![spriteFile isEqualToString:@""])
        {
            CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:spriteFile];
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
            if ([[fnt lowercaseString] hasSuffix:@".ttf"])
            {
                fnt = [[fnt lastPathComponent] stringByDeletingPathExtension];
            }
            [node setValue:fnt forKey:name];
        }
    }
    else if (type == kCCBPropTypeBlock)
    {
        NSString* selectorName = [self readCachedString];
        int selectorTarget = [self readIntWithSign:NO];
        
        if (setProp)
        {
            if (!jsControlled)
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
                        __block id t = target;
                        
                        void (^block)(id sender);
                        block = ^(id sender) {
                            [t performSelector:selector withObject:sender];
                        };
                        
                        NSString* setSelectorName = [NSString stringWithFormat:@"set%@:",[name capitalizedString]];
                        SEL setSelector = NSSelectorFromString(setSelectorName);
                        
                        if ([node respondsToSelector:setSelector])
                        {
                            [node performSelector:setSelector withObject:block];
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
            else
            {
                // JS Callbacks
                if (selectorTarget)
                {
                    if (selectorTarget == kCCBTargetTypeDocumentRoot)
                    {
                        [actionManager.documentCallbackNames addObject:selectorName];
                        [actionManager.documentCallbackNodes addObject:node];
                    }
                    else if (selectorTarget == kCCBTargetTypeOwner)
                    {
                        [ownerCallbackNames addObject:selectorName];
                        [ownerCallbackNodes addObject:node];
                    }
                }
            }
        }
    }
    else if (type == kCCBPropTypeBlockCCControl)
    {
        NSString* selectorName = [self readCachedString];
        int selectorTarget = [self readIntWithSign:NO];
        int ctrlEvts = [self readIntWithSign:NO];
        
        if (setProp)
        {
            // Since we do not know for sure that CCControl is available, use
            // NSInvocation to call it's addTarget:action:forControlEvents: method
            NSMethodSignature* sig = [node methodSignatureForSelector:@selector(addTarget:action:forControlEvents:)];
            if (sig)
            {
                SEL selector = NSSelectorFromString(selectorName);
                id target = NULL;
                if (selectorTarget == kCCBTargetTypeDocumentRoot) target = actionManager.rootNode;
                else if (selectorTarget == kCCBTargetTypeOwner) target = owner;
                
                if (selector && target)
                {
                    NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:sig];
                    [invocation setTarget:node];
                    [invocation setSelector:@selector(addTarget:action:forControlEvents:)];
                    [invocation setArgument:&target atIndex:2];
                    [invocation setArgument:&selector atIndex:3];
                    [invocation setArgument:&ctrlEvts atIndex:4];
                    
                    [invocation invoke];
                }
            }
            else
            {
                NSLog(@"CCBReader: Failed to add selector/target block for CCControl");
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
        NSString* path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:ccbFileName];
        NSData* d = [NSData dataWithContentsOfFile:path];
        
        CCBReader* reader = [[[CCBReader alloc] init] autorelease];
        reader.actionManager.rootContainerSize = parent.contentSize;
        
        // Setup byte array & owner
        reader->data = [d retain];
        reader->bytes = (unsigned char*)[d bytes];
        reader->currentByte = 0;
        reader->currentBit = 0;
        
        reader->owner = [owner retain];
        
        reader->ownerOutletNames = [ownerOutletNames retain];
        reader->ownerOutletNodes = [ownerOutletNodes retain];
        reader->ownerCallbackNames = [ownerCallbackNames retain];
        reader->ownerCallbackNodes = [ownerCallbackNodes retain];
        
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
    CCBKeyframe* keyframe = [[[CCBKeyframe alloc] init] autorelease];
    
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
             || type == kCCBPropTypePosition)
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
        NSString* spriteSheet = [self readCachedString];
        NSString* spriteFile = [self readCachedString];
        
        CCSpriteFrame* spriteFrame;
        if ([spriteSheet isEqualToString:@""])
        {
            CCTexture2D* texture = [[CCTextureCache sharedTextureCache] addImage:spriteFile];
            CGRect bounds = CGRectMake(0, 0, texture.contentSize.width, texture.contentSize.height);
            spriteFrame = [CCSpriteFrame frameWithTexture:texture rect:bounds];
        }
        else
        {
            CCSpriteFrameCache* frameCache = [CCSpriteFrameCache sharedSpriteFrameCache];
                
            // Load the sprite sheet only if it is not loaded
            if (![loadedSpriteSheets member:spriteSheet])
            {
                [frameCache addSpriteFramesWithFile:spriteSheet];
                [loadedSpriteSheets addObject:spriteSheet];
            }
            
            spriteFrame = [frameCache spriteFrameByName:spriteFile];
        }
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
    
    NSString* jsControllerName = NULL;
    if (jsControlled)
    {
        jsControllerName = [self readCachedString];
    }
    
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
    CCNode* node = [[[class alloc] init] autorelease];
    
    // Set root node
    if (!actionManager.rootNode) actionManager.rootNode = node;
    
    // Assign controller
    if (jsControlled && actionManager.rootNode == node)
    {
        actionManager.documentControllerName = jsControllerName;
    }
    
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
            CCBSequenceProperty* seqProp = [[[CCBSequenceProperty alloc] init] autorelease];
            
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
        embeddedNode.tag = ccbFileNode.tag;
        embeddedNode.visible = YES;
        //embeddedNode.ignoreAnchorPointForPosition = ccbFileNode.ignoreAnchorPointForPosition;
        
        [actionManager moveAnimationsFromNode:ccbFileNode toNode:embeddedNode];
        
        ccbFileNode.ccbFile = NULL;
        
        node = embeddedNode;
    }
    
    // Assign to variable (if applicable)
    if (!jsControlled)
    {
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
    }
    else
    {
        // Assign to arrays used by javascript bindings
        if (memberVarAssignmentType)
        {
            if (memberVarAssignmentType == kCCBTargetTypeOwner)
            {
                [ownerOutletNames addObject:memberVarAssignmentName];
                [ownerOutletNodes addObject:node];
            }
            else
            {
                [actionManager.documentOutletNames addObject:memberVarAssignmentName];
                [actionManager.documentOutletNodes addObject:node];
            }
        }
    }
    
    [animatedProps release];
    animatedProps = NULL;
    
    // Read and add children
    int numChildren = [self readIntWithSign:NO];
    for (int i = 0; i < numChildren; i++)
    {
        CCNode* child = [self readNodeGraphParent:node];
        [node addChild:child];
    }
    
    return node;
}

- (BOOL) readSequences
{
    NSMutableArray* sequences = actionManager.sequences;
    
    int numSeqs = [self readIntWithSign:NO];
    
    for (int i = 0; i < numSeqs; i++)
    {
        CCBSequence* seq = [[[CCBSequence alloc] init] autorelease];
        seq.duration = [self readFloat];
        seq.name = [self readCachedString];
        seq.sequenceId = [self readIntWithSign:NO];
        seq.chainedSequenceId = [self readIntWithSign:YES];
        
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
    
    // Read JS check
    jsControlled = [self readBool];
    
    return YES;
}

- (void) cleanUpNodeGraph:(CCNode*)node
{
    node.userObject = NULL;
    
    CCNode* child = NULL;
    CCARRAY_FOREACH(node.children, child)
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
    
    [actionManagers setObject:self.actionManager forKey:[NSValue valueWithPointer:node]];
    
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
    
    CCNode* child = NULL;
    CCARRAY_FOREACH(nodeGraph.children, child)
    {
        [CCBReader callDidLoadFromCCBForNodeGraph:child];
    }
}

- (CCNode*) nodeGraphFromData:(NSData*)d owner:(id)o parentSize:(CGSize) parentSize
{
    // Setup byte array
    data = [d retain];
    bytes = (unsigned char*)[d bytes];
    currentByte = 0;
    currentBit = 0;
    
    owner = [o retain];
    
    self.actionManager.rootContainerSize = parentSize;
    
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
    
    // Assign actionManagers to userObject
    if (jsControlled)
    {
        nodesWithAnimationManagers = [[NSMutableArray alloc] init];
        animationManagersForNodes = [[NSMutableArray alloc] init];
    }
    for (NSValue* pointerValue in animationManagers)
    {
        CCNode* node = [pointerValue pointerValue];
        
        CCBAnimationManager* manager = [animationManagers objectForKey:pointerValue];
        node.userObject = manager;
        
        if (jsControlled)
        {
            [nodesWithAnimationManagers addObject:node];
            [animationManagersForNodes addObject:manager];
        }
    }
    
    // Call didLoadFromCCB
    [CCBReader callDidLoadFromCCBForNodeGraph:nodeGraph];
    
    return nodeGraph;
}

- (CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)o parentSize:(CGSize)parentSize
{
    // Add ccbi suffix
    if (![file hasSuffix:@".ccbi"]) file = [file stringByAppendingString:@".ccbi"];
    
    NSString* path = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:file];
    NSData* d = [NSData dataWithContentsOfFile:path];
    
    return [self nodeGraphFromData:d owner:(id)o parentSize:parentSize];
}

- (CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)o
{
    return [self nodeGraphFromFile:file owner:o parentSize:[[CCDirector sharedDirector] winSize]];
}

- (CCNode*) nodeGraphFromFile:(NSString*) file
{
    return [self nodeGraphFromFile:file owner:NULL parentSize:[[CCDirector sharedDirector] winSize]];
}

+ (CCBReader*) reader
{
    return [[[CCBReader alloc] init] autorelease];
}

+ (CCNode*) nodeGraphFromFile:(NSString*) file owner:(id)owner
{
    return [CCBReader nodeGraphFromFile:file owner:owner parentSize:[[CCDirector sharedDirector] winSize]];
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
    return [CCBReader sceneWithNodeGraphFromFile:file owner:owner parentSize:[[CCDirector sharedDirector] winSize]];
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

+ (void) setResolutionScale:(float)scale
{
    ccbResolutionScale = scale;
}

#ifdef CCB_ENABLE_UNZIP
+ (BOOL) unzipResources:(NSString*)resPath
{
    NSString* fullResPath = [[CCFileUtils sharedFileUtils] fullPathFromRelativePath:resPath];
    
    NSString* dstPath = [CCBReader ccbDirectoryPath];
    
    return [SSZipArchive unzipFileAtPath:fullResPath toDestination:dstPath overwrite:YES password:NULL error:NULL];
}
#endif
@end



@implementation CCBFile
@synthesize ccbFile;
@end



@implementation CCBFileUtils

- (id) init
{
    self = [super init];
    if (!self) return NULL;
    
    // Add the ccb directory to the resource path
    self.searchPath = [[NSArray arrayWithObject:[CCBReader ccbDirectoryPath]] arrayByAddingObjectsFromArray: self.searchPath];
    
    NSLog(@"ccbDirectoryPath: %@", [CCBReader ccbDirectoryPath]);
    
    return self;
}

- (void) dealloc
{
    //self.ccbDirectoryPath = NULL;
    [super dealloc];
}
@end
