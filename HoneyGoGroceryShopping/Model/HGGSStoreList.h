//
//  HGGSStoreList.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGSStoreList : NSObject
{
}
@property (nonatomic, copy) NSString* fileName;
@property (nonatomic, strong) NSMutableArray* list;

+(id) create:(NSString *)fileName list:(NSMutableArray*)list;

@end
