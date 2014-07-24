#import "PackagePublishSettings.h"
#import "RMPackage.h"
#import "CCBPublisherTypes.h"
#import "ResourcePublishPackageCommand.h"
#import "PublishOSSettings.h"
#import "MiscConstants.h"

NSString *const KEY_PUBLISH_TO_ZIP = @"publishToZip";
NSString *const KEY_PUBLISH_TO_MAINPROJECT = @"publishToMainProject";
NSString *const KEY_OS_SETTINGS = @"osSettings";
NSString *const KEY_OUTPUTDIR = @"outputDir";
NSString *const KEY_PUBLISH_ENV = @"publishEnv";

@interface PackagePublishSettings ()

@property (nonatomic, strong) NSMutableDictionary *publishSettingsForOsType;

@end


@implementation PackagePublishSettings

- (instancetype)init
{
    return [self initWithPackage:nil];
}

- (instancetype)initWithPackage:(RMPackage *)package
{
    self = [super init];

    if (self)
    {
        self.publishToZip = YES;
        self.publishToMainProject = YES;

        self.package = package;
        self.publishSettingsForOsType = [NSMutableDictionary dictionary];
        self.outputDirectory = DEFAULT_OUTPUTDIR_PUBLISHED_PACKAGES;

        _publishSettingsForOsType[[self osTypeToString:kCCBPublisherOSTypeIOS]] = [[PublishOSSettings alloc] init];
        _publishSettingsForOsType[[self osTypeToString:kCCBPublisherOSTypeAndroid]] = [[PublishOSSettings alloc] init];
    }

    return self;
}

- (NSString *)osTypeToString:(CCBPublisherOSType)osType
{
    switch (osType)
    {
        case kCCBPublisherOSTypeIOS :
            return @"ios";

        case kCCBPublisherOSTypeAndroid :
            return @"android";

        default :
            return nil;
    }
}

- (NSDictionary *)osSettings
{
    return _publishSettingsForOsType;
}

- (PublishOSSettings *)settingsForOsType:(CCBPublisherOSType)type;
{
    return _publishSettingsForOsType[[self osTypeToString:type]];
}

- (void)setOSSettings:(PublishOSSettings *)osSettings forOsType:(CCBPublisherOSType)type
{
    if (!osSettings)
    {
        return;
    }

    _publishSettingsForOsType[[self osTypeToString:type]] = osSettings;
}

- (BOOL)load
{
    NSString *fullPath = [_package.dirPath stringByAppendingPathComponent:@"Package.plist"];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:fullPath];

    if (!dict)
    {
        return NO;
    }

    self.publishToZip = [dict[KEY_PUBLISH_TO_ZIP] boolValue];
    self.publishToMainProject = [dict[KEY_PUBLISH_TO_MAINPROJECT] boolValue];
    self.outputDirectory = dict[KEY_OUTPUTDIR];
    self.publishEnvironment = (CCBPublishEnvironment) [dict[KEY_PUBLISH_ENV] integerValue];

    for (NSString *osType in dict[KEY_OS_SETTINGS])
    {
        NSDictionary *dictOsSettings = dict[KEY_OS_SETTINGS][osType];
        PublishOSSettings *publishOSSettings = [[PublishOSSettings alloc] initWithDictionary:dictOsSettings];
        _publishSettingsForOsType[osType] = publishOSSettings;
    }

    return YES;
}

- (BOOL)store
{
    NSAssert(_package != nil, @"package must not be nil");

    NSDictionary *dict = [self toDictionary];
    NSString *fullPath = [_package.dirPath stringByAppendingPathComponent:@"Package.plist"];
    return [dict writeToFile:fullPath atomically:YES];
}

- (NSDictionary *)toDictionary
{
    NSMutableDictionary *result = [NSMutableDictionary dictionary];

    result[KEY_PUBLISH_TO_ZIP] = @(_publishToZip);
    result[KEY_PUBLISH_TO_MAINPROJECT] = @(_publishToMainProject);
    result[KEY_OUTPUTDIR] = _outputDirectory;
    result[KEY_PUBLISH_ENV] = @(_publishEnvironment);
    result[KEY_OS_SETTINGS] = [NSMutableDictionary dictionary];

    for (NSString *osType in _publishSettingsForOsType)
    {
        PublishOSSettings *someOsSettings = _publishSettingsForOsType[osType];

        result[KEY_OS_SETTINGS][osType] = [someOsSettings toDictionary];
    }

    return result;
}

@end