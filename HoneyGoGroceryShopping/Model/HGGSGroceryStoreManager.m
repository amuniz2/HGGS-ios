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
    NSLog(@"store manager deleteStore called");

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
-(void)saveMasterList:(HGGSGroceryStore*)store
{
    [store saveMasterList];
    [self synchWithDb:store storeList:[store getMasterList]];
}
-(void)saveCurrentList:(HGGSGroceryStore*)store
{
    [store saveCurrentList];
    [self synchWithDb:store storeList:[store getCurrentList]];
}
-(void)saveShoppingList:(HGGSGroceryStore*)store
{
    [store saveShoppingList];
}

-(void)saveGroceryAisles:(HGGSGroceryStore*)store
{
    [store saveGroceryAisles];
    [self synchWithDb:store storeList:[store getGroceryAisles]];
}

/*
 -(void)saveStoreList:(HGGSGroceryStore*)store listType:(storeFileType)listType
{
    if (([store saveList:listType ]) && ([store ShareLists]))
    {
        HGGSDbGroceryFilesStore * dbStore = [HGGSDbGroceryFilesStore sharedDbStore];;
        // copy any files that have been updated in dropbox
        [dbStore copyToDropbox:store  notifyCopyCompleted:nil];
        [store unloadLists];
    }
    
}
*/

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
    [_allStores setObject:storeToLoad forKey:storeName];
    
    if ([storeToLoad shareLists])
    {
        // copy any files that have been updated in dropbox
        [self fetchAnyNewDbFilesForStore:storeToLoad];
        [[HGGSDbGroceryFilesStore sharedDbStore] notifyOfChangesToStore:storeToLoad];

    }
    return storeToLoad;
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

-(void)fetchAnyNewDbFilesForStore:(HGGSGroceryStore*) store
{
    [self fetchNewDbStoreList:[[store storeLists] objectForKey:[NSNumber numberWithInt:AISLE_CONFIG]]];
    [self fetchNewDbStoreList:[[store storeLists] objectForKey:[NSNumber numberWithInt:MASTER_LIST]]];
    [self fetchNewDbStoreList:[[store storeLists] objectForKey:[NSNumber numberWithInt:CURRENT_LIST]]];
    
}
-(void)fetchNewDbStoreList:(HGGSStoreList*) storeList
{
    [storeList unload];
//    [[HGGSDbGroceryFilesStore sharedDbStore] copyToDropbox:storeList  notifyCopyCompleted:nil];
    [[HGGSDbGroceryFilesStore sharedDbStore] copyFromDropbox:storeList  notifyCopyCompleted:nil];
}

-(void)synchWithDb:(HGGSGroceryStore*) store storeList:(HGGSStoreList*)storeList
{
    if ([store shareLists])
    {
        [storeList unload];
        HGGSDbGroceryFilesStore * dbStore = [HGGSDbGroceryFilesStore sharedDbStore];;
        [dbStore copyToDropbox:storeList  notifyCopyCompleted:nil];
    }
}

-(NSString *)getGroceryStoresFolder
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // for ios, there will only be one director in the list
    return  [documentDirectories objectAtIndex:0];
}

#pragma mark HGGSGroceryStoreDelegate Methods
-(void)groceryStore:(HGGSStoreList*) list
{
    HGGSGroceryStore *groceryStore = [list store];
    if ([groceryStore shareLists])
    {
        HGGSDbGroceryFilesStore * dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
        [dbStore copyToDropbox:list  notifyCopyCompleted:nil];
    }
}

@end