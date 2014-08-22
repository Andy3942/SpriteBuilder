/*
 * CocosBuilder: http://www.cocosbuilder.com
 *
 * Copyright (c) 2012 Zynga Inc.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "ResourceManagerPreviewView.h"
#import "ResourceManager.h"
#import "CCBImageView.h"
#import "AppDelegate.h"
#import "ProjectSettings.h"
#import "FCFormatConverter.h"
#import "ResourceManagerPreivewAudio.h"
#import "ResourceTypes.h"
#import "RMResource.h"
#import "RMDirectory.h"
#import "MiscConstants.h"
#import "NSAlert+Convenience.h"

@interface ResourceManagerPreviewView()

@property (nonatomic) BOOL initialUpdate;
@property (nonatomic, strong) RMResource *previewedResource;

@end



@implementation ResourceManagerPreviewView

@dynamic    format_supportsPVRTC;

#pragma mark Setup

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    [_previewMain setAllowsCutCopyPaste:NO];
    [_previewPhone setAllowsCutCopyPaste:NO];
    [_previewPhonehd setAllowsCutCopyPaste:NO];
    [_previewTablet setAllowsCutCopyPaste:NO];
    [_previewTablethd setAllowsCutCopyPaste:NO];
    
    previewAudioViewController = [[ResourceManagerPreviewAudio alloc] initWithNibName:@"ResourceManagerPreviewAudio" bundle:[NSBundle mainBundle]];
    
    previewAudioViewController.view.frame = CGRectMake(0, 0, previewSound.frame.size.width, previewSound.frame.size.height);
    
    [previewSound addSubview:previewAudioViewController.view];
    
    [previewAudioViewController setupPlayer];

    [_androidContainerImage setHidden:!IS_SPRITEBUILDER_PRO];
    [_androidContainerSound setHidden:!IS_SPRITEBUILDER_PRO];
    [_androidContainerSpriteSheet setHidden:!IS_SPRITEBUILDER_PRO];
}

- (AppDelegate*) appDelegate
{
    return [AppDelegate appDelegate];
}

- (void) resetView
{
    // Clear all previews
    [_previewMain setImage:NULL];
    [_previewPhone setImage:NULL];
    [_previewPhonehd setImage:NULL];
    [_previewTablet setImage:NULL];
    [_previewTablethd setImage:NULL];

    self.imgMain = NULL;
    self.imgPhone = NULL;
    self.imgPhonehd = NULL;
    self.imgTablet = NULL;
    self.imgTablethd = NULL;
    
    self.previewedResource = NULL;
    
    self.enabled = NO;
    self.scaleFrom = 0;
    
    self.format_ios_compress_enabled = NO;
    self.format_ios_dither_enabled = NO;
    self.format_ios_compress = NO;
    self.format_ios_dither = NO;
    
    self.trimSprites = NO;
}

- (void)setPreviewResource:(id)resource
{
    [self resetView];

    [self hideAllPeviewViews];

    self.initialUpdate = YES;

    if ([resource isKindOfClass:[RMResource class]])
    {
        RMResource* res = (RMResource*) resource;
        self.previewedResource = res;
        
        if (res.type == kCCBResTypeImage)
        {
            [self updateImagePreview:resource settings:_projectSettings res:res];
        }
        else if (res.type == kCCBResTypeDirectory && [res.data isDynamicSpriteSheet])
        {
            [self updateSpriteSheetPreview:_projectSettings res:res];
        }
        else if (res.type == kCCBResTypeAudio)
        {
            [self updateSoundPreview:_projectSettings res:res];
        }
        else if (res.type == kCCBResTypeCCBFile)
        {
            [self updateCCBFilePreview:res];
        }
        else
        {
            [viewGeneric setHidden:NO];
        }
    }
    else
    {
        [viewGeneric setHidden:NO];
    }

    self.initialUpdate = NO;
}

- (void)hideAllPeviewViews
{
    [viewGeneric setHidden:YES];
    [viewImage setHidden:YES];
    [viewSpriteSheet setHidden:YES];
    [viewSound setHidden:YES];
    [viewCCB setHidden:YES];
}

- (void)updateCCBFilePreview:(RMResource *)res
{
    NSString *imgPreviewPath = [res.filePath stringByAppendingPathExtension:@"ppng"];
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:imgPreviewPath];
    if (!img)
    {
        img = [NSImage imageNamed:@"ui-nopreview.png"];
    }

    [previewCCB setImage:img];

    [viewCCB setHidden:NO];
}

- (void)updateSoundPreview:(ProjectSettings *)settings res:(RMResource *)res
{
    self.format_ios_sound = [[settings propertyForResource:res andKey:@"format_ios_sound"] intValue];
    self.format_ios_sound_quality = [[settings propertyForResource:res andKey:@"format_ios_sound_quality"] intValue];
    self.format_ios_sound_quality_enabled = _format_ios_sound != 0;

    self.format_android_sound = [[settings propertyForResource:res andKey:@"format_android_sound"] intValue];
    self.format_android_sound_quality = [[settings propertyForResource:res andKey:@"format_android_sound_quality"] intValue];
    self.format_android_sound_quality_enabled = YES;

    // Update icon
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFileType:@"wav"];
    [icon setScalesWhenResized:YES];
    icon.size = NSMakeSize(128, 128);
    [previewSoundImage setImage:icon];

    [previewAudioViewController loadAudioFile:res.filePath];

    self.enabled = YES;

    [viewSound setHidden:NO];
}

- (void)updateSpriteSheetPreview:(ProjectSettings *)settings res:(RMResource *)res
{
    self.format_ios = [[settings propertyForResource:res andKey:@"format_ios"] intValue];
    self.format_ios_dither = [[settings propertyForResource:res andKey:@"format_ios_dither"] boolValue];
    self.format_ios_compress = [[settings propertyForResource:res andKey:@"format_ios_compress"] boolValue];
    self.format_ios_dither_enabled = [self supportsDither_ios:_format_ios];
    self.format_ios_compress_enabled = [self supportsCompress_ios:_format_ios];

    self.format_android = [[settings propertyForResource:res andKey:@"format_android"] intValue];
    self.format_android_dither = [[settings propertyForResource:res andKey:@"format_android_dither"] boolValue];
    self.format_android_compress = [[settings propertyForResource:res andKey:@"format_android_compress"] boolValue];
    self.format_android_dither_enabled = [self supportsDither_android:_format_android];
    self.format_android_compress_enabled = NO;

    self.trimSprites = ![[settings propertyForResource:res andKey:@"keepSpritesUntrimmed"] boolValue];

    NSString *imgPreviewPath = [res.filePath stringByAppendingPathExtension:@"ppng"];
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:imgPreviewPath];
    if (!img)
    {
        img = [NSImage imageNamed:@"ui-nopreview.png"];
    }

    [previewSpriteSheet setImage:img];

    self.enabled = YES;

    [viewSpriteSheet setHidden:NO];
}

- (void)updateImagePreview:(id)selection settings:(ProjectSettings *)settings res:(RMResource *)res
{
    self.imgMain = [selection previewForResolution:@"auto"];
    self.imgPhone = [selection previewForResolution:@"phone"];
    self.imgPhonehd = [selection previewForResolution:@"phonehd"];
    self.imgTablet = [selection previewForResolution:@"tablet"];
    self.imgTablethd = [selection previewForResolution:@"tablethd"];

    [_previewMain setImage:self.imgMain];
    [_previewPhone setImage:self.imgPhone];
    [_previewPhonehd setImage:self.imgPhonehd];
    [_previewTablet setImage:self.imgTablet];
    [_previewTablethd setImage:self.imgTablethd];

    // Load settings
    self.scaleFrom = [[settings propertyForResource:res andKey:@"scaleFrom"] intValue];

    self.format_ios = [[settings propertyForResource:res andKey:@"format_ios"] intValue];
    self.format_ios_dither = [[settings propertyForResource:res andKey:@"format_ios_dither"] boolValue];
    self.format_ios_compress = [[settings propertyForResource:res andKey:@"format_ios_compress"] boolValue];
    self.format_ios_dither_enabled = [self supportsDither_ios:_format_ios];
    self.format_ios_compress_enabled = [self supportsCompress_ios:_format_ios];

    self.format_android = [[settings propertyForResource:res andKey:@"format_android"] intValue];
    self.format_android_dither = [[settings propertyForResource:res andKey:@"format_android_dither"] boolValue];
    self.format_android_compress = [[settings propertyForResource:res andKey:@"format_android_compress"] boolValue];
    self.format_android_dither_enabled = [self supportsDither_android:_format_android];
    self.format_android_compress_enabled = NO;

    int tabletScale = [[settings propertyForResource:res andKey:@"tabletScale"] intValue];
    if (!tabletScale)
    {
        tabletScale = 2;
    }
    self.tabletScale = tabletScale;

    self.enabled = YES;

    [viewImage setHidden:NO];
}

#pragma mark Callbacks

- (NSString*) resolutionDirectoryForImageView:(NSImageView*) imgView
{
    NSString* resolution = NULL;
    if (imgView == _previewMain) resolution = @"auto";
    else if (imgView == _previewPhone) resolution = @"phone";
    else if (imgView == _previewPhonehd) resolution = @"phonehd";
    else if (imgView == _previewTablet) resolution = @"tablet";
    else if (imgView == _previewTablethd) resolution = @"tablethd";
    
    if (!resolution) return NULL;
    
    return [@"resources-" stringByAppendingString:resolution];
}

- (IBAction)droppedFile:(id)sender
{
    if (_projectSettings)
    {
        [self resetView];
        return;
    }
    
    if (!_previewedResource)
    {
        return;
    }
    
    CCBImageView* imgView = sender;
    
    NSString* srcImagePath = imgView.imagePath;
    
    if (![[[srcImagePath pathExtension] lowercaseString] isEqualToString:@"png"])
    {
        [NSAlert showModalDialogWithTitle:@"Unsupported Format"
                                  message:@"Sorry, only png images are supported as source images."];
        return;
    }
    
    NSString* resolution = [self resolutionDirectoryForImageView:imgView];
    if (!resolution) return;
    
    // Calc dst path
    NSString* dir = [_previewedResource.filePath stringByDeletingLastPathComponent];
    NSString* file = [_previewedResource.filePath lastPathComponent];
    
    NSString* dstFile = [[dir stringByAppendingPathComponent:resolution] stringByAppendingPathComponent:file];
    
    // Create directory if it doesn't exist
    NSFileManager* fm = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:[dstFile stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:NULL error:NULL];
    
    // Copy file
    [fm removeItemAtPath:dstFile error:NULL];
    [fm copyItemAtPath:srcImagePath toPath:dstFile error:NULL];
    
    // Reload open document
    [[AppDelegate appDelegate] reloadResources];
}

- (IBAction)actionRemoveFile:(id)sender
{
    if (!_previewedResource) return;
    
    CCBImageView* imgView = NULL;
    int tag = [sender tag];
    if (tag == 0) imgView = _previewPhone;
    else if (tag == 1) imgView = _previewPhonehd;
    else if (tag == 2) imgView = _previewTablet;
    else if (tag == 3) imgView = _previewTablethd;
    
    if (!imgView) return;
    
    NSString* resolution = [self resolutionDirectoryForImageView:imgView];
    if (!resolution) return;
    
    NSString* dir = [_previewedResource.filePath stringByDeletingLastPathComponent];
    NSString* file = [_previewedResource.filePath lastPathComponent];
    
    NSString* rmFile = [[dir stringByAppendingPathComponent:resolution] stringByAppendingPathComponent:file];
    
    // Remove file
    NSFileManager* fm = [NSFileManager defaultManager];
    [fm removeItemAtPath:rmFile error:NULL];
    
    // Remove from view
    imgView.image = NULL;
    
    // Reload open document
    [[AppDelegate appDelegate] reloadResources];
}

#pragma mark Edit properties

-(BOOL)format_supportsPVRTC
{
    //early out.
    if(_previewedResource.type != kCCBResTypeImage)
        return YES;
    
    NSBitmapImageRep * bitmapRep = self.imgMain.representations[0];
    if(bitmapRep == nil)
        return YES;
    
    if(bitmapRep.pixelsHigh != bitmapRep.pixelsWide)
        return NO;
    
    //Is power of 2?
    double result = log((double)bitmapRep.pixelsHigh)/log(2.0);

    return 1 << (int)result == bitmapRep.pixelsHigh;
}

- (BOOL) supportsCompress_ios:(int)format
{
    if (format == kFCImageFormatPVR_RGBA8888) return YES;
    if (format == kFCImageFormatPVR_RGBA4444) return YES;
    if (format == kFCImageFormatPVR_RGB565) return YES;
    if (format == kFCImageFormatPVRTC_2BPP) return YES;
    if (format == kFCImageFormatPVRTC_4BPP) return YES;
    return NO;
}

- (BOOL) supportsDither_ios:(int)format
{
    if (format == kFCImageFormatPNG_8BIT) return YES;
    if (format == kFCImageFormatPVR_RGBA4444) return YES;
    if (format == kFCImageFormatPVR_RGB565) return YES;
    return NO;
}

- (BOOL) supportsDither_android:(int)format
{
    if (format == kFCImageFormatPNG_8BIT) return YES;
    if (format == kFCImageFormatPVR_RGBA4444) return YES;
    if (format == kFCImageFormatPVR_RGB565) return YES;
    return NO;
}

- (void) setScaleFrom:(int)scaleFrom
{
    _scaleFrom = scaleFrom;

    if (_initialUpdate)
    {
        return;
    }

    if (_previewedResource)
    {
        // Return if the value hasn't changed
        int oldScaleFrom = [[_projectSettings propertyForResource:_previewedResource andKey:@"scaleFrom"] intValue];
        if (oldScaleFrom == scaleFrom) return;

        if (scaleFrom)
        {
            [_projectSettings setProperty:@(scaleFrom) forResource:_previewedResource andKey:@"scaleFrom"];
        }
        else
        {
            [_projectSettings removePropertyForResource:_previewedResource andKey:@"scaleFrom"];
        }

        // Reload the resource
        [ResourceManager touchResource:_previewedResource];
        [[AppDelegate appDelegate] reloadResources];
    }
}

- (void) setFormat_ios:(int)format_ios
{
    _format_ios = format_ios;

    if (_initialUpdate)
    {
        return;
    }

    if (_previewedResource)
    {
        if (format_ios)
        {
            [_projectSettings setProperty:@(format_ios) forResource:_previewedResource andKey:@"format_ios"];
        }
        else
        {
            [_projectSettings removePropertyForResource:_previewedResource andKey:@"format_ios"];
        }
        
        self.format_ios_dither_enabled = [self supportsDither_ios:format_ios];
        self.format_ios_compress_enabled = [self supportsCompress_ios:format_ios];
    }
}

- (void) setFormat_android:(int)format_android
{
    _format_android = format_android;

    if (_initialUpdate)
    {
        return;
    }

    if (_previewedResource)
    {
        if (format_android)
        {
            [_projectSettings setProperty:@(format_android) forResource:_previewedResource andKey:@"format_android"];
        }
        else
        {
            [_projectSettings removePropertyForResource:_previewedResource andKey:@"format_android"];
        }
        
        self.format_android_dither_enabled = [self supportsDither_android:format_android];
        self.format_android_compress_enabled = NO;
    }
}

- (void) setFormat_ios_dither:(BOOL)format_ios_dither
{
    _format_ios_dither = format_ios_dither;

    if (_initialUpdate)
    {
        return;
    }

    if (_previewedResource)
    {
        if (format_ios_dither)
        {
            [_projectSettings setProperty:@(format_ios_dither) forResource:_previewedResource andKey:@"format_ios_dither"];
        }
        else
        {
            [_projectSettings removePropertyForResource:_previewedResource andKey:@"format_ios_dither"];
        }
    }
}

- (void) setFormat_android_dither:(BOOL)format_android_dither
{
    _format_android_dither = format_android_dither;

    if (_initialUpdate)
    {
        return;
    }

    if (_previewedResource)
    {
        if (format_android_dither)
        {
            [_projectSettings setProperty:@(format_android_dither) forResource:_previewedResource andKey:@"format_android_dither"];
        }
        else
        {
            [_projectSettings removePropertyForResource:_previewedResource andKey:@"format_android_dither"];
        }
    }
}

- (void) setFormat_ios_compress:(BOOL)format_ios_compress
{
    _format_ios_compress = format_ios_compress;

    if (_initialUpdate)
    {
        return;
    }

    if (_previewedResource)
    {
        if (format_ios_compress)
        {
            [_projectSettings setProperty:@(format_ios_compress) forResource:_previewedResource andKey:@"format_ios_compress"];
        }
        else
        {
            [_projectSettings removePropertyForResource:_previewedResource andKey:@"format_ios_compress"];
        }
    }
}

- (void) setFormat_android_compress:(BOOL)format_android_compress
{
    _format_android_compress = format_android_compress;

    if (_initialUpdate)
    {
        return;
    }

    if (_previewedResource)
    {
        if (format_android_compress)
        {
            [_projectSettings setProperty:@(format_android_compress) forResource:_previewedResource andKey:@"format_android_compress"];
        }
        else
        {
            [_projectSettings removePropertyForResource:_previewedResource andKey:@"format_android_compress"];
        }
    }
}

- (void) setTrimSprites:(BOOL) trimSprites
{
    if (_trimSprites == trimSprites)
    {
        return;
    }

    _trimSprites = trimSprites;

    if (_initialUpdate)
    {
        return;
    }

    if (_previewedResource)
    {
        if (!trimSprites)
        {
            [_projectSettings setProperty:@(!trimSprites) forResource:_previewedResource andKey:@"keepSpritesUntrimmed"];
        }
        else
        {
            [_projectSettings removePropertyForResource:_previewedResource andKey:@"keepSpritesUntrimmed"];
        }
    }
}

- (void) setTabletScale:(int)tabletScale
{
    if (_tabletScale == tabletScale)
    {
        return;
    }
    
    _tabletScale = tabletScale;

    if (_initialUpdate)
    {
        return;
    }

    // Return if tabletScale hasn't changed
    int oldTabletScale = [[_projectSettings propertyForResource:_previewedResource andKey:@"tabletScale"] intValue];
    if (tabletScale == oldTabletScale) return;
    if (tabletScale == 2 && !oldTabletScale) return;
    
    // Update value and reload assets
    if (tabletScale != 2)
    {
        [_projectSettings setProperty:@(tabletScale) forResource:_previewedResource andKey:@"tabletScale"];
    }
    else
    {
        [_projectSettings removePropertyForResource:_previewedResource andKey:@"tabletScale"];
    }
    
    [ResourceManager touchResource:_previewedResource];
    [[AppDelegate appDelegate] reloadResources];
}

- (void) setFormat_ios_sound:(int)format_ios_sound
{
    _format_ios_sound = format_ios_sound;

    if (_initialUpdate)
    {
        return;
    }

    if (_previewedResource)
    {
        [_projectSettings setProperty:@(format_ios_sound) forResource:_previewedResource andKey:@"format_ios_sound"];

        self.format_ios_sound_quality_enabled = format_ios_sound != 0;
    }
}

- (void) setFormat_android_sound:(int)format_android_sound
{
    _format_android_sound = format_android_sound;

    if (_initialUpdate)
    {
        return;
    }

    if (_previewedResource)
    {
        [_projectSettings setProperty:@(format_android_sound) forResource:_previewedResource andKey:@"format_android_sound"];
        self.format_android_sound_quality_enabled = YES;
    }
}

- (void) setFormat_ios_sound_quality:(int)format_ios_sound_quality
{
    _format_ios_sound_quality = format_ios_sound_quality;

    if (_initialUpdate)
    {
        return;
    }

    if (_previewedResource)
    {
        [_projectSettings setProperty:@(format_ios_sound_quality) forResource:_previewedResource andKey:@"format_ios_sound_quality"];
    }
}

- (void) setFormat_android_sound_quality:(int)format_android_sound_quality
{
    _format_android_sound_quality = format_android_sound_quality;

    if (_initialUpdate)
    {
        return;
    }

    if (_previewedResource)
    {
        [_projectSettings setProperty:@(format_android_sound_quality) forResource:_previewedResource andKey:@"format_android_sound_quality"];
    }
}

#pragma mark Split view constraints

- (CGFloat) splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    if (proposedMinimumPosition < 220) return 220;
    else return proposedMinimumPosition;
}

- (CGFloat) splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    float max = (float) (splitView.frame.size.height - 100);
    if (proposedMaximumPosition > max) return max;
    else return proposedMaximumPosition;
}


@end
