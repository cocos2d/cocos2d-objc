//
//  CCLetterInfo.h
//  cocos2d-ios
//
//  Created by Sergey Fedortsov on 18.11.13.
//
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@class CCFontLetterDefinition;
@interface CCLetterInfo : NSObject
@property (nonatomic, retain) CCFontLetterDefinition* definition;
@property (nonatomic, assign) CGPoint position;
@property (nonatomic, assign) CGSize contentSize;
@property (nonatomic, assign) BOOL visible;
@end

