//
//  GroceryItem.h
//  Grocery List Single View
//
//  Created by Ana Muniz on 9/19/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGSGroceryItem : NSObject <NSCopying>
{
    //NSDictionary *someInstanceVariable;
}

@property NSInteger quantity;
@property bool selected;
@property (nonatomic, copy) NSString *sectionId;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, copy)NSString *unit;
@property (nonatomic, copy)NSString *section;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, copy) NSDate *lastPurchasedDate;

-(id)initFromDictionary:(NSDictionary *)itemAttributes;
@property(nonatomic,strong)NSDictionary *asDictionary;

-(id)initWithDetails:(NSString*)name quantity:(NSInteger)amount unit:(NSString *)unitDescription section:(NSString *)grocerySection notes:(NSString*)notes select:(bool)selected lastPurchasedOn:(NSDate*)lastPurchasedDate;

-(id)initWithOldDetails:(NSString*)name quantity:(NSInteger)amount unit:(NSString *)unitDescription section:(NSString *)grocerySection notes:(NSString*)notes select:(bool)selected lastPurchasedOn:(NSDate*)lastPurchasedDate sectionId:(NSString*)sectionId;

- (NSComparisonResult) compareWithAnotherItem:(HGGSGroceryItem*) anotherItem;



@end
