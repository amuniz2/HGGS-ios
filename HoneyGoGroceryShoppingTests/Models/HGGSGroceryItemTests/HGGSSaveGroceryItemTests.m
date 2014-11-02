//
//  HGGSSaveGroceryItemTests.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/30/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSSaveGroceryItemTests.h"
#import "HGGSGroceryItem.h"
#import "HGGSDate.h"

@interface HGGSSaveGroceryItemTests()
{
    NSString* _expectedName ;
}
@end

@implementation HGGSSaveGroceryItemTests

- (void)setUp
{
    [super setUp];
    _expectedName = @"Test Name";
    _itemToSerialize = [[HGGSGroceryItem alloc] initWithDetails:_expectedName quantity:0 unit:@"" section:@"" notes:@"" select:NO lastPurchasedOn:nil];
    
    
}
-(void)testAsDictionary
{
    NSDate* expectedDate = [NSDate date];
    
    NSString* expectedNotes = @"some random notes";
    int quantity = 5;
    
    NSNumber* expectedQuantity = [NSNumber numberWithInt:quantity];
    NSString* expectedSection = @"Deli";
    NSString* expectedSectionId = @"23c67a59-1c43-4c1d-8fc4-af95a8b7a947";
    NSString* expectedUnit = @"box";
    bool selected = NO;
    NSString* expectedSelected = selected ? @"true" :  @"false";
    
    //set up
    //[_itemToSerialize setName:expectedName];
    [_itemToSerialize setLastPurchasedDate:expectedDate ];
    [_itemToSerialize setNotes:expectedNotes];
    [_itemToSerialize setQuantity:quantity];
    [_itemToSerialize setSection:expectedSection];
    [_itemToSerialize setSectionId:expectedSectionId];
    [_itemToSerialize setSelected:selected];
    [_itemToSerialize setUnit:expectedUnit];
    
    // act
    NSDictionary* itemAttributes = [_itemToSerialize asDictionary];

    // assert
    XCTAssertEqualObjects(_expectedName,[itemAttributes objectForKey:@"name"], @"Item names do not match.");
    XCTAssertEqualObjects([HGGSDate dateAsString:expectedDate],[itemAttributes objectForKey:@"lastPurchasedDate"], @"Item's LastPurchasedDates do not match.");
    XCTAssertEqualObjects(expectedNotes,[itemAttributes objectForKey:@"notes"]);
    XCTAssertEqualObjects(expectedQuantity,[itemAttributes objectForKey:@"quantity"]);
    XCTAssertEqualObjects(expectedSection,[itemAttributes objectForKey:@"section"]);
    XCTAssertEqualObjects(expectedSelected,[itemAttributes objectForKey:@"selected"]);
    XCTAssertEqualObjects(expectedUnit,[itemAttributes objectForKey:@"unit"]);
    
}
@end
