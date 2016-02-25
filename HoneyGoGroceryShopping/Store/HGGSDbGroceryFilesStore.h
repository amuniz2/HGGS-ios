//
//  HGGSDbGroceryFilesStore.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/19/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import <DropboxSDK/DropboxSDK.h>

@class HGGSStoreList;
@class HGGSGroceryStore;

@interface HGGSDbGroceryFilesStore : NSObject
{
    //    DBFilesystem *_fs;
}
+(HGGSDbGroceryFilesStore*) sharedDbStore;
@property (nonatomic, weak) id  DropboxClient;

-(void)groceryFilesExistForStore:(NSString *)storeName;
//-(void) copyFromDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted;
//-(void) copyStoreFromDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted;
//-(void) copyStoreToDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted;
//-(void) copyToDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted copyImages:(BOOL)copyImages;
//-(void) deleteFromDropbox:(HGGSStoreList *)storeList notifyDeleteCompleted:(void(^)(BOOL))notifyDeleteCompleted;
-(void)notifyOfChangesToStore:(HGGSGroceryStore*)store;
//-(void) copyImagesFromDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted;
-(void)copyFileFromDropbox:(NSString *)fileName fromFolder:storeFolder intoFolder:(NSString *)localPath;
-(BOOL)copyFileToDropbox:(NSString *)fileName  fromFolder:(NSString *)localFolder intoFolder:(NSString *)dbFilePath;
-(void) getListOfImagesFromDropboxFolder:(NSString *)subFolder;
-(void)deleteFileFromDropbox:(NSString *)dbFilePath;

@end
