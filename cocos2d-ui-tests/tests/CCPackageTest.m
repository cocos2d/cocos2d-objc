//
//  CCPackageTest.m
//  cocos2d-tests-ios
//
//  Created by Nicky Weber on 19.09.14.
//  Copyright (c) 2014 Cocos2d. All rights reserved.
//
#import "CCPlatformTextField.h"
#import "TestBase.h"
#import "CCPackageManager.h"
#import "CCPackageManagerDelegate.h"
#import "CCPackage.h"
#import "CCPackageConstants.h"
#import "AppDelegate.h"



@interface CCPackageTestURLProtocol : NSURLProtocol

@end


@implementation CCPackageTestURLProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest*)theRequest
{
    return [theRequest.URL.scheme caseInsensitiveCompare:@"http"] == NSOrderedSame;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)theRequest
{
    return theRequest;
}

- (void)startLoading
{
    NSString *fileName = [self.request.URL lastPathComponent];

    NSString *pathToPackage = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"Resources-shared/Packages/%@", fileName] ofType:nil];
    NSData *data = [NSData dataWithContentsOfFile:pathToPackage];

    NSHTTPURLResponse *response;
    if (pathToPackage)
    {
    response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:nil];
    }
    else
    {
        response = [[NSHTTPURLResponse alloc] initWithURL:self.request.URL
                                                                  statusCode:404
                                                                 HTTPVersion:@"HTTP/1.1"
                                                                headerFields:nil];
    }


    id<NSURLProtocolClient> client = [self client];
    [client URLProtocol:self didLoadData:data];
    [client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    [client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading
{
    NSLog(@"Package test: Something went wrong.");
}

@end


#pragma mark - Test class

@interface CCPackageTest : TestBase <CCPackageManagerDelegate>

@property (nonatomic, strong) CCPackage *package;

@end


@implementation CCPackageTest

- (void) setupPackageTest
{
    [self setupLocalHTTPRequests];

    [self.contentNode removeAllChildren];

    [self removePersistedPackages];

    [self removeAllPackages];

    [self resetCocos2d];

    [self cleanDirectories];

    [CCPackageManager sharedManager].delegate = self;

    [self addLabels];

    self.package = [[CCPackageManager sharedManager] downloadPackageWithName:@"testpackage"
                                                                  resolution:@"phonehd"
                                                                   remoteURL:[NSURL URLWithString:@"http://package.request.fake/testpackage-iOS-phonehd.zip"]
                                                         enableAfterDownload:YES];
}

- (void)setupLocalHTTPRequests
{
   [NSURLProtocol registerClass:[CCPackageTestURLProtocol class]];
}

- (void)removePersistedPackages
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:PACKAGE_STORAGE_USERDEFAULTS_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addLabels
{
    CGSize winSize = [CCDirector sharedDirector].viewSize;

    CCLabelTTF *labelSmiley1 = [CCLabelTTF labelWithString:@"Jolly Smiley? ->" fontName:@"HelveticaNeue-Light" fontSize:10 * [CCDirector sharedDirector].UIScaleFactor];
    CCLabelTTF *labelSmiley2 = [CCLabelTTF labelWithString:@"<- Angry Smiley?" fontName:@"HelveticaNeue-Light" fontSize:10 * [CCDirector sharedDirector].UIScaleFactor];

    labelSmiley1.position = ccp((CGFloat) (winSize.width / 2.0 - 75.0), (CGFloat) (winSize.height / 2.0));
    labelSmiley2.position = ccp((CGFloat) (winSize.width / 2.0 + 75.0), (CGFloat) (winSize.height / 2.0));

    [self.contentNode addChild:labelSmiley1];
    [self.contentNode addChild:labelSmiley2];
}

- (void)removeAllPackages
{
    for (CCPackage *aPackage in [[CCPackageManager sharedManager].allPackages mutableCopy])
    {
        [[CCPackageManager sharedManager] deletePackage:aPackage error:nil];
    }
}

- (void)resetCocos2d
{
    [(AppController *) [UIApplication sharedApplication].delegate configureFileUtilsSearchPathAndRegisterSpriteSheets];
}

- (void)cleanDirectories
{
    NSString *installFolder = [CCPackageManager sharedManager].installedPackagesPath;
    NSString *unzipFolder = [NSTemporaryDirectory() stringByAppendingPathComponent:PACKAGE_REL_UNZIP_FOLDER];
    NSString *downloadFolder = [NSTemporaryDirectory() stringByAppendingPathComponent:PACKAGE_REL_DOWNLOAD_FOLDER];

    NSArray *foldersToClean = @[
            [NSURL fileURLWithPath:installFolder],
            [NSURL fileURLWithPath:unzipFolder],
            [NSURL fileURLWithPath:downloadFolder]];


    for (NSURL *folderURL in foldersToClean)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtURL:folderURL
                                                 includingPropertiesForKeys:@[NSURLNameKey]
                                                                    options:NSDirectoryEnumerationSkipsSubdirectoryDescendants
                                                               errorHandler:^BOOL(NSURL *url, NSError *error) {
                                                                   return YES;
                                                               }];

        NSLog(@"%@", folderURL);
        for (NSURL *fileURL in dirEnumerator)
        {
            NSLog(@"\t%@", fileURL);

            NSError *error;
            if (![fileManager removeItemAtURL:fileURL error:&error])
            {
                NSLog(@"Error removing file: %@", error);
            }
        }
    }
}


#pragma mark - CCPackageManagerDelegate

- (void)packageInstallationFinished:(CCPackage *)package
{
    self.subTitle = [NSString stringWithFormat:@"Package installed"];

    CGSize winSize = [CCDirector sharedDirector].viewSize;

    CCSprite *smiley1 = [CCSprite spriteWithImageNamed:@"jollySmiley.png"];
    [self.contentNode addChild:smiley1];
    smiley1.position = ccp((CGFloat) (winSize.width / 2.0 - 20.0), (CGFloat) (winSize.height / 2.0));

    CCSprite *smiley2 = [CCSprite spriteWithImageNamed:@"smileys/angrySmiley.png"];
    [self.contentNode addChild:smiley2];
    smiley2.position = ccp((CGFloat) (winSize.width / 2.0 + 20.0) , (CGFloat) (winSize.height / 2.0));


/*
    NSError *error;
    if (![[CCPackageManager sharedManager] deletePackage:package error:&error])
    {
        NSLog(@"Error removing package: %@", error);
    }
*/
}

- (void)packageInstallationFailed:(CCPackage *)package error:(NSError *)error
{
    self.subTitle = [NSString stringWithFormat:@"Test failed: installation failed."];
    [NSURLProtocol unregisterClass:[CCPackageTestURLProtocol class]];
}

- (void)packageDownloadFinished:(CCPackage *)package
{
    self.subTitle = [NSString stringWithFormat:@"Download finished"];
    [NSURLProtocol unregisterClass:[CCPackageTestURLProtocol class]];
}

- (void)packageDownloadFailed:(CCPackage *)package error:(NSError *)error
{
    self.subTitle = [NSString stringWithFormat:@"Test failed: download failed."];
    [NSURLProtocol unregisterClass:[CCPackageTestURLProtocol class]];
}

- (void)packageUnzippingFinished:(CCPackage *)package
{
    self.subTitle = [NSString stringWithFormat:@"Unzip finished"];
    [NSURLProtocol unregisterClass:[CCPackageTestURLProtocol class]];
}

- (void)packageUnzippingFailed:(CCPackage *)package error:(NSError *)error
{
    self.subTitle = [NSString stringWithFormat:@"Test failed: unzipping failed."];
    [NSURLProtocol unregisterClass:[CCPackageTestURLProtocol class]];
}

- (void)packageDownloadProgress:(CCPackage *)package downloadedBytes:(NSUInteger)downloadedBytes totalBytes:(NSUInteger)totalBytes
{
    NSLog(@"downloading... %u / %u", downloadedBytes, totalBytes);
}

- (void)packageUnzippingProgress:(CCPackage *)package unzippedBytes:(NSUInteger)unzippedBytes totalBytes:(NSUInteger)totalBytes
{
    NSLog(@"unzipping... %u / %u", unzippedBytes, totalBytes);
}

@end
