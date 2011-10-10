
#import "cocos2d.h"

@class CCSprite;
@class CCParticleBatchNode; 

//CLASS INTERFACE
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
@interface AppController : NSObject <UIApplicationDelegate>
{
	UIWindow *window;
}
@end

#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
@interface cocos2dmacAppDelegate : NSObject <NSApplicationDelegate>
{
	NSWindow	*window_;
	MacGLView	*glView_;
}

@property (assign) IBOutlet NSWindow	*window;
@property (assign) IBOutlet MacGLView	*glView;

- (IBAction)toggleFullScreen:(id)sender;

@end
#endif // Mac

@class Emitter;

@interface ParticleDemoBatch : CCLayerColor
{
	CCParticleSystem	*emitter_;
	CCSprite			*background;
	CCParticleBatchNode* batchNode_;
}

@property (readwrite,retain) CCParticleSystem *emitter;

-(NSString*) title;
-(NSString*) subtitle;

@end

@interface DemoBatchFirework : ParticleDemoBatch
{}
@end

@interface DemoBatchFire : ParticleDemoBatch
{}
@end

@interface DemoBatchSun : ParticleDemoBatch
{}
@end

@interface DemoBatchGalaxy : ParticleDemoBatch
{}
@end

@interface DemoBatchFlower : ParticleDemoBatch
{}
@end

@interface DemoBatchBigFlower : ParticleDemoBatch
{}
@end

@interface DemoBatchRotFlower : ParticleDemoBatch
{}
@end

@interface DemoBatchMeteor : ParticleDemoBatch
{}
@end

@interface DemoBatchSpiral : ParticleDemoBatch
{}
@end

@interface DemoBatchExplosion : ParticleDemoBatch
{}
@end

@interface DemoBatchSmoke : ParticleDemoBatch
{}
@end

@interface DemoBatchSnow : ParticleDemoBatch
{}
@end

@interface DemoBatchRain : ParticleDemoBatch
{}
@end

@interface DemoBatchModernArt : ParticleDemoBatch
{}
@end

@interface DemoBatchRing : ParticleDemoBatch
{}
@end

@interface ParallaxParticle : ParticleDemoBatch
{}
@end

@interface ParticleDesigner1 : ParticleDemoBatch
{}
@end

@interface ParticleDesigner2 : ParticleDemoBatch
{}
@end

@interface ParticleDesigner3 : ParticleDemoBatch
{}
@end

@interface ParticleDesigner4 : ParticleDemoBatch
{}
@end

@interface ParticleDesigner5 : ParticleDemoBatch
{}
@end

@interface ParticleDesigner6 : ParticleDemoBatch
{}
@end

@interface ParticleDesigner7 : ParticleDemoBatch
{}
@end

@interface ParticleDesigner8 : ParticleDemoBatch
{}
@end

@interface ParticleDesigner9 : ParticleDemoBatch
{}
@end

@interface ParticleDesigner10 : ParticleDemoBatch
{}
@end

@interface ParticleDesigner11 : ParticleDemoBatch
{}
@end

@interface ParticleDesigner12 : ParticleDemoBatch
{}
@end

@interface RadiusMode1 : ParticleDemoBatch
{}
@end

@interface RadiusMode2 : ParticleDemoBatch
{}
@end

@interface Issue704 : ParticleDemoBatch
{}
@end

@interface Issue872 : ParticleDemoBatch
{}
@end

@interface Issue870 : ParticleDemoBatch
{
	int index;
}
@end

@interface MultipleParticleSystems : ParticleDemoBatch
{}
@end

@interface MultipleParticleSystemsBatched : ParticleDemoBatch
{
}
@end

@interface AddAndDeleteParticleSystems : ParticleDemoBatch
{
}
@end

@interface ReorderParticleSystems : ParticleDemoBatch
{
}
@end


