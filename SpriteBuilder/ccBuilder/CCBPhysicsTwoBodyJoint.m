//
//  CCBPhysicsTwoBodyJoint.m
//  SpriteBuilder
//
//  Created by John Twigg on 3/6/14.
//
//

#import "CCBPhysicsTwoBodyJoint.h"
#import "GeometryUtil.h"
#import "AppDelegate.h"

const float kMargin = 8.0f/64.0f;
const float kEdgeRadius = 8.0f;

static const float kDefaultLength = 58.0f;


@interface CCBPhysicsTwoBodyJoint()
{
    CCSprite        * anchorHandleA;
    CCSprite        * anchorHandleB;
}
@end

@implementation CCBPhysicsTwoBodyJoint
@synthesize anchorB;


-(void)setupBody
{
     
    anchorHandleA = [CCSprite spriteWithImageNamed:@"joint-anchor.png"];
    anchorHandleB = [CCSprite spriteWithImageNamed:@"joint-anchor.png"];
    
    [scaleFreeNode addChild:anchorHandleA];
    [scaleFreeNode addChild:anchorHandleB];
    
}


-(float)worldLength
{
    if(self.bodyA && self.bodyB)
    {
        CGPoint worldPosA = [self.bodyA convertToWorldSpace:self.anchorA];
        CGPoint worldPosB = [self.bodyB convertToWorldSpace:self.anchorB];
        
        float distance = ccpDistance(worldPosA, worldPosB);
        return distance;
    }
    
    return kDefaultLength;
}

-(float)localLength
{
    
    if(self.bodyA && self.bodyB)
    {
        CGPoint worldPosA = [self.bodyA convertToWorldSpace:self.anchorA];
        CGPoint worldPosB = [self.bodyB convertToWorldSpace:self.anchorB];
        
        CGPoint localPosA = [self convertToNodeSpace:worldPosA];
        CGPoint localPosB = [self convertToNodeSpace:worldPosB];
        
        float distance = ccpDistance(localPosA, localPosB);
        return distance;
    }
    
    return kDefaultLength;
}

-(void)updateRenderBody
{
    
    float length = [self worldLength];
    
    //Anchor B
    anchorHandleB.position = ccpMult(ccp(length,0),1/[CCDirector sharedDirector].contentScaleFactor);
    
    
}


-(float)rotation
{
    if(self.bodyA && self.bodyB)
    {
        CGPoint worldPosA = [self.bodyA convertToWorldSpace:self.anchorA];
        CGPoint worldPosB = [self.bodyB convertToWorldSpace:self.anchorB];
        
        CGPoint segment = ccpSub(worldPosB,worldPosA);
        float angleRad = atan2f(segment.y, segment.x);
        float angle = -kmRadiansToDegrees( angleRad);
        return  angle;
    }
    
    return 0.0f;
}



-(JointHandleType)hitTestJointHandle:(CGPoint)worlPos
{
    {
        CGPoint pointA = [anchorHandleA convertToNodeSpaceAR:worlPos];
        pointA = ccpAdd(pointA, ccp(0,5.0f));
        if(ccpLength(pointA) < 8.0f)
        {
            return BodyAnchorA;
        }
    }
    
    {
        CGPoint pointB = [anchorHandleB convertToNodeSpaceAR:worlPos];
        pointB = ccpAdd(pointB, ccp(0,5.0f));
        if(ccpLength(pointB) < 8.0f)
        {
            return BodyAnchorB;
        }
    }
    
    
    return [super hitTestJointHandle:worlPos];;
}


- (BOOL)hitTestWithWorldPos:(CGPoint)pos
{
    CGPoint anchorAWorldpos = [anchorHandleA convertToWorldSpace:CGPointZero];
    CGPoint anchorBWorldpos = [anchorHandleB convertToWorldSpace:CGPointZero];
    
    
    float distance = [GeometryUtil distanceFromLineSegment:anchorAWorldpos b:anchorBWorldpos c:pos];
    
    if(distance < 7.0f)
    {
        return YES;
    }
    
    return NO;
    
}


-(void)setAnchorFromBodyB
{
    if(!self.bodyB)
    {
        self.anchorB = CGPointZero;
        [[AppDelegate appDelegate] refreshProperty:@"anchorB"];
        return;
    }
    
    CGPoint anchorBPositionNodePos = ccpAdd(self.position, ccp(kDefaultLength,0));
    
    CGPoint worldPos = [self.parent convertToWorldSpace:anchorBPositionNodePos];
    CGPoint lAnchorb = [self.bodyB convertToNodeSpace:worldPos];
    
    self.anchorB = lAnchorb;
    [[AppDelegate appDelegate] refreshProperty:@"anchorB"];
}



-(void)setBodyB:(CCNode *)aBodyB
{
    [super setBodyB:aBodyB];
    [self setAnchorFromBodyB];
}


-(void)setAnchorB:(CGPoint)lAnchorB
{
    anchorB = lAnchorB;
}



-(void)setBodyHandle:(CGPoint)worldPos bodyType:(JointHandleType)bodyType
{
    if(bodyType == BodyAnchorB)
    {
        CGPoint newPosition = [self.bodyB convertToNodeSpace:worldPos];
        self.anchorB = newPosition;
        [[AppDelegate appDelegate] refreshProperty:@"anchorB"];
        
    }
    
    [super setBodyHandle:worldPos bodyType:bodyType];
}



@end
