//
//  NewPackageWindowController.m
//  SpriteBuilder
//
//  Created by Nicky Weber on 22.05.14.
//
//

#import "NewPackageWindowController.h"

#import "PackageCreateDelegateProtocol.h"


@interface NewPackageWindowController ()

@property (nonatomic, readwrite, copy) NSString *packageName;

@end


@implementation NewPackageWindowController

- (instancetype)init
{
    self = [super initWithWindowNibName:@"NewPackageWindow"];

    if (self)
    {
        self.packageName = @"UntitledPackage";
    }

    return self;
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    [self resetWarning];
}

- (IBAction)onCreate:(id)sender
{
    NSError *error;
    if (![_delegate createPackageWithName:_packageName error:&error])
    {
        [self showCannotCreatePackageWarningWithError:error];
        return;
    }

    [NSApp stopModalWithCode:1];
}

- (void)showCannotCreatePackageWarningWithError:(NSError *)error
{
    _errorMessage.hidden = NO;
    _errorMessage.stringValue = error.localizedDescription;
    _packageNameInput.textColor = [NSColor colorWithSRGBRed:1.0 green:0.0 blue:0.0 alpha:1.0];
}

- (void)resetWarning
{
    _errorMessage.hidden = YES;
    _packageNameInput.textColor = [NSColor blackColor];
}

- (IBAction)onCancel:(id)sender
{
    [NSApp stopModalWithCode:0];
}

- (void)windowDidLoad
{
    [super windowDidLoad];

    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

@end
