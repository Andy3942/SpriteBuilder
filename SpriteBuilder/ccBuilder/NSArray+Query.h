//
//  NSArray+Query.h
//  SpriteBuilder
//
//  Created by John Twigg on 2/6/14.
//
//

#import <Foundation/Foundation.h>

typedef id (^ConvertBlock) (id obj, int idx);
typedef BOOL (^PredicateBlock) (id obj, int idx);
typedef void (^VoidBlock) (id obj, int idx);


@interface NSArray (Query)


//Converts all objects in an to a a different type.
-(NSArray*)convertAll:(ConvertBlock)aBlock;
-(id)findFirst:(PredicateBlock)aBlock;
-(void)forEach:(VoidBlock)aBlock;
@end
