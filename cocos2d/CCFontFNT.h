//
//  CCFontFNT.h
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 14.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCFont.h"

@interface CCFontFNT : CCFont
- (instancetype) initWithFNTFilePath:(NSString*)fntFilePath;
+ (instancetype) fontWithFNTFilePath:(NSString*)fntFilePath;
@end
