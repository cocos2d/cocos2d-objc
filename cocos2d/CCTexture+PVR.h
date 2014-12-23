#import "Platforms/CCGL.h"
#import "CCTexture.h"


@class CCFile;


@interface CCTexture(PVR)

-(id)initPVRWithCCFile:(CCFile *)file options:(NSDictionary *)options;

@end


