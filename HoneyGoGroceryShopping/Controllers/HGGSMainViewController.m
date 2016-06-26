//
//  HGGSViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/9/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSMainViewController.h"
#import "HGGSEditStoreViewController.h"
#import "HGGSGroceryStoreManager.h"
#import "HGGSGroceryStore.h"
#import "HGGSEditShoppingListViewController.h"
#import "HGGSShoppingListViewController.h"

@interface HGGSMainViewController ()
@end
//todo: NSUserDefaults..
@implementation HGGSMainViewController
{
    bool _startNewShoppingList;
    UIAlertView *_startNewListAlertView;
    HGGSDropboxClient *_dropboxClient;
}

#pragma mark Lifecycle Methods
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Custom initialization
    UINavigationItem *navItem = [self navigationItem];
    
    [navItem setTitle:@"Select Grocery Store"];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editStore:)];
    [navItem setLeftBarButtonItem:editButton];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addStore)];
    [navItem setRightBarButtonItem:addButton];
    _startNewListAlertView = nil;
    
}
-(void)dealloc
{
    _dropboxClient = nil;
     _startNewListAlertView = nil;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self storeSelector] reloadComponent:0];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    HGGSGroceryStore *storeJustEdited = [[HGGSGroceryStoreManager sharedStoreManager] storeBeingWorkedOn];
    [[HGGSGroceryStoreManager sharedStoreManager] setStoreBeingWorkedOn:nil];
    
    if ((storeJustEdited == nil) || (![storeJustEdited shareLists]))
        return;
    
    _dropboxClient = [HGGSDropboxClient CreateFromController:self forStore:storeJustEdited];
    [_dropboxClient setDelegate:self];
    [_dropboxClient setActivityIndicatorCenter:CGPointMake(self.view.center.x, self.view.frame.origin.y + self.view.frame.size.height + 20)];
    [_dropboxClient copyStoreToDropbox];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{

    HGGSGroceryStoreManager *storeManager = [HGGSGroceryStoreManager sharedStoreManager];
    HGGSGroceryStore *storeSelected = [[storeManager allStores] objectForKey:[_keys objectAtIndex:[_storeSelector selectedRowInComponent:0]]];
    
    [storeManager prepareStore:storeSelected];
    [storeManager setStoreBeingWorkedOn:storeSelected];
    if ([segue.identifier isEqualToString:@"toEditStore"])
    {
        HGGSEditStoreViewController *editStoreController = segue.destinationViewController;
      
        _keys = nil;
//        [storeManager setStoreBeingWorkedOn:storeSelected];
        [editStoreController setGroceryStore:_addNewStore ? [[HGGSGroceryStore alloc] initWithStoreName:@""] : storeSelected];
        [editStoreController setAddStore:_addNewStore];
        _addNewStore = NO;
    }
    else if ([segue.identifier isEqualToString:@"toEditShoppingList"])
    {
        HGGSEditShoppingListViewController *editShoppingListController = segue.destinationViewController;
        
        //TODO: Ask user if new list should be started.
        [editShoppingListController setStartNewList:_startNewShoppingList];
        [editShoppingListController setStore:storeSelected];
        [storeManager setStoreBeingWorkedOn:storeSelected];
    }
    else if ([segue.identifier isEqualToString:@"toShoppingList"])
    {
        HGGSShoppingListViewController *shoppingListController = segue.destinationViewController;
        //todo: how to decide whether to reset list
        [shoppingListController setStartNewShoppingList:NO];
        [shoppingListController setStore:storeSelected];
    }
    else
        NSLog(@"Seque identifier: %@", segue.identifier);

    
}
#pragma mart Alert Boxes
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (alertView == _startNewListAlertView)
    {
        _startNewShoppingList =(buttonIndex != alertView.cancelButtonIndex);
        [self performSegueWithIdentifier:@"toEditShoppingList" sender:self];
    }
}

#pragma mark Actions
-(IBAction)promptIfNewListShouldBeStarted:(id)sender
{
    HGGSGroceryStoreManager *storeManager = [HGGSGroceryStoreManager sharedStoreManager];
    HGGSGroceryStore *storeSelected = [[storeManager allStores] objectForKey:[_keys objectAtIndex:[_storeSelector selectedRowInComponent:0]]];
    
    NSString* promptMessage = [NSString stringWithFormat:@"Start a new shopping list for %@?", [storeSelected name]];
    
    
    NSString *alertTitle = @"Prepare Shopping List";
    NSString *alertOkButtonText = @"Yes";
    NSString *alertNoButtonText = @"No";
    
    if ([UIAlertController class] == nil) { //[UIAlertController class] returns nil on iOS 7 and older. You can use whatever method you want to check that the system version is iOS 8+
        if (_startNewListAlertView == nil)
        {
            _startNewListAlertView = [[UIAlertView alloc]
                                      initWithTitle:alertTitle message:promptMessage delegate:self
                                      cancelButtonTitle:alertNoButtonText otherButtonTitles:alertOkButtonText, nil];
            _startNewListAlertView.alertViewStyle = UIAlertViewStyleDefault;
            
        }
        [_startNewListAlertView show];
    }
    else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                                 message:promptMessage
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        //We add buttons to the alert controller by creating UIAlertActions:
        UIAlertAction *actionYes = [UIAlertAction actionWithTitle:alertOkButtonText
                                                           style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action){
                                                              _startNewShoppingList = YES;
                                                              [self performSegueWithIdentifier:@"toEditShoppingList" sender:self];
                                                          }]; //You can use a block here to handle a press on this button
        UIAlertAction *actionNo = [UIAlertAction actionWithTitle:alertNoButtonText
                                                            style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             _startNewShoppingList = NO;
                                                             [self performSegueWithIdentifier:@"toEditShoppingList" sender:self];
                                                         }]; //You can use a block here to handle a press on this button
        [alertController addAction:actionYes];
        [alertController addAction:actionNo];
        
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
}
-(IBAction)editStore:(id)sender
{
    // load master list view controller and display the view
    // note: in the future we will only do this if the user clicks "Edit" on the item selected in the store picker
    //HGGSGroceryStore *store = [[[HGGSGroceryStoreManager sharedStoreManager]allStores] objectForKey:[_keys objectAtIndex:[_storeSelector selectedRowInComponent:0]]];
    _addNewStore = NO;
    [self performSegueWithIdentifier:@"toEditStore" sender:self];
}

-(void)addStore
{
    //HGGSGroceryStore* newStore = [[HGGSGroceryStore alloc] init];
    _addNewStore = YES;
    [self performSegueWithIdentifier:@"toEditStore" sender:self];

}

#pragma mark UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark UIPickerViewDataSource
// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[[HGGSGroceryStoreManager sharedStoreManager] allStores] count];
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSDictionary *stores = [[HGGSGroceryStoreManager sharedStoreManager] allStores];
    if (!_keys)
    {
        _keys = [[stores allKeys] sortedArrayUsingComparator:^(id a, id b) {
            return [a compare:b];
        } ];
    }
    
    return [[stores objectForKey:[_keys objectAtIndex:row]] name];
}
#pragma mark HGGSDropboxControllerDelegate methods
-(void)synchActivityCompleted:(BOOL) succeeded error:(NSString*)errorMessage
{
    if (!succeeded)
    {
        [self displayDropboxError:errorMessage];
    }
    [_dropboxClient setDelegate:nil];
}
#pragma  mark  Private
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

@end

