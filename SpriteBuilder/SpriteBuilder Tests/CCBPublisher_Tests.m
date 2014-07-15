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

@interface CCBPublisher_Tests : FileSystemTestCase


@end

@implementation CCBPublisher_Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPublishingTemplateProject
{
    [self createFolders:@[@"Published"]];

    [self createPNGAtPath:@"project.spritebuilder/Packages/SpriteBuilder Resources.sbpack/ccbResources/resources-auto/ccbButtonHighlighted.png"
                    width:4
                   height:12];
    [self createPNGAtPath:@"project.spritebuilder/Packages/SpriteBuilder Resources.sbpack/ccbResources/resources-auto/ccbButtonHighlighted2.png"
                    width:20
                   height:8];

    [self copyTestingResource:@"blank.wav" toFolder:@"project.spritebuilder/Packages/SpriteBuilder Resources.sbpack"];
    [self copyTestingResource:@"photoshop.psd" toFolder:@"project.spritebuilder/Packages/SpriteBuilder Resources.sbpack/resources-auto"];

    ProjectSettings *projectSettings = [[ProjectSettings alloc] init];
    projectSettings.projectPath = [self fullPathForFile:@"project.spritebuilder/publishtest.ccbproj"];
    projectSettings.publishEnablediPhone = YES;
    projectSettings.publishEnabledAndroid = NO;
    projectSettings.designTarget = kCCBDesignTargetFixed;
    projectSettings.defaultOrientation = kCCBOrientationPortrait;
    projectSettings.resourceAutoScaleFactor = 4;

    [projectSettings addResourcePath:[self fullPathForFile:@"project.spritebuilder/Packages/SpriteBuilder Resources.sbpack"] error:nil];

    CCBWarnings *warnings = [[CCBWarnings alloc] init];

    CCBPublisher *publisher = [[CCBPublisher alloc] initWithProjectSettings:projectSettings
                                                                   warnings:warnings
                                                              finishedBlock:nil];

    publisher.publishInputDirectories = @[[self fullPathForFile:@"project.spritebuilder/Packages/SpriteBuilder Resources.sbpack"]];
    publisher.publishOutputDirectory = [self fullPathForFile:@"Published"];

    [publisher start];

    [self assertFileExists:@"Published/ccbResources/resources-tablet/ccbButtonHighlighted.png"];
    [self assertFileExists:@"Published/ccbResources/resources-tablet/ccbButtonHighlighted2.png"];
    [self assertFileExists:@"Published/ccbResources/resources-tablethd/ccbButtonHighlighted.png"];
    [self assertFileExists:@"Published/ccbResources/resources-tablethd/ccbButtonHighlighted2.png"];
    [self assertFileExists:@"Published/ccbResources/resources-phone/ccbButtonHighlighted.png"];
    [self assertFileExists:@"Published/ccbResources/resources-phone/ccbButtonHighlighted2.png"];
    [self assertFileExists:@"Published/ccbResources/resources-phonehd/ccbButtonHighlighted.png"];
    [self assertFileExists:@"Published/ccbResources/resources-phonehd/ccbButtonHighlighted2.png"];
    [self assertFileExists:@"Published/resources-tablet/photoshop.png"];
    [self assertFileExists:@"Published/resources-tablethd/photoshop.png"];
    [self assertFileExists:@"Published/resources-phone/photoshop.png"];
    [self assertFileExists:@"Published/resources-phonehd/photoshop.png"];

    [self assertFileExists:@"Published/blank.caf"];
    [self assertFileExists:@"Published/configCocos2d.plist"];
    [self assertFileExists:@"Published/fileLookup.plist"];
    [self assertFileExists:@"Published/spriteFrameFileList.plist"];

    [self assertConfigCocos2d:@"Published/configCocos2d.plist" isEqualToDictionary:
            @{
                @"CCSetupScreenMode": @"CCScreenModeFixed",
                @"CCSetupScreenOrientation": @"CCScreenOrientationPortrait",
                @"CCSetupTabletScale2X": @(YES)
            }];

    [self assertRenamingRuleInfFileLookup:@"Published/fileLookup.plist" originalName:@"blank.wav" renamedName:@"blank.caf"];
    [self assertRenamingRuleInfFileLookup:@"Published/fileLookup.plist" originalName:@"photoshop.psd" renamedName:@"photoshop.png"];

    [self assertPNGAtPath:@"Published/ccbResources/resources-phone/ccbButtonHighlighted.png" hasWidth:1 hasHeight:3];
    [self assertPNGAtPath:@"Published/ccbResources/resources-phone/ccbButtonHighlighted2.png" hasWidth:5 hasHeight:2];
    [self assertPNGAtPath:@"Published/ccbResources/resources-phonehd/ccbButtonHighlighted.png" hasWidth:2 hasHeight:6];
    [self assertPNGAtPath:@"Published/ccbResources/resources-phonehd/ccbButtonHighlighted2.png" hasWidth:10 hasHeight:4];
    [self assertPNGAtPath:@"Published/ccbResources/resources-tablet/ccbButtonHighlighted.png" hasWidth:2 hasHeight:6];
    [self assertPNGAtPath:@"Published/ccbResources/resources-tablet/ccbButtonHighlighted2.png" hasWidth:10 hasHeight:4];
    [self assertPNGAtPath:@"Published/ccbResources/resources-tablethd/ccbButtonHighlighted.png" hasWidth:4 hasHeight:12];
    [self assertPNGAtPath:@"Published/ccbResources/resources-tablethd/ccbButtonHighlighted2.png" hasWidth:20 hasHeight:8];

    NSLog(@"%@", [self fullPathForFile:@""]);
    NSLog(@"%@", publisher.publishOutputDirectory);
    NSLog(@"---");
}

- (void)testCustomScalingFactors
{
    [self createFolders:@[@"Published"]];

    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/resources-auto/rocket.png"
                    width:4
                   height:20];

    // Overriden resolution for tablet hd
    [self createPNGAtPath:@"baa.spritebuilder/Packages/foo.sbpack/resources-tablethd/rocket.png"
                    width:3
                   height:17];

    ProjectSettings *projectSettings = [[ProjectSettings alloc] init];
    projectSettings.projectPath = [self fullPathForFile:@"baa.spritebuilder/test.ccbproj"];
    projectSettings.publishEnablediPhone = YES;
    projectSettings.publishEnabledAndroid = NO;
    projectSettings.resourceAutoScaleFactor = 4;

    [projectSettings setValue:[NSNumber numberWithInt:1] forRelPath:@"rocket.png" andKey:@"scaleFrom"];

    [projectSettings addResourcePath:[self fullPathForFile:@"baa.spritebuilder/Packages/foo.sbpack"] error:nil];

    CCBWarnings *warnings = [[CCBWarnings alloc] init];
    CCBPublisher *publisher = [[CCBPublisher alloc] initWithProjectSettings:projectSettings
                                                                   warnings:warnings
                                                              finishedBlock:nil];

    publisher.publishInputDirectories = @[[self fullPathForFile:@"baa.spritebuilder/Packages/foo.sbpack"]];
    publisher.publishOutputDirectory = [self fullPathForFile:@"Published"];

    [publisher start];

    // The overridden case
    [self assertPNGAtPath:@"Published/resources-tablethd/rocket.png" hasWidth:3 hasHeight:17];

    [self assertPNGAtPath:@"Published/resources-tablet/rocket.png" hasWidth:8 hasHeight:40];
    [self assertPNGAtPath:@"Published/resources-phone/rocket.png" hasWidth:4 hasHeight:20];
    [self assertPNGAtPath:@"Published/resources-phonehd/rocket.png" hasWidth:8 hasHeight:40];
}


#pragma mark - assert helpers

- (void)assertRenamingRuleInfFileLookup:(NSString *)fileLookupName originalName:(NSString *)originalName renamedName:(NSString *)expectedRenamedName
{
    NSDictionary *fileLookup = [NSDictionary dictionaryWithContentsOfFile:[self fullPathForFile:fileLookupName]];
    NSDictionary *rules = fileLookup[@"filenames"];

    XCTAssertTrue([expectedRenamedName isEqualToString:rules[originalName]], @"Rename rule does not match, found \"%@\" for key \"%@\" expected: \"%@\"",
                  rules[originalName], originalName, expectedRenamedName);
}

- (void)assertConfigCocos2d:(NSString *)fileName isEqualToDictionary:(NSDictionary *)expectedDict;
{
    NSDictionary *config = [NSDictionary dictionaryWithContentsOfFile:[self fullPathForFile:fileName]];

    XCTAssertNotNil(config, @"Config is nil for given filename \"%@\"", [self fullPathForFile:fileName]);
    XCTAssertTrue([config isEqualToDictionary:expectedDict], @"Dictionary %@ does not match %@", config, expectedDict);
}

@end
