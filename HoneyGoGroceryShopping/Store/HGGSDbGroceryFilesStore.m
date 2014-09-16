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
-(void) copyStoreListsFromDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
                   {
                       [self doCopyFromDropbox:[store getMasterList] notifyCopyCompleted:nil];
                       [self doCopyFromDropbox:[store getGroceryAisles] notifyCopyCompleted:nil];
                       [self doCopyFromDropbox:[store getCurrentList] notifyCopyCompleted:notifyCopyCompleted];
                   });
    
}

-(void) copyFromDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
                   {
                       [self doCopyFromDropbox:storeList notifyCopyCompleted:notifyCopyCompleted];
                   });
    
}

-(void) copyStoreListsToDropbox:(HGGSGroceryStore *)store notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
                   {
                       [self doCopyToDropbox:[store getGroceryAisles] notifyCopyCompleted:nil];
                       [self doCopyToDropbox:[store getMasterList] notifyCopyCompleted:nil];
                       [self doCopyToDropbox:[store getCurrentList] notifyCopyCompleted:notifyCopyCompleted];
                   });
    
}

-(void) copyToDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
                   {
                       [self doCopyToDropbox:storeList notifyCopyCompleted:notifyCopyCompleted];
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
    [self notifyOfChangesToStoreList:[store getGroceryAisles]];
    [self notifyOfChangesToStoreList:[store getMasterList]];
    [self notifyOfChangesToStoreList:[store getCurrentList]];
}

-(void) notifyOfChangesToStoreList:(HGGSStoreList*)storeList
{
    __weak id weakSelfRef = self;
    //NSString *storeName = [storeList storeName];
    DBPath* dbFolderPath = [[DBPath root] childPath:[storeList storeName]];
    [_fs addObserver:self forPath:[dbFolderPath childPath:[storeList fileName]] block:^{
        if (![storeList exists])
            [weakSelfRef doCopyFromDropbox:storeList notifyCopyCompleted:nil];
        /*else
        {
            //if files are loaded, determine if the changes are those made by the loaded store itself
            if ([weakSelfRef newDbFile:storeList ])
            {
                // otherwise, we need to prompt user on ui thread
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelfRef promptUserForReceiptOfDbFile:storeList];
                });
            }
        }
        */
            
    }];
    
}
-(void)syncWithDropbox:(HGGSStoreList*) storeList
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
                   {
                       [self doSyncWithDropbox:storeList];
                       [self notifyOfChangesToStoreList:storeList];
                   });
    
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
            fileCopied =[contents writeToFile:localFilePath atomically:NO encoding:NSUTF8StringEncoding error:&error];
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
-(DBPath*) dbFolderPathFor:(HGGSStoreList*)storeList
{
    DBPath *dbStoreFolderPath = [[DBPath root] childPath:[storeList storeName]];
    return [dbStoreFolderPath childPath:[storeList fileName]];
}
-(void) doCopyFromDropbox:(HGGSStoreList *)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
{
    bool fileCopied = NO;
    DBError *error;
    NSString *localPath =  [storeList localFolder];
    NSString *localFileName = [localPath stringByAppendingPathComponent:[storeList fileName]];
   
    DBFileInfo *fileInfo = [_fs fileInfoForPath:[self dbFolderPathFor:storeList] error:&error];
    if([self copyFileFromDropbox:fileInfo localFile:localFileName])
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

-(void) doCopyToDropbox:(HGGSStoreList*)storeList notifyCopyCompleted:(void(^)(BOOL))notifyCopyCompleted
{
    NSString* storeName = [storeList storeName];
    DBPath * dbStoreFolder = [[DBPath root] childPath:storeName];
    DBPath * dbStoreFileName ;
    NSString *localFile = [[storeList localFolder] stringByAppendingPathComponent:[storeList fileName]];
    bool fileCopied = NO;

    dbStoreFileName = [dbStoreFolder childPath:[storeList fileName]];
    if([self copyFileToDropbox:localFile DBFilePath:dbStoreFileName])
    {
        fileCopied = YES;
        [storeList setLastSyncDate:[NSDate date]];
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

-(void)doSyncWithDropbox:(HGGSStoreList*) storeList
{
    if([self newLocalFile:storeList])
    {
        [self copyToDropbox:storeList  notifyCopyCompleted:nil];
    }
    else if ([self newDbFile:storeList])
    {
        [self copyFromDropbox:storeList notifyCopyCompleted:nil];
    }
}

-(BOOL)newDbFile:(HGGSStoreList*)storeList
{
    DBPath * dbStoreFolder = [[DBPath root] childPath:[storeList storeName]];
    DBPath* dbSharedListFilePath;
    DBFileInfo * dbSharedListFileInfo;
    NSDate *dbSharedListModifiedDate;;
    
    dbSharedListFilePath = [dbStoreFolder childPath:[storeList fileName]];
    dbSharedListFileInfo = [_fs fileInfoForPath:dbSharedListFilePath error:nil];
    dbSharedListModifiedDate = [dbSharedListFileInfo modifiedTime];
    return [dbSharedListModifiedDate compare:[storeList lastSyncDate]] == NSOrderedDescending;
    

}

-(BOOL)newLocalFile:(HGGSStoreList*)storeList
{
    
    NSDate * localFileDate = [storeList lastModificationDate];
    if (localFileDate)
    {
        return [localFileDate compare:[storeList lastSyncDate]] == NSOrderedDescending;
        
    }
    return NO;
    
}
@end