//
//  HGGSGroceryStoreTests.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/4/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import "HGGSSaveStoreListTests.h"
#import "HGGSGroceryStore.h"
#import "HGGSGroceryStoreManager.h"

@implementation HGGSSaveStoreListTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    _testStoreName = @"SaveStoreListTest";
    
    store = [[HGGSGroceryStoreManager sharedStoreManager] addStore:_testStoreName];
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
    [[store getMasterList] save];
    
    NSString *fileName = [[store getLocalFolder] stringByAppendingPathComponent:[HGGSGroceryStore getFileNameComponent:MASTER_LIST]];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:fileName]);
    
}

-(void) testSavingGroceryStoreAisleConfiguration
{
    [store saveGroceryAisles];
    
    NSString *fileName = [[store getLocalFolder] stringByAppendingPathComponent:[HGGSGroceryStore getFileNameComponent:AISLE_CONFIG]];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:fileName]);
    
}

-(void) testSavingStoreInfo
{
    [store saveStoreInfo];
    
    NSString *fileName = [[store getLocalFolder] stringByAppendingPathComponent:[HGGSGroceryStore getFileNameComponent:STORE]];
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:fileName]);
    
}
/*- (void)testLoadingGroceryStoreMasterList
{
    
    HGGSGroceryStore *store = [HGGSGroceryStore createStore:@"Test Store"];
    
    //NSMutableArray* items = [store loadGroceryItemsFromString:_groceryItemsAsString];
    NSMutableArray* items = [store groceryItemsInMasterList];
    
    STAssertEquals([items count], 2, nil);
}
*/

@end
