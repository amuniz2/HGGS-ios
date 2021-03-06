//
//  HGGSStoreList.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGGSStoreList.h"

@class HGGSGroceryItem;

@interface HGGSStoreItems : HGGSStoreList
{
}


+(id) createList:(NSString *)fileName store:(id)store list:(NSMutableArray*)list;

-(NSMutableArray*)copyOfList;
-(bool) itemExists:(NSString *)key;
//-(HGGSGroceryItem*) itemWithkey:(NSString *)key;
-(void)remove:(NSString *)key;
-(void)load;
@end
