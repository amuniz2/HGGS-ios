//
//  HGGSStoreList.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSStoreList.h"

@implementation HGGSStoreList
+(HGGSStoreList*) create:(NSString *)fileName list:(NSMutableArray*)list
{
    HGGSStoreList* storeList = [[HGGSStoreList alloc] init];
    if (storeList)
    {
        [storeList setFileName:fileName];
        [storeList setList:list];
    }
    return storeList;
}

@end
