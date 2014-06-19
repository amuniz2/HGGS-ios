//
//  HGGSSaveAisleConfigurationTest.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/12/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSSaveAisleConfigurationTest.h"
#import "HGGSGrocerySection.h"

@implementation HGGSSaveAisleConfigurationTest

- (void)setUp
{
    [super setUp];
    
}

-(void)testAsDictionary
{
    HGGSGrocerySection* sectionToConvertToDictionary = [[HGGSGrocerySection alloc] init];
    
    NSString* expectedName = @"Deli";
    NSString* expectedSectionId = @"23c67a59-1c43-4c1d-8fc4-af95a8b7a947";
    int aisle = 5;
    NSNumber* expectedAisle = [NSNumber numberWithInt:aisle];
    int order = 1;
    NSNumber* expectedOrder = [NSNumber numberWithInt:order];
    
    //set up
    [sectionToConvertToDictionary setName:expectedName];
    [sectionToConvertToDictionary setOrder:order];
    [sectionToConvertToDictionary setAisle:aisle];
    [sectionToConvertToDictionary setSectionId:expectedSectionId];
    
    // act
    NSDictionary* sectionAttributes = [sectionToConvertToDictionary asDictionary];
    
    // assert
    XCTAssertEqualObjects(expectedName,[sectionAttributes objectForKey:@"name"]);
    XCTAssertEqualObjects(expectedSectionId,[sectionAttributes objectForKey:@"id"]);
    XCTAssertEqualObjects(expectedAisle,[sectionAttributes objectForKey:@"order"]);
    XCTAssertEqualObjects(expectedOrder,[sectionAttributes objectForKey:@"index"]);
    
}

@end
