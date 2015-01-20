#import "CCFileMetaData.h"


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

- (NSString *)description
{
    return [NSString stringWithFormat:@"filename: %@, UIScale: %d, localizations: %@", _filename, _useUIScale, _localizations];
}

@end
