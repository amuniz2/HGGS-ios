//
//  HGGSEditStoreViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/9/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import <DropboxSDK/DropboxSDK.h>
#import "HGGSAppDelegate.h"
#import "HGGSEditStoreViewController.h"
#import "HGGSMasterListViewController.h"
#import "HGGSGroceryStore.h"
#import "HGGSGroceryStoreManager.h"
#import "HGGSDbGroceryFilesStore.h"
#import "HGGSSynchronizeDropboxFilesViewController.h"
#import "HGGSAisleConfigurationControllerViewController.h"
#import "HGGSGrocerySectionsViewController.h"

#pragma mark Constants
#define LINK_DROPBOX_MESSAGE @"Link with Dropbox"
#define SHARE_GROCERY_LISTS @"Share Grocery Lists"
#define STOP_SHARING_GROCERY_LISTS @"Stop Sharing Grocery Lists"
#define UNLINK_FROM_DROPBOX @"Un-link Dropbox"

#define SEGUE_TO_CHOOSE_SYNCH_OPTION @"toSynchWithDropbox"

@interface HGGSEditStoreViewController ()//<HGGSDropboxControllerDelegate >
{
    BOOL _gettingDropboxFolderInfo;
    HGGSDropboxClient *_dropboxClient;
}
@end

@implementation HGGSEditStoreViewController

#pragma mark Lifecycle Methods
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [[self groceryStoreName] setText:[[self groceryStore] name ] ];
    
    [_groceryStoreName setDelegate:self];
    [self updateDropboxActionButton];
    
    UIBarButtonItem *delButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(confirmDeleteStore)];
    [[self navigationItem] setRightBarButtonItem:delButton];
    
    [self toggleEditMode:NO];
 
    _dropboxClient = [HGGSDropboxClient  CreateFromController:self forStore:[self groceryStore]];
    [_dropboxClient setDelegate:self];
    [_dropboxClient setActivityIndicatorCenter:CGPointMake(_dropboxButton.center.x, _dropboxButton.frame.origin.y + _dropboxButton.frame.size.height + 20)];
    
    
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showEditStoreButtons:(self.groceryStore != nil)];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    if (_inEditMode)
    {
        [self renameStore];
    }
    [[self groceryStore] unload];
    [super viewWillDisappear:animated];
    
}

-(void)dealloc
{
    _confirmDeleteStoreAlertView = nil;
    _unlinkAlertView = nil;
}

#pragma mark Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"toMasterList"])
    {
        HGGSMasterListViewController *masterListController = segue.destinationViewController;
        
        [masterListController setStore:self.groceryStore];
        [self.groceryStore setName:[[self groceryStoreName] text]];
        
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_CHOOSE_SYNCH_OPTION])
    {
        HGGSSynchronizeDropboxFilesViewController *synchController = segue.destinationViewController;
        [synchController setGroceryStore:self.groceryStore];
        [synchController setDismissBlock:^{[self updateDropboxActionButton];}];
        
    }
    else if ([segue.identifier isEqualToString:@"toAisleConfiguration"])
    {
        HGGSAisleConfigurationControllerViewController *aisleConfigViewController = segue.destinationViewController;
        
        [aisleConfigViewController setStore:self.groceryStore];
        [self.groceryStore setName:[[self groceryStoreName] text]];
    }
    else if ([segue.identifier isEqualToString:@"toGrocerySections"])
    {
        HGGSGrocerySectionsViewController *grocerySectionsViewController = segue.destinationViewController;
        
        [grocerySectionsViewController setStore:self.groceryStore];
        [self.groceryStore setName:[[self groceryStoreName] text]];
        
    }
    else
        NSLog(@"Seque identifier: %@", segue.identifier);
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
#pragma mark Private Methods
-(void)confirmDeleteStore
{
    NSString* promptMessage = [NSString stringWithFormat:@"All store informaiton, including grocery lists pertaining to %@ will be deleted.  Are you sure you want to delete this store?", [[self groceryStore] name]];
    
    if (_confirmDeleteStoreAlertView == nil)
        _confirmDeleteStoreAlertView = [[UIAlertView alloc]
                                        initWithTitle:@"Delete Store" message:promptMessage delegate:self
                                        cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    _confirmDeleteStoreAlertView.alertViewStyle = UIAlertViewStyleDefault;
    [_confirmDeleteStoreAlertView show];
    
}
-(void) createStore:(NSString *)newStoreName
{
    if ((newStoreName != nil) && (![newStoreName isEqualToString:@""]))
    {
        [self setGroceryStore:[[HGGSGroceryStoreManager sharedStoreManager] addStore:newStoreName]];
        [self.groceryStore setName:newStoreName];
        [self showEditStoreButtons:YES];
    }
}
-(void)linkDropbox
{
    //    DBAccountManager* accountManager = [DBAccountManager sharedManager];
    //    _isLinked =  (accountManager && [accountManager linkedAccount]);
    
    
    _unlinkAlertView = nil;
}

-(void) linkWithDropbox
{
    
    if ([[DBSession sharedSession] isLinked])
        return;
    
    _unlinkAlertView = nil;
    
    [[DBSession sharedSession] linkFromController:self];
    
    HGGSAppDelegate * appDelegate  = (HGGSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setDropboxViewController:self];
    
    if (!_activityIndicator)
    {
        _activityIndicator  = [[UIActivityIndicatorView alloc] init];
        [_activityIndicator setHidesWhenStopped:YES];
    }
    [_activityIndicator startAnimating];
}

-(void) showEditStoreButtons:(bool)show
{
    [_editAislesButton setHidden:!show];
    [_editMasterListButton setHidden:!show];
    [_dropboxButton setHidden:!show];
    
}


//-(void) unlinkFromDropbox
//{
//    if (!_isLinked)
//        return;
//
//    [[[DBAccountManager sharedManager] linkedAccount] unlink];
//    _isLinked = false;
//    [self updateDropboxActionButton];
//
//}
-(void) stopSharing
{
    [self.groceryStore setShareLists:NO];
    
    //    if (![[HGGSGroceryStoreManager sharedStoreManager] groceryListsAreBeingShared])
    //    {
    //        NSString* promptMessage = @"You are not sharing any grocery lists - do you want to disconnect from Dropbox?";
    //
    //        if (_unlinkAlertView == nil)
    //            _unlinkAlertView = [[UIAlertView alloc]
    //                                            initWithTitle:@"Stop sharing" message:promptMessage delegate:self
    //                                            cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    //        _unlinkAlertView.alertViewStyle = UIAlertViewStyleDefault;
    //        [_unlinkAlertView show];
    //
    //    }
    [self updateDropboxActionButton];
}
-(void)startSharing
{
    
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    [dbStore setDropboxClient:self];
    
//    if (![[DBSession sharedSession] isLinked])
//    {
//        [[DBSession sharedSession] linkFromController:self];
//    }
//    [dbStore setDropboxClient:self];
    
     [dbStore existingGroceryStores];
}
-(void) displayDropboxError:(NSString*)error
{
    NSString *message;
    
    if (error == nil)
        message = @"An error occurred copying a file to/from the Dropbox server.";
    else
        message = error;
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Dropbox Error"
                                                    message:message
                                                   delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    
    [alert show];
}

#pragma mark Actions
-(void)renameStore
{
    NSString *newStoreName = [[self groceryStoreName] text];
    
    // verify that the store name does not already exist
    if ([[HGGSGroceryStoreManager sharedStoreManager] store:newStoreName] != nil)
    {
        UIAlertView *errorAlert = [[UIAlertView alloc]
                                   initWithTitle:@"Duplicate Store" message:@"A store with this name already exists.  Please specify a unique name for this store." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
        
        [errorAlert show];
        
        return;
    }
    
    // set name and return to read-only mode
    if ([self groceryStore] == nil)
        [self createStore:newStoreName];
    else
        [[self groceryStore] setName:newStoreName];
    
}
-(IBAction)enterOrExitEditMode:(id)sender
{
    if(_inEditMode)
    {
        [self renameStore];
        [self toggleEditMode:NO];
    }
    else
    {
        // enter editing mode
        [self toggleEditMode:YES];
    }
}

- (void)linkToDropbox:(id)sender
{
    //determine what needs to happen:
    //(1) link to dropbox & share files
    //(2) stop sharing files through dropbox
    //(3) start sharing files through dropbox
    //(4) unlink from droptbox
    
    //if (!_isLinked)
    //    [self linkWithDropbox];
    ///else
    if (![self.groceryStore shareLists])
        [self startSharing];
    else
        [self stopSharing];
    
    /* only want to allow un-linking if NO stores are shared */
    /*    case notSharing:
     [self unlinkFromDropbox];
     break;
     */
    
}
-(void) presentSynchOptionsToUser
{
    
    [self performSegueWithIdentifier:SEGUE_TO_CHOOSE_SYNCH_OPTION sender:self];
    
    //[self presentViewController:synchController animated:YES completion:nil];
}

-(void)updateDropboxActionButton
{
    NSString *dropboxMessage = LINK_DROPBOX_MESSAGE;
    if ([self.groceryStore shareLists])
    {
        dropboxMessage = STOP_SHARING_GROCERY_LISTS;
    }
    else //if (_isLinked)
    {
        dropboxMessage = SHARE_GROCERY_LISTS;
    }
    //    else
    //    {
    //        dropboxMessage = LINK_DROPBOX_MESSAGE;
    //    }
    [_dropboxButton setTitle:dropboxMessage forState:UIControlStateNormal];
    [_dropboxButton setNeedsDisplay];
}
#pragma mark Manage Edit Mode

-(void) toggleEditMode:(bool)enable
{
    [self assignToolbarIconsEditMode:enable];
    [self groceryStoreName].enabled = enable;
    [self groceryStoreName].userInteractionEnabled = enable;
    [[self groceryStoreName] setBorderStyle:(enable ? UITextBorderStyleRoundedRect : UITextBorderStyleNone)];
    
    //[[self groceryStoreName] setFont:(enable ? [UIFont systemFontOfSize:15.0] : [UIFont boldSystemFontOfSize:17.0])];
    _inEditMode = enable;
}
-(void)assignToolbarIconsEditMode:(bool)editMode
{
    // need to insert the middle button
    NSArray* items = [_editToolbar items];
    UIBarButtonItem* button;
    NSMutableArray* newItems;
    
    if (editMode)
    {
        button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(enterOrExitEditMode:)];
    }
    else
    {
        button  = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(enterOrExitEditMode:)];
    }
    
    newItems = [[NSMutableArray alloc] initWithArray:items];
    [newItems setObject:button atIndexedSubscript:0];
    
    [_editToolbar setItems:newItems];
    
}

#pragma mark Dropbox Linked Handler
-(void)onSharingStatusUpdate
{
    if (_activityIndicator)
    {
        [_activityIndicator stopAnimating];
        _activityIndicator = nil;
    }
    
    //    DBAccountManager * accountManager = [DBAccountManager sharedManager];
    //    _isLinked =  (accountManager && [accountManager linkedAccount]);
    //
    //    [self updateDropboxActionButton];
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    //    if (alertView == _unlinkAlertView)
    //    {
    //        if (buttonIndex != alertView.cancelButtonIndex)
    //            [self unlinkFromDropbox];
    //    }
    if (alertView == _confirmDeleteStoreAlertView)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
            [self onDeleteStoreConfirmed];
    }
    else
        [self onSharingStatusUpdate];
    
}
-(void)onDeleteStoreConfirmed
{
    [[HGGSGroceryStoreManager sharedStoreManager] deleteStore:[[self groceryStore] name]];
    [[self navigationController] popViewControllerAnimated:YES];
    
}
#pragma mark HGGSDropboxControllerDelegate methods
-(void)synchActivityCompleted:(BOOL) succeeded error:(NSString*)errorMessage
{
    if (!succeeded)
    {
        [self displayDropboxError:errorMessage];
        [self.groceryStore setShareLists:NO];
    }
    else
    {
        // if file was copied from db...
        [self.groceryStore setShareLists:YES];
        [self updateDropboxActionButton];
    }
    
}

#pragma mark DBRestClientDelegate methods
-(bool)storeExists:(DBMetadata*) metadata
{
    if (metadata.contents.count == 0)
        return NO;
    
    for (DBMetadata * item in metadata.contents) {
        
        if (item.isDirectory && [item.path isEqualToString:[NSString stringWithFormat:@"/%@", _groceryStoreName.text]] )
            return YES;
    }
    return NO;
    
}
- (void)restClient:(DBRestClient *)client loadedMetadata:(DBMetadata *)metadata {
    [[HGGSDbGroceryFilesStore sharedDbStore] setDropboxClient:_dropboxClient];

    if ((metadata.isDirectory) && [self storeExists:metadata])
    {
        [self presentSynchOptionsToUser];
    }
    else
    {
        //[_groceryStore setShareLists:YES];
        //[dropboxClient setDelegate:self];
        [[HGGSDbGroceryFilesStore sharedDbStore] setDropboxClient:_dropboxClient];

        [_dropboxClient copyStoreToDropbox];
       // [self updateDropboxActionButton];
    }
}

- (void)restClient:(DBRestClient *)client loadMetadataFailedWithError:(NSError *)error {
    [[HGGSDbGroceryFilesStore sharedDbStore] setDropboxClient:_dropboxClient];
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Dropbox Error" message:[NSString stringWithFormat:@"%@", error] delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    
    [errorAlert show];
    
    return;
    
}

@end
