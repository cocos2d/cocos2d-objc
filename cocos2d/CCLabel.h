//
//  CCLabel.h
//  CCLabelPort
//
//  Created by Sergey Fedortsov on 13.11.13.
//  Copyright (c) 2013 Sergey Fedortsov. All rights reserved.
//

#import "CCSpriteBatchNode.h"

#import "CCLabelTextFormatProtocol.h"



@interface CCLabel : CCSpriteBatchNode <CCLabelProtocol, CCRGBAProtocol, CCLabelTextFormatProtocol>

@end
