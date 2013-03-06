#import "cocos2d.h"
#import "BaseAppController.h"

//CLASS INTERFACE
@interface AppController : BaseAppController
@end

@interface LayerTest: CCLayer
{
}
-(NSString*) title;
-(NSString*) subtitle;
@end

@interface LayerTestCascadingOpacityA : LayerTest
{
}
@end

@interface LayerTestCascadingOpacityB : LayerTest
{
}
@end

@interface LayerTestCascadingOpacityC : LayerTest
{
}
@end

@interface LayerTestCascadingColorA : LayerTest
{
}
@end

@interface LayerTestCascadingColorB : LayerTest
{
}
@end

@interface LayerTestCascadingColorC : LayerTest
{
}
@end

@interface LayerTest1 : LayerTest
{
}
@end

@interface LayerTest2 : LayerTest
{
}
@end

@interface LayerTestBlend : LayerTest
{
}
@end

@interface LayerGradient : LayerTest
{
}
@end

@interface LayerIgnoreAnchorPointPos : LayerTest
{
}
@end

@interface LayerIgnoreAnchorPointRot : LayerTest
{
}
@end

@interface LayerIgnoreAnchorPointScale : LayerTest
{
}
@end

@interface LayerExtendedBlendOpacityTest : LayerTest
{
}
@end
