//
// Created by Nicky Weber on 19.01.15.
//

#import <Foundation/Foundation.h>


@interface CCFileMetaData : NSObject

@property (nonatomic, copy) NSString *filename;
@property (nonatomic, copy) NSDictionary *localizations;
@property (nonatomic) BOOL useUIScale;

- (instancetype)initWithFilename:(NSString *)filename;

@end
