//
//  CCBPPhysicsPivotJoint.m
//  SpriteBuilder
//
//  Created by John Twigg
//
//

#import "CCBPhysicsPivotJoint.h"
#import "AppDelegate.h"



@interface CCBPhysicsJoint()
-(void)updateSelectionUI;
@end

@implementation CCBPhysicsPivotJoint
{
    CCSprite * joint;
    CCSprite* jointAnchor;
}

@synthesize anchorA;

- (id) init
{
    self = [super init];
    if (!self)
    {
        return NULL;
    }
    
    scaleFreeNode.scale = 1.0f;
    [self setupBody];
    
    return self;
}

-(void)setupBody
{
    
    joint = [CCSprite spriteWithImageNamed:@"joint-pivot.png"];
    jointAnchor = [CCSprite spriteWithImageNamed:@"joint-anchor.png"];
    
    [scaleFreeNode addChild:joint];
    [scaleFreeNode addChild:jointAnchor];
   // self.contentSize = joint.contentSize;
   // self.anchorPoint = ccp(0.5f,0.5f);
    
}


-(void)updateSelectionUI
{
    //If selected, display selected sprites.
    if(selectedBodyHandle & (1 << EntireJoint))
    {
        joint.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"joint-pivot-sel.png"];
        jointAnchor.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"joint-anchor-sel.png"];
    }
    else
    {
        joint.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"joint-pivot.png"];
        jointAnchor.spriteFrame = [CCSpriteFrame frameWithImageNamed:@"joint-anchor.png"];
    }
    
    [super updateSelectionUI];
}


- (BOOL)hitTestWithWorldPos:(CGPoint)pos
{
    pos = [scaleFreeNode convertToNodeSpace:pos];
    if(ccpLength(pos) < 17.0f)
    {
        return YES;
    }
    
    return NO;    
}

-(JointHandleType)hitTestJoint:(CGPoint)worldPos
{
    
    return JointHandleUnknown;
}


-(CGPoint)anchorA
{
    return anchorA;
}

-(void)setAnchorA:(CGPoint)aAnchorA
{
    anchorA = aAnchorA;
    [self setPositionFromAnchor];
    
}


-(void)setBodyA:(CCNode *)aBodyA
{
    [super setBodyA:aBodyA];
    
    if(!aBodyA)
    {
        self.anchorA = CGPointZero;
        [[AppDelegate appDelegate] refreshProperty:@"anchorA"];
        return;
    }
    else
    {
        [self setAnchorFromBodyA];
    }
    
}

-(void)setPositionFromAnchor
{
    CGPoint worldPos = [self.bodyA convertToWorldSpace:self.anchorA];
    CGPoint nodePos = [self.parent convertToNodeSpace:worldPos];
    _position = nodePos;
}

-(void)setAnchorFromBodyA
{
    CGPoint worldPos = [self.parent convertToWorldSpace:self.position];
    CGPoint lAnchorA = [self.bodyA convertToNodeSpace:worldPos];
    anchorA = lAnchorA;
    
    [[AppDelegate appDelegate] refreshProperty:@"anchorA"];
   
}

-(void)setPosition:(CGPoint)position
{
    [super setPosition:position];
    
    if(!self.bodyA)
    {
        return;
    }
    
    [self setAnchorFromBodyA];
}


-(void)setBodyHandle:(CGPoint)worldPos bodyType:(JointHandleType)bodyType
{
    if(bodyType == BodyAnchorA)
    {
        CGPoint newPosition = [self.parent convertToNodeSpaceAR:worldPos];
        [self setPosition:newPosition];
    }
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(object == self.bodyA)
    {
        CGPoint worldPos = [self.bodyA convertToWorldSpace:self.anchorA];
        CGPoint localPos = [self.parent convertToNodeSpace:worldPos];
        self.position = localPos;
    }
}

-(void)onExit
{
 
}

-(void)dealloc
{
    self.bodyA = nil;

}


@end
