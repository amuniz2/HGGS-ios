//
//  HGGSGrocerySection.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/30/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGSGrocerySection : NSObject
{}
@property int aisle;
@property int order;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sectionId;

-(id)initFromDictionary:(NSDictionary *)itemAttributes;
@property(nonatomic,strong)NSDictionary *asDictionary;

-(id)initWithDetails:(NSString*)name aisle:(int)aisle order:(int)order;

-(id)initWithOldDetails:(NSString*)name aisle:(int)aisle order:(int)order sectionId:(NSString*)sectionId;

@end
