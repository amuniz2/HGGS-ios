//
//  HGGSGroceryItemTests.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/4/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import "HGGSLoadGroceryItemTests.h"
#import "HGGSGroceryItem.h"
#import "HGGSDate.h"

@implementation HGGSLoadGroceryItemTests
- (void)setUp
{
    [super setUp];
    


}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testInitFromDictionary
{
    NSDate *expectedDate = [NSDate date];
    NSString* expectedDateAsString = [HGGSDate dateAsString:expectedDate];
    NSString* expectedName = @"everroast chicken";
    NSString* expectedNotes = @"some random notes";
    NSInteger expectedQuantity = 5;
    
    NSNumber* quantityAsNumber = [NSNumber numberWithInt:expectedQuantity];
    NSString* expectedSection = @"Deli";
    NSString* expectedSectionId = @"23c67a59-1c43-4c1d-8fc4-af95a8b7a947";
    NSString* expectedUnit = @"lb";
    NSString* selected = @"true";

    _groceryItemAsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"0fa4e221-5210-4c11-8a37-89962d438d59",@"id",
                                expectedUnit,@"unit",
                                expectedSectionId,@"category",
                                selected,@"selected",
                                expectedDateAsString,@"lastPurchasedDate",
                                expectedName,@"name",
                                quantityAsNumber,@"quantity",
                                expectedNotes,@"notes",
                                expectedSection,@"section",
                                nil];
    
    HGGSGroceryItem *item = [[HGGSGroceryItem alloc] initFromDictionary:_groceryItemAsDictionary];
    
    XCTAssertEqualObjects([item unit], expectedUnit);
    XCTAssertEqualObjects([item sectionId], expectedSectionId);
    XCTAssertTrue([item selected]);
    
    XCTAssertEqualObjects([HGGSDate dateAsString:[item lastPurchasedDate]], [HGGSDate dateAsString:expectedDate]);
    XCTAssertEqualObjects([item name], expectedName);
    XCTAssertEqual([item quantity], expectedQuantity);
    XCTAssertEqualObjects([item notes], expectedNotes);
    XCTAssertEqualObjects([item section], expectedSection);

}
- (void)testInitWithDetails
{
    NSDate *expectedDate = [NSDate date];
    NSString* expectedName = @"everroast chicken";
    NSString* expectedNotes = @"some random notes";
    unsigned int expectedQuantity = 5;
    
    NSString* expectedSection = @"Deli";
    NSString* expectedUnit = @"lb";
    bool selected = YES;
    
    
    HGGSGroceryItem *item = [[HGGSGroceryItem alloc] initWithDetails:expectedName quantity:expectedQuantity unit:expectedUnit section:expectedSection notes:expectedNotes select:selected lastPurchasedOn:expectedDate];
     
    XCTAssertEqualObjects([item unit], expectedUnit);
    XCTAssertEqualObjects([item sectionId], nil);
    XCTAssertTrue([item selected]);
    
    XCTAssertEqualObjects([HGGSDate dateAsString:[item lastPurchasedDate]], [HGGSDate dateAsString:expectedDate]);
    XCTAssertEqualObjects([item name], expectedName);
    XCTAssert([item quantity] == expectedQuantity);
    XCTAssertEqualObjects([item notes], expectedNotes);
    XCTAssertEqualObjects([item section], expectedSection);
    
}
- (void)testInitWithOldDetails
{
    NSDate *expectedDate = [NSDate date];
    NSString* expectedName = @"everroast chicken";
    NSString* expectedNotes = @"some random notes";
    NSInteger expectedQuantity = 5;
    
    NSString* expectedSection = @"Deli";
    NSString* expectedSectionId = @"23c67a59-1c43-4c1d-8fc4-af95a8b7a947";
    NSString* expectedUnit = @"lb";
    bool selected = YES;

    
    HGGSGroceryItem *item = [[HGGSGroceryItem alloc] initWithOldDetails:expectedName quantity:expectedQuantity unit:expectedUnit section:expectedSection notes:expectedNotes select:selected lastPurchasedOn:expectedDate sectionId:expectedSectionId];
    
    XCTAssertEqualObjects([item unit], expectedUnit);
    XCTAssertEqualObjects([item sectionId], expectedSectionId);
    XCTAssertTrue([item selected]);
    
    XCTAssertEqualObjects([HGGSDate dateAsString:[item lastPurchasedDate]], [HGGSDate dateAsString:expectedDate]);
    XCTAssertEqualObjects([item name], expectedName);
    XCTAssert([item quantity] == expectedQuantity);
    XCTAssertEqualObjects([item notes], expectedNotes);
    XCTAssertEqualObjects([item section], expectedSection);
    
}
/*
- (void)testInitFromDictionary_WhenDataComesFromAndroidApp
{
    NSDate *expectedDate = [NSDate date];
    NSString* expectedDateAsString = @"Sun Jul 14 12:48:15 EDT 2013";
    NSString* expectedName = @"swifter pads";
    NSString* expectedNotes = @"";
    int expectedQuantity = 1;
    
    NSNumber* quantityAsNumber = [NSNumber numberWithInt:expectedQuantity];
    NSString* expectedSection = @"Deli";
    NSString* expectedSectionId = @"a6eeabae-491d-4680-ab50-696f7e30769c";
    NSString* expectedUnit = @"";
    int selected = true;
 
    // {"id":"b162db18-7ac2-43cd-979e-d02c1cd39348","unit":"","category":"a6eeabae-491d-4680-ab50-696f7e30769c","selected":true,"lastPurchasedDate":"Sun Jul 14 12:48:15 EDT 2013","name":"swifter pads","quantity":1,"notes":""}
 
    _groceryItemAsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:@"b162db18-7ac2-43cd-979e-d02c1cd39348",@"id",
                                expectedUnit,@"unit",
                                expectedSectionId,@"category",
                                selected,@"selected",
                                expectedDateAsString,@"lastPurchasedDate",
                                expectedName,@"name",
                                quantityAsNumber,@"quantity",
                                expectedNotes,@"notes",
                                expectedSection,@"section",
                                nil];
    
    HGGSGroceryItem *item = [[HGGSGroceryItem alloc] initFromDictionary:_groceryItemAsDictionary];
    XCTAssertEqualObjects([item unit], expectedUnit, nil);
    XCTAssertEqualObjects([item sectionId], expectedSectionId, nil);
    XCTAssertTrue([item selected], nil);
    
    XCTAssertEqualObjects([HGGSDate dateAsString:[item lastPurchasedDate]], [HGGSDate dateAsString:expectedDate], nil);
    XCTAssertEqualObjects([item name], expectedName, nil);
    XCTAssertEquals([item quantity], expectedQuantity, nil);
    XCTAssertEqualObjects([item notes], expectedNotes, nil);
    XCTAssertEqualObjects([item section], expectedSection, nil);
    
}
*/
@end