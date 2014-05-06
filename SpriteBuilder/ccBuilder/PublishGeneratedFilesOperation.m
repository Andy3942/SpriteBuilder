#import "PublishGeneratedFilesOperation.h"

#import "CCBPublisherTemplate.h"
#import "CCBFileUtil.h"
#import "ProjectSettings.h"
#import "PublishFileLookup.h"
#import "PublishingTaskStatusProgress.h"


@implementation PublishGeneratedFilesOperation

- (void)main
{
    NSLog(@"[%@]", [self class]);

    [self publishGeneratedFiles];

    [_publishingTaskStatusProgress taskFinished];
}

- (void)publishGeneratedFiles
{
    [_publishingTaskStatusProgress updateStatusText:@"Generating misc files"];

    // Create the directory if it doesn't exist
    BOOL createdDirs = [[NSFileManager defaultManager] createDirectoryAtPath:_outputDir withIntermediateDirectories:YES attributes:NULL error:NULL];
    if (!createdDirs)
    {
        [_warnings addWarningWithDescription:@"Failed to create output directory %@" isFatal:YES];
        return;
    }

    if (_targetType == kCCBPublisherTargetTypeIPhone
        || _targetType == kCCBPublisherTargetTypeAndroid)
    {
        [self generateMainJSFile];
    }

    [self generateFileLookup];

    [self generateSpriteSheetLookup];

    [self generateCocos2dSetupFile];
}

- (void)generateMainJSFile
{
    if (_projectSettings.javascriptBased
        && _projectSettings.javascriptMainCCB
        && ![_projectSettings.javascriptMainCCB isEqualToString:@""]
        && ![self fileExistInResourcePaths:@"main.js"])
    {
        // Find all jsFiles
        NSArray *jsFiles = [CCBFileUtil filesInResourcePathsWithExtension:@"js"];
        NSString *mainFile = [_outputDir stringByAppendingPathComponent:@"main.js"];

        // Generate file from template
        CCBPublisherTemplate *tmpl = [CCBPublisherTemplate templateWithFile:@"main-jsb.txt"];
        [tmpl setStrings:jsFiles forMarker:@"REQUIRED_FILES" prefix:@"require(\"" suffix:@"\");\n"];
        [tmpl setString:_projectSettings.javascriptMainCCB forMarker:@"MAIN_SCENE"];

        [tmpl writeToFile:mainFile];
    }
}

- (void)generateCocos2dSetupFile
{
    NSMutableDictionary* configCocos2d = [NSMutableDictionary dictionary];

    NSString* screenMode = @"";
    if (_projectSettings.designTarget == kCCBDesignTargetFixed)
    {
        screenMode = @"CCScreenModeFixed";
    }
    else if (_projectSettings.designTarget == kCCBDesignTargetFlexible)
    {
        screenMode = @"CCScreenModeFlexible";
    }

    [configCocos2d setObject:screenMode forKey:@"CCSetupScreenMode"];

    NSString *screenOrientation = @"";
    if (_projectSettings.defaultOrientation == kCCBOrientationLandscape)
	{
		screenOrientation = @"CCScreenOrientationLandscape";
	}
	else if (_projectSettings.defaultOrientation == kCCBOrientationPortrait)
	{
		screenOrientation = @"CCScreenOrientationPortrait";
	}

    [configCocos2d setObject:screenOrientation forKey:@"CCSetupScreenOrientation"];

    [configCocos2d setObject:[NSNumber numberWithBool:YES] forKey:@"CCSetupTabletScale2X"];

    NSString *configCocos2dFile = [_outputDir stringByAppendingPathComponent:@"configCocos2d.plist"];
    [configCocos2d writeToFile:configCocos2dFile atomically:YES];
}

- (void)generateSpriteSheetLookup
{
    NSMutableDictionary* spriteSheetLookup = [NSMutableDictionary dictionary];

    NSMutableDictionary *metadata = [NSMutableDictionary dictionary];
    [metadata setObject:[NSNumber numberWithInt:1] forKey:@"version"];

    [spriteSheetLookup setObject:metadata forKey:@"metadata"];

    [spriteSheetLookup setObject:[_publishedSpriteSheetFiles allObjects] forKey:@"spriteFrameFiles"];

    NSString* spriteSheetLookupFile = [_outputDir stringByAppendingPathComponent:@"spriteFrameFileList.plist"];

    [spriteSheetLookup writeToFile:spriteSheetLookupFile atomically:YES];
}

- (void)generateFileLookup
{
    [_fileLookup writeToFileAtomically:[_outputDir stringByAppendingPathComponent:@"fileLookup.plist"]];
}

- (BOOL) fileExistInResourcePaths:(NSString*)fileName
{
    for (NSString* dir in _projectSettings.absoluteResourcePaths)
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[dir stringByAppendingPathComponent:fileName]])
        {
            return YES;
        }
    }
    return NO;
}

@end