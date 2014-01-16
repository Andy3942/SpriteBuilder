/*
 * SpriteBuilder: http://www.spritebuilder.org
 *
 * Copyright (c) 2014 Apportable Inc.
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

// TODO: enclose in #ifdef COMPILING_FOR_SPRITEKIT

#define CCB_SPRITEKIT_READER

#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
#define __CC_PLATFORM_IOS 1
#elif defined(__MAC_OS_X_VERSION_MAX_ALLOWED)
#define __CC_PLATFORM_MAC 1
#endif

#import <SpriteKit/SpriteKit.h>

#import "CCFileUtils.h"
#import "CCSpriteFrameCache.h"
#import "CGPointExtension.h"

#import "CCBSpriteKitDummy.h"

typedef NS_ENUM(unsigned char, CCPositionUnit)
{
    CCPositionUnitPoints,
    CCPositionUnitUIPoints,
    CCPositionUnitNormalized,
};

typedef NS_ENUM(unsigned char, CCSizeUnit)
{
    CCSizeUnitPoints,
    CCSizeUnitUIPoints,
    CCSizeUnitNormalized,
    CCSizeUnitInsetPoints,
    CCSizeUnitInsetUIPoints,
};

typedef NS_ENUM(unsigned char, CCPositionReferenceCorner)
{
    CCPositionReferenceCornerBottomLeft,
    CCPositionReferenceCornerTopLeft,
    CCPositionReferenceCornerTopRight,
    CCPositionReferenceCornerBottomRight,
};

typedef struct _CCPositionType
{
    CCPositionUnit xUnit;
    CCPositionUnit yUnit;
    CCPositionReferenceCorner corner;
} CCPositionType;

typedef struct _CCSizeType
{
    CCSizeUnit widthUnit;
    CCSizeUnit heightUnit;
} CCSizeType;

static inline CCPositionType CCPositionTypeMake(CCPositionUnit xUnit, CCPositionUnit yUnit, CCPositionReferenceCorner corner)
{
    CCPositionType pt;
    pt.xUnit = xUnit;
    pt.yUnit = yUnit;
    pt.corner = corner;
    return pt;
}

static inline CCSizeType CCSizeTypeMake(CCSizeUnit widthUnit, CCSizeUnit heightUnit)
{
    CCSizeType cst;
    cst.widthUnit = widthUnit;
    cst.heightUnit = heightUnit;
    return cst;
}

typedef struct _ccBlendFunc
{
	unsigned int src;
	unsigned int dst;
} ccBlendFunc;

typedef NS_ENUM(unsigned char, CCPhysicsBodyType)
{
	CCPhysicsBodyTypeDynamic,
	CCPhysicsBodyTypeStatic,
};

#import "SKNode+CCBReader.h"
#import "SKPhysicsBody+CCBReader.h"
#import "SKTexture+CCBReader.h"

typedef double CCTime;
typedef SKColor CCColor;
typedef SKNode CCNode;
typedef SKPhysicsBody CCPhysicsBody;
typedef SKScene CCScene;
typedef SKSpriteNode CCSprite;
typedef SKTexture CCSpriteFrame;
typedef SKTexture CCTexture;

// just forward all unsupported features to a dummy class to make the compiler happy
@class CCBSpriteKitDummy;
typedef CCBSpriteKitDummy CCActionManager;
typedef CCBSpriteKitDummy CCDirector;
typedef CCBSpriteKitDummy OALSimpleAudio;

@class CCBSpriteKitDummyAction;
typedef CCBSpriteKitDummyAction CCAction;
typedef CCBSpriteKitDummyAction CCActionCallFunc;
typedef CCBSpriteKitDummyAction CCActionDelay;
typedef CCBSpriteKitDummyAction CCActionEase;
typedef CCBSpriteKitDummyAction CCActionEaseBackIn;
typedef CCBSpriteKitDummyAction CCActionEaseBackInOut;
typedef CCBSpriteKitDummyAction CCActionEaseBackOut;
typedef CCBSpriteKitDummyAction CCActionEaseBounceIn;
typedef CCBSpriteKitDummyAction CCActionEaseBounceInOut;
typedef CCBSpriteKitDummyAction CCActionEaseBounceOut;
typedef CCBSpriteKitDummyAction CCActionEaseElasticIn;
typedef CCBSpriteKitDummyAction CCActionEaseElasticInOut;
typedef CCBSpriteKitDummyAction CCActionEaseElasticOut;
typedef CCBSpriteKitDummyAction CCActionEaseIn;
typedef CCBSpriteKitDummyAction CCActionEaseInOut;
//typedef CCBSpriteKitDummy CCActionEaseInstant;
typedef CCBSpriteKitDummyAction CCActionEaseOut;
typedef CCBSpriteKitDummyAction CCActionFadeTo;
typedef CCBSpriteKitDummyAction CCActionHide;
typedef CCBSpriteKitDummyAction CCActionInstant;
typedef CCBSpriteKitDummyAction CCActionInterval;
typedef CCBSpriteKitDummyAction CCActionMoveTo;
typedef CCBSpriteKitDummyAction CCActionScaleTo;
typedef CCBSpriteKitDummyAction CCActionSequence;
typedef CCBSpriteKitDummyAction CCActionShow;
typedef CCBSpriteKitDummyAction CCActionSkewTo;
typedef CCBSpriteKitDummyAction CCActionTintTo;

static inline Class CCBClassFromString(NSString* className)
{
	Class theClass = NSClassFromString(className);
	
	if (theClass == nil)
	{
		// TODO: CCButton, CCTextField, CCSlider, CCScrollView, CCLayoutBox, CCPhysicsNode
		if ([className isEqualToString:@"CCNode"])
		{
			theClass = [SKNode class];
		}
		else if ([className isEqualToString:@"CCSprite"] || [className isEqualToString:@"CCNodeColor"] || [className isEqualToString:@"CCNodeGradient"])
		{
			theClass = [SKSpriteNode class];
		}
		else if ([className isEqualToString:@"CCLabelTTF"])
		{
			theClass = [SKLabelNode class];
		}
		else if ([className isEqualToString:@"CCParticleSystem"])
		{
			theClass = [SKEmitterNode class];
		}
		else
		{
			theClass = [SKNode class];
		}
		NSLog(@"CCBClassFromString('%@') = %@", className, NSStringFromClass(theClass));
	}
	
	return theClass;
}
