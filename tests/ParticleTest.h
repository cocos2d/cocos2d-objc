
#import "cocos2d.h"

@class CCSprite;

//CLASS INTERFACE
#import "BaseAppController.h"

@interface AppController : BaseAppController
@end

@class Emitter;

@interface ParticleDemo : CCLayerColor
{
	CCParticleSystem	*emitter_;
	CCSprite			*background;
}

@property (readwrite,retain) CCParticleSystem *emitter;

-(NSString*) title;
-(NSString*) subtitle;

@end

@interface DemoFirework : ParticleDemo
{}
@end

@interface DemoFire : ParticleDemo
{}
@end

@interface DemoSun : ParticleDemo
{}
@end

@interface DemoGalaxy : ParticleDemo
{}
@end

@interface DemoFlower : ParticleDemo
{}
@end

@interface DemoBigFlower : ParticleDemo
{}
@end

@interface DemoRotFlower : ParticleDemo
{}
@end

@interface DemoMeteor : ParticleDemo
{}
@end

@interface DemoSpiral : ParticleDemo
{}
@end

@interface DemoExplosion : ParticleDemo
{}
@end

@interface DemoSmoke : ParticleDemo
{}
@end

@interface DemoSnow : ParticleDemo
{}
@end

@interface DemoRain : ParticleDemo
{}
@end

@interface DemoModernArt : ParticleDemo
{}
@end

@interface DemoRing : ParticleDemo
{}
@end

@interface ParallaxParticle : ParticleDemo
{}
@end

@interface ParticleDesigner1 : ParticleDemo
{}
@end

@interface ParticleDesigner2 : ParticleDemo
{}
@end

@interface ParticleDesigner3 : ParticleDemo
{}
@end

@interface ParticleDesigner4 : ParticleDemo
{}
@end

@interface ParticleDesigner5 : ParticleDemo
{}
@end

@interface ParticleDesigner6 : ParticleDemo
{}
@end

@interface ParticleDesigner7 : ParticleDemo
{}
@end

@interface ParticleDesigner8 : ParticleDemo
{}
@end

@interface ParticleDesigner9 : ParticleDemo
{}
@end

@interface ParticleDesigner10 : ParticleDemo
{}
@end

@interface ParticleDesigner11 : ParticleDemo
{}
@end

@interface ParticleDesigner12 : ParticleDemo
{}
@end

@interface RadiusMode1 : ParticleDemo
{}
@end

@interface RadiusMode2 : ParticleDemo
{}
@end

@interface Issue704 : ParticleDemo
{}
@end

@interface Issue872 : ParticleDemo
{}
@end

@interface Issue870 : ParticleDemo
{
	int index;
}
@end

@interface Issue1201 : ParticleDemo
{}
@end

@interface ParticleBatchHybrid : ParticleDemo
{
	CCNode *parent1;
	CCNode *parent2;
}
@end

@interface ParticleBatchMultipleEmitters : ParticleDemo
{}
@end

@interface ParticleReorder : ParticleDemo
{
	NSUInteger order;
}
@end

@interface MultipleParticleSystems : ParticleDemo
{}
@end

@interface MultipleParticleSystemsBatched : ParticleDemo
{
	CCParticleBatchNode *batchNode_;
}
@end

@interface AddAndDeleteParticleSystems : ParticleDemo
{
	CCParticleBatchNode *batchNode_;
}
@end

@interface ReorderParticleSystems : ParticleDemo
{
	CCParticleBatchNode *batchNode_;
}
@end

@interface PremultipliedAlphaTest : ParticleDemo
@end

@interface PremultipliedAlphaTest2 : ParticleDemo
@end
