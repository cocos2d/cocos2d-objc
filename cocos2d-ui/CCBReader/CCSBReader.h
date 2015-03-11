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

#import <Foundation/Foundation.h>

#import "CCNode.h"
#import "CCSpriteFrame.h"
#import "CCAnimationManager.h"

@protocol CCSBReaderDidLoad <NSObject>
@optional
- (void) didLoadFromSB;

@end

@interface CCNode(CCSBReader) <CCSBReaderDidLoad>

@end

/**
 The CCSBReader loads SpriteBuilder (SB) documents.
 
 For the most part you'll just use one of these two methods:
 
    // load a SB document as a CCNode instance
    CCNode* myNode = [CCSBReader load:@"MyNode"];

    // load a SB document of type "Sprite" as a CCSprite instance
    CCSprite* mySprite = (CCSprite*)[CCSBReader load:@"MySprite"];

    // load a SB document wrapped in a CCScene instance
    CCScene* scene = [CCSBReader loadAsScene:@"MyNode"];
 
 You can optionally pass an owner object to the CCSBReader load methods. This owner object then gets assigned all of the SpriteBuilder document's member variables that are marked to be set to the "Owner".
 In all other cases owner is nil and assigning variables to Owner discards their assignment.
 
 When a SpriteBuilder document was loaded, all nodes created from the document will receive the didLoadFromSB message, if implemented as follows:
 
 **Objective-C:**
 
    -(void) didLoadFromSB {
        NSLog(@"%@ did load", self);
    }

 **Swift:**
 
    func didLoadFromSB() {
        NSLog("%@ did load", self)
    }
 
 Nodes created from a SpriteBuilder document will also have a valid CCAnimationManager instance assigned to their [CCNode animationManager] property.
 */
@interface CCSBReader : NSObject
{
    NSData* data;
    unsigned char* bytes;
    int currentByte;
    int currentBit;
    
    NSMutableArray* stringCache;
    NSMutableSet* loadedSpriteSheets;
    
    id owner;
    
    CCAnimationManager* animationManager;
    NSMutableDictionary* actionManagers;
    NSMutableSet* animatedProps;
    NSMutableDictionary* nodeMapping;//Maps UUID -> Node
	NSMutableArray * postDeserializationUUIDFixup;
}

/// -----------------------------------------------------------------------
/// @name Setup
/// -----------------------------------------------------------------------

/**
 *  Call this method to configure the CCFileUtils to work correctly with SpriteBuilder. It will setup search paths for the resources to use with the current device and resolution. It assumes that the SpriteBuilder resources has been published to a directory named Published-iOS that has been added as a blue folder in Xcode.
 */
+ (void) configureCCFileUtils;

/// -----------------------------------------------------------------------
/// @name Instantiation
/// -----------------------------------------------------------------------

/**
 *  Creates a new CCSBReader. You don't normally need to do this because you can directly use most methods, ie `[CCSBReader load:@"MyNode"];`.
 *
 *  @return A new CCSBReader.
 */
+ (CCSBReader*) reader;

/// -----------------------------------------------------------------------
/// @name Loading SpriteBuilder documents
/// -----------------------------------------------------------------------

/**
 *  Loads a sbi-file with the specified name. Using the extension is optional, e.g. both MyNodeGraph and MyNodeGraph.sbi will work.
 *
 *  @param file Name of the file to load.
 *
 *  @return The loaded node graph.
 */
- (CCNode*) load:(NSString*) file;

/**
 *  Loads a sbi-file with the specified name. Using the extension is optional, e.g. both MyNodeGraph and MyNodeGraph.sbi will work.
 *
 *  @param file Name of the file to load.
 *
 *  @return The loaded node graph.
 */
+ (CCNode*) load:(NSString*) file;

/**
 *  Loads a sbi-file with the specified name and wraps it in a CCScene node. Using the extension is optional, e.g. both MyNodeGraph and MyNodeGraph.sbi will work.
 *
 *  @param file Name of the file to load.
 *
 *  @return The loaded node graph.
 */
+ (CCScene*) loadAsScene:(NSString*) file;

/// -----------------------------------------------------------------------
/// @name Loading SpriteBuilder documents with custom owner
/// -----------------------------------------------------------------------

/**
 *  Loads a sbi-file with the specified name and owner. Using the extension is optional, e.g. both MyNodeGraph and MyNodeGraph.sbi will work.
 *
 *  @param file Name of the file to load.
 *  @param owner The owner object used to load the file.
 *
 *  @return The loaded node graph.
 */
- (CCNode*) load:(NSString*) file owner:(id)owner;

/**
 *  Loads a sbi-file from the provided NSData object. This method is useful if you load sbi-files from the internet. If you are not using the owner variable, pass NULL.
 *
 *  @param data       Data object to load the sbi-file from.
 *  @param owner      The owner object used to load the file, or NULL if not used.
 *
 *  @return The loaded node graph.
 */
- (CCNode*) loadWithData:(NSData*) data owner:(id)owner;

/**
 *  Loads a sbi-file with the specified name and owner. Using the extension is optional, e.g. both MyNodeGraph and MyNodeGraph.sbi will work.
 *
 *  @param file Name of the file to load.
 *  @param owner The owner object used to load the file.
 *
 *  @return The loaded node graph.
 */
+ (CCNode*) load:(NSString*) file owner:(id)owner;

/**
 *  Loads a sbi-file with the specified name and owner and wraps it in a CCScene node. Using the extension is optional, e.g. both MyNodeGraph and MyNodeGraph.sbi will work.
 *
 *  @param file Name of the file to load.
 *  @param owner The owner object used to load the file.
 *
 *  @return The loaded node graph.
 */
+ (CCScene*) loadAsScene:(NSString *)file owner:(id)owner;

/// -----------------------------------------------------------------------
/// @name Animations
/// -----------------------------------------------------------------------

/**
 *  Once a sb-file has been loaded, the animationManager property will be set to contain the top level CCAnimationManager
 */
@property (nonatomic,strong) CCAnimationManager* animationManager;

@end

