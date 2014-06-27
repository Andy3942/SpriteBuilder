//
//  AndroidPluginInstaller.m
//  SpriteBuilder
//
//  Created by John Twigg on 6/27/14.
//
//

#import "AndroidPluginInstaller.h"



#ifdef DEBUG
#define SBPRO_TEST_INSTALLER
#endif



static const float kSBProPluginVersion = 1.0;
NSString*   kSBDefualtsIdentifier = @"SBProPluginVersion";

@implementation AndroidPluginInstaller

+(BOOL)runPythonScript:(NSString*)command output:(NSString**)result
{
    NSTask* task = [[NSTask alloc] init];
    task.launchPath = @"/usr/bin/python";
	
	NSString *scriptPath = [[NSBundle mainBundle] pathForResource:@"plugin_installer" ofType:@"py"];
	NSString *pluginBundlePath = [[NSBundle mainBundle] pathForResource:@"AndroidPlugin" ofType:@"zip" inDirectory:@"Generated"];
	
    task.arguments = [NSArray arrayWithObjects: scriptPath, command, pluginBundlePath, nil];
	
    // NSLog breaks if we don't do this...
    [task setStandardInput: [NSPipe pipe]];
	
    NSPipe *stdOutPipe = nil;
    stdOutPipe = [NSPipe pipe];
    [task setStandardOutput:stdOutPipe];
	
    NSPipe* stdErrPipe = nil;
    stdErrPipe = [NSPipe pipe];
    [task setStandardError: stdErrPipe];
	
    [task launch];
	
    NSData* data = [[stdOutPipe fileHandleForReading] readDataToEndOfFile];
	
    [task waitUntilExit];
	
    NSInteger exitCode = task.terminationStatus;
	*result = [[NSString alloc] initWithBytes: data.bytes length:data.length encoding: NSUTF8StringEncoding];
	
	if( exitCode != 0)
	{
		NSLog(@"Error with python: %@ %@", task.launchPath, command);
		NSLog(@"%@",*result);
	}
	
    return exitCode == 0;
}

+(BOOL)installPlugin:(NSString**)output
{
	return [self runPythonScript:@"install" output:output];
}

+(BOOL)removePlugin:(NSString**)output
{
	return [self runPythonScript:@"clean" output:output];
}

+(BOOL)verifyPluginInstallation:(NSString**)output
{
	return [self runPythonScript:@"validate" output:output];
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

+(void)setInstallationVersion
{
	[[NSUserDefaults standardUserDefaults] setObject:@(kSBProPluginVersion) forKey:kSBDefualtsIdentifier];
}


@end
