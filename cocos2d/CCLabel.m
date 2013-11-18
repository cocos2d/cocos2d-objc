//
//  CCLabel.m
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCLabel.h"

#import "CCLabelTextFormatter.h"
#import "CCSprite_Private.h"
#import "CCSpriteBatchNode_Private.h"
#import "CCLetterInfo.h"

@interface CCLabel ()
- (void) alignText;
@end

@implementation CCLabel
{
    BOOL _isOpacityModifyRGB;
    
    CCSprite* _reusedLetter;
    NSMutableArray* _lettersInfo;
    
    CGFloat                       _commonLineHeight;
    BOOL                        _lineBreakWithoutSpaces;
    CGFloat                       _width;
    CCTextAlignment              _alignment;
    NSString *        _currentUTF16String;
    NSString *        _originalUTF16String;
    CGSize             *        _advances;
    CCFontAtlas        *        _fontAtlas;
}
@synthesize color = _realColor;
@synthesize displayedColor = _displayedColor;
@synthesize cascadeColorEnabled = _cascadeColorEnabled;
@synthesize cascadeOpacityEnabled = _cascadeOpacityEnabled;
@synthesize opacity = _realOpacity;
@synthesize displayedOpacity = _displayedOpacity;
@synthesize lettersInfo = _lettersInfo;

- (instancetype) initWithString:(NSString*)label ttfFontName:(NSString*)fontName fontSize:(CGFloat)fontSize lineSize:(CGFloat)lineSize alignment:(CCTextAlignment)alignment glyphs:(CCGlyphCollection)glyphs customGlyphs:(NSString*)customGlyphs
{
    if (self = [super init])
        return nil;
    return nil;
}

- (instancetype) initWithFontAtlas:(CCFontAtlas*)atlas alignment:(CCTextAlignment)alignment
{
    if (self = [super init]) {
        _lettersInfo = [[NSMutableArray alloc] initWithCapacity:30];
        _fontAtlas = atlas;
        _alignment = alignment;
        _lineBreakWithoutSpaces = NO;
        _displayedColor = ccWHITE;
        _realColor = ccWHITE;
        _cascadeColorEnabled = YES;
        _cascadeOpacityEnabled = YES;
        _displayedOpacity = 255;
        _realOpacity = 255;
        _isOpacityModifyRGB = YES;
        
        CCTexture* tex = [_fontAtlas textureAtSlot:0];
        _reusedLetter = [[CCSprite alloc] initWithTexture:tex];
        [_reusedLetter setOpacityModifyRGB:_isOpacityModifyRGB];
        
        self = [super initWithTexture:tex capacity:30];
    }
    return self;
}

- (void) setString:(NSString *)label
{
    [self setText:label lineWidth:_width alignment:CCTextAlignmentCenter lineBreakWithoutSpaces:NO];
}

- (BOOL) setText:(NSString*)text lineWidth:(CGFloat)lineWidth alignment:(CCTextAlignment)alignment lineBreakWithoutSpaces:(BOOL)lineBreakWithoutSpaces
{
    if (!_fontAtlas)
        return NO;
    
    // carloX
    // reset the string
    [self resetCurrentString];
    
    
    _width                  = lineWidth;
    _alignment              = alignment;
    _lineBreakWithoutSpaces = lineBreakWithoutSpaces;
    
    // store locally common line height
    _commonLineHeight = [_fontAtlas commonLineHeight];
    if (_commonLineHeight <= 0)
        return NO;
    
    _cascadeColorEnabled = YES;
    
    [self setCurrentString:text];
    [self setOriginalString:text];
    
    // align text
    [self alignText];
    
    // done here
    return YES;
}

- (void) setAlignment:(CCTextAlignment)alignment
{
    // store the new alignment
    if (alignment != _alignment) {
        // store
        _alignment = alignment;
        
        // reset the string
        [self resetCurrentString];
        
        // need to align text again
        [self alignText];
    }
}

- (void) setWidth:(CGFloat)width
{
    if (width != _width) {
        // store
        _width = width;
        
        // reset the string
        [self resetCurrentString];
        
        // need to align text again
        [self alignText];
    }
}

- (void) setLineBreakWithoutSpace:(BOOL)breakWithoutSpace
{
    if (breakWithoutSpace != _lineBreakWithoutSpaces) {
        // store
        _lineBreakWithoutSpaces = breakWithoutSpace;
        
        // need to align text again
        [self alignText];
    }
}


- (void) setScale:(float)scale
{
    [super setScale:scale];
    [self alignText];
}

- (void) setScaleX:(float)scaleX
{
    [super setScaleX:scaleX];
    [self alignText];
}

- (void) setScaleY:(float)scaleY
{
    [super setScaleY:scaleY];
    [self alignText];
}


- (void) alignText
{
    if (_textureAtlas)
        [_textureAtlas removeAllQuads];

    
    [_fontAtlas prepareLetterDefinitions:_currentUTF16String];
    
    [CCLabelTextFormatter makeStringSprites:self];
    if ([CCLabelTextFormatter multilineText:self]) {
        [CCLabelTextFormatter makeStringSprites:self];
    }

    [CCLabelTextFormatter alignText:self];
    

    
//    int strLen = cc_wcslen(_currentUTF16String);
//    if (_children && _children->count() != 0)
//    {
//        for (auto child: *_children)
//        {
//            Node* pNode = static_cast<Node*>( child );
//            if (pNode)
//            {
//                int tag = pNode->getTag();
//                if(tag < 0 || tag >= strLen)
//                    SpriteBatchNode::removeChild(pNode, true);
//            }
//        }
//    }
    
    [_reusedLetter setBatchNode:nil];
   
    int vaildIndex = 0;
   // CCSprite* child = nil;
   // CGRect uvRect;
    for (int ctr = 0; ctr < [_currentUTF16String length]; ++ctr)
    {
        CCLetterInfo* info = [_lettersInfo objectAtIndex:ctr];
        if (info.definition.validDefinition)
        {
//            child = static_cast<Sprite*>( this->getChildByTag(ctr) );
//            if (child)
//            {
//                uvRect.size.height = info.definition.height;
//                uvRect.size.width  = info.definition.width;
//                uvRect.origin.x    = info.definition.U;
//                uvRect.origin.y    = info.definition.V;
//                
//                [child setTexture:[_fontAtlas textureAtSlot:info.definition.textureID]];
//                [child setTextureRect:uvRect];
//            }
            
            [self updateSprite:_reusedLetter withLetterDefinition:info.definition texture:[_fontAtlas textureAtSlot:info.definition.textureID]];
            [_reusedLetter setPosition:info.position];
            [self insertQuadFromSprite:_reusedLetter quadIndex:vaildIndex++];
        }
    }

}

- (BOOL) computeAdvancesForString:(NSString*)stringToRender
{
    if (_advances)
    {
        free(_advances);
        _advances = 0;
    }

    _advances = [_fontAtlas.font getAdvancesForText:stringToRender];
    
    return _advances != nil;
}

- (BOOL) setOriginalString:(NSString*)stringToSet
{
    if (_originalUTF16String) {
        _originalUTF16String = nil;
    }
    
    _originalUTF16String = [stringToSet copy];
    
    return YES;
}

- (BOOL) setCurrentString:(NSString*)stringToSet
{
    // set the new string
    if (_currentUTF16String) {
        _currentUTF16String = nil;
    }
    //
    _currentUTF16String  = [stringToSet copy];
    // compute the advances
    return [self computeAdvancesForString:stringToSet];

}

- (void) resetCurrentString
{
    if ((!_currentUTF16String) && (!_originalUTF16String))
        return;
    
    
    _currentUTF16String = [_originalUTF16String copy];
    
}

- (CCSprite*) updateSprite:(CCSprite*)spriteToUpdate withLetterDefinition:(CCFontLetterDefinition*)theDefinition texture:(CCTexture*)theTexture
{
    if (!spriteToUpdate) {
        return nil;
    } else {
        CGRect uvRect;
        uvRect.size.height = theDefinition.height;
        uvRect.size.width  = theDefinition.width;
        uvRect.origin.x    = theDefinition.U;
        uvRect.origin.y    = theDefinition.V;
        
        
        CCSpriteFrame* frame = [CCSpriteFrame frameWithTexture:theTexture rect:uvRect];
        if (frame) {
            [spriteToUpdate setBatchNode:self];
            [spriteToUpdate setTexture:theTexture];
            [spriteToUpdate setSpriteFrame:frame];
            [spriteToUpdate setAnchorPoint:ccp(theDefinition.anchorX, theDefinition.anchorY)];
        }
        
        return spriteToUpdate;
    }

}


- (BOOL)recordLetterInfo:(CGPoint)point character:(unichar)theChar spriteIndex:(NSInteger)spriteIndex
{
    if (spriteIndex >= [_lettersInfo count])
    {
        CCLetterInfo* tmpInfo = [CCLetterInfo new];
        [_lettersInfo addObject:tmpInfo];
    }
    CCLetterInfo* tmpInfo = [_lettersInfo objectAtIndex:spriteIndex];
    tmpInfo.definition = [_fontAtlas fontLetterDefinitionForCharacter:theChar];
    tmpInfo.position = point;
    tmpInfo.contentSize = CGSizeMake(tmpInfo.definition.width, tmpInfo.definition.height);
    
    return tmpInfo.definition.validDefinition;
}

- (BOOL) recordPlaceholderInfo:(NSInteger)spriteIndex
{
    if (spriteIndex >= [_lettersInfo count]) {
        CCLetterInfo* tmpInfo = [CCLetterInfo new];
        [_lettersInfo addObject:tmpInfo];
    }
    
    CCLetterInfo* tmpInfo = [_lettersInfo objectAtIndex:spriteIndex];
    tmpInfo.definition.validDefinition = NO;
    
    return NO;
}

- (void) addChild:(CCNode *)node z:(NSInteger)z name:(NSString *)name
{
    NSAssert(NO, @"addChild: is not supported on CCLabel.");
}

#pragma mark - CCLabelTextFormatProtocol
- (CCSprite*) letter:(NSInteger)ID
{
    if (ID < [self stringLength])
    {
//        CCLetterInfo* info = [_lettersInfo objectAtIndex:ID];
//        
//        if(info.definition.validDefinition == false)
//            return nil;
//        
//        Sprite* sp = static_cast<Sprite*>(this->getChildByTag(ID));
//        
//        if (!sp)
//        {
//            Rect uvRect;
//            uvRect.size.height = _lettersInfo[ID].def.height;
//            uvRect.size.width  = _lettersInfo[ID].def.width;
//            uvRect.origin.x    = _lettersInfo[ID].def.U;
//            uvRect.origin.y    = _lettersInfo[ID].def.V;
//            
//            sp = new Sprite();
//            sp->initWithTexture(&_fontAtlas->getTexture(_lettersInfo[ID].def.textureID),uvRect);
//            sp->setBatchNode(this);
//            sp->setAnchorPoint(Point(_lettersInfo[ID].def.anchorX, _lettersInfo[ID].def.anchorY));
//            sp->setPosition(_lettersInfo[ID].position);
//            sp->setOpacity(_realOpacity);
//            
//            this->addSpriteWithoutQuad(sp, ID, ID);
//            sp->release();
//        }
//        return sp;
    }
    
    return nil;
}

- (CGFloat) letterPosXLeft:(NSInteger)idx
{
    CCLetterInfo* info = [_lettersInfo objectAtIndex:idx];
    return info.position.x * _scaleX - (info.contentSize.width * _scaleX * info.definition.anchorX);
}

- (CGFloat) letterPosXRight:(NSInteger)idx
{
    CCLetterInfo* info = [_lettersInfo objectAtIndex:idx];
    return info.position.x * _scaleX + (info.contentSize.width * _scaleX * info.definition.anchorX);
}


- (CGFloat) commonLineHeight
{
    return _commonLineHeight;
}

- (CGFloat) kerningForCharsPairWithFirst:(unichar)first andSecond:(unichar)second
{
    return 0.0f;
}

- (CGFloat) xOffsetForChar:(unichar)c
{
    CCFontLetterDefinition* tempDefinition = [_fontAtlas fontLetterDefinitionForCharacter:c];
    if (!tempDefinition)
        return -1.0f;
    return tempDefinition.offsetX;
}

- (CGFloat) yOffsetForChar:(unichar)c
{
    CCFontLetterDefinition* tempDefinition = [_fontAtlas fontLetterDefinitionForCharacter:c];
    if (!tempDefinition)
        return -1.0f;
    return tempDefinition.offsetY;
}

- (CGFloat) advanceForChar:(unichar)c hintPositionInString:(NSInteger)hintPos
{
    if (_advances) {
        CCFontLetterDefinition* tempDefinition = [_fontAtlas fontLetterDefinitionForCharacter:c];
        if (!tempDefinition)
            return -1.0f;
        return _advances[hintPos].width;
    } else {
        return -1.0f;
    }
}

- (CGRect) rectForChar:(unichar)c
{
    return [[_fontAtlas font] rectForCharacter:c];
}


// string related stuff
- (NSInteger) stringNumLines
{
    NSInteger quantityOfLines = 1;
    
    NSUInteger stringLen = [_currentUTF16String length];
    if (stringLen == 0)
        return -1;
    
    // count number of lines
    for (NSUInteger i = 0; i < stringLen - 1; ++i) {
        unichar c = [_currentUTF16String characterAtIndex:i];
        if (c == '\n') {
            quantityOfLines++;
        }
    }
    
    return quantityOfLines;
}

- (NSInteger) stringLength
{
    return [_currentUTF16String length];
}

- (unichar) charAtStringPosition:(NSInteger)position
{
    return [_currentUTF16String characterAtIndex:position];
}

- (const char*) UTF8String
{
    return [_currentUTF16String UTF8String];
}

- (void) assignNewUTF8String:(NSString *)newString
{
    [self setCurrentString:newString];
}

- (CCTextAlignment) textAlignment
{
    return _alignment;
}

// label related stuff
- (CGFloat) maxLineWidth
{
    return _width;
}

- (BOOL) breakLineWithoutSpace
{
    return _lineBreakWithoutSpaces;
}

- (CGSize) labelContentSize
{
    return [self contentSize];
}

- (void) setLabelContentSize:(CGSize)labelContentSize
{
    [self setContentSize:labelContentSize];
}

#pragma mark - CCRGBAProtocol

- (BOOL) doesOpacityModifyRGB
{
    return _isOpacityModifyRGB;
}

- (void) setOpacityModifyRGB:(BOOL)isOpacityModifyRGB
{
    _isOpacityModifyRGB = isOpacityModifyRGB;
    
    for (CCNode* child in _children) {
        if ([child conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            [(id<CCRGBAProtocol>)child setOpacityModifyRGB:isOpacityModifyRGB];
        }
    }
    
    [_reusedLetter setOpacityModifyRGB:YES];
}

- (unsigned char) opacity
{
    return _realOpacity;
}

- (unsigned char) displayedOpacity
{
    return _displayedOpacity;
}


- (void) setOpacity:(GLubyte)opacity
{
    _displayedOpacity = _realOpacity = opacity;
    [_reusedLetter setOpacity:opacity];
	if( _cascadeOpacityEnabled ) {
		GLubyte parentOpacity = 255;
        if ([_parent conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            id<CCRGBAProtocol> parentRGBA = (id<CCRGBAProtocol>)_parent;
            if ([parentRGBA isCascadeOpacityEnabled])
                parentOpacity = [parentRGBA displayedOpacity];
        }
        [self updateDisplayedOpacity:parentOpacity];
	}
}

- (void) updateDisplayedOpacity:(GLubyte)parentOpacity
{
    _displayedOpacity = _realOpacity * parentOpacity/255.0;
    
    for (CCSprite* child in _children) {
        [child updateDisplayedOpacity:_displayedOpacity];
    }
    
    ccV3F_C4B_T2F_Quad *quads = [_textureAtlas quads];
    int count = [_textureAtlas totalQuads];
    ccColor4B color4 = (ccColor4B){_displayedColor.r, _displayedColor.g, _displayedColor.b, _displayedOpacity};

    if (_isOpacityModifyRGB)
    {
        color4.r *= _displayedOpacity/255.0f;
        color4.g *= _displayedOpacity/255.0f;
        color4.b *= _displayedOpacity/255.0f;
    }
    for (int index = 0; index < count; ++index)
    {
        quads[index].bl.colors = color4;
        quads[index].br.colors = color4;
        quads[index].tl.colors = color4;
        quads[index].tr.colors = color4;
        [_textureAtlas updateQuad:&quads[index] atIndex:index];
    }

}


- (BOOL) isCascadeOpacityEnabled
{
    return NO;
}

- (void) setCascadeOpacityEnabled:(BOOL)cascadeOpacityEnabled
{
    _cascadeOpacityEnabled = cascadeOpacityEnabled;
}

- (ccColor3B) color
{
    return _realColor;
}

- (ccColor3B) displayedColor
{
    return _displayedColor;
}

- (void) setColor:(ccColor3B)color
{
    _displayedColor = _realColor = color;
    [_reusedLetter setColor:color];
	if( _cascadeColorEnabled )
    {
		ccColor3B parentColor = ccWHITE;
        
        if ([_parent conformsToProtocol:@protocol(CCRGBAProtocol)]) {
            parentColor = [(id<CCRGBAProtocol>)_parent displayedColor];
        }
        
        [self updateDisplayedColor:parentColor];
	}
}

- (void) updateDisplayedColor:(ccColor3B)parentColor
{
    _displayedColor.r = _realColor.r * parentColor.r/255.0;
	_displayedColor.g = _realColor.g * parentColor.g/255.0;
	_displayedColor.b = _realColor.b * parentColor.b/255.0;
    
    for (CCSprite* child in _children) {
        [child updateDisplayedColor:_displayedColor];
    }
    
    
    ccV3F_C4B_T2F_Quad *quads = [_textureAtlas quads];
    int count = [_textureAtlas totalQuads];
    ccColor4B color4 = (ccColor4B){ _displayedColor.r, _displayedColor.g, _displayedColor.b, _displayedOpacity };
    
    // special opacity for premultiplied textures
    if (_isOpacityModifyRGB)
    {
        color4.r *= _displayedOpacity/255.0f;
        color4.g *= _displayedOpacity/255.0f;
        color4.b *= _displayedOpacity/255.0f;
    }
    for (int index=0; index<count; ++index)
    {
        quads[index].bl.colors = color4;
        quads[index].br.colors = color4;
        quads[index].tl.colors = color4;
        quads[index].tr.colors = color4;
        [_textureAtlas updateQuad:&quads[index] atIndex:index];
    }
}

- (BOOL) isCascadeColorEnabled
{
    return NO;
}

- (void) setCascadeColorEnabled:(BOOL)cascadeColorEnabled
{
    _cascadeColorEnabled = cascadeColorEnabled;
}



@end
