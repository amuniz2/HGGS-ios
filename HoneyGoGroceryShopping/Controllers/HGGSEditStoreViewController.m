//
//  HGGSEditStoreViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/9/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import <Dropbox/Dropbox.h>
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

@interface HGGSEditStoreViewController ()

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
    
    DBAccountManager* accountManager = [DBAccountManager sharedManager];
    
    _isLinked =  (accountManager && [accountManager linkedAccount]);
    _unlinkAlertView = nil;
    
    [_groceryStoreName setDelegate:self];
    [self updateDropboxActionButton];
    
    UIBarButtonItem *delButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(confirmDeleteStore)];
    [[self navigationItem] setRightBarButtonItem:delButton];
    
    [self toggleEditMode:NO];
    
/*    [[DBAccountManager sharedManager] addObserver:self block:(DBAccountManagerObserver)^(DBAccount* account)
     {
         [self onSharingStatusUpdate];
     }];
 */
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showEditStoreButtons:(_groceryStore != nil)];
   
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    if (_inEditMode)
    {
       [self renameStore];
    }
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
        
        [masterListController setStore:_groceryStore];
        [_groceryStore setName:[[self groceryStoreName] text]];
        
    }
    else if ([segue.identifier isEqualToString:SEGUE_TO_CHOOSE_SYNCH_OPTION])
    {
        HGGSSynchronizeDropboxFilesViewController *synchController = segue.destinationViewController;
        [synchController setGroceryStore:_groceryStore];
        [synchController setDismissBlock:^{[self updateDropboxActionButton];}];

    }
    else if ([segue.identifier isEqualToString:@"toAisleConfiguration"])
    {
        HGGSAisleConfigurationControllerViewController *aisleConfigViewController = segue.destinationViewController;
        
        [aisleConfigViewController setStore:_groceryStore];
        [_groceryStore setName:[[self groceryStoreName] text]];
    }
    else if ([segue.identifier isEqualToString:@"toGrocerySections"])
    {
        HGGSGrocerySectionsViewController *grocerySectionsViewController = segue.destinationViewController;
        
        [grocerySectionsViewController setStore:_groceryStore];
        [_groceryStore setName:[[self groceryStoreName] text]];
        
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
        _groceryStore = [[HGGSGroceryStoreManager sharedStoreManager] addStore:newStoreName];
        [_groceryStore setName:newStoreName];
        [self showEditStoreButtons:YES];
    }
}

-(void) linkWithDropbox
{
    if (_isLinked)
        return;
    
    HGGSAppDelegate * appDelegate  = (HGGSAppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate setDropboxViewController:self];
    
    if (!_activityIndicator)
    {
        _activityIndicator  = [[UIActivityIndicatorView alloc] init];
        [_activityIndicator setHidesWhenStopped:YES];
    }
    [_activityIndicator startAnimating];
    
    [[DBAccountManager sharedManager] linkFromController:self];
    
}

-(void) showEditStoreButtons:(bool)show
{
    [_editAislesButton setHidden:!show];
    [_editMasterListButton setHidden:!show];
    [_dropboxButton setHidden:!show];
    
}


-(void) unlinkFromDropbox
{
    if (!_isLinked)
        return;
    
    [[[DBAccountManager sharedManager] linkedAccount] unlink];
    _isLinked = false;
    [self updateDropboxActionButton];
    
}
-(void) stopSharing
{
    [_groceryStore setShareLists:NO];
    
    if (![[HGGSGroceryStoreManager sharedStoreManager] groceryListsAreBeingShared])
    {
        NSString* promptMessage = @"You are not sharing any grocery lists - do you want to disconnect from Dropbox?";
        
        // no stores are sharing their grocery lists - prompt the user if they would like to unlink from dropbox
        if (_unlinkAlertView == nil)
            _unlinkAlertView = [[UIAlertView alloc]
                                            initWithTitle:@"Stop sharing" message:promptMessage delegate:self
                                            cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
        _unlinkAlertView.alertViewStyle = UIAlertViewStyleDefault;
        [_unlinkAlertView show];
        
    }
    [self updateDropboxActionButton];
}
-(void)startSharing
{
    HGGSDbGroceryFilesStore *dbStore = [HGGSDbGroceryFilesStore sharedDbStore];
    [dbStore groceryFilesExistForStore:[_groceryStore name] returnResult:
     ^void(BOOL filesExistInDropbox)
     {
         if (filesExistInDropbox)
             [self presentSynchOptionsToUser:dbStore];
         else
         {
             [_groceryStore setShareLists:YES];
             [self updateDropboxActionButton];
             [dbStore copyToDropbox:[_groceryStore getMasterList]  notifyCopyCompleted:nil];
             [dbStore copyToDropbox:[_groceryStore getGroceryAisles]  notifyCopyCompleted:nil];
             [dbStore copyToDropbox:[_groceryStore getCurrentList]  notifyCopyCompleted:nil];
         }
     }];
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
    
    if (!_isLinked)
        [self linkWithDropbox];
    else if (![_groceryStore shareLists])
        [self startSharing];
    else
        [self stopSharing];
    
    /* only want to allow un-linking if NO stores are shared */
    /*    case notSharing:
     [self unlinkFromDropbox];
     break;
     */
    
}
-(void) presentSynchOptionsToUser:(HGGSDbGroceryFilesStore *)dbStore
{
    
    [self performSegueWithIdentifier:SEGUE_TO_CHOOSE_SYNCH_OPTION sender:self];

    //[self presentViewController:synchController animated:YES completion:nil];
}

-(void)updateDropboxActionButton
{
    NSString *dropboxMessage = LINK_DROPBOX_MESSAGE;
    if ([_groceryStore shareLists])
    {
        dropboxMessage = STOP_SHARING_GROCERY_LISTS;
    }
    else if (_isLinked)
    {
        dropboxMessage = SHARE_GROCERY_LISTS;
    }
    else
    {
        dropboxMessage = LINK_DROPBOX_MESSAGE;
    }
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
    
    DBAccountManager * accountManager = [DBAccountManager sharedManager];
    _isLinked =  (accountManager && [accountManager linkedAccount]);
    
    [self updateDropboxActionButton];
 }
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == _unlinkAlertView)
    {
        if (buttonIndex != alertView.cancelButtonIndex)
            [self unlinkFromDropbox];
    }
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
    NSLog(@"onDeleteStoreConfirmed called");
    [[HGGSGroceryStoreManager sharedStoreManager] deleteStore:[[self groceryStore] name]];
    [[self navigationController] popViewControllerAnimated:YES];

}
@end
