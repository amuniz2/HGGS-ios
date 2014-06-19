//
//  HGGSGroceryStoreManager.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 9/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGGSGroceryStore.h"


@interface HGGSGroceryStoreManager : NSObject <HGGSGroceryStoreDelegate>
{
    NSMutableDictionary* _allStores;
    NSArray *_allkeys ;

}
@property (readonly, nonatomic, strong) NSDictionary *allStores;
+(HGGSGroceryStoreManager *)sharedStoreManager;

-(void)deleteStore:(NSString *)storeName;
-(HGGSGroceryStore *)addStore:(NSString*)storeName;
-(void)saveChanges;
-(void)saveStoreList:(HGGSGroceryStore*)store listType:(storeFileType)listType;
-(HGGSGroceryStore *)store:(NSString *)name;
@end
