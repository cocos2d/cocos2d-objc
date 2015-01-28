#import "CCNode+RecursiveDescription.h"


@implementation CCNode (RecursiveDescription)

- (NSString *)recursiveDescription
{
    return [self recursivelyListChildren:0];
}

- (NSString *)recursivelyListChildren:(NSUInteger)depth
{
    NSString *padding = @"";
    for (int i = 0; i < depth; i++)
    {
        padding = [NSString stringWithFormat:@"%@ | ", padding];
    }

    NSString *description = [NSString stringWithFormat:@"%@%@", padding, self.description];
    NSMutableArray *children = [@[description] mutableCopy];

    for (CCNode *node in self.children)
    {
        [children addObject:[node recursivelyListChildren:depth + 1]];
    }

    return [children componentsJoinedByString:@"\n"];
}

@end
