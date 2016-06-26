//
//  HGGSDbGroceryFilesStore.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/19/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import <DropboxSDK/DropboxSDK.h>

//@class HGGSStoreList;
@class HGGSGroceryStore;

@interface HGGSDbGroceryFilesStore : NSObject
{
    //    DBFilesystem *_fs;
}
+(HGGSDbGroceryFilesStore*) sharedDbStore;
@property (nonatomic, weak) id  DropboxClient;
@property (nonatomic, strong) DBRestClient * restClient;

-(void)groceryFilesExistForStore:(NSString *)storeName;
-(void)existingGroceryStores;

-(void)copyFileFromDropbox:(NSString *)fileName fromFolder:storeFolder intoFolder:(NSString *)localPath;
-(BOOL)copyFileToDropbox:(NSString *)fileName  fromFolder:(NSString *)localFolder intoFolder:(NSString *)dbFilePath parentRevision:(NSString*)parentRevision;
-(void) getListOfImagesFromDropboxFolder:(NSString *)subFolder;
-(void)deleteFileFromDropbox:(NSString *)dbFilePath;
-(void)getFileMetadata:(NSString *)fileName forStore:(NSString *)storeName;
@end
