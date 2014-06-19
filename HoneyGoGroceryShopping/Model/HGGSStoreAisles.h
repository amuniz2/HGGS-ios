//
//  HGGSStoreList.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGGSStoreList.h"

@class HGGSGroceryAisle;
@class HGGSGrocerySection;

@interface HGGSStoreAisles : HGGSStoreList
{
}


+(HGGSStoreList*) createList:(NSString*)storeFolder store:(id)store fileName:(NSString *)fileName list:(NSMutableArray*)list;

-(void)insertAisle:(HGGSGroceryAisle*)aisle atIndex:(NSInteger)index;

-(HGGSGroceryAisle *)findAisleForGrocerySection:(HGGSGrocerySection*)section;
-(HGGSGrocerySection *) findGrocerySection:(NSString*) name;
-(HGGSGrocerySection*) insertNewGrocerySection:(NSString*)name inAisle:(NSInteger)aisleNumber atSectionIndex:(NSInteger)sectionIndex;
-(HGGSGroceryAisle*)insertGrocerySection:(HGGSGrocerySection*)section  atSectionIndex:(NSInteger)sectionIndex;

@end
