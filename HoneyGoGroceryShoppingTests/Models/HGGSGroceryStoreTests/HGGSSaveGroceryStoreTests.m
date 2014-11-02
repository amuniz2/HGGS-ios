//
//  HGGSGroceryStoreTests.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/4/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import "HGGSSaveGroceryStoreTests.h"
#import "HGGSGroceryStore.h"
#import "HGGSGroceryStoreManager.h"

@implementation HGGSSaveGroceryStoreTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    _testStoreName = @"SaveGroceryStoreTest";
    
    _store = [[HGGSGroceryStoreManager sharedStoreManager] addStore:_testStoreName];
    HGGSGroceryItem * groceryItem = [[HGGSGroceryItem alloc] initWithDetails:@"everroast chicken" quantity:2 unit:@"lbs" section:@"Deli" notes:@"in 2 units"
                                     select:YES lastPurchasedOn:[NSDate date]] ;

    
    groceryItem = [[HGGSGroceryItem alloc] initWithDetails:@"chicken nuggets" quantity:1 unit:@"bag" section:@"frozen meats" notes:@"Tyson Honey Battered Chicken Breast Tender 25.5 Ounce" select:NO lastPurchasedOn:[NSDate date]];
}

- (void)tearDown
{
    // Tear-down code here.
    [[HGGSGroceryStoreManager sharedStoreManager] deleteStore:@"Test Store"];
    [super tearDown];
    
}

-(void) testSavingGroceryStoreMasterList
{
    [[_store getMasterList] save];
   
    NSString *fileName = [[_store localFolder] stringByAppendingPathComponent:[HGGSGroceryStore getFileNameComponent:MASTER_LIST]];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:fileName]);
    
}

-(void) testSavingGroceryStoreAisleConfiguration
{
    [[_store getGroceryAisles] save];
    
    NSString *fileName = [[_store localFolder] stringByAppendingPathComponent:[HGGSGroceryStore getFileNameComponent:AISLE_CONFIG]];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:fileName]);
    
}

-(void) testSavingStoreInfo
{
    [_store saveStoreInfo];
    
    NSString *fileName = [[_store localFolder] stringByAppendingPathComponent:[HGGSGroceryStore getFileNameComponent:STORE]];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:fileName]);
    
}

@end
