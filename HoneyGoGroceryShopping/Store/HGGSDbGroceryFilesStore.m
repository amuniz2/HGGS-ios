//
//  HGGSDbGroceryFilesStore.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/19/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import <DropboxSDK/DropboxSDK.h>
#import "HGGSDbGroceryFilesStore.h"
#import "HGGSGroceryStore.h"
#import "HGGSStoreList.h"
#import "HGGSAlertSharedStoreFileUpdated.H"
#import "NSString+SringExtensions.h"

@implementation HGGSDbGroceryFilesStore
{
    DBRestClient *_restClient;
}

#pragma mark Class Methods
+(HGGSDbGroceryFilesStore *) sharedDbStore
{
    static HGGSDbGroceryFilesStore * sharedDbStore = nil;
    if(!sharedDbStore)
    {
        sharedDbStore = [[super allocWithZone:nil] init];
    }
    return sharedDbStore;
    
}
#pragma Initializers
-(id)init
{
    self = [super init];
    if (self)
    {
        // TODO: create RESTClient?
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
    }
    return self;
    
}
#pragma mark Public Methods
/*-(void) copyFromDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
 {
 if ([self newDbFile:storeList])
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
 {
 [self doCopyFromDropbox:storeList notifyCopyCompleted:notifyCopyCompleted];
 });
 
 }
 */
/*
 -(void) copyImagesFromDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
 {
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
 {
 [self doCopyImagesFromDropbox:store notifyCopyCompleted:notifyCopyCompleted];
 });
 
 }
 */
/*-(void) doCopyImagesFromDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
 {
 DBPath* dbStoreFolder = [[DBPath root] childPath:[store name]];
 
 [self doCopyFilesInDBFolder:[dbStoreFolder childPath:@"images"] toLocalFolder:[store imagesFolder] lastSyncDate:[store lastImagesSyncDate]];
 
 if (notifyCopyCompleted != nil)
 notifyCopyCompleted(YES);
 }*/
/*-(void) copyStoreToDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
 {
 
 //    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
 //                   {
 [self doCopyFilesInDirectory:[store imagesFolder] toDropboxFolder:[self dbFolderForStoreImages:store] lastSyncDate:[store lastImagesSyncDate]];
 [self doCopyToDropbox:[store getGroceryAisles] notifyCopyCompleted:nil copyImages:NO];
 [self doCopyToDropbox:[store getMasterList] notifyCopyCompleted:nil copyImages:NO];
 [self doCopyToDropbox:[store getCurrentList] notifyCopyCompleted:notifyCopyCompleted copyImages:NO];
 [store setLastImagesSyncDate:[NSDate date]];
 //                   });
 
 }
 */
/*-(void) copyToDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted copyImages:(BOOL)copyImages
 {
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
 {
 [self doCopyToDropbox:storeList notifyCopyCompleted:notifyCopyCompleted copyImages:copyImages];
 });
 
 }*/
/*-(void) deleteFromDropbox:(HGGSStoreList *)storeList notifyDeleteCompleted:(void(^)(BOOL))notifyDeleteCompleted
 {
 dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
 {
 [self doDeleteFromDropbox:storeList notifyDeleteCompleted:notifyDeleteCompleted];
 });
 
 }
 */
-(void)groceryFilesExistForStore:(NSString *)storeName
{
    NSString *dbFolder = [NSString stringWithFormat:@"/%@", storeName];
    [_restClient loadMetadata:dbFolder];
    
    /*    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
     {
     BOOL result = [self doFilesExistInStore:storeName];
     dispatch_async(dispatch_get_main_queue(), ^{
     // This will be called on the main thread, so that
     // you can update the UI, for example.
     //[self longOperationDone];
     returnResult( result);
     });
     });
     */
}

/*
 -(void) notifyOfChangesToStore:(HGGSGroceryStore*)store
 {
 NSString* dbStoreFolder = [self dbFolderForStore:store];
 
 [self notifyOfChangesToStoreImages:store inStoreFolder:dbStoreFolder];
 [self notifyOfChangesToStoreList:[store getGroceryAisles] inFolder:dbStoreFolder];
 [self notifyOfChangesToStoreList:[store getMasterList]  inFolder:dbStoreFolder];
 [self notifyOfChangesToStoreList:[store getCurrentList]  inFolder:dbStoreFolder];
 }
 */
//-(void) notifyOfChangesToStoreList:(HGGSStoreList*)storeList inFolder:(DBPath *)inFolder
//{
//    __weak id weakSelfRef = self;
//
//    [_fs addObserver:self forPath:[inFolder childPath:[storeList fileName]] block:^{
//        if (![storeList exists])
//            [weakSelfRef doCopyFromDropbox:storeList notifyCopyCompleted:nil];
//    }];
//
//
//}
//
//-(void) notifyOfChangesToStoreImages:(HGGSGroceryStore*)store inStoreFolder:(DBPath *)inStoreFolder
//{
//    __weak id weakSelfRef = self;
//
//    [_fs addObserver:self forPath:[inStoreFolder childPath:@"images"] block:^{
//
//        // todo: copy image files from dropbox to local
//        [weakSelfRef doCopyFilesInDBFolder:inStoreFolder toLocalFolder:[store imagesFolder] lastSyncDate:[store lastImagesSyncDate]];
//    }];
//
//}

#pragma mark Property Overrides
-(id)DropboxClient
{
    return _restClient.delegate;
}

-(void)setDropboxClient:(id)dropboxClient
{
    if (_restClient != nil)
    {
        _restClient.delegate = dropboxClient;
    }
}

/*
 #pragma mark UIAlertView
 -(void)promptUserForReceiptOfDbFile:(HGGSStoreList *)storeList
 {
 NSString* promptMessage = [NSString stringWithFormat:@"There are updated grocery lists avilable for %@.  Do you want to replace the current list with the updated list from Dropbox?", [storeList storeName]];
 //todo:
 HGGSAlertSharedStoreFileUpdated *alertView =
 [[HGGSAlertSharedStoreFileUpdated alloc]
 initWithTitle:@"Grocery List Received" message:promptMessage delegate:self
 cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
 alertView.alertViewStyle = UIAlertViewStyleDefault;
 [alertView setStoreListUpdated:storeList];
 [alertView setDelegate:self];
 [alertView show];
 
 
 }
 - (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
 {
 //todo - if the user does not cancel, need to unload the copy the files from dropbox and reload the lists
 if (buttonIndex == 1)
 {
 HGGSAlertSharedStoreFileUpdated * alertV = (HGGSAlertSharedStoreFileUpdated*)alertView;
 [self copyFromDropbox:[alertV storeListUpdated] notifyCopyCompleted:nil];
 
 }
 }
 */

#pragma mark Private Methods
/*-(void)copyFileFromDropbox:(NSString *)fileName fromFolder:storeFolder intoFolder:(NSString *)localPath
 {
 NSString *dbFilePath = [NSString stringWithFormat:@"/%@/%@", storeFolder, fileName];
 [_restClient loadFile:dbFilePath intoPath:intoFolder];
 }*/

-(BOOL)copyFileToDropbox:(NSString *)fileName  fromFolder:(NSString *)localFolder intoFolder:(NSString *)dbFilePath
{
    NSString *localFilePath = [localFolder stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:localFilePath])
        return NO;
    
    // Upload file to Dropbox
    [_restClient uploadFile:fileName toPath:dbFilePath withParentRev:nil fromPath:localFilePath];
    
    //    DBFile * dbFile = [_fs openFile:dbFilePath error:&error];
    //    if (error)
    //        dbFile = [_fs createFile:dbFilePath error:&error];
    //
    //    if (dbFile)
    //    {
    //        error = nil;
    //        fileCopied =[dbFile writeContentsOfFile:localFilePath shouldSteal:NO error:&error];
    //        [dbFile close];
    //    }
    //
    //    if (error)
    //    {
    //        NSLog(@"Error opening file %@: %@", dbFilePath, error);
    //    }
    return YES;
    
}

-(void)deleteFileFromDropbox:(NSString *)dbFilePath
{
    //DBError *error;
    
    [_restClient deletePath:dbFilePath];
    
    /*   if ([_fs deletePath:[dbFileInfo path] error:&error])
     return YES;
     
     else if (error)
     {
     NSLog(@"Error deleting file %@: %@", [dbFileInfo path], error);
     }
     return NO;
     */
}

/*
 -(bool)doFilesExistInStore:(NSString*) storeName
 {
 
 NSError *error;
 
 NSArray * filesInStoreFolder = [_fs listFolder:[[DBPath root] childPath:storeName] error:&error];
 return ([filesInStoreFolder count] > 0);
 }
 -(NSString*) dbFilePathFor:(HGGSStoreList*)storeList
 {
 NSString *rootDir = @"/";
 
 NSString *dbStoreFolderPath = [rootDir childPath:[storeList storeName]];
 return [dbStoreFolderPath childPath:[storeList fileName]];
 }
 */
/*-(NSString *)localFilePathForList:(HGGSStoreList*)storeList
 {
 NSString *localPath =  [[storeList store] localFolder];
 return [localPath stringByAppendingPathComponent:[storeList fileName]];
 
 }*/
-(NSString *)dbFolderForStore:(HGGSGroceryStore*)store
{
    return [NSString stringWithFormat:@"/%@", [store name] ];
}

-(NSString *)dbFolderForStoreImages:(HGGSGroceryStore*)store
{
    return [NSString stringWithFormat:@"/%@/images",[store name] ];
}

/*-(void) doCopyFromDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
 {
 bool fileCopied = NO;
 DBError *error;
 
 DBFileInfo *fileInfo = [_fs fileInfoForPath:[self dbFilePathFor:storeList] error:&error];
 if([self copyFileFromDropbox:fileInfo localFile:[self localFilePathForList:storeList]])
 {
 fileCopied = YES;
 [storeList setLastSyncDate:[NSDate date]];
 [storeList reload];
 }
 
 if (notifyCopyCompleted)
 {
 dispatch_async(dispatch_get_main_queue(), ^{
 // This will be called on the main thread, so that
 // you can update the UI, for example.
 //[self longOperationDone];
 notifyCopyCompleted(fileCopied);
 });
 }
 
 }
 */
/*
 -(bool)isDbFile:(DBFileInfo*)dbFileInfo ofType:(NSString*)extension newerThan:(NSDate*)otherFileDate
 {
 if (![[[dbFileInfo path]name] endsWith:[NSString stringWithFormat:@".%@",extension]])
 return NO;
 
 NSDate* dbFileDate = [dbFileInfo modifiedTime];
 
 return ((otherFileDate == nil) || ([dbFileDate compare:otherFileDate] == NSOrderedDescending));
 
 }
 */
-(bool)isFile:(NSString*)filePath ofType:(NSString*)extension newerThan:(NSDate*)otherFileDate
{
    if (![filePath endsWith:[NSString stringWithFormat:@".%@",extension]])
        return NO;
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];
    
    if (fileAttributes == nil)
        return NO;
    
    if([fileAttributes valueForKey:NSFileType] != NSFileTypeRegular)
        return NO;
    
    NSDate* localFileDate = [fileAttributes objectForKey:NSFileModificationDate];
    
    return ((otherFileDate == nil) || ([localFileDate compare:otherFileDate] == NSOrderedDescending));
    
}
-(void) getListOfImagesFromDropboxFolder:(NSString *)storeName
{
    NSString *dbFolder = [NSString stringWithFormat:@"/%@/images",storeName];
    [_restClient loadMetadata:dbFolder];
}

/*-(void) doCopyFilesInDirectory:(NSString*)localFolder toDropboxFolder:(NSString*)dbFolder lastSyncDate:(NSDate*)lastSyncDate
 {
 NSString *jpegFilePath;
 DBPath *dbFilePath;
 DBFileInfo * dbFileInfo;
 
 NSArray *contentsOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localFolder error:nil];
 
 [_restClient loadMetadata:dbFolder];
 
 [_restClient createFolder:dbFolder];
 //    dbFileInfo = ([_fs fileInfoForPath:dbFolder error:nil ]);
 //    if (dbFileInfo == nil)
 //        [_fs createFolder:dbFolder error:nil];
 
 for (NSString * file in contentsOfFolder)
 {
 if ([self isFile:jpegFilePath ofType:@"jpg" newerThan:lastSyncDate])
 [self copyFileToDropbox:file  dbPath:dbFolder localFolder:localFolder];
 }
 
 }
 */
/*
 -(void) doCopyFilesInDBFolder:(NSString*)dbFolder toLocalFolder:(NSString*)localFolder lastSyncDate:(NSDate*)lastSyncDate
 {
 NSString *localFilePath;
 
 NSArray * filesInImagesFolder = [_fs listFolder:dbFolder error:nil];
 
 if (![[NSFileManager defaultManager] fileExistsAtPath:localFolder])
 [[NSFileManager defaultManager] createDirectoryAtPath:localFolder withIntermediateDirectories:NO attributes:nil error:nil];
 
 for (DBFileInfo *dbFileInfo in filesInImagesFolder)
 {
 localFilePath = [localFolder stringByAppendingPathComponent:[[dbFileInfo path] name]];
 
 if ([self isDbFile:dbFileInfo ofType:@"jpg" newerThan:lastSyncDate])
 [self copyImageFromDropbox:dbFileInfo localFile:localFilePath];
 }
 
 }
 */

/*-(void) doCopyToDropbox:(HGGSStoreList*)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted copyImages:(BOOL)copyImages
 {
 NSString* storeName = [storeList storeName];
 DBPath * dbStoreFolder = [[NSString stringWithFormat:@"/%@",storeName];
 NSString *localFolder = [[storeList store] localFolder] ;
 bool fileCopied = NO;
 
 dbStoreFileName = [dbStoreFolder childPath:[storeList fileName]];
 if([self copyFileToDropbox:[storeList fileName] filePath:[storeList store] localFolder:localFolder];
 {
 //todo: move to when file is actually successfully uploaded
 fileCopied = YES;
 [storeList setLastSyncDate:[NSDate date]];
 if (copyImages)
 {
 //images may have been updated as well
 [self doCopyFilesInDirectory:[[storeList store] imagesFolder] toDropboxFolder:[dbStoreFolder childPath:@"images"] lastSyncDate:[[storeList store] lastImagesSyncDate]];
 
 }
 }
 if (notifyCopyCompleted)
 {
 dispatch_async(dispatch_get_main_queue(), ^{
 // This will be called on the main thread, so that
 // you can update the UI, for example.
 //[self longOperationDone];
 notifyCopyCompleted(fileCopied );
 });
 }
 }
 */
/*-(bool)doDeleteFromDropbox:(HGGSStoreList *)storeList notifyDeleteCompleted:(void(^)(BOOL))notifyDeleteCompleted
 {
 int filesDeleted = 0;
 NSString *storeName = [storeList storeName];
 DBPath *dbStoreFolderPath =[[DBPath root] childPath:storeName];
 NSArray * filesInStoreFolder = [_fs listFolder:dbStoreFolderPath error:nil];
 unsigned long filesToDelete = [filesInStoreFolder count];
 bool success = NO;
 
 
 if (!dbStoreFolderPath)
 //no need to delete if it doesnt exist
 return YES;
 
 for (DBFileInfo *fileInfo in filesInStoreFolder)
 {
 if ([self deleteFileFromDropbox:fileInfo])
 filesDeleted++;
 
 }
 if (filesDeleted == filesToDelete)
 {
 if ([self deleteFileFromDropbox:[_fs fileInfoForPath:dbStoreFolderPath error:nil]])
 success = YES;
 
 }
 if (notifyDeleteCompleted)
 {
 dispatch_async(dispatch_get_main_queue(), ^{
 notifyDeleteCompleted(success);
 });
 }
 
 return success;
 
 
 }
 */
/*-(BOOL)newDbFile:(HGGSStoreList*)storeList
 {
 DBPath * dbStoreFolder = [[DBPath root] childPath:[storeList storeName]];
 DBPath* dbSharedListFilePath;
 DBFileInfo * dbSharedListFileInfo;
 NSDate *dbSharedListModifiedDate;;
 
 //NSString *localFilePath = [self localFilePathForList:storeList] ;
 //NSDictionary *localFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:localFilePath error:nil];
 
 dbSharedListFilePath = [dbStoreFolder childPath:[storeList fileName]];
 dbSharedListFileInfo = [_fs fileInfoForPath:dbSharedListFilePath error:nil];
 dbSharedListModifiedDate = [dbSharedListFileInfo modifiedTime];
 //return [dbSharedListModifiedDate compare:[localFileAttributes objectForKey:NSFileModificationDate]] == NSOrderedDescending;
 return [dbSharedListModifiedDate compare:[storeList lastSyncDate]] == NSOrderedDescending;
 }*/

//TODO: not used --- but should we use it?
/*-(BOOL)newLocalFile:(HGGSStoreList*)storeList
 {
 DBPath * dbFilePath = [self dbFilePathFor:storeList];
 DBFileInfo *dbFileInfo = [_fs fileInfoForPath:dbFilePath error:nil];
 NSDate * localFileDate = [storeList lastModificationDate];
 
 if (localFileDate)
 {
 return [localFileDate compare:[dbFileInfo modifiedTime]] == NSOrderedDescending;
 }
 return NO;
 
 }*/
@end