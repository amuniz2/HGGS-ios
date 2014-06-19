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


+(id) createList:(NSString*)localFolder store:(id)store fileName:(NSString *)fileName list:(NSMutableArray*)list;

-(NSMutableArray*)copyOfList;
-(bool) itemExists:(NSString *)key;
-(HGGSGroceryItem*) item:(NSString *)key;
-(void)remove:(NSString *)key;

@end
