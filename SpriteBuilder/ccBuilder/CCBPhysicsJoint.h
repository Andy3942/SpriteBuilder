//
//  CCBPhysicsJoint.h
//  SpriteBuilder
//
//  Created by John Twigg on 2/19/14.
//
//

#import "cocos2d.h"

static const int kNumProperties = 6;
extern NSString *  dependantProperties[kNumProperties];

typedef enum
{
    BodyIndexA,
    BodyIndexB,
    
    BodyIndexUnknown = -1,
}BodyIndex;

@class SceneGraph;
@interface CCBPhysicsJoint : CCNode <NSPasteboardWriting>
{
    CCNode * scaleFreeNode;
    
    CCSprite * bodyAOutlet;
    CCSprite * bodyBOutlet;
 
    NSUInteger bodyA_UUID;
    CCNode    *bodyA;
    
    NSUInteger bodyB_UUID;
    CCNode    *bodyB;
    
    SceneGraph * sceneGraph;
}

@property CCNode * bodyA;
@property CCNode * bodyB;

@property BOOL isSelected;//Is clears on Visit


-(int)hitTestOutlet:(CGPoint)point;
-(void)setOutletStatus:(BodyIndex)idx value:(BOOL)value;
-(void)refreshOutletStatus;
-(CGPoint)outletWorldPos:(BodyIndex)idx;


-(void)fixupReferences;

-(void)removeObserverBody:(CCNode*)body;
-(void)addObserverBody:(CCNode*)body;

@end
