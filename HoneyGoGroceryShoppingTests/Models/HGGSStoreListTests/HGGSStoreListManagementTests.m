//
//  HGGS.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 2/19/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import "HGGSStoreListManagementTests.h"
#import "HGGSGroceryStoreManager.h"
#import "HGGSGroceryStore.h"
#import "HGGSGroceryItem.h"

@implementation HGGSStoreListManagementTests
{
    NSString *_testStoreName;
    HGGSStoreItems *_masterList;
}
-(void)setUp
{
    [super setUp];
    _testStoreName = @"ManageStoreListTest";
    
    HGGSGroceryStore* localStore = [[HGGSGroceryStoreManager sharedStoreManager] addStore:_testStoreName];
    _masterList = [localStore getMasterList];
    [_masterList addItem:[[HGGSGroceryItem alloc] initWithDetails:@"everroast chicken" quantity:2 unit:@"lbs" section:@"Deli" notes:@"in 2 units" select:YES lastPurchasedOn:[NSDate date]]];
    [_masterList addItem:[[HGGSGroceryItem alloc] initWithDetails:@"chicken nuggets" quantity:1 unit:@"bag" section:@"frozen meats" notes:@"Tyson Honey Battered Chicken Breast Tender 25.5 Ounce" select:NO lastPurchasedOn:[NSDate date]]];
}

-(void)testAddGroceryItemToMasterList
{
    HGGSGroceryItem *itemWithUniqueName = [[HGGSGroceryItem alloc] initWithDetails:@"some unique name" quantity:1 unit:@"misc unit" section:@"misc scetion" notes:@"misc notes" select:NO lastPurchasedOn:[NSDate date]];
    NSInteger index = [_masterList addItem:itemWithUniqueName];
    
    
    XCTAssert(3 == [_masterList itemCount], @"item count did not increase after adding item with unique name");
    XCTAssertEqualObjects(itemWithUniqueName, [_masterList itemAt:index], @"item added not found at index returned by addItem");
    
}

-(void)testInsertGroceryItemInItemListAtCorrectLocation
{
    HGGSGroceryItem *itemBeforeFirst = [[HGGSGroceryItem alloc] initWithDetails:@"AAA Chese" quantity:1 unit:@"misc unit" section:@"Deli" notes:@"misc notes" select:NO lastPurchasedOn:[NSDate date]];
    NSInteger beforeFirstIndex = [_masterList addItem:itemBeforeFirst];
    XCTAssertEqual(0, beforeFirstIndex, "@item not inserted at beginning of the list");

    HGGSGroceryItem *itemInMiddle = [[HGGSGroceryItem alloc] initWithDetails:@"some unique name" quantity:1 unit:@"misc unit" section:@"E Section" notes:@"misc notes" select:NO lastPurchasedOn:[NSDate date]];
    NSInteger middleIndex = [_masterList addItem:itemInMiddle];
    XCTAssertEqual(2, middleIndex, "@item not inserted in the middle of the list");
    
    HGGSGroceryItem *itemAfterLast = [[HGGSGroceryItem alloc] initWithDetails:@"some other unique name" quantity:1 unit:@"misc unit" section:@"G section" notes:@"misc notes" select:NO lastPurchasedOn:[NSDate date]];
    NSInteger lastIndex = [_masterList addItem:itemAfterLast];
    XCTAssertEqual (4, lastIndex, "@item not inserted at the end of the list");
    
    XCTAssert(5 == [_masterList itemCount], @"item count did not increase after adding item with unique name");
    XCTAssertEqualObjects(itemBeforeFirst, [_masterList itemAt:beforeFirstIndex], @"item added not found at index returned by addItem");
    XCTAssertEqualObjects(itemInMiddle, [_masterList itemAt:middleIndex], @"item added not found at index returned by addItem");
    XCTAssertEqualObjects(itemAfterLast, [_masterList itemAt:lastIndex], @"item added not found at index returned by addItem");
    
}


-(void)testCannotAddGroceryItemWithSameName
{
    HGGSGroceryItem *itemWithDuplicateeName = [[HGGSGroceryItem alloc] initWithDetails:@"chicken nuggets" quantity:1 unit:@"misc unit" section:@"misc scetion" notes:@"misc notes" select:NO lastPurchasedOn:[NSDate date]];
    NSInteger index = [_masterList addItem:itemWithDuplicateeName];
    
    
    XCTAssert(2 == [_masterList itemCount], @"item count increased after adding item with duplicate name");
    XCTAssertEqual(-1, index, @"added duplicate item");

}


@end
