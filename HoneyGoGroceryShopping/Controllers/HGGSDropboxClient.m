//
//  HGGSDropboxClientControllerViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/6/15.
//  Copyright © 2015 Ana Muniz. All rights reserved.
//

#import "HGGSDropboxClient.h"
#import "HGGSGroceryStore.h"
#import "HGGSDropboxFileRevisions.h"

@interface HGGSDropboxClient ()
{
    SynchStatus _synchStatus;
    NSUInteger _numberOfFilesLeftToSynch;
    UIActivityIndicatorView *_activityIndicator;
    DbFileSynchOption _syncActivity;
    BOOL _lastSyncFailed;
}
@end

@implementation HGGSDropboxClient

//- (void)viewDidLoad {
//    [super viewDidLoad];
//    // Do any additional setup after loading the view.
//
//    [self setActivityIndicatorCenter:[[self view] center]];
//}

//- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
//    // Dispose of any resources that can be recreated.
//}

#pragma mark Class Methods
+(id)CreateFromController:(UIViewController *)controller forStore:(HGGSGroceryStore *)store
{
    HGGSDropboxClient * client = [[HGGSDropboxClient alloc] init];
    
    [client setGroceryStore:store];
    [client setClientController: controller];
    
    [[HGGSDbGroceryFilesStore sharedDbStore] setDropboxClient:client];

    return client;
}
#pragma mark Lifecycle
-(void)dealloc
{
    _delegate = nil;
}
#pragma mark public api
-(void) copyStoreToDropbox
{
    _syncActivity = ShareLocalFile;
    
    [self startActivity];

    _synchStatus = CopyingSetupFile;
    
    [self getStoreSetupMetadata];

}
-(void) copySetupOnlyToDropbox
{
    _syncActivity = ShareLocalFile;
    [self startActivity];
    
    _synchStatus = CopyingSetupOnlyfile;
    
    [self getStoreSetupMetadata];
}

-(void) copyListToDropbox
{
    _syncActivity = ShareLocalFile;
    [self startActivity];

    _synchStatus = CopyingItems;

    //todo: only if local version is there and more recent!!
    [self getListMetadata];
   
}

-(void) copyStoreFromDropbox
{
    _syncActivity = ShareDropboxFile;
    [self startActivity];
    _synchStatus = CopyingSetupFile;
    
    [self getStoreSetupMetadata];
}
-(void) copySetupOnlyFromDropbox
{
    _syncActivity = ShareLocalFile;
    [self startActivity];

    _synchStatus = CopyingSetupOnlyfile;
    
    [self getStoreSetupMetadata];
    
}

-(void) copyListFromDropbox
{
    _syncActivity = ShareDropboxFile;
    [self startActivity];

    _synchStatus = CopyingItems;
    
    //todo: only if db version is there and more recent!!
    [self getListMetadata];
}
#pragma mark Property Overrides
-(void)setGroceryStore:(HGGSGroceryStore *)groceryStore
{
    _groceryStore = groceryStore;
    _dbRootFolder = [NSString stringWithFormat:@"/%@", [groceryStore name]];
}
//-(void) syncStore
//{
//    _lastSyncFailed = NO;
//    _syncActivity = UpdateToLatestFile;
//    [self syncSetupFile];
//    [self showActivityIndicator];
//}

#pragma mark private methods
-(void)getStoreSetupMetadata
{
    [[HGGSDbGroceryFilesStore sharedDbStore] getFileMetadata:[HGGSGroceryStore getFileNameComponent:AISLE_CONFIG] forStore:[_groceryStore name]];
}

-(void)getListMetadata
{
    [[HGGSDbGroceryFilesStore sharedDbStore] getFileMetadata:[HGGSGroceryStore getFileNameComponent:LIST] forStore:[_groceryStore name]];
}

-(NSDate *)lastModificationDateOfLocalFile:(NSString *)fileName inFolder:(NSString*)localFolder
{
    NSString * localFilePath = [localFolder stringByAppendingPathComponent:fileName];
    
    NSDictionary *fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:localFilePath error:nil];
    if (fileAttributes == nil)
        return nil;
    
    if([fileAttributes valueForKey:NSFileType] != NSFileTypeRegular)
        return nil;
    
    return [fileAttributes objectForKey:NSFileModificationDate];
    
}
-(void)startActivity
{
    _lastSyncFailed = NO;
    _numberOfFilesLeftToSynch = 0;
    [self showActivityIndicator];
}
-(void)showActivityIndicator
{
    if (!_activityIndicator)
    {
        _activityIndicator  = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_activityIndicator setHidesWhenStopped:YES];
      
        _activityIndicator.center = [self activityIndicatorCenter];
        [[self.clientController view] addSubview:_activityIndicator];
        
    }
    [_activityIndicator startAnimating];
}
-(void)endActivityWithError:(NSString *)error
{
    _synchStatus = Idle;
    _numberOfFilesLeftToSynch = 0;
    [[[self groceryStore] dropboxFileRevisions] save];
    [self hideActivityIndicator];
    [[self delegate] synchActivityCompleted:!_lastSyncFailed error:error];
}
-(void)endActivity
{
    [self endActivityWithError:nil];
}

-(void) hideActivityIndicator
{
    [_activityIndicator stopAnimating];
    _activityIndicator = nil;
}

-(void) copyStoreSetupFromDropbox
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];

    _synchStatus = CopyingSetupFile;
    
    [dbStore copyFileFromDropbox:[HGGSGroceryStore getFileNameComponent:AISLE_CONFIG] fromFolder:[self.groceryStore name] intoFolder:[self.groceryStore localFolder] ];
}
-(void) copyStoreSetupOnlyFromDropbox
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    _synchStatus = CopyingSetupOnlyfile;
    [dbStore copyFileFromDropbox:[HGGSGroceryStore getFileNameComponent:AISLE_CONFIG] fromFolder:[self.groceryStore name] intoFolder:[self.groceryStore localFolder] ];
}


-(void) copyStoreSetupToDropbox
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    NSString *fileName = [HGGSGroceryStore getFileNameComponent:AISLE_CONFIG];
    NSString *currentLocalFileRevision = [[_groceryStore dropboxFileRevisions] getLocalFileRevisionFor:fileName];
    
    if ([dbStore copyFileToDropbox:fileName fromFolder:[self.groceryStore localFolder] intoFolder:_dbRootFolder parentRevision:currentLocalFileRevision])
        _synchStatus = CopyingSetupFile;
    else
        [self endActivityWithError:@"Error occurred copying while store configuration to the Dropbox server"];
}
-(void) copyStoreSetupOnlyToDropbox
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    NSString *fileName = [HGGSGroceryStore getFileNameComponent:AISLE_CONFIG];
    NSString *currentLocalFileRevision = [[_groceryStore dropboxFileRevisions] getLocalFileRevisionFor:fileName];
    
    if ([dbStore copyFileToDropbox:fileName fromFolder:[self.groceryStore localFolder] intoFolder:_dbRootFolder parentRevision:currentLocalFileRevision])
        _synchStatus = CopyingSetupOnlyfile;
    else
        [self endActivityWithError:@"Error occurred copying while store configuration to the Dropbox server"];
}
-(void) performActivity
{
    switch (_syncActivity) {
        case ShareDropboxFile:
            switch(_synchStatus)
            {
                case CopyingItems:
                    [self copyGroceryListFromDropbox];
                    break;
                
                case CopyingSetupFile:
                    [self copyStoreSetupFromDropbox];
                    break;
                    
                case CopyingSetupOnlyfile:
                    [self copyStoreSetupOnlyFromDropbox];
                    break;
                    
                default:
                    [self endActivity];
                
            }
            break;
            
            
        case ShareLocalFile:
            switch(_synchStatus)
        {
            case CopyingItems:
                [self copyGroceryListToDropbox];
                break;
                
            case CopyingSetupFile:
               [self copyStoreSetupToDropbox];
                break;
                
            case CopyingSetupOnlyfile:
                [self copyStoreSetupOnlyToDropbox];
                break;
                
            default:
                [self endActivity];
        }
            
        default:
            break;
    }
}
-(void)skipToNextActivity
{
    switch (_syncActivity) {
        case ShareDropboxFile:
            switch(_synchStatus)
            {
                case CopyingItems:
                    [self copyImagesFromDropbox];
                    break;
                    
                case CopyingSetupFile:
                    [self copyGroceryListFromDropbox];
                    break;
                    
                default:
                    [self endActivity];
                    
                
            }
            
            break;
        
            
        case ShareLocalFile:
            switch(_synchStatus)
            {
                case CopyingItems:
                    [self copyImagesToDropbox];
                    break;
                    
                case CopyingSetupFile:
                    [self copyGroceryListToDropbox];
                    break;
                    
                default:
                    [self endActivity];
                    break;
            }
            
        default:
            break;
    }
}

-(void)syncSetupFile
{
    // todo
//    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
//
//    if()
//        _synchStatus = SyncingSetupFile;
//    else
//        [self hideActivityIndicator];
}

-(void) copyGroceryListFromDropbox
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    _synchStatus = CopyingItems;
    [dbStore copyFileFromDropbox:[HGGSGroceryStore getFileNameComponent:LIST] fromFolder:[self.groceryStore name] intoFolder:[self.groceryStore localFolder] ];
}

-(void) copyGroceryListToDropbox
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    NSString *fileName = [HGGSGroceryStore getFileNameComponent:LIST];
    NSString *currentLocalFileRevision = [[_groceryStore dropboxFileRevisions] getLocalFileRevisionFor:fileName];
    
    _synchStatus = CopyingItems;
    if ([dbStore copyFileToDropbox:fileName fromFolder:[self.groceryStore localFolder] intoFolder:_dbRootFolder parentRevision:currentLocalFileRevision])
        _synchStatus = CopyingItems;
    else
        [self endActivityWithError:@"Error occurred copying the grocyer list to the Dropbox server"];
}

-(void) copyImagesFromDropbox
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    NSString *imagesFolder = [_dbRootFolder stringByAppendingPathComponent:@"images"];
    _synchStatus = CopyingImages;
    [dbStore getListOfImagesFromDropboxFolder:imagesFolder];
}
-(void) copyImagesToDropbox
{
    NSFileManager *localFileManager = [NSFileManager defaultManager];
    NSString *imagesFolder = [self.groceryStore imagesFolder];
    //NSDate* saveImagesAfter = [_groceryStore saveImagesSavedAfter];
    NSMutableArray *imageFilesToCopy = [[NSMutableArray alloc] init];
    NSArray *localImageFiles = [localFileManager contentsOfDirectoryAtPath:imagesFolder error:nil];
    
    for (NSString * file in localImageFiles)
    {
        //NSString *localFilePath = [imagesFolder stringByAppendingPathComponent:file];
        //NSDictionary * attributes=[localFileManager attributesOfItemAtPath:localFilePath error:&error];
        //if (attributes != nil && [attributes[NSFileModificationDate] timeIntervalSinceDate:saveImagesAfter] > 0)
        //{
            [imageFilesToCopy addObject:file];
        //}
    }
    _numberOfFilesLeftToSynch = [imageFilesToCopy count];
    if (_numberOfFilesLeftToSynch > 0)
    {
        _synchStatus = CopyingImages;
        [self copyLocalImages:imageFilesToCopy];
    }
    else
        [self endActivity];
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
//                   {
//                       NSArray *imageFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imagesFolder error:nil];
//                       _numberOfFilesLeftToSynch = [imageFiles count];
//                       
//                       dispatch_async(dispatch_get_main_queue(), ^{
//                           [self copyLocalImages:imageFiles];
//                       });
//                   });
}
-(void) copyLocalImages:(NSArray *)files
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    NSString *imagesFolder = [_dbRootFolder stringByAppendingPathComponent:@"images"];
    for (NSString * file in files)
    {
        [dbStore copyFileToDropbox:file  fromFolder:[self.groceryStore imagesFolder] intoFolder:imagesFolder
                    parentRevision:[[_groceryStore dropboxFileRevisions] getLocalFileRevisionFor:file] ];
    }
}
-(void)triggerCopyOfImagesFromDropbox:(DBMetadata *)metadata
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    
    _numberOfFilesLeftToSynch = metadata.contents.count;
    NSString *imagesSubFolder = [[self.groceryStore name] stringByAppendingPathComponent:@"images"];
    
    for (DBMetadata *file in metadata.contents) {
        
        
        //NSDate *localFileDate = [self lastModificationDateOfLocalFile:file.filename inFolder:imagesSubFolder];
        NSString* localFileRevision = [[_groceryStore dropboxFileRevisions] getLocalFileRevisionFor:file.filename];
        
        
        if (!file.isDirectory && (![localFileRevision isEqualToString:file.rev]))
        {
            [dbStore copyFileFromDropbox:file.filename fromFolder:imagesSubFolder intoFolder:[self.groceryStore imagesFolder] ];
        }
        else
        {
            // no need to copy the file, so just remove it from the count of files that need to be copied
            _numberOfFilesLeftToSynch--;
        }
    }
    if (_numberOfFilesLeftToSynch == 0)
        [self endActivity];
    
}
#pragma mark DBRestClientDelegate methods
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory)
    {
        if (_synchStatus == CopyingImages)
        {
            [self triggerCopyOfImagesFromDropbox:metadata];
        }
        return;
    }
    if ((_synchStatus == CopyingItems) || (_synchStatus == CopyingSetupFile) || (_synchStatus == CopyingSetupOnlyfile))
    {
        if (_syncActivity == ShareDropboxFile)
        {
            NSString* localFileRevision = [[_groceryStore dropboxFileRevisions] getLocalFileRevisionFor:metadata.filename];
                
            if ((localFileRevision == nil) || ![localFileRevision isEqualToString:metadata.rev])
                [self performActivity];
            else
                [self skipToNextActivity];
        }
        else
        {
            NSError *error;
            NSFileManager *localFileManager = [NSFileManager defaultManager];
            NSDate *dbDate = metadata.lastModifiedDate;
                
            NSString *localFilePath = [[_groceryStore localFolder] stringByAppendingPathComponent:[HGGSGroceryStore getFileNameComponent:LIST]];
            NSDictionary * attributes=[localFileManager attributesOfItemAtPath:localFilePath error:&error];
            if (attributes != nil && [attributes[NSFileModificationDate] timeIntervalSinceDate:dbDate] > 0)
                [self performActivity];
            else
                [self skipToNextActivity];
        }
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSString *errorDescription = [NSString stringWithFormat:@"Error loading metadata: %@", error];
    
    // okay if file just not found
    if (_syncActivity == ShareDropboxFile)
    {
        if (error.code == 404)
            [self skipToNextActivity];
        else
        {
            _lastSyncFailed = YES;
            [self endActivityWithError:errorDescription];
        }
    }
    else if (error.code == 404)
    {
        [self performActivity];
    }
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    [[[self groceryStore] dropboxFileRevisions] addOrUpdateRevisionTo:metadata.rev forFile:metadata.filename];
    if (_synchStatus == CopyingSetupFile)
        [self copyGroceryListFromDropbox];
    else if (_synchStatus == CopyingSetupOnlyfile)
        [self endActivity];
    else if (_synchStatus == CopyingItems)
        [self copyImagesFromDropbox];
    else if (_synchStatus == CopyingImages)
    {
        --_numberOfFilesLeftToSynch;
        if (_numberOfFilesLeftToSynch == 0)
            [self endActivity];
    }
    
    
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    
    _lastSyncFailed = YES;
    [self endActivityWithError:[NSString stringWithFormat:@"There was an error loading the file: %@", error]];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    [[[self groceryStore] dropboxFileRevisions] addOrUpdateRevisionTo:metadata.rev forFile:metadata.filename];
    if (_synchStatus == CopyingSetupFile)
        [self copyGroceryListToDropbox];
    else if (_synchStatus == CopyingSetupOnlyfile)
        [self endActivity];
    else if (_synchStatus == CopyingItems)
        [self copyImagesToDropbox];
    else if (_synchStatus == CopyingImages)
    {
        --_numberOfFilesLeftToSynch;
        if (_numberOfFilesLeftToSynch == 0)
            [self endActivity];
    }
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSString *message = [NSString stringWithFormat:@"File upload failed with error: %@", error];
    
    [self endActivityWithError:message];
}
#pragma mark Abstract Methods
-(void)synchActivityCompleted:(BOOL) succeeded error:(NSString*)error
{
    [NSException raise:NSInternalInconsistencyException
            format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}
@end
