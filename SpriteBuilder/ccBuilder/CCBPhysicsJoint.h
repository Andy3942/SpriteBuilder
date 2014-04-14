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
    BodyAnchorA,
    BodyAnchorB,
    
    BodyOutletA,
    BodyOutletB,
    
    //-------
    MinHandleType,
    MaxHandleType,
    
    //------------
    RestLengthHandle,
    
    EntireJoint, //The entire joint has been touched at some point.
    
    JointHandleUnknown = -1,
}JointHandleType;



@class SceneGraph;
@interface CCBPhysicsJoint : CCNode <NSPasteboardWriting>
{
    UInt32 selectedBodyHandle;//bitfield
    
    CCNode * scaleFreeNode;
 
	CCNode   * bodyOutletRoot;
    CCSprite * bodyAOutlet;
    CCSprite * bodyBOutlet;
 
    NSUInteger bodyA_UUID;
    CCNode    *bodyA;
    
    NSUInteger bodyB_UUID;
    CCNode    *bodyB;
    
    SceneGraph * sceneGraph;
    
    NSMutableDictionary * spriteFrameCache;
}

@property CCNode * bodyA;
@property CCNode * bodyB;
@property(nonatomic) BOOL maxForceEnabled;
@property(nonatomic) CGFloat maxForce;
@property(nonatomic) BOOL collideBodies;
@property(nonatomic) BOOL breakingForceEnabled;
@property(nonatomic) CGFloat breakingForce;


-(JointHandleType)hitTestJointHandle:(CGPoint)worlPos; //Which part of the joint did you hit? AnchorA/B Handle Min/Max?
-(void)setJointHandleSelected:(JointHandleType)handleType; //Tell the renderer that a particular component is selected. Clears every frame.
-(void)removeJointHandleSelected:(JointHandleType)handleType;
-(void)clearJointHandleSelected;

-(void)refreshOutletStatus;
-(CGPoint)outletWorldPos:(JointHandleType)idx;
-(void)setBodyHandle:(CGPoint)worldPos bodyType:(JointHandleType)bodyType;
-(CCSpriteFrame*)frameWithImageNamed:(NSString*)name;

-(void)fixupReferences;

-(void)removeObserverBody:(CCNode*)body;
-(void)addObserverBody:(CCNode*)body;

+(NSString *)convertBodyTypeToString:(JointHandleType) index;


@end
