#import "CCPackageInstallData.h"
#import "CCPackage.h"


@implementation CCPackageInstallData

- (instancetype)initWithPackage:(CCPackage *)package
{
    NSAssert(package != nil, @"package must not be nil.");

    self = [super init];
    if (self)
    {
        self.package = package;
    }

    return self;
}

@end
