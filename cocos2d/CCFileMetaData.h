//
// Created by Nicky Weber on 19.01.15.
//

#import <Foundation/Foundation.h>

/**
 Meta data of a file describing certain details.
 
 @since 4.0
 */
@interface CCFileMetaData : NSObject

/**
 The filename to be actually used. Spritebuilder is making use of this to alias filenames, like a wav file becoming an ogg file for Android platforms.
 
 @since 4.0
 */
@property (nonatomic, copy) NSString *filename;

/**
 A dictionary containing a filename per languageID. Structure looks like this:
 
 {
    "es" : "path/to/file-es.exension",
    "en" : "path/to/file-en.exension"
 }
 
 @since 4.0
 */
@property (nonatomic, copy) NSDictionary *localizations;

/**
 Whether an image should be scaled for UI purposes or not.
 
 @since 4.0
 */
@property (nonatomic) BOOL useUIScale;

/**
 Convenience initializer.
 
 @param filename The filename to be used.
 
 @return an Instance of CCFileMetaData
 
 @since 4.0
 */
- (instancetype)initWithFilename:(NSString *)filename;

@end
