//
// Created by Nicky Weber on 14.01.15.
//

#import <Foundation/Foundation.h>

@protocol CCFileUtilsDatabaseProtocol <NSObject>

@required
- (NSDictionary *)metaDataForFileNamed:(NSString *)filename inSearchPath:(NSString *)searchPath;

@end
