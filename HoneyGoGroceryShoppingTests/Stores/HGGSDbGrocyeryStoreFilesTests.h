//
//  HGGSDbGrocyeryStoreFilesTests.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/27/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import <XCTest/XCTest.h>

@class HGGSDbGroceryFilesStore;
@class HGGSGroceryStore;

@interface HGGSDbGrocyeryStoreFilesTests : XCTestCase
{
    NSString* _testStoreName;
    HGGSDbGroceryFilesStore *_dbStore;
    HGGSGroceryStore *_testStore;
}

@end
