//
//  HGGSFindGrocerySectionsTests.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/21/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSFindGrocerySectionsTests.h"
#import "HGGSGrocerySection.h"
#import "HGGSGroceryStoreManager.h"
#import "HGGSGroceryStore.h"
#import "HGGSGroceryAisle.h"
#import "HGGSGroceryItem.h"

@implementation HGGSFindGrocerySectionsTests
{
    HGGSGroceryStore* _store;
    NSString* _storeName;
    HGGSGrocerySection* _deliSection ;
    HGGSGrocerySection* _dairySection;
    
}
- (void)setUp
{
    [super setUp];
    _storeName = @"FindGrocerySectionsTest";
    _store = [[HGGSGroceryStoreManager sharedStoreManager] addStore:_storeName];

    _deliSection = [_store insertNewGrocerySection:@"Deli" inAisle:1 atSectionIndex:0  ] ;
    [_store insertNewGrocerySection:@"other section in aisle 1" inAisle:1 atSectionIndex:1  ];
    [_store insertNewGrocerySection:@"Frozen Meats" inAisle:2 atSectionIndex:0  ];

    _dairySection = [_store insertNewGrocerySection:@"Dairy" inAisle:5 atSectionIndex:0  ] ;
    [_dairySection setSectionId:@"9ac05a99-86a3-4456-adea-98bb650be8c5"];

    
}
-(void)testFindSingleGrocerySectionInSingleAisle
{
    NSArray* foundSectionsInAisles = [_store findGrocerySections:@"dairy" inAisles:YES];
    NSUInteger count;
    
    XCTAssertEqual((NSUInteger)1, [foundSectionsInAisles count]);
    count =[[[foundSectionsInAisles objectAtIndex:0] grocerySections] count];
    XCTAssertEqual((NSUInteger)1,count);
    
    XCTAssertEqualObjects(_dairySection, [[[foundSectionsInAisles objectAtIndex:0] grocerySections] objectAtIndex:0]);

}
-(void)testFindSingleGrocerySectionBySectionId
{
    HGGSGrocerySection* foundSection = [_store findGrocerySectionBySectionId:@"9ac05a99-86a3-4456-adea-98bb650be8c5" ];
    
    XCTAssertEqualObjects(_dairySection, foundSection);
    
}

-(void)testFindMultipleGrocerySectionsInMultipleAisles
{
    NSArray* foundSectionsInAisles = [_store findGrocerySections:@"d" inAisles:YES];
    
    XCTAssertEqual((NSUInteger)2, [foundSectionsInAisles count]);
    XCTAssertEqual((NSUInteger)1,[[[foundSectionsInAisles objectAtIndex:0] grocerySections] count]);
    XCTAssertEqual((NSUInteger)1,[[[foundSectionsInAisles objectAtIndex:1] grocerySections] count]);
    XCTAssertEqualObjects(_deliSection,[[[foundSectionsInAisles objectAtIndex:0] grocerySections] objectAtIndex:0]);
    XCTAssertEqualObjects(_dairySection,[[[foundSectionsInAisles objectAtIndex:1] grocerySections] objectAtIndex:0]);
    
}

-(void)testFindAisle
{
    NSArray* foundSectionsInAisles = [_store findGrocerySections:@"1" inAisles:NO];
    HGGSGroceryAisle* aisleFound;
    XCTAssertEqual((NSUInteger)1, [foundSectionsInAisles count]);
    aisleFound = [foundSectionsInAisles objectAtIndex:0];
    XCTAssertEqual((NSInteger) 1,  [aisleFound number]);
    XCTAssertEqual((NSUInteger) 2,  [[aisleFound grocerySections] count]);
    
}

@end
