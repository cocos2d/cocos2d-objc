//
//  CCLabelTextFormatter.h
//  cocos2d-ios
//
//  Created by Sergey Fedortsov on 17.11.13.
//
//

#import "CCLabelTextFormatProtocol.h"

@interface CCLabelTextFormatter : NSObject
+ (BOOL) multilineText:(id<CCLabelTextFormatProtocol>)label;
+ (BOOL) alignText:(id<CCLabelTextFormatProtocol>)label;
+ (BOOL) makeStringSprites:(id<CCLabelTextFormatProtocol>)label;

@end
