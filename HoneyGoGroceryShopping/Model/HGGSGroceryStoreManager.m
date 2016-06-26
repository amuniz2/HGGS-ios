//
//  HGGSGroceryStoreManager.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 9/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSGroceryStoreManager.h"
#import "HGGSGroceryStore.h"
#import "HGGSDbGroceryFilesStore.h"
#import "HGGSDropboxFileRevisions.h"

@interface HGGSGroceryStoreManager()
    -(NSString *)getGroceryStoresFolder;
    -(HGGSGroceryStore *)loadStore:(NSString*)storeName;
    -(NSArray *) storeFoldersInPath:(NSString *) path;
@end

@implementation HGGSGroceryStoreManager

#pragma mark Class Methods
+(HGGSGroceryStoreManager *)sharedStoreManager
{
    static HGGSGroceryStoreManager * sharedStoreManager = nil;
    if(!sharedStoreManager)
    {
        sharedStoreManager = [[super allocWithZone:nil] init];
        if ([[sharedStoreManager allStores] count] == 0 )
            [sharedStoreManager createDefaultStore];
    }
    return sharedStoreManager;
}
#pragma mark Initializers
-(id)allocWithZone:(NSZone *)zone
{
    return [HGGSGroceryStoreManager sharedStoreManager];
}
-(id)init
{
    self = [super init];
    if (self)
    {
        _allkeys = nil;
        _allStores = [[NSMutableDictionary alloc] init];
        [self loadData];
    }
    return self;
}
-(void)dealloc
{
    //set each store's delegate to nil
    for (int i=0; i< [_allStores count];i++)
    {
        HGGSGroceryStore* store;
        NSEnumerator * enumerator = [_allStores objectEnumerator];
        while(store = [enumerator nextObject])
        {
            [store setDelegate:nil];
        }
    }
}

#pragma mark Properties
-(NSDictionary *) allStores
{
    return _allStores;
}

-(BOOL) groceryListsAreBeingShared
{
    HGGSGroceryStore * store;
    NSEnumerator * enumerator = [_allStores objectEnumerator];
    while(store = [enumerator nextObject])
    {
        if ([store shareLists])
            return true;
    }
    return false;
    
}
#pragma mark Public Methods
-(void)deleteStore:(NSString *)storeName
{
    HGGSGroceryStore *storeToDelete = [_allStores objectForKey:storeName];
    if (storeToDelete)
    {
        [HGGSGroceryStore deleteStore:storeToDelete];
        [_allStores removeObjectForKey:storeName];
    }
}

-(HGGSGroceryStore *) addStore:(NSString *) storeName
{
    HGGSGroceryStore * newStore = [HGGSGroceryStore createStore:storeName];
    
    [_allStores setObject:newStore forKey:storeName];
    
    return newStore;
}
-(HGGSGroceryStore *)createDefaultStore
{
    return [self addStore:@"My Grocery Store"];
}

-(HGGSGroceryStore *)store:(NSString*)name
{
    return [_allStores objectForKey:name];

}
-(void)saveChanges
{
    for(HGGSGroceryStore *store in [_allStores objectEnumerator])
    {
        [self saveStore:store];
    }
}
-(void)saveGroceryList:(HGGSGroceryStore*)store
{
    [store saveGroceryList];
    //todo:?
    //[self synchWithDb:store storeList:[store getGroceryList] copyImages:YES];
}
//-(void)saveShoppingList:(HGGSGroceryStore*)store
//{
//    [store saveShoppingList];
//}

-(void)saveGroceryAisles:(HGGSGroceryStore*)store
{
    [store saveGroceryAisles];
    //todo:?
    //[self synchWithDb:store storeList:[store getGroceryAisles] copyImages:NO];
}

#pragma mark private methods
-(void)loadData
{
    NSArray *foldersInPath = [self storeFoldersInPath:[self getGroceryStoresFolder]];
    for (NSString * folder in foldersInPath)
    {
        [self loadStore:folder];
    }
    
}
-(HGGSGroceryStore *)loadStore:(NSString*)storeName
{
    HGGSGroceryStore *storeToLoad = [[HGGSGroceryStore alloc] initWithStoreName:storeName];
    [storeToLoad converToNewStorage];
    
    // todo: initial load should only load store names!! 
    [_allStores setObject:storeToLoad forKey:storeName];
    
    return storeToLoad;
}
-(void)prepareStore:(HGGSGroceryStore*)store
{
    if  (![store preparedForWork])
    {
        HGGSDropboxFileRevisions *fileRevisions = [[HGGSDropboxFileRevisions alloc] initFromFolder:[store localFolder]];
        // copy any files that have been updated in dropbox
        // todo: [self fetchAnyNewDbFilesForStore:store];
        [fileRevisions loadLocalFileRevisions];
        [store setDropboxFileRevisions:fileRevisions];
        [store setPreparedForWork:YES];
        [store setSaveImagesSavedAfter:[NSDate date]];
    }
}
-(void)saveStore:(HGGSGroceryStore*) store
{
    [store saveStoreInfo];
}

-(NSArray *) storeFoldersInPath:(NSString *) path
{
    NSMutableArray* storeFoldersInPath = [[NSMutableArray alloc] init];
    NSDictionary* fileAttributes;
    
    NSArray *contentsOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString * file in contentsOfFolder)
    {
        fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[path stringByAppendingPathComponent:file ] error:nil];
        if ([fileAttributes valueForKey:NSFileType] == NSFileTypeDirectory)
        {
            [storeFoldersInPath addObject:file];
        }
    }
    return storeFoldersInPath;

}

//-(void)fetchAnyNewDbFilesForStore:(HGGSGroceryStore*) store
//{
//    if([store anyListsLoaded])
//        [store saveStoreInfo];
//    
//    [[HGGSDbGroceryFilesStore sharedDbStore] copyImagesFromDropbox:store  notifyCopyCompleted:^void(BOOL succeeded)
//     {
//         [self fetchNewDbStoreList:[store aisles]];
//         [self fetchNewDbStoreList:[store storeList]];
//     }];
//    
//    
//}
//-(void)fetchNewDbStoreList:(HGGSStoreList*) storeList
//{
//    
//    [storeList unload];
//    [[HGGSDbGroceryFilesStore sharedDbStore] copyFromDropbox:storeList  notifyCopyCompleted:nil];
//}
//
//-(void)synchWithDb:(HGGSGroceryStore*) store storeList:(HGGSStoreList*)storeList copyImages:(BOOL)copyImages
//{
//    if ([store shareLists])
//    {
//        //[storeList unload];
//        HGGSDbGroceryFilesStore * dbStore = [HGGSDbGroceryFilesStore sharedDbStore];;
//        [dbStore copyToDropbox:storeList  notifyCopyCompleted:nil copyImages:copyImages];
//    }
//}

-(NSString *)getGroceryStoresFolder
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // for ios, there will only be one director in the list
    return  [documentDirectories objectAtIndex:0];
}


@end