//
//  CCBPublisher_Tests.m
//  SpriteBuilder
//
//  Created by Nicky Weber on 10.07.14.
//
//

#import <XCTest/XCTest.h>
#import "FileSystemTestCase.h"
#import "FileSystemTestCase+Images.h"
#import "CCBPublisher.h"
#import "ProjectSettings.h"
#import "CCBWarnings.h"
#import "FCFormatConverter.h"

@interface CCBPublisher_Tests : FileSystemTestCase

@property (nonatomic, strong) ProjectSettings *projectSettings;
@property (nonatomic, strong) CCBWarnings *warnings;
@property (nonatomic, strong) CCBPublisher *publisher;

@end

@implementation CCBPublisher_Tests

- (void)setUp
{
    [super setUp];

    self.projectSettings = [[ProjectSettings alloc] init];
    _projectSettings.projectPath = [self fullPathForFile:@"baa.spritebuilder/publishtest.ccbproj"];
    _projectSettings.publishEnablediPhone = YES;
    _projectSettings.publishEnabledAndroid = NO;

    [_projectSettings addResourcePath:[self fullPathForFile:@"baa.spritebuilder/Packages/foo.sbpack"] error:nil];

    self.warnings = [[CCBWarnings alloc] init];

    self.publisher = [[CCBPublisher alloc] initWithProjectSettings:_projectSettings
                                                          warnings:_warnings
                                                     finishedBlock:nil];

    _publisher.publishInputDirectories = @[[self fullPathForFile:@"baa.spritebuilder/Packages/foo.sbpack"]];
    [_publisher setPublishOutputDirectory:[self fullPathForFile:@"Published-iOS"] forTargetType:kCCBPublisherTargetTypeIPhone];
    [_publisher setPublishOutputDirectory:[self fullPathForFile:@"Published-Android"] forTargetType:kCCBPublisherTargetTypeAndroid];

    [self createFolders:@[@"Published-iOS", @"Published-Android"]];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPublishingProject
{
    // Language files are just copied
    [self createEmptyFiles:@[@"baa.spritebuilder/Packages/foo.sbpack/Strings.ccbLang"]];

    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/ccbResources/resources-auto/ccbButtonHighlighted.png"
                    width:4
                   height:12];
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/ccbResources/resources-auto/ccbButtonHighlighted2.png"
                    width:20
                   height:8];

    [self copyTestingResource:@"blank.wav" toFolder:@"baa.spritebuilder/Packages/foo.sbpack"];
    [self copyTestingResource:@"photoshop.psd" toFolder:@"baa.spritebuilder/Packages/foo.sbpack/resources-auto"];

    _projectSettings.designTarget = kCCBDesignTargetFixed;
    _projectSettings.defaultOrientation = kCCBOrientationPortrait;
    _projectSettings.resourceAutoScaleFactor = 4;

    [_publisher start];

    [self assertFileExists:@"Published-iOS/Strings.ccbLang"];

    [self assertFileExists:@"Published-iOS/ccbResources/resources-tablet/ccbButtonHighlighted.png"];
    [self assertFileExists:@"Published-iOS/ccbResources/resources-tablet/ccbButtonHighlighted2.png"];
    [self assertFileExists:@"Published-iOS/ccbResources/resources-tablethd/ccbButtonHighlighted.png"];
    [self assertFileExists:@"Published-iOS/ccbResources/resources-tablethd/ccbButtonHighlighted2.png"];
    [self assertFileExists:@"Published-iOS/ccbResources/resources-phone/ccbButtonHighlighted.png"];
    [self assertFileExists:@"Published-iOS/ccbResources/resources-phone/ccbButtonHighlighted2.png"];
    [self assertFileExists:@"Published-iOS/ccbResources/resources-phonehd/ccbButtonHighlighted.png"];
    [self assertFileExists:@"Published-iOS/ccbResources/resources-phonehd/ccbButtonHighlighted2.png"];
    [self assertFileExists:@"Published-iOS/resources-tablet/photoshop.png"];
    [self assertFileExists:@"Published-iOS/resources-tablethd/photoshop.png"];
    [self assertFileExists:@"Published-iOS/resources-phone/photoshop.png"];
    [self assertFileExists:@"Published-iOS/resources-phonehd/photoshop.png"];

    [self assertFileExists:@"Published-iOS/blank.caf"];
    [self assertFileExists:@"Published-iOS/configCocos2d.plist"];
    [self assertFileExists:@"Published-iOS/fileLookup.plist"];
    [self assertFileExists:@"Published-iOS/spriteFrameFileList.plist"];

    [self assertConfigCocos2d:@"Published-iOS/configCocos2d.plist" isEqualToDictionary:
            @{
                @"CCSetupScreenMode": @"CCScreenModeFixed",
                @"CCSetupScreenOrientation": @"CCScreenOrientationPortrait",
                @"CCSetupTabletScale2X": @(YES)
            }];

    [self assertRenamingRuleInfFileLookup:@"Published-iOS/fileLookup.plist" originalName:@"blank.wav" renamedName:@"blank.caf"];
    [self assertRenamingRuleInfFileLookup:@"Published-iOS/fileLookup.plist" originalName:@"photoshop.psd" renamedName:@"photoshop.png"];

    [self assertPNGAtPath:@"Published-iOS/ccbResources/resources-phone/ccbButtonHighlighted.png" hasWidth:1 hasHeight:3];
    [self assertPNGAtPath:@"Published-iOS/ccbResources/resources-phone/ccbButtonHighlighted2.png" hasWidth:5 hasHeight:2];
    [self assertPNGAtPath:@"Published-iOS/ccbResources/resources-phonehd/ccbButtonHighlighted.png" hasWidth:2 hasHeight:6];
    [self assertPNGAtPath:@"Published-iOS/ccbResources/resources-phonehd/ccbButtonHighlighted2.png" hasWidth:10 hasHeight:4];
    [self assertPNGAtPath:@"Published-iOS/ccbResources/resources-tablet/ccbButtonHighlighted.png" hasWidth:2 hasHeight:6];
    [self assertPNGAtPath:@"Published-iOS/ccbResources/resources-tablet/ccbButtonHighlighted2.png" hasWidth:10 hasHeight:4];
    [self assertPNGAtPath:@"Published-iOS/ccbResources/resources-tablethd/ccbButtonHighlighted.png" hasWidth:4 hasHeight:12];
    [self assertPNGAtPath:@"Published-iOS/ccbResources/resources-tablethd/ccbButtonHighlighted2.png" hasWidth:20 hasHeight:8];
}

- (void)testPublishingOfResolutions
{
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/resources-auto/picture.png" width:4 height:12];

    _projectSettings.publishEnablediPhone = YES;
    _projectSettings.publishResolution_ios_tablet = YES;
    _projectSettings.publishResolution_ios_tablethd = NO;
    _projectSettings.publishResolution_ios_phone = NO;
    _projectSettings.publishResolution_ios_phonehd = YES;

    _projectSettings.publishEnabledAndroid = YES;
    _projectSettings.publishResolution_android_tablet = NO;
    _projectSettings.publishResolution_android_tablethd = YES;
    _projectSettings.publishResolution_android_phone = YES;
    _projectSettings.publishResolution_android_phonehd = NO;

    [_publisher start];

    [self assertFileExists:@"Published-iOS/resources-phonehd/picture.png"];
    [self assertFileExists:@"Published-iOS/resources-tablet/picture.png"];
    [self assertFileDoesNotExists:@"Published-iOS/resources-phone/picture.png"];
    [self assertFileDoesNotExists:@"Published-iOS/resources-tablethd/picture.png"];

    [self assertFileExists:@"Published-Android/resources-phone/picture.png"];
    [self assertFileExists:@"Published-Android/resources-tablethd/picture.png"];
    [self assertFileDoesNotExists:@"Published-Android/resources-phonehd/picture.png"];
    [self assertFileDoesNotExists:@"Published-Android/resources-tablet/picture.png"];
}

- (void)testCustomScalingFactorsForImages
{
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/resources-auto/rocket.png" width:4 height:20];

    // Overriden resolution for tablet hd
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/resources-tablethd/rocket.png" width:3 height:17];

    _projectSettings.resourceAutoScaleFactor = 4;
    [_projectSettings setValue:[NSNumber numberWithInt:1] forRelPath:@"rocket.png" andKey:@"scaleFrom"];

    [_publisher start];

    // The overridden case
    [self assertPNGAtPath:@"Published-iOS/resources-tablethd/rocket.png" hasWidth:3 hasHeight:17];

    [self assertPNGAtPath:@"Published-iOS/resources-tablet/rocket.png" hasWidth:8 hasHeight:40];
    [self assertPNGAtPath:@"Published-iOS/resources-phone/rocket.png" hasWidth:4 hasHeight:20];
    [self assertPNGAtPath:@"Published-iOS/resources-phonehd/rocket.png" hasWidth:8 hasHeight:40];
}

- (void)testDifferentOutputFormatsForIOSAndAndroid
{
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/resources-auto/rocket.png" width:4 height:20];
    [self copyTestingResource:@"blank.wav" toFolder:@"baa.spritebuilder/Packages/foo.sbpack"];

    _projectSettings.publishEnabledAndroid = YES;
    _projectSettings.resourceAutoScaleFactor = 4;

    [_projectSettings setValue:@(kFCImageFormatJPG_High) forRelPath:@"rocket.png" andKey:@"format_ios"];
    [_projectSettings setValue:@(kFCImageFormatJPG_High) forRelPath:@"rocket.png" andKey:@"format_android"];
    [_projectSettings setValue:@(kFCSoundFormatMP4) forRelPath:@"blank.wav" andKey:@"format_ios_sound"];

    [_publisher start];

    [self assertRenamingRuleInfFileLookup:@"Published-iOS/fileLookup.plist" originalName:@"rocket.png" renamedName:@"rocket.jpg"];
    [self assertRenamingRuleInfFileLookup:@"Published-iOS/fileLookup.plist" originalName:@"blank.wav" renamedName:@"blank.m4a"];

    [self assertRenamingRuleInfFileLookup:@"Published-Android/fileLookup.plist" originalName:@"rocket.png" renamedName:@"rocket.jpg"];
    [self assertRenamingRuleInfFileLookup:@"Published-Android/fileLookup.plist" originalName:@"blank.wav" renamedName:@"blank.ogg"];

    [self assertJPGAtPath:@"Published-iOS/resources-tablet/rocket.jpg" hasWidth:2 hasHeight:10];
    [self assertJPGAtPath:@"Published-iOS/resources-tablethd/rocket.jpg" hasWidth:4 hasHeight:20];
    [self assertJPGAtPath:@"Published-iOS/resources-phone/rocket.jpg" hasWidth:1 hasHeight:5];
    [self assertJPGAtPath:@"Published-iOS/resources-phonehd/rocket.jpg" hasWidth:2 hasHeight:10];

    [self assertJPGAtPath:@"Published-Android/resources-tablet/rocket.jpg" hasWidth:2 hasHeight:10];
    [self assertJPGAtPath:@"Published-Android/resources-tablethd/rocket.jpg" hasWidth:4 hasHeight:20];
    [self assertJPGAtPath:@"Published-Android/resources-phone/rocket.jpg" hasWidth:1 hasHeight:5];
    [self assertJPGAtPath:@"Published-Android/resources-phonehd/rocket.jpg" hasWidth:2 hasHeight:10];

    [self assertFileExists:@"Published-iOS/blank.m4a"];
    [self assertFileExists:@"Published-Android/blank.ogg"];
}

- (void)testSpriteSheets
{
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/sheet/resources-auto/rock.png" width:4 height:4 color:[NSColor redColor]];
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/sheet/resources-auto/scissor.png" width:8 height:4 color:[NSColor greenColor]];
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/sheet/resources-auto/paper.png" width:12 height:12 color:[NSColor whiteColor]];
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/sheet/resources-auto/shotgun.png" width:4 height:12 color:[NSColor blackColor]];
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/sheet/resources-auto/sword.png" width:4 height:12 color:[NSColor yellowColor]];

    _projectSettings.resourceAutoScaleFactor = 4;
    [_projectSettings setValue:[NSNumber numberWithBool:YES] forRelPath:@"sheet" andKey:@"isSmartSpriteSheet"];

    [_publisher start];

    [self assertFileExists:@"Published-iOS/resources-tablet/sheet.plist"];
    [self assertPNGAtPath:@"Published-iOS/resources-tablet/sheet.png" hasWidth:16 hasHeight:16];
    [self assertFileExists:@"Published-iOS/resources-tablethd/sheet.plist"];
    [self assertPNGAtPath:@"Published-iOS/resources-tablethd/sheet.png" hasWidth:32 hasHeight:16];
    [self assertFileExists:@"Published-iOS/resources-phone/sheet.plist"];
    [self assertPNGAtPath:@"Published-iOS/resources-phone/sheet.png" hasWidth:16 hasHeight:8];
    [self assertFileExists:@"Published-iOS/resources-phonehd/sheet.plist"];
    [self assertPNGAtPath:@"Published-iOS/resources-phonehd/sheet.png" hasWidth:16 hasHeight:16];

    // Previews are generated in texture packer
    [self assertFileExists:@"baa.spritebuilder/Packages/foo.sbpack/sheet.ppng"];

    [self assertFileExists:@"Published-iOS/spriteFrameFileList.plist"];
    [self assertSpriteFrameFileList:@"Published-iOS/spriteFrameFileList.plist" containsEntry:@"sheet.plist"];
}

- (void)testSpriteSheetOutputPVRRGBA88888AndPVRTC
{
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/pvr/resources-auto/rock.png" width:4 height:4 color:[NSColor redColor]];
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/pvr/resources-auto/scissor.png" width:8 height:4 color:[NSColor greenColor]];

    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/pvrtc/resources-auto/rock.png" width:4 height:4 color:[NSColor redColor]];
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/pvrtc/resources-auto/scissor.png" width:8 height:4 color:[NSColor greenColor]];

    _projectSettings.resourceAutoScaleFactor = 4;
    _projectSettings.publishResolution_ios_phonehd = YES;
    _projectSettings.publishResolution_ios_phone = NO;
    _projectSettings.publishResolution_ios_tablet = NO;
    _projectSettings.publishResolution_ios_tablethd = NO;

    [_projectSettings setValue:@(YES) forRelPath:@"pvr" andKey:@"isSmartSpriteSheet"];
    [_projectSettings setValue:@(kFCImageFormatPVR_RGBA8888) forRelPath:@"pvr" andKey:@"format_ios"];

    [_projectSettings setValue:@(YES) forRelPath:@"pvrtc" andKey:@"isSmartSpriteSheet"];
    [_projectSettings setValue:@(kFCImageFormatPVRTC_4BPP) forRelPath:@"pvrtc" andKey:@"format_ios"];

    [_publisher start];

    [self assertFileExists:@"Published-iOS/resources-phonehd/pvr.plist"];
    [self assertFileExists:@"Published-iOS/resources-phonehd/pvr.pvr"];
    // Previews are generated in texture packer
    [self assertFileExists:@"baa.spritebuilder/Packages/foo.sbpack/pvr.ppng"];

    [self assertFileExists:@"Published-iOS/resources-phonehd/pvrtc.plist"];
    [self assertFileExists:@"Published-iOS/resources-phonehd/pvrtc.pvr"];
    [self assertFileExists:@"baa.spritebuilder/Packages/foo.sbpack/pvrtc.ppng"];

    [self assertFileExists:@"Published-iOS/spriteFrameFileList.plist"];
    [self assertSpriteFrameFileList:@"Published-iOS/spriteFrameFileList.plist" containsEntry:@"pvr.plist"];
    [self assertSpriteFrameFileList:@"Published-iOS/spriteFrameFileList.plist" containsEntry:@"pvrtc.plist"];
}


#pragma mark - assert helpers

- (void)assertSpriteFrameFileList:(NSString *)filename containsEntry:(NSString *)entry
{
    NSString *fullFilePath = [self fullPathForFile:filename];
    NSDictionary *completeFile = [NSDictionary dictionaryWithContentsOfFile:[self fullPathForFile:filename]];
    NSArray *files = completeFile[@"spriteFrameFiles"];

    XCTAssertTrue([files containsObject:entry], @"SpriteFrameFileList does not contain entry \"%@\", entries found %@ at path \"%@\"", entry, files, fullFilePath);
}

- (void)assertRenamingRuleInfFileLookup:(NSString *)fileLookupName originalName:(NSString *)originalName renamedName:(NSString *)expectedRenamedName
{
    NSString *fullFilePath = [self fullPathForFile:fileLookupName];
    NSDictionary *fileLookup = [NSDictionary dictionaryWithContentsOfFile:fullFilePath];
    NSDictionary *rules = fileLookup[@"filenames"];

    XCTAssertTrue([expectedRenamedName isEqualToString:rules[originalName]], @"Rename rule does not match, found \"%@\" for key \"%@\" expected: \"%@\" at path \"%@\"",
                  rules[originalName], originalName, expectedRenamedName, fullFilePath );
}

- (void)assertConfigCocos2d:(NSString *)fileName isEqualToDictionary:(NSDictionary *)expectedDict;
{
    NSString *fullFilePath = [self fullPathForFile:fileName];

    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:fullFilePath];

    XCTAssertNotNil(config, @"Config is nil for given filename \"%@\"", [self fullPathForFile:fileName]);
    XCTAssertTrue([config isEqualToDictionary:expectedDict], @"Dictionary %@ does not match %@ at path \"%@\"", config, expectedDict, fullFilePath);
}

@end
