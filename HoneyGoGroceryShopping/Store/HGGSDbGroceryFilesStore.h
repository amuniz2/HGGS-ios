//
//  HGGSDbGroceryFilesStore.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/19/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import <Dropbox/Dropbox.h>

@class HGGSStoreList;
@class HGGSGroceryStore;

@interface HGGSDbGroceryFilesStore : NSObject
{
    DBFilesystem *_fs;
}
+(HGGSDbGroceryFilesStore*) sharedDbStore;

-(void)groceryFilesExistForStore:(NSString *)storeName returnResult:(void(^)(BOOL))returnResult;
-(void)syncWithDropbox:(HGGSStoreList*) storeList;
-(void) copyFromDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted;
-(void) copyStoreListsFromDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted;
-(void) copyStoreListsToDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted;
-(void) copyToDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted;
-(void) deleteFromDropbox:(HGGSStoreList *)storeList notifyDeleteCompleted:(void(^)(BOOL))notifyDeleteCompleted;
-(void)notifyOfChangesToStoreList:(HGGSStoreList*)storeList;
-(void)notifyOfChangesToStore:(HGGSGroceryStore*)store;
@end
