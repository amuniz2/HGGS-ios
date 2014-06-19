//
//  HGGSGroceryStoreManagerTests.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/7/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSGroceryStoreManagerTests.h"
#import "HGGSGroceryStoreManager.h"
#import "HGGSGroceryStore.h"

@interface HGGSGroceryStoreManagerTests()

    @property (nonatomic) HGGSGroceryStoreManager * storeManager;

@end

@implementation HGGSGroceryStoreManagerTests
- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    
    
    [self setStoreManager:[HGGSGroceryStoreManager sharedStoreManager]];
    
}

- (void)tearDown
{
    
}

-(void) testCreateStore
{
    NSString *storeName = @"New Store";
    HGGSGroceryStore* newStore = [_storeManager addStore:storeName];
    NSDictionary *allStores ;
    
    XCTAssertNotNil(newStore);
    
    allStores = [_storeManager allStores];
    
    XCTAssertNotNil([allStores objectForKey:storeName]);
    
    [_storeManager deleteStore:storeName];
    
}

@end
