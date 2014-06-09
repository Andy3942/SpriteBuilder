//
//  CCAnimation_Tests.m
//  SpriteBuilder
//
//  Created by John Twigg on 6/9/14.
//
//

#import <XCTest/XCTest.h>
#import "cocos2d.h"
#import "CCBXCocos2diPhone.h"
#import "PlugInManager.h"
#import "PlugInExport.h"
#import "CCBReader.h"
#import "CCAnimationManager.h"
#import "CCAnimationManager_Private.h"
#import "CCBSequence.h"

@implementation CCAnimationManager (Test)

-(CCBSequence*)runningSequence
{
	return _runningSequence;
}

@end

@interface CCAnimationDelegateTester : NSObject<CCBAnimationManagerDelegate>


@end

@implementation CCAnimationDelegateTester

- (void) completedAnimationSequenceNamed:(NSString*)name
{
	
}

@end

@interface CCAnimation_Tests : XCTestCase

@end

@implementation CCAnimation_Tests

-(NSData*)writeCCB:(NSString*)srcFileName
{
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSString *path = [bundle pathForResource:srcFileName ofType:@"ccb"];
	NSDictionary *  doc  = [NSDictionary dictionaryWithContentsOfFile:path];
	
	PlugInExport *plugIn = [[PlugInManager sharedManager] plugInExportForExtension:@"ccbi"];
	NSData *data = [plugIn exportDocument:doc];
	return data;
}

- (void)setUp
{
    [super setUp];
	

	
	
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}



- (void)testAnimationSync1
{
	NSData * animData = [self writeCCB:@"AnimationTest1"];

	CCBReader * reader = [CCBReader reader];
	CCNode * rootNode = [reader loadWithData:animData owner:self];
	
	CCNode * node0 = rootNode.children[0];
	CCNode * node1 = rootNode.children[1];
	CCNode * node2 = rootNode.children[2];
	
	
	XCTAssertTrue([node0.name isEqualToString:@"node0"]);
	XCTAssertTrue([node1.name isEqualToString:@"node1"]);
	XCTAssertTrue([node2.name isEqualToString:@"node2"]);
	 
	
	const float kDelta = 0.1f;//100ms;
	const CGFloat kAccuracy = 0.01f;
	const CGFloat kTranslation = 500.0f;
	
	
	float totalElapsed = 0.0f;
	__block float currentAnimElapsed = 0.0f;
	
	CCBSequence * seq = rootNode.animationManager.sequences[0];
	
	[rootNode.animationManager setCompletedAnimationCallbackBlock:^(id sender) {
		XCTAssertTrue(fabsf(currentAnimElapsed - seq.duration) < kAccuracy, @"The animation should have taken 4 seconds. Possible divergenc.");
		
		currentAnimElapsed = 0.0f;
	}];
	
	while(totalElapsed <= seq.duration * 20)
	{
		[rootNode.animationManager update:kDelta];
		
		totalElapsed += kDelta;
		currentAnimElapsed += kDelta;

		float timeIntoSeq = rootNode.animationManager.runningSequence.time;

		//This animation specifcally see's all three nodes translate after three seconds back to the root pos.
		if(timeIntoSeq >= 3.0f)
		{
			//All final translations go from x=500 -> x=0 over 1 second.
			float perentageIntroSyncedTranlation = 1.0f - (seq.duration - timeIntoSeq);
			float desiredXCoord = (1.0f - perentageIntroSyncedTranlation) * kTranslation;
			
			
			XCTAssertTrue(fabsf(node0.position.x - node1.position.x) < kAccuracy, @"They should all equal each other");
			
			XCTAssertTrue(fabsf(node0.position.x - node2.position.x) < kAccuracy, @"They should all equal each other");
			
			XCTAssertTrue(fabsf(node0.position.x - desiredXCoord) < kAccuracy, @"They should all equal each desiredXCoord. Possible divergenc. XPos:%0.2f DesiredPos:%0.2f totalElapsed:%0.2f", node0.position.x,desiredXCoord, totalElapsed);
			
		}
		
	}
}

@end
