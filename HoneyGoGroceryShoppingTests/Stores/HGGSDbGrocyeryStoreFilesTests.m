//
//  HGGSDbGrocyeryStoreFilesTests.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/27/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import <Dropbox/Dropbox.h>

#import "HGGSDbGrocyeryStoreFilesTests.h"
#import "HGGSDbGroceryFilesStore.h"
#import "HGGSGroceryStore.h"
#import "HGGSGroceryStoreManager.h"


@implementation HGGSDbGrocyeryStoreFilesTests
- (void)setUp
{
    [super setUp];
    
    _testStoreName = @"DbStoreCopyFromDbTestStore";
    // Set-up code here.
    if([[HGGSGroceryStoreManager sharedStoreManager] store:_testStoreName])
    {
        // if the store exists, delete it
        [[HGGSGroceryStoreManager sharedStoreManager] deleteStore:_testStoreName];
    }
    
    _dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    _testStore = [[HGGSGroceryStoreManager sharedStoreManager] addStore:_testStoreName];

    [self createTestFileInDropbox:_testStoreName];
}

- (void)tearDown
{
    [[HGGSGroceryStoreManager sharedStoreManager] deleteStore:_testStoreName];
    [super tearDown];
    
}

/*
 -(void) testCopyStoreFromDropbox
{
    [_dbStore copyFromDropbox:_testStore notifyCopyCompleted:^void(BOOL succeeded)
     {
         XCTAssertTrue(succeeded);

     }];
     [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3.00]];
     XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[_testStore getFileName:MASTER_LIST]]);
     XCTAssertEqual([[_testStore loadList:MASTER_LIST] count], (NSUInteger)0);
    //XCTAssertEqualObjects(<#a1#>, <#a2#>, <#description, ...#>)
}
 */
/*
-(void) testDeleteStoreFromDropbox
{
    
    [_dbStore deleteFromDropbox:_testStore notifyDeleteCompleted:nil];
    
}
*/
-(DBFilesystem *)getDbFilesystem
{
    DBFilesystem *fs = [DBFilesystem sharedFilesystem];
    if (!fs)
    {
        DBAccountManager* accountManager = [DBAccountManager sharedManager];
        DBAccount* linkedAccount = [accountManager linkedAccount];
    
        fs = [[DBFilesystem alloc] initWithAccount:linkedAccount];
        [DBFilesystem setSharedFilesystem:fs];
    }
    return fs;
}
-(void)createTestFileInDropbox:(NSString*)storeName
{
    DBFilesystem *fs = [self getDbFilesystem];
    DBError* error;
    NSString* fileContents = [NSString stringWithFormat:@"[{\"name\":\"Milk\",\"unit\":\"gallon\",\"notes\":\"Skim\",\"quantity\":1},{\"name\":\"Eggs\",\"unit\":\"dozen\",\"notes\":\"\",\"quantity\":1},{\"name\":\"Vitamin D Supplement\",\"unit\":\"bottle\",\"notes\":\"Gummies\",\"quantity\":1},{\"name\":\"Yogurt - strawberry\",\"unit\":\"\",\"notes\":\"lowfat\",\"quantity\":1},{\"name\":\"Ground turkey\",\"unit\":\"lbs\",\"notes\":\"\",\"quantity\":2},{\"name\":\"Chicken nuggets\",\"unit\":\"bag\",\"notes\":\"\",\"quantity\":1}]"];
    DBPath * storeFolerPathInDb = [[DBPath root] childPath:storeName] ;
    [fs createFolder:storeFolerPathInDb  error:&error];
    if (!error)
    {
        DBFile* file = [fs createFile:[storeFolerPathInDb childPath:@"master_list.json"] error:&error];
        if (file)
            [file writeString:fileContents error:&error];
        
    }
        
}
@end
