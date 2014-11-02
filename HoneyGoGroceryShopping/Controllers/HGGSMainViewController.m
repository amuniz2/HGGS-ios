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

}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self storeSelector] reloadComponent:0];
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
    if ([segue.identifier isEqualToString:@"toEditStore"])
    {
        HGGSEditStoreViewController *editStoreController = segue.destinationViewController;
      
        _keys = nil;
        [editStoreController setGroceryStore:_addNewStore ? [[HGGSGroceryStore alloc] initWithStoreName:@""] : storeSelected];
        [editStoreController setAddStore:_addNewStore];
        _addNewStore = NO;
    }
    else if ([segue.identifier isEqualToString:@"toEditShoppingList"])
    {
        HGGSEditShoppingListViewController *editShoppingListController = segue.destinationViewController;
        [editShoppingListController setStore:storeSelected];
    }
    else if ([segue.identifier isEqualToString:@"toShoppingList"])
    {
        HGGSShoppingListViewController *shoppingListController = segue.destinationViewController;
        [shoppingListController setStore:storeSelected];
    }
    else
        NSLog(@"Seque identifier: %@", segue.identifier);

    
}

#pragma mark Actions
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

@end

