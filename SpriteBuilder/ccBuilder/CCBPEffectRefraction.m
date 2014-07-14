//
//  CCBPEffectRefraction.m
//  SpriteBuilder
//
//  Created by John Twigg on 7/8/14.
//
//

#import "CCBPEffectRefraction.h"
#import "CCNode+NodeInfo.h"
#import "CCBWriterInternal.h"
#import "CCBReaderInternal.h"

@interface CCBWriterInternal(Private)
+ (id) serializeSpriteFrame:(NSString*)spriteFile sheet:(NSString*)spriteSheetFile;
@end

@implementation CCBPEffectRefraction

+(CCEffect<CCEffectProtocol>*)defaultConstruct
{
	return [[self alloc] init];
}

-(id)serialize
{
	return @{@"refraction" : @(self.refraction),
			 @"environment" : @(self.environment.UUID),
			 @"normalMap" : [CCBWriterInternal serializeSpriteFrame:nil sheet:nil]};
}

-(void)deserialize:(NSDictionary*)dict
{
	self.refraction = [dict[@"refraction"] floatValue];
	self.environment = nil;//[dict[@"intensity"] integerValue];
	
	//self.normalMap = [CCBReaderInternal  //de[dict[@"normalMap"] ];
	
}


-(EffectDescription*)effectDescription
{
	return [EffectsManager effectByClassName: NSStringFromClass([self class])];
}

@end
