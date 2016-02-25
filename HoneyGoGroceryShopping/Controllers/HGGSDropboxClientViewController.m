//
//  HGGSDropboxClientControllerViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/6/15.
//  Copyright © 2015 Ana Muniz. All rights reserved.
//

#import "HGGSDropboxClientViewController.h"
#import "HGGSGroceryStore.h"

@interface HGGSDropboxClientViewController ()
{
    SynchStatus _synchStatus;
    NSUInteger _numberOfFilesLeftToSynch;
    UIActivityIndicatorView *_activityIndicator;
    DbFileSynchOption _syncActivity;
    BOOL _lastSyncFailed;
    
}
@end

@implementation HGGSDropboxClientViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self setActivityIndicatorCenter:[[self view] center]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark public api
-(void) copyStoreToDropbox
{
    _lastSyncFailed = NO;
    _syncActivity = ShareLocalFile;
    [self showActivityIndicator];
    
    [self copyStoreSetupToDropbox];
}

-(void) copyStoreFromDropbox
{
    _lastSyncFailed = NO;
    _syncActivity = ShareDropboxFile;
    [self copyStoreSetupFromDropbox ];
    [self showActivityIndicator];
}

-(void) syncStore
{
    _lastSyncFailed = NO;
    _syncActivity = UpdateToLatestFile;
    [self syncSetupFile];
    [self showActivityIndicator];
}

#pragma mark private methods

-(void)showActivityIndicator
{
    if (!_activityIndicator)
    {
        _activityIndicator  = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_activityIndicator setHidesWhenStopped:YES];
        _activityIndicator.center = [self activityIndicatorCenter];
        [self.view addSubview:_activityIndicator];
        
    }
    [_activityIndicator startAnimating];
}
-(void) hideActivityIndicator
{
    _synchStatus = Idle;
    _numberOfFilesLeftToSynch = 0;
    
    [_activityIndicator stopAnimating];
    _activityIndicator = nil;
    [self synchActivityCompleted:!_lastSyncFailed];
}

-(void) copyStoreSetupFromDropbox
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    _synchStatus = CopyingSetupFile;
    [dbStore copyFileFromDropbox:[HGGSGroceryStore getFileNameComponent:AISLE_CONFIG] fromFolder:[self.groceryStore name] intoFolder:[self.groceryStore localFolder] ];
}

-(void) copyStoreSetupToDropbox
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    if ([dbStore copyFileToDropbox:[HGGSGroceryStore getFileNameComponent:AISLE_CONFIG] fromFolder:[self.groceryStore localFolder] intoFolder:[self.groceryStore name]])
        _synchStatus = CopyingSetupFile;
    else
        [self hideActivityIndicator];
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
    _synchStatus = CopyingItems;
    if ([dbStore copyFileToDropbox:[HGGSGroceryStore getFileNameComponent:LIST] fromFolder:[self.groceryStore localFolder] intoFolder:[self.groceryStore name] ])
        _synchStatus = CopyingItems;
    else
        [self hideActivityIndicator];
}

-(void) copyImagesFromDropbox
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    NSString *imagesFolder = [[self.groceryStore name] stringByAppendingPathComponent:@"images"];
    [dbStore getListOfImagesFromDropboxFolder:imagesFolder];
    _synchStatus = CopyingImages;
    
}
-(void) copyImagesToDropbox
{
    NSString *imagesFolder = [self.groceryStore imagesFolder];
    _synchStatus = CopyingImages;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^()
                   {
                       NSArray *imageFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:imagesFolder error:nil];
                       _numberOfFilesLeftToSynch = [imageFiles count];
                       
                       dispatch_async(dispatch_get_main_queue(), ^{
                           [self copyLocalImages:imageFiles];
                       });
                   });
}
-(void) copyLocalImages:(NSArray *)files
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    NSString *imagesFolder = [[self.groceryStore name] stringByAppendingPathComponent:@"images"];
    for (NSString * file in files)
    {
        [dbStore copyFileToDropbox:file  fromFolder:[self.groceryStore imagesFolder] intoFolder:imagesFolder];
    }
}

#pragma mark DBRestClientDelegate methods
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    if (metadata.isDirectory)
    {
        HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
        
        NSLog(@"Folder '%@' contains:", metadata.path);
        if (_synchStatus != CopyingImages)
            return;
        
        _numberOfFilesLeftToSynch = metadata.contents.count;
        NSString *imagesSubFolder = [[self.groceryStore name] stringByAppendingPathComponent:@"images"];
        
        for (DBMetadata *file in metadata.contents) {
            [dbStore copyFileFromDropbox:file.filename fromFolder:imagesSubFolder intoFolder:[self.groceryStore imagesFolder] ];
            
            //            [dbStore copyFileFromDropbox:file.path localFile:[[self groceryStore] imagesFolder] ];
        }
        _synchStatus = Idle;
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    NSLog(@"Error loading metadata: %@", error);
    _lastSyncFailed = YES;
    [self hideActivityIndicator];
}

- (void)restClient:(DBRestClient *)client loadedFile:(NSString *)localPath
       contentType:(NSString *)contentType metadata:(DBMetadata *)metadata
{
    NSLog(@"File loaded into path: %@", localPath);
    if (_synchStatus == CopyingSetupFile)
        [self copyGroceryListFromDropbox];
    else if (_synchStatus == CopyingItems)
        [self copyImagesFromDropbox];
    else if (_synchStatus == CopyingImages)
    {
        --_numberOfFilesLeftToSynch;
        if (_numberOfFilesLeftToSynch == 0)
            [self hideActivityIndicator];
    }
    
    
}

- (void)restClient:(DBRestClient *)client loadFileFailedWithError:(NSError *)error {
    NSLog(@"There was an error loading the file: %@", error);
    _lastSyncFailed = YES;
    [self hideActivityIndicator];
}

- (void)restClient:(DBRestClient *)client uploadedFile:(NSString *)destPath
              from:(NSString *)srcPath metadata:(DBMetadata *)metadata {
    NSLog(@"File uploaded successfully to path: %@", metadata.path);
    if (_synchStatus == CopyingSetupFile)
        [self copyGroceryListToDropbox];
    else if (_synchStatus == CopyingItems)
        [self copyImagesToDropbox];
    else if (_synchStatus == CopyingImages)
    {
        --_numberOfFilesLeftToSynch;
        if (_numberOfFilesLeftToSynch == 0)
            [self hideActivityIndicator];
    }
}

- (void)restClient:(DBRestClient *)client uploadFileFailedWithError:(NSError *)error {
    NSLog(@"File upload failed with error: %@", error);
    [self hideActivityIndicator];
}
#pragma mark Abstract Methods
-(void)synchActivityCompleted:(BOOL) succeeded
{
    [NSException raise:NSInternalInconsistencyException
            format:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)];
}
@end
