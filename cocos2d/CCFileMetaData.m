#import "CCFileMetaData.h"
#import "ioapi.h"


@implementation CCFileMetaData

- (instancetype)initWithFilename:(NSString *)filename
{
    self = [super init];
    if (self)
    {
        self.filename = filename;
    }

    return self;
}

@end
