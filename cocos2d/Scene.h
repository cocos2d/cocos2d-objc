/* cocos2d for iPhone
 *
 * http://www.cocos2d-iphone.org
 *
 * Copyright (C) 2008,2009 Ricardo Quesada
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the 'cocos2d for iPhone' license.
 *
 * You will find a copy of this license within the cocos2d for iPhone
 * distribution inside the "LICENSE" file.
 *
 */


#import <UIKit/UIKit.h>

#import "CocosNode.h"

/** Scene is a subclass of CocosNode that is used only as an abstract concept.
 
 Scene an CocosNode are almost identical with the difference that Scene has it's
 anchor point (by default) at the center of the screen.

 For the moment Scene has no other logic than that, but in future releases it might have
 additional logic.

 It is a good practice to use and Scene as the parent of all your nodes.
*/
@interface Scene : CocosNode {

}
@end
