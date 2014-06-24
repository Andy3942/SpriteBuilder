//
//  EffectsManager.m
//  SpriteBuilder
//
//  Created by John Twigg on 6/23/14.
//
//

#import "EffectsManager.h"
#import "CCBPEffectBrightness.h"
#import "CCBPEffectContrast.h"
//#import "CCBPEffectGlow.h"
#import "CCBPEffectPixelate.h"
#import "CCBPEffectSaturation.h"
#import "NSArray+Query.h"
#import "EffectBrightnessControl.h"
#import "EffectContrastControl.h"
#import "EffectPixelateControl.h"
#import "EffectSaturationControl.h"

@implementation EffectDescription

-(CCEffect*)constructDefault
{

	Class classType = NSClassFromString(self.className);
	NSAssert([classType conformsToProtocol:@protocol(EffectProtocol)], @"Should conform to Effect Protocol");

	Class<EffectProtocol> protocolClass = (Class<EffectProtocol>)classType;
	
	return [protocolClass defaultConstruct];;
}
@end

@implementation EffectsManager

+(NSArray*)effects
{
	
	NSMutableArray * effectDescriptions = [NSMutableArray new];
	
	{
		EffectDescription * effectDescription = [[EffectDescription alloc] init];
		effectDescription.title = @"Brightness";
		effectDescription.description = @"Makes things bright";
		effectDescription.imageName = @"effect-brightness.png";
		effectDescription.className = NSStringFromClass([CCBPEffectBrightness class]);
		effectDescription.viewController = NSStringFromClass([EffectBrightnessControl class]);
		
		[effectDescriptions addObject:effectDescription];
	}
	
	{
		EffectDescription * effectDescription = [[EffectDescription alloc] init];
		effectDescription.title = @"Contrast";
		effectDescription.description = @"Makes things contrast";
		effectDescription.imageName = @"effect-contrast.png";
		effectDescription.className = NSStringFromClass([CCBPEffectContrast class]);
		effectDescription.viewController = NSStringFromClass([EffectContrastControl class]);
		
		
		
		[effectDescriptions addObject:effectDescription];
	}
	
	{
		EffectDescription * effectDescription = [[EffectDescription alloc] init];
		effectDescription.title = @"Pixellate";
		effectDescription.description = @"Makes things pixelate";
		effectDescription.imageName = @"effect-pixelate.png";
		effectDescription.className = NSStringFromClass([CCBPEffectPixelate class]);
		effectDescription.viewController = NSStringFromClass([EffectPixelateControl class]);
		
		[effectDescriptions addObject:effectDescription];
	}
	
	{
		EffectDescription * effectDescription = [[EffectDescription alloc] init];
		effectDescription.title = @"Saturation";
		effectDescription.description = @"Makes things saturate";
		effectDescription.imageName = @"effect-saturation.png";
		effectDescription.className = NSStringFromClass([CCBPEffectSaturation class]);
		effectDescription.viewController = NSStringFromClass([EffectSaturationControl class]);
		
		[effectDescriptions addObject:effectDescription];
	}
	
	return effectDescriptions;
}

+(EffectDescription*)effectByClassName:(NSString*)className
{
	return [[self effects] findFirst:^BOOL(EffectDescription * effectDescription, int idx) {
		return [effectDescription.className isEqualToString:className];
	}];
}

@end
