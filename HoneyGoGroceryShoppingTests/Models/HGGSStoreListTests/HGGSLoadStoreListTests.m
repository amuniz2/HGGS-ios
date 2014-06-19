//
//  HGGSGroceryStoreTests.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/4/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import "HGGSLoadStoreListTests.h"
#import "HGGSGroceryStore.h"
#import "HGGSGroceryItem.h"
#import "HGGSGroceryStoreManager.h"

@interface HGGSLoadStoreListTests()

    @property (nonatomic) HGGSGroceryItem * groceryItem1;
    @property (nonatomic) HGGSGroceryItem * groceryItem2;
    @property (nonatomic) HGGSGroceryItem * groceryItem3;
    @property (nonatomic) HGGSGroceryItem * groceryItem4;

@end
@implementation HGGSLoadStoreListTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
   
    
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
    
}

-(void) testLoadingGroceryStoreMasterList
{
    _testStoreName = @"LoadStoreListTest";
    
    HGGSGroceryStore* localStore = [[HGGSGroceryStoreManager sharedStoreManager] addStore:_testStoreName];
    HGGSStoreList *masterList = [localStore getMasterList];
    self.groceryItem1 = [[HGGSGroceryItem alloc] initWithDetails:@"everroast chicken" quantity:2 unit:@"lbs" section:@"Deli" notes:@"in 2 units" select:YES lastPurchasedOn:[NSDate date]];
    self.groceryItem2  = [[HGGSGroceryItem alloc] initWithDetails:@"chicken nuggets" quantity:1 unit:@"bag" section:@"frozen meats" notes:@"Tyson Honey Battered Chicken Breast Tender 25.5 Ounce" select:NO lastPurchasedOn:[NSDate date]];
    [masterList addItem:_groceryItem1];
    [masterList addItem:_groceryItem2];
    [masterList save];

    HGGSGroceryStore *store = [[HGGSGroceryStore alloc] initWithStoreName:_testStoreName];
    NSArray * itemsLoaded = [[store  getMasterList] list];
    
    XCTAssertEqualObjects([store name],_testStoreName);
    XCTAssertEqual([itemsLoaded count], (NSUInteger)2);
    XCTAssertEqualObjects(self.groceryItem1, [itemsLoaded objectAtIndex:0]);
    XCTAssertEqualObjects(self.groceryItem2, [itemsLoaded objectAtIndex:1]);
    
    [[HGGSGroceryStoreManager sharedStoreManager] deleteStore:_testStoreName];
    
}

-(void) testLoadingGroceryStoreItems_InOrder
{
    _testStoreName = @"LoadStoreListTest";
    
    HGGSGroceryStore* localStore = [[HGGSGroceryStoreManager sharedStoreManager] addStore:_testStoreName];
    HGGSStoreList *masterList = [localStore getMasterList];
    self.groceryItem1 = [[HGGSGroceryItem alloc] initWithDetails:@"everroast chicken" quantity:2 unit:@"lbs" section:@"Deli" notes:@"in 2 units" select:YES lastPurchasedOn:[NSDate date]];
    self.groceryItem2  = [[HGGSGroceryItem alloc] initWithDetails:@"chicken nuggets" quantity:1 unit:@"bag" section:@"frozen meats" notes:@"Tyson Honey Battered Chicken Breast Tender 25.5 Ounce" select:NO lastPurchasedOn:[NSDate date]];
    self.groceryItem3 = [[HGGSGroceryItem alloc] initWithDetails:@"buffalo chicken" quantity:2 unit:@"lbs" section:@"Deli" notes:@"in 2 units" select:YES lastPurchasedOn:[NSDate date]];
    self.groceryItem4  = [[HGGSGroceryItem alloc] initWithDetails:@"meatballs" quantity:1 unit:@"bag" section:@"frozen meats" notes:@"Tyson Honey Battered Chicken Breast Tender 25.5 Ounce" select:NO lastPurchasedOn:[NSDate date]];
    [masterList addItem:_groceryItem1];
    [masterList addItem:_groceryItem2];
    [masterList addItem:_groceryItem3];
    [masterList addItem:_groceryItem4];
    [masterList save];
    
    HGGSGroceryStore *store = [[HGGSGroceryStore alloc] initWithStoreName:_testStoreName];
    NSArray * itemsLoaded = [[store  getMasterList] list];
    
    XCTAssertEqualObjects([store name],_testStoreName);
    XCTAssertEqual([itemsLoaded count], (NSUInteger)4);
    XCTAssertEqualObjects(self.groceryItem3, [itemsLoaded objectAtIndex:0]);
    XCTAssertEqualObjects(self.groceryItem1, [itemsLoaded objectAtIndex:1]);
    XCTAssertEqualObjects(self.groceryItem2, [itemsLoaded objectAtIndex:2]);
    XCTAssertEqualObjects(self.groceryItem4, [itemsLoaded objectAtIndex:3]);
    
    [[HGGSGroceryStoreManager sharedStoreManager] deleteStore:_testStoreName];
    
}

-(void) testLoadingGroceryStoreMasterList_fromAndroidApp
{
    _testStoreName = @"LoadAndroidGroceryStoreMasterListTest";
    
    _testStoreName = @"LoadAndroidGroceryStoreMasterListTest";
    
    NSString* fileContents =@"[{\"id\":\"b162db18-7ac2-43cd-979e-d02c1cd39348\",\"unit\":\"\",\"category\":\"a6eeabae-491d-4680-ab50-696f7e30769c\",\"selected\":true,\"lastPurchasedDate\":\"Sun Jul 14 12:48:15 EDT 2013\",\"name\":\"swifter pads\",\"quantity\":1,\"notes\":\"\"},{\"id\":\"61668427-63c5-4a97-a709-ed0afccf8057\",\"unit\":\"\",\"category\":\"a6eeabae-491d-4680-ab50-696f7e30769c\",\"selected\":true,\"lastPurchasedDate\":\"Sun Jul 14 12:48:15 EDT 2013\",\"name\":\"water\",\"quantity\":1,\"notes\":\"\"}]";
    HGGSGroceryStore* localStore = [[HGGSGroceryStoreManager sharedStoreManager] addStore:_testStoreName];
    
    NSString* fileName = [[localStore getLocalFolder] stringByAppendingPathComponent:[HGGSGroceryStore getFileNameComponent:MASTER_LIST]];
    XCTAssertTrue( [fileContents writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:nil]);
    
    NSArray * itemsLoaded = [[localStore  getMasterList] list];
    
    XCTAssertEqualObjects([localStore name],_testStoreName);
    XCTAssertEqual([itemsLoaded count], (NSUInteger)2);
    
    [[HGGSGroceryStoreManager sharedStoreManager] deleteStore:_testStoreName];
    
}

/*- (void)testLoadingGroceryStoreMasterList
{
    
    HGGSGroceryStore *store = [HGGSGroceryStore createStore:@"Test Store"];
    
    //NSMutableArray* items = [store loadGroceryItemsFromString:_groceryItemsAsString];
    NSMutableArray* items = [store groceryItemsInMasterList];
    
    XCTAssertEquals([items count], 2, nil);
}
*/

@end
