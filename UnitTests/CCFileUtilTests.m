////
////  CCFileUtilTests
////
////  Created by Andy Korth on December 6th, 2013.
////
////
//
//#import <XCTest/XCTest.h>
//#import "cocos2d.h"
//#import "CCUnitTestHelperMacros.h"
//
//
//#import "CCFile_Private.h"
//
//
//@interface CCFileTests : XCTestCase @end
//@implementation CCFileTests
//
//-(void)setUp
//{
//    [CCFile setEncryptionKey:@"44DAACE285BB4204AA31EA6A4D7E17E7"];
//}
//
//-(void)testBasics
//{
//    NSString *name = @"Resources-shared/configCocos2d.plist";
//    CGFloat scale = 1.5;
//    
//    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
//    XCTAssertNotNil(url, @"What happened to the config file?");
//    
//    CCFile *file = [[CCFile alloc] initWithName:name url:url contentScale:scale];
//    
//    XCTAssertEqualObjects(name, file.name);
//    XCTAssertEqualObjects(url, file.url);
//    XCTAssertEqualObjects(url.path, file.absoluteFilePath);
//    XCTAssertEqual(scale, file.contentScale);
//    
//    NSInputStream *stream = [file openInputStream];
//    XCTAssertNotNil(stream);
//    [stream close];
//    
//    XCTAssertNotNil([file loadPlist:nil]);
//    XCTAssertNotNil([file loadData:nil]);
//}
//
//-(void)_testLoadMethods:(NSString *)name
//{
//    NSURL *url = [[NSBundle mainBundle] URLForResource:name withExtension:nil];
//    XCTAssertNotNil(url, @"What happened to the file?");
//    
//    id plist = @{@"Foo": @"Bar"};
//    
//    CCFile *file = [[CCFile alloc] initWithName:name url:url contentScale:1.0];
//    XCTAssertEqualObjects([file loadPlist:nil], plist);
//    
//    // Could probably make a better test... but...
//    XCTAssertTrue([file loadData:nil].length > 0);
//}
//
//-(void)testLoadMethods
//{
//    [self _testLoadMethods:@"CCFileTest.plist"];
//    [self _testLoadMethods:@"CCFileTest.plist.gz"];
//    [self _testLoadMethods:@"CCFileTest.plist.ccp"];
//    [self _testLoadMethods:@"CCFileTest.plist.gz.ccp"];
//}
//
//-(void)testLoadDataMethods
//{
//    NSURL *gzippedURL = [[NSBundle mainBundle] URLForResource:@"CCFileTest.plist.gz" withExtension:nil];
//    CCFile *gzippedFile = [[CCFile alloc] initWithName:@"Test" url:gzippedURL contentScale:1.0];
//    
//    NSURL *encryptedURL = [[NSBundle mainBundle] URLForResource:@"CCFileTest.plist.ccp" withExtension:nil];
//    CCFile *encryptedFile = [[CCFile alloc] initWithName:@"Test" url:encryptedURL contentScale:1.0];
//    
//    XCTAssertEqualObjects([encryptedFile loadData:nil], [gzippedFile loadData:nil]);
//}
//
//#warning TODO
//// Need tests for files larger than 32kb for gzip buffers and 4kb for encryption buffers.
//
//@end
//
//@interface  CCFileUtils()
//+(void) resetSingleton;
//@end
//
//@interface CCFileUtilTests : XCTestCase @end
//@implementation CCFileUtilTests
//
//- (void)setUp
//{
//    [super setUp];
//
//    [CCFileUtils resetSingleton];
//
//    CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
//
//    sharedFileUtils.directoriesDict =
//            [@{CCFileUtilsSuffixiPad : @"resources-tablet",
//                    CCFileUtilsSuffixiPadHD : @"resources-tablethd",
//                    CCFileUtilsSuffixiPhone : @"resources-phone",
//                    CCFileUtilsSuffixiPhoneHD : @"resources-phonehd",
//                    CCFileUtilsSuffixiPhone5 : @"resources-phone",
//                    CCFileUtilsSuffixiPhone5HD : @"resources-phonehd",
//                    CCFileUtilsSuffixDefault : @""} mutableCopy];
//
//    sharedFileUtils.searchMode = CCFileUtilsSearchModeDirectory;
//    [sharedFileUtils buildSearchResolutionsOrder];
//}
//
//-(void)testFullPathForFilenameMissingFile
//{
//	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
//
//	NSString *path = [sharedFileUtils fullPathForFilename:@"file that does not exist"];
//	
//	XCTAssertTrue(path == nil, @"");
//	
//	// File does not exist in this directory
//	path = [sharedFileUtils fullPathForFilename:@"powered.png"];
//	XCTAssertTrue(path == nil, @"");
//}
//
//// XCode Unit tests look inside the target's test application bundle - not the unit test app bundle, but the "cocos2d-tests-ios.app" bundle.
//-(void)testFullPathForFilename
//{
//	[CCFileUtils resetSingleton];
//	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
//
//	NSString *path = [sharedFileUtils fullPathForFilename:@"Images/powered.png"];
//	NSLog(@"Path: %@", path);
//	XCTAssertTrue(path != nil, @"");
//}
//
//- (void)testFullPathsOfFileNameInAllSearchPaths
//{
//    NSString *pathToUnzippedPackage = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/testpackage-iOS-phonehd_unzipped/testpackage-iOS-phonehd"];
//    NSString *pathToUnzippedPackage2 = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources-shared/Packages/anotherpackage-iOS-phonehd_unzipped/anotherpackage-iOS-phonehd"];
//
//    [CCFileUtils sharedFileUtils].searchPath = @[pathToUnzippedPackage, pathToUnzippedPackage2];
//
//    NSArray *paths = [[CCFileUtils sharedFileUtils] fullPathsOfFileNameInAllSearchPaths:@"fileLookup.plist"];
//    XCTAssertEqual(paths.count, 2);
//}
//
//- (void)testLoadFileNameLookupsInAllSearchPaths
//{
//    NSString *pathToPackage = [NSTemporaryDirectory() stringByAppendingPathComponent:@"pack1"];
//    NSString *pathToPackage2 = [NSTemporaryDirectory() stringByAppendingPathComponent:@"pack2"];
//
//    [CCFileUtils sharedFileUtils].searchPath = @[pathToPackage, pathToPackage2];
//
//    NSFileManager *fileManager = [NSFileManager defaultManager];
//    [fileManager createDirectoryAtPath:pathToPackage withIntermediateDirectories:YES attributes:nil error:nil];
//    [fileManager createDirectoryAtPath:pathToPackage2 withIntermediateDirectories:YES attributes:nil error:nil];
//
//    NSDictionary *lookup1 = @{
//        @"filenames": @{
//            @"foo.wav" : @"foo.mp4"
//        },
//        @"metadata": @{
//            @"version" : @1
//        }
//    };
//    [lookup1 writeToFile:[pathToPackage stringByAppendingPathComponent:@"fileLookup.plist"] atomically:YES];
//
//    NSDictionary *lookup2 = @{
//        @"filenames": @{
//            @"baa.psd" : @"baa.png"
//        },
//        @"metadata": @{
//            @"version" : @1
//        }
//    };
//    [lookup2 writeToFile:[pathToPackage2 stringByAppendingPathComponent:@"fileLookup.plist"] atomically:YES];
//
//    [[CCFileUtils sharedFileUtils] loadFileNameLookupsInAllSearchPathsWithName:@"fileLookup.plist"];
//    NSDictionary *filenameLookup = [CCFileUtils sharedFileUtils].filenameLookup;
//    XCTAssertEqualObjects(filenameLookup[@"baa.psd"], @"baa.png");
//    XCTAssertEqualObjects(filenameLookup[@"foo.wav"], @"foo.mp4");
//}
//
//-(void)testCCFileUtilsSearchModeSuffix
//{
//	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
//	sharedFileUtils.searchMode = CCFileUtilsSearchModeSuffix;
//	
//	XCTAssertTrue([sharedFileUtils fullPathForFilename:@"Images/powered.png"] != nil, @"");
//}
//
//-(void)testCCFileUtilsSearchModeDirectory
//{
//	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
//	sharedFileUtils.searchMode = CCFileUtilsSearchModeDirectory;
//	
//	NSString *path = [sharedFileUtils fullPathForFilename:@"Images/powered.png" contentScale:nil];
//	XCTAssertTrue(path != nil, @"");
//	
//	CGFloat scale = 1.0;
//	CGFloat biggerScale = 2.0;
//	
//	path = [sharedFileUtils fullPathForFilename:@"Images/powered.png" contentScale:&scale];
//	XCTAssertTrue(path != nil, @"");
//	
//	path = [sharedFileUtils fullPathForFilename:@"Images/powered.png" contentScale:&biggerScale];
//	XCTAssertTrue(path != nil, @"");
//}
//
//-(void)testCustomSearchPathsForExtensions
//{
//	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
//	[sharedFileUtils purgeCachedEntries];
//	[sharedFileUtils setSearchPath: @[ @"Images", kCCFileUtilsDefaultSearchPath] ];
//	
//	XCTAssertTrue( [sharedFileUtils fullPathForFilename:@"Images/powered.png" contentScale:nil] != nil, @"");
//	XCTAssertTrue( [sharedFileUtils fullPathForFilename:@"powered.png" contentScale:nil] != nil, @"Search path 'Images' didn't work.");
//}
//
//-(void)testContentScaleLoading
//{
//	CCFileUtils *sharedFileUtils = [CCFileUtils sharedFileUtils];
//	sharedFileUtils.searchMode = CCFileUtilsSearchModeSuffix;
//	
//	// assume we're on iPhone5 HD.
//	// CCFileUtilsSuffixiPhoneHD is hardcoded to look for the "-hd" suffix.
//	// So overwrite to look only for these for the purpose of the test.
//	[ (NSMutableArray*) [sharedFileUtils searchResolutionsOrder] removeAllObjects];
//	[ (NSMutableArray*) [sharedFileUtils searchResolutionsOrder] addObject:CCFileUtilsSuffixiPhoneHD];
//
//	CGFloat scale = 0.0;
//	
//	NSString *path1 = [sharedFileUtils fullPathForFilename:@"Images/blocks.png" contentScale:&scale];
//	XCTAssertTrue(scale == 2.0, @"");
//	XCTAssertTrue(path1 != nil, @"");
//}
//
//@end
