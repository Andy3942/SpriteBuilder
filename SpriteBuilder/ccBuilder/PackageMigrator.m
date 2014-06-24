#import "PackageMigrator.h"

#import "ProjectSettings.h"
#import "ProjectSettings+Packages.h"
#import "NSString+Packages.h"
#import "PackageImporter.h"

#define LocalLogDebug( s, ... ) NSLog( @"[DEBUG] <%@:%d> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  [NSString stringWithFormat:(s), ##__VA_ARGS__] )
#define LocalLogError( s, ... ) NSLog( @"[ERROR] <%@:%d> %@", [[NSString stringWithUTF8String:__FILE__] lastPathComponent], __LINE__,  [NSString stringWithFormat:(s), ##__VA_ARGS__] )

@interface PackageMigrator ()

@property (nonatomic, strong) NSMutableDictionary *renameMap;
@property (nonatomic, weak)ProjectSettings *projectSettings;
@property (nonatomic) BOOL resourcePathWithPackagesFolderNameFound;

@end


@implementation PackageMigrator

- (instancetype)init
{
    NSLog(@"Create instances of %@ with designated initializer.", [self class]);
    [self doesNotRecognizeSelector:_cmd];
}

- (instancetype)initWithProjectSettings:(ProjectSettings *)projectSettings
{
    self = [super init];
    if (self)
    {
        self.projectSettings = projectSettings;
        self.resourcePathWithPackagesFolderNameFound = NO;
        self.renameMap = [NSMutableDictionary dictionary];
    }

    return self;
}

- (BOOL)migrate:(NSError **)error
{
    LocalLogDebug(@"Package migration started...");

/*    if (![self renameResourcePathWithPackagesFolderName:error])
    {
        return NO;
    }


    if (![self migrateAllResourcePaths:error])
    {
        return NO;
    }*/


    if (![self createPackagesFolderIfNotExisting:NULL])
    {
        return NO;
    }

    NSMutableArray *resourcePathsToImport = [NSMutableArray array];
    for (NSMutableDictionary *resourcePathDict in [_projectSettings.resourcePaths copy])
    {
        NSString *fullResourcePath = [_projectSettings fullPathForResourcePathDict:resourcePathDict];
        if ([_projectSettings isPathInPackagesFolder:fullResourcePath])
        {
            continue;
        }

        [resourcePathsToImport addObject:[fullResourcePath mutableCopy]];
        if (![_projectSettings removeResourcePath:fullResourcePath error:error])
        {
            return NO;
        }
    }

    for (NSMutableString *fullPath in resourcePathsToImport)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];

        NSString *oldPath = fullPath;
        NSString *newPath = [fullPath stringByAppendingPackageSuffix];

        if (![fileManager moveItemAtPath:oldPath toPath:newPath error:error])
        {
            return NO;
        }

        [fullPath setString:newPath];
    }

    PackageImporter *packageImporter = [[PackageImporter alloc] init];
    packageImporter.projectSettings = _projectSettings;
    if (![packageImporter importPackagesWithPaths:resourcePathsToImport error:error])
    {
        return NO;
    }

    for (NSMutableString *fullPath in resourcePathsToImport)
    {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager removeItemAtPath:fullPath error:error])
        {
            return NO;
        }
    }

    LocalLogDebug(@"Package finished successfully!");
    return YES;
}

- (BOOL)createPackagesFolderIfNotExisting:(NSError **)error
{
    if ([self packageFolderExists])
    {
        LocalLogDebug(@"Creating packages folder...already exists.");
        return YES;
    }

    return [self tryToCreatePackagesFolder:error];
}

- (BOOL)tryToCreatePackagesFolder:(NSError **)error
{
    LocalLogDebug(@"Trying to create packages folder...");
    NSString *packageFolderPath = [_projectSettings packagesFolderPath];

    NSAssert(packageFolderPath, @"ProjectSettings' packagesFolderPath not yielding anything, forgot to set projectPath property?");

    NSFileManager *fileManager = [NSFileManager defaultManager];;
    if (![fileManager createDirectoryAtPath:packageFolderPath
                          withIntermediateDirectories:NO
                                           attributes:nil
                                                error:error])
    {
        LocalLogError(@"ERROR Creating packages folder: %@", (*error).localizedDescription);
        return NO;
    }
    LocalLogDebug(@"Trying to create packages folder DONE");
    return YES;
}

- (BOOL)packageFolderExists
{
    NSString *packageFolderPath = [_projectSettings packagesFolderPath];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    return [fileManager fileExistsAtPath:packageFolderPath];
}


/*
- (BOOL)renameResourcePathWithPackagesFolderName:(NSError **)error
{
    if ([self packageFolderExists]
        && [self isPackageFolderAResourcePath])
    {
        return [self renamePackagesResourcePathFolder:error];
    }
    return YES;
}


- (BOOL)isPackageFolderAResourcePath
{
    // NOTE: If a resource path is named packages/ or whatever in PACKAGES_FOLDER_NAME is
    // it has to be renamed in order create the packages/ folder
    if ([_projectSettings isResourcePathInProject:[_projectSettings packagesFolderPath]])
    {
        self.resourcePathWithPackagesFolderNameFound = YES;
        return YES;
    }
    return NO;
}

- (BOOL)renamePackagesResourcePathFolder:(NSError **)error
{
    LocalLogDebug(@"Trying to rename resource folder with \"packages\" name...");

    NSFileManager *fileManager = [NSFileManager defaultManager];;
    NSString *renamePathTo = [self renamePathForSpecialCasePackagesFolderAsResourcePath:@"user"];

    NSString *renamePathFrom = [_projectSettings packagesFolderPath];
    if (![fileManager moveItemAtPath:renamePathFrom toPath:renamePathTo error:error])
    {
        LocalLogError(@"ERROR Special case renaming: %@ -> \"%@\" found: renaming to: \"%@\"", (*error).localizedDescription, renamePathFrom, renamePathTo);
        return NO;
    }

    _renameMap[renamePathFrom] = renamePathTo;

    LocalLogDebug(@"Special case: resource path with name \"%@\" found: renaming to: \"%@\"", PACKAGES_FOLDER_NAME, renamePathTo);
    LocalLogDebug(@"Trying to rename resource folder with \"packages\" name DONE");

    NSString *newResourcePathName = [renamePathTo lastPathComponent];
    for (NSMutableDictionary *resourcePath in _projectSettings.resourcePaths)
    {
        if ([[_projectSettings fullPathForResourcePathDict:resourcePath] isEqualToString:[_projectSettings packagesFolderPath]])
        {
            // TODO: use ResourcePath object
            resourcePath[@"path"] = [[resourcePath[@"path"] stringByDeletingLastPathComponent] stringByAppendingPathComponent:newResourcePathName];
            LocalLogDebug(@"New relative path: \"%@\"", [_projectSettings fullPathForResourcePathDict:resourcePath]);
        }
    }

    return YES;
}

- (NSString *)renamePathForSpecialCasePackagesFolderAsResourcePath:(NSString *)suffix
{
    NSFileManager *fileManager = [NSFileManager defaultManager];;
    NSString *renamePathTo = [[_projectSettings packagesFolderPath] stringByAppendingPathExtension:suffix];
    NSUInteger count = 0;
    while ([fileManager fileExistsAtPath:renamePathTo])
    {
        LocalLogDebug(@"Special case: name \"%@\" exists, trying next...", [renamePathTo lastPathComponent]);

        NSString *renameSuffixWithCount =[NSString stringWithFormat:@"%@.%lu", suffix, count];
        renamePathTo = [[_projectSettings packagesFolderPath] stringByAppendingPathExtension:renameSuffixWithCount];
        count ++;
    }
    return renamePathTo;
}

- (BOOL)migrateAllResourcePaths:(NSError **)error
{
    LocalLogDebug(@"Migrating resource paths...");
    for (NSMutableDictionary *resourcePathDict in _projectSettings.resourcePaths)
    {
        ResourcePath *resourcePath = [[ResourcePath alloc] initWithDictionary:resourcePathDict];

        LocalLogDebug(@"Current resource path \"%@\"", resourcePath.relativePath);
        if ([self isResourcePathInPackagesFolder:resourcePath])
        {
            LocalLogDebug(@"Skipping: Resource path \"%@\" already in packages folder.", resourcePath);
            continue;
        }

        if (![self moveResourcePathToPackagesFolder:resourcePath error:error])
        {
            return NO;
        }

        resourcePathDict[@"path"] = resourcePath.relativePath;
        LocalLogDebug(@"Resource path moved to rel path \"%@\"", resourcePath.relativePath);
    }
    return YES;
}

- (BOOL)isResourcePathInPackagesFolder:(ResourcePath *)resourcePath
{
    NSString *fullResourcePath = [_projectSettings fullPathForResourcePath:resourcePath];

    return [_projectSettings isPathInPackagesFolder:fullResourcePath];
}

- (BOOL)renameResourcePathBeforeMovingToPackage:(ResourcePath *)resourcePath error:(NSError **)error
{
    // Use map? / History for rollback?
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *fullResourcePath = [_projectSettings fullPathForResourcePath:resourcePath];
    NSString *folderNameOfResource = [resourcePath.relativePath lastPathComponent];
    NSString *futureFullPathInPackagesFolder = [_projectSettings fullPathForPackageName:folderNameOfResource];

    // TODO melt with renamePathForSpecialCasePackagesFolderAsResourcePath
    NSUInteger count = 0;
    while ([fileManager fileExistsAtPath:futureFullPathInPackagesFolder])
    {
        LocalLogDebug(@"Existing folder in packages/ for moving resource path. Name \"%@\" exists, trying next...", [futureFullPathInPackagesFolder lastPathComponent]);

        NSString *renameSuffixWithCount =[NSString stringWithFormat:@"%@.%lu", @"renamed", count];
        futureFullPathInPackagesFolder = [[_projectSettings packagesFolderPath] stringByAppendingPathExtension:renameSuffixWithCount];
        count ++;
    }

    if (![fileManager moveItemAtPath:fullResourcePath toPath:futureFullPathInPackagesFolder error:error])
    {
        LocalLogDebug(@"EROR renaming \"%@\" to \"%@\"", fullResourcePath, futureFullPathInPackagesFolder);
        return NO;
    }

    NSString *newResourcePathName = [futureFullPathInPackagesFolder lastPathComponent];
    resourcePath.relativePath = [[resourcePath.relativePath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newResourcePathName];
    LocalLogDebug(@"New relative path: \"%@\"", fullResourcePath);

    return YES;
}

- (BOOL)moveResourcePathToPackagesFolder:(ResourcePath *)resourcePath error:(NSError **)error
{
    LocalLogDebug(@"Trying to move resource path \"%@\" to packages/ folder", resourcePath);
    if (![self canMoveResourcePathToPackagesFolder:resourcePath])
    {
        LocalLogDebug(@"Cannot move, name collision, trying to rename: \"%@\"", resourcePath);
        if (![self renameResourcePathBeforeMovingToPackage:resourcePath error:error])
        {
            return NO;
        }
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSString *fromPath = [_projectSettings fullPathForResourcePath:resourcePath];
    NSString *packageName = [resourcePath.relativePath lastPathComponent];
    NSString *toPath = [_projectSettings fullPathForPackageName:packageName];

    if (![fileManager moveItemAtPath:fromPath toPath:toPath error:error])
    {
        return NO;
    }

    resourcePath.relativePath = [PACKAGES_FOLDER_NAME stringByAppendingPathComponent:packageName];

    return YES;
}

- (BOOL)canMoveResourcePathToPackagesFolder:(ResourcePath *)resourcePath
{
    NSString *folderNameOfResource = [resourcePath.relativePath lastPathComponent];
    NSString *futureFullPathInPackagesFolder = [_projectSettings fullPathForPackageName:folderNameOfResource];

    NSFileManager *fileManager = [NSFileManager defaultManager];

    return ![fileManager fileExistsAtPath:futureFullPathInPackagesFolder];
}

- (BOOL)restoreSpecialCasePackagesResourcePathFolder
{
    // The renamed resource path has been moved and can now be renamed back to
    // its original name, it will get the PACKAGE_NAME_SUFFIX appended later on
    if (_resourcePathWithPackagesFolderNameFound)
    {
        // Restore name
    }

    return YES;
}

- (BOOL)addPackageSuffixToMovedResourcePaths:(NSMutableDictionary *)resourcePath
{
    return YES;
}

*/

@end