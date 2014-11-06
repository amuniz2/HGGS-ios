//
//  HGGSDbGroceryFilesStore.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/19/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import <Dropbox/Dropbox.h>
#import "HGGSDbGroceryFilesStore.h"
#import "HGGSGroceryStore.h"
#import "HGGSStoreList.h"
#import "HGGSAlertSharedStoreFileUpdated.H"
#import "NSString+SringExtensions.h"

@implementation HGGSDbGroceryFilesStore
{
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
        DBAccountManager* accountManager = [DBAccountManager sharedManager];
        DBAccount* linkedAccount = [accountManager linkedAccount];
        if ((!accountManager) ||(!linkedAccount))
            return nil;
        
        _fs = [DBFilesystem sharedFilesystem];
        if (!_fs)
        {
            _fs = [[DBFilesystem alloc] initWithAccount:linkedAccount];
            [DBFilesystem setSharedFilesystem:_fs];
        }
    }
    return self;
    
}
#pragma mark Public Methods
-(void) copyStoreFromDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
{
    
    [self copyImagesFromDropbox:store notifyCopyCompleted:nil];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
                   {
                       [self doCopyImagesFromDropbox:store notifyCopyCompleted:nil];
                       [self doCopyFromDropbox:[store getMasterList] notifyCopyCompleted:nil];
                       [self doCopyFromDropbox:[store getGroceryAisles] notifyCopyCompleted:nil];
                       [self doCopyFromDropbox:[store getCurrentList] notifyCopyCompleted:notifyCopyCompleted];
                       [store setLastImagesSyncDate:[NSDate date]];
                   });
    
}

-(void) copyFromDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
{
    if ([self newDbFile:storeList])
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
                       {
                           [self doCopyFromDropbox:storeList notifyCopyCompleted:notifyCopyCompleted];
                       });
        
}

-(void) copyImagesFromDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
    {
        [self doCopyImagesFromDropbox:store notifyCopyCompleted:notifyCopyCompleted];
    });
    
}
-(void) doCopyImagesFromDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
{
    DBPath* dbStoreFolder = [[DBPath root] childPath:[store name]];
    
    [self doCopyFilesInDBFolder:[dbStoreFolder childPath:@"images"] toLocalFolder:[store imagesFolder] lastSyncDate:[store lastImagesSyncDate]];
    
    if (notifyCopyCompleted != nil)
        notifyCopyCompleted(YES);
}
-(void) copyStoreToDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
                   {
                       [self doCopyFilesInDirectory:[store imagesFolder] toDropboxFolder:[self dbFolderForStoreImages:store] lastSyncDate:[store lastImagesSyncDate]];
                       [self doCopyToDropbox:[store getGroceryAisles] notifyCopyCompleted:nil copyImages:NO];
                       [self doCopyToDropbox:[store getMasterList] notifyCopyCompleted:nil copyImages:NO];
                       [self doCopyToDropbox:[store getCurrentList] notifyCopyCompleted:notifyCopyCompleted copyImages:NO];
                       [store setLastImagesSyncDate:[NSDate date]];
                   });
    
}

-(void) copyToDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted copyImages:(BOOL)copyImages
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
                   {
                       [self doCopyToDropbox:storeList notifyCopyCompleted:notifyCopyCompleted copyImages:copyImages];
                   });
    
}
-(void) deleteFromDropbox:(HGGSStoreList *)storeList notifyDeleteCompleted:(void(^)(BOOL))notifyDeleteCompleted
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
                   {
                       [self doDeleteFromDropbox:storeList notifyDeleteCompleted:notifyDeleteCompleted];
                   });
    
}

-(void)groceryFilesExistForStore:(NSString *)storeName returnResult:(void(^)(BOOL))returnResult
{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
    {
        BOOL result = [self doFilesExistInStore:storeName];
        dispatch_async(dispatch_get_main_queue(), ^{
            // This will be called on the main thread, so that
            // you can update the UI, for example.
            //[self longOperationDone];
            returnResult( result);
        });
    });
    
}

-(void) notifyOfChangesToStore:(HGGSGroceryStore*)store
{
    DBPath* dbStoreFolder = [[DBPath root] childPath:[store name]];
    
    [self notifyOfChangesToStoreImages:store inStoreFolder:dbStoreFolder];
    [self notifyOfChangesToStoreList:[store getGroceryAisles] inFolder:dbStoreFolder];
    [self notifyOfChangesToStoreList:[store getMasterList]  inFolder:dbStoreFolder];
    [self notifyOfChangesToStoreList:[store getCurrentList]  inFolder:dbStoreFolder];
}

-(void) notifyOfChangesToStoreList:(HGGSStoreList*)storeList inFolder:(DBPath *)inFolder
{
    __weak id weakSelfRef = self;
 
    [_fs addObserver:self forPath:[inFolder childPath:[storeList fileName]] block:^{
        if (![storeList exists])
            [weakSelfRef doCopyFromDropbox:storeList notifyCopyCompleted:nil];
    }];


}

-(void) notifyOfChangesToStoreImages:(HGGSGroceryStore*)store inStoreFolder:(DBPath *)inStoreFolder
{
    __weak id weakSelfRef = self;

    [_fs addObserver:self forPath:[inStoreFolder childPath:@"images"] block:^{
        
        // todo: copy image files from dropbox to local
        [weakSelfRef doCopyFilesInDBFolder:inStoreFolder toLocalFolder:[store imagesFolder] lastSyncDate:[store lastImagesSyncDate]];
    }];
    
}


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

/*        [self copyFromDropbox:[alertV storeListUpdated] notifyCopyCompleted:^(BOOL completed)
        {
            if (completed)
                [[alertV storeListUpdated] reload];
        }];
*/
    }
}


#pragma mark Private Methods
-(BOOL)copyFileFromDropbox:(DBFileInfo *)dbFileInfo localFile:(NSString *)localFilePath
{
    DBError *dberror;
    NSError *error;
    BOOL fileCopied = NO;
    DBFile * dbFile = [_fs openFile:[dbFileInfo path] error:&dberror];

    if (dbFile)
    {
        NSString * contents = [dbFile readString:&dberror];
        [dbFile close];
        if (contents)
        {
            error = nil;
            fileCopied =[contents writeToFile:localFilePath atomically:NO encoding:NSUTF8StringEncoding error:&error];
        }
    }
    if (error)
    {
        NSLog(@"Error copying file %@: %@", dbFileInfo, error);
    }
    return fileCopied && !error;
    
}

-(BOOL)copyImageFromDropbox:(DBFileInfo *)dbFileInfo localFile:(NSString *)localFilePath
{
    DBError *dberror;
    NSError *error;
    BOOL fileCopied = NO;
    DBFile * dbFile = [_fs openFile:[dbFileInfo path] error:&dberror];
    
    if (dbFile)
    {
        NSData * contents = [dbFile readData:&dberror];
        [dbFile close];
        if (contents)
        {
            error = nil;
            fileCopied =[contents writeToFile:localFilePath atomically:NO ];
        }
    }
    if (error)
    {
        NSLog(@"Error copying file %@: %@", dbFileInfo, error);
    }
    return fileCopied && !error;
    
}


-(BOOL)copyFileToDropbox:(NSString *)localFilePath DBFilePath:(DBPath *)dbFilePath
{
    DBError * error;
    BOOL fileCopied = NO;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:localFilePath])
        return NO;

    DBFile * dbFile = [_fs openFile:dbFilePath error:&error];
    if (error)
        dbFile = [_fs createFile:dbFilePath error:&error];
    
    if (dbFile)
    {
        error = nil;
        fileCopied =[dbFile writeContentsOfFile:localFilePath shouldSteal:NO error:&error];
        [dbFile close];
    }
    
    if (error)
    {
        NSLog(@"Error opening file %@: %@", dbFilePath, error);
    }
    return fileCopied;
    
}

-(bool)deleteFileFromDropbox:(DBFileInfo *)dbFileInfo
{
    DBError *error;
    
    if ([_fs deletePath:[dbFileInfo path] error:&error])
        return YES;
    
    else if (error)
    {
        NSLog(@"Error deleting file %@: %@", [dbFileInfo path], error);
    }
    return NO;
}

-(bool)doFilesExistInStore:(NSString*) storeName
{

    NSError *error;

    NSArray * filesInStoreFolder = [_fs listFolder:[[DBPath root] childPath:storeName] error:&error];
    return ([filesInStoreFolder count] > 0);
}
-(DBPath*) dbFilePathFor:(HGGSStoreList*)storeList
{
    DBPath *dbStoreFolderPath = [[DBPath root] childPath:[storeList storeName]];
    return [dbStoreFolderPath childPath:[storeList fileName]];
}
-(NSString *)localFilePathForList:(HGGSStoreList*)storeList
{
    NSString *localPath =  [[storeList store] localFolder];
    return [localPath stringByAppendingPathComponent:[storeList fileName]];

}
-(DBPath *)dbFolderForStoreImages:(HGGSGroceryStore*)store
{
    DBPath *dbStoreFolderPath = [[DBPath root] childPath:[store name]];
    return [dbStoreFolderPath childPath:@"images"];

}

-(void) doCopyFromDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
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
-(bool)isDbFile:(DBFileInfo*)dbFileInfo ofType:(NSString*)extension newerThan:(NSDate*)otherFileDate
{
    if (![[[dbFileInfo path]name] endsWith:[NSString stringWithFormat:@".%@",extension]])
        return NO;
    
    NSDate* dbFileDate = [dbFileInfo modifiedTime];
    
    return ((otherFileDate == nil) || ([dbFileDate compare:otherFileDate] == NSOrderedDescending));
    
}

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

-(void) doCopyFilesInDirectory:(NSString*)localFolder toDropboxFolder:(DBPath*)dbFolder lastSyncDate:(NSDate*)lastSyncDate
{
    NSString *jpegFilePath;
    DBPath *dbFilePath;
    DBFileInfo * dbFileInfo;
    
    NSArray *contentsOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:localFolder error:nil];
    
    dbFileInfo = ([_fs fileInfoForPath:dbFolder error:nil ]);
    if (dbFileInfo == nil)
        [_fs createFolder:dbFolder error:nil];
 
    for (NSString * file in contentsOfFolder)
    {
        dbFilePath = [dbFolder childPath:file];
        jpegFilePath = [localFolder stringByAppendingPathComponent:file];
        if ([self isFile:jpegFilePath ofType:@"jpg" newerThan:lastSyncDate])
            [self copyFileToDropbox:jpegFilePath DBFilePath:dbFilePath];
    }
    
}

-(void) doCopyFilesInDBFolder:(DBPath*)dbFolder toLocalFolder:(NSString*)localFolder lastSyncDate:(NSDate*)lastSyncDate
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

-(void) doCopyToDropbox:(HGGSStoreList*)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted copyImages:(BOOL)copyImages
{
    NSString* storeName = [storeList storeName];
    DBPath * dbStoreFolder = [[DBPath root] childPath:storeName];
    DBPath * dbStoreFileName ;
    NSString *localFile = [[[storeList store] localFolder] stringByAppendingPathComponent:[storeList fileName]];
    bool fileCopied = NO;

    dbStoreFileName = [dbStoreFolder childPath:[storeList fileName]];
    if([self copyFileToDropbox:localFile DBFilePath:dbStoreFileName])
    {
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

-(bool)doDeleteFromDropbox:(HGGSStoreList *)storeList notifyDeleteCompleted:(void(^)(BOOL))notifyDeleteCompleted
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

-(BOOL)newDbFile:(HGGSStoreList*)storeList
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
}

//TODO: not used --- but should we use it?
-(BOOL)newLocalFile:(HGGSStoreList*)storeList
{
    DBPath * dbFilePath = [self dbFilePathFor:storeList];
    DBFileInfo *dbFileInfo = [_fs fileInfoForPath:dbFilePath error:nil];
    NSDate * localFileDate = [storeList lastModificationDate];
    
    if (localFileDate)
    {
        return [localFileDate compare:[dbFileInfo modifiedTime]] == NSOrderedDescending;
    }
    return NO;
    
}
@end