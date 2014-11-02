//
//  HGGSLoadGrocerySectionTests.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/12/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSLoadGrocerySectionTests.h"
#import "HGGSGrocerySection.h"

@implementation HGGSLoadGrocerySectionTests

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
    NSString* expectedSectionId = @"23c67a59-1c43-4c1d-8fc4-af95a8b7a947";
    NSString* expectedName = @"Produce";
    NSInteger expectedAisle = 2;
    NSNumber *aisleAsNumber = [NSNumber numberWithInteger:expectedAisle];
    NSInteger expectedOrder = 3;
    NSNumber* orderAsNumber = [NSNumber numberWithInteger:expectedOrder];
    
    _grocerySectionAsDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:expectedSectionId,@"id",
                                expectedName,@"name",
                                aisleAsNumber,@"order",
                                orderAsNumber,@"index",
                                nil];
    
    HGGSGrocerySection *section = [[HGGSGrocerySection alloc] initFromDictionary:_grocerySectionAsDictionary imagesFolder:nil];
    
    XCTAssertEqualObjects([section sectionId], expectedSectionId);
    XCTAssertEqualObjects([section name], expectedName);
    XCTAssertEqual([section aisle], expectedAisle);
    XCTAssertEqual([section order], expectedOrder);
    
}
/*- (void)testInitWithDetails
{
    NSString* expectedName = @"frozen dessers";
    NSInteger expectedAisle = 16;
    NSInteger expectedOrder = 2;

    HGGSGrocerySection *section = [[HGGSGrocerySection alloc] initWithDetails:expectedName  aisle:expectedAisle order:expectedOrder groceryItemsInSection:nil];
    
    XCTAssertEqualObjects([section sectionId], nil);
    
    XCTAssertEqualObjects([section name], expectedName);
    XCTAssertEqual([section aisle], expectedAisle);
    XCTAssertEqual([section order], expectedOrder);
    
}
- (void)testInitWithOldDetails
{
    NSString* expectedName = @"frozen dessers";
    NSInteger expectedAisle = 16;
    NSInteger expectedOrder = 2;
    NSString* expectedSectionId = @"23c67a59-1c43-4c1d-8fc4-af95a8b7a947";
    
    HGGSGrocerySection *section = [[HGGSGrocerySection alloc] initWithOldDetails:expectedName  aisle:expectedAisle order:expectedOrder sectionId:expectedSectionId groceryItemsInSection:nil];
    
    XCTAssertEqualObjects([section sectionId], expectedSectionId);
    XCTAssertEqualObjects([section name], expectedName);
    XCTAssertEqual([section aisle], expectedAisle);
    XCTAssertEqual([section order], expectedOrder);

 }
*/
@end
