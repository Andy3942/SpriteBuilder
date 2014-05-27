// SpriteBuilder error domain
NSString *const SBErrorDomain = @"SBErrorDomain";

// === Error codes ===

// GUI / DragnDrop
NSInteger const SBNodeDoesNotSupportChildrenError = 1000;
NSInteger const SBChildRequiresSpecificParentError = 1001;
NSInteger const SBParentDoesNotPermitSpecificChildrenError = 1002;

// Update Cocos2d
NSInteger const SBCocos2dUpdateTemplateZipFileDoesNotExistError = 2000;
NSInteger const SBCocos2dUpdateUnzipTemplateFailedError = 2001;
NSInteger const SBCocos2dUpdateUnzipTaskError = 2002;

// Create Resource path
NSInteger const SBDuplicateResourcePathError = 2100;
NSInteger const SBResourcePathNotInProject = 2101;
NSInteger const SBImportingPackagesError = 2102;
NSInteger const SBResourcePathExistsButNotInProjectError = 2103;