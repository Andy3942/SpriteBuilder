//
//  AndroidPluginInstallerWindow.m
//  SpriteBuilder
//
//  Created by John Twigg on 6/27/14.
//
//

#import "AndroidPluginInstallerWindow.h"
#import "AndroidPluginInstaller.h"
#import "AppDelegate.h"
#import "NSAlert+Convenience.h"

#ifdef DEBUG
#define SBPRO_TEST_INSTALLER
#endif
static const float kSBProPluginVersion = 1.0;
static NSString*   kSBDefualtsIdentifier = @"SBProPluginVersion";

@interface AndroidPluginInstallerWindow ()
{

	
}
@property (weak) IBOutlet NSProgressIndicator *activityIndicator;
@end

@implementation AndroidPluginInstallerWindow

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
	[self runInstaller];
	
}

-(void)runInstaller
{
	[self.activityIndicator startAnimation:self];
	
	dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
		
		NSNumber * currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"SBProPluginVersion"];
		BOOL upgrading = currentVersion == nil;
		
		
		
		BOOL success = YES;
		NSString*output;
		
		//////		//////		//////		//////		//////		//////		//////
		//If we're upgrading, clean
		if(upgrading && ![AndroidPluginInstaller removePlugin:&output])
		{
			success = false;
		}
		
		
		//Verify plugin
		if(success && ![AndroidPluginInstaller verifyPluginInstallation:&output])
		{
			success = false;
		}
		
		
		//Install new plugin.
		if(success && ![AndroidPluginInstaller installPlugin:&output])
	    {
			success = false;
	    }
		
		if(success)
		{
			[[NSUserDefaults standardUserDefaults] setObject:@(kSBProPluginVersion) forKey:kSBDefualtsIdentifier];
		}
				
		dispatch_async(dispatch_get_main_queue(), ^(void){
			
			if(!success)
			{
				NSString * errorLine = [self lastLine:output];
				[NSAlert showModalDialogWithTitle:@"Failed to install Android Plugin" message:errorLine];
				[NSApp stopModalWithCode:0];
			}
				
			[NSApp stopModalWithCode:1];
		});
	});
	
}


-(NSString*)lastLine:(NSString*)string
{

	NSMutableArray * fileLines = [[NSMutableArray alloc] initWithArray:[string componentsSeparatedByString:@"\r\n"] copyItems: YES];
	return fileLines.lastObject;
}

+(BOOL)needsInstallation
{
	
#ifdef SBPRO_TEST_INSTALLER
	return YES;
#endif

	NSNumber * currentVersion = [[NSUserDefaults standardUserDefaults] objectForKey:kSBDefualtsIdentifier];
	if(currentVersion == nil || [currentVersion floatValue] < kSBProPluginVersion)
	{
		return YES;
	}
	return NO;
}

@end
