//
//  HGGSGrocerySection.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/30/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol HGGSGrocerySectionDelegate <NSObject>

-(void)didChangeAisle:(id)section fromAisleNumber:(NSInteger)fromAisleNumber toAisleNumber:(NSInteger)toAisleNumber;

@end

@interface HGGSGrocerySection : NSObject <NSCopying>
{}
@property (retain) id <HGGSGrocerySectionDelegate> delegate;

@property (nonatomic) NSInteger aisle;
@property (nonatomic) NSInteger order;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *sectionId;
@property (nonatomic, strong) NSMutableArray* groceryItems;

-(id)initFromDictionary:(NSDictionary *)itemAttributes;
@property(nonatomic,strong)NSDictionary *asDictionary;

-(id)initWithDetails:(NSString*)name aisle:(NSInteger)aisle order:(NSInteger)order  groceryItemsInSection:(NSMutableArray*)groceryItems;

-(id)initWithOldDetails:(NSString*)name aisle:(int)aisle order:(int)order sectionId:(NSString*)sectionId  groceryItemsInSection:(NSMutableArray*)groceryItems;

@end
