//
//  HGGSEditShoppingListViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/2/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSEditShoppingListViewController.h"
#import "HGGSGroceryStoreManager.h"
#import "HGGSGroceryStore.h"
#import "HGGSShoppingItemCellView.h"
#import "HGGSStoreItems.h"
#import "HGGSEditGroceryItemViewController.h"

@interface HGGSEditShoppingListViewController () 
{
    NSArray* _searchResults;
    bool _changesToSave;
    bool _addNewItem;
    HGGSStoreItems* _currentGroceryList;
    
}
@end

@implementation HGGSEditShoppingListViewController

#pragma mark Lifecycle Methods
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    UINavigationItem *navItem = [self navigationItem];
    
    [navItem setTitle:[NSString stringWithFormat:@"%@ List",[_store name]]];
    _changesToSave = NO;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroceryItem:)];
    [navItem setRightBarButtonItem:addButton];
    
//    [[self tableView] setEditing:YES];
    
    //[[self store] loadList:CURRENT_LIST];
    if ([_store shoppingListIsMoreRecentThanCurrentList] )
    {
        [_store createCurrentList];
        _changesToSave = YES;
    }

    _currentGroceryList = [_store getCurrentList];


}
-(void)dealloc
{
    if (_changesToSave)
    {
        HGGSGroceryStoreManager* storeManager = [HGGSGroceryStoreManager sharedStoreManager];
        [storeManager saveCurrentList:[self store]];
      
        _changesToSave = NO;
        
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self saveChangedCellsStillDisplayed:[self activeTableView]];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    HGGSGroceryItem *groceryItem;
    HGGSEditGroceryItemViewController *editItemController = segue.destinationViewController;
    UITableView* activeTableView;
    
    activeTableView = (_searchResults) ? [[self searchDisplayController] searchResultsTableView] : [self tableView];
    if ([segue.identifier isEqualToString:@"toEditShoppingItem"])
    {
        [editItemController setGroceryStore:_store];
        [editItemController setGrocerySections:[_store grocerySections]];
        [editItemController setExistingItems:_currentGroceryList];

        [editItemController setIsNewItem:_addNewItem];
        if ( _addNewItem)
        {
            groceryItem = [[HGGSGroceryItem alloc] init];
            [editItemController setInEditMode:YES];
            _addNewItem = NO;
            [editItemController setGroceryItem:groceryItem];
            [editItemController setItemType:newShoppingItem];
            
            __weak HGGSEditGroceryItemViewController *weakRefToController = editItemController;
            
            [editItemController setDismissBlock:^{
                [self handleReturnFromAddItemController:weakRefToController];
            }];
        }
        else
        {
            if (_searchResults)
                groceryItem = [_searchResults objectAtIndex:[activeTableView indexPathForSelectedRow].row];
            else
                groceryItem = [_currentGroceryList itemAt:[activeTableView indexPathForSelectedRow].row];
            
            [editItemController setGroceryItem:groceryItem];
            [editItemController setItemType:shoppingItem];
            
            __weak HGGSEditGroceryItemViewController *weakRefToController = editItemController;
            
            [editItemController setDismissBlock:^{
                [self handleReturnFromEditItemController:weakRefToController];
            }];
        }
    }
    else
    {
        NSLog(@"Unrecognized seque identifier: %@", segue.identifier);
    }
    
}


#pragma mark Actions
-(IBAction) addGroceryItem:(id)sender
{
    _addNewItem = YES;
    [self performSegueWithIdentifier:@"toEditShoppingItem" sender:self];
    
}
#pragma mark UITableViewDataSource Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView)
    {
        return [_currentGroceryList itemCount];
    }
    if (_searchResults)
        return [_searchResults count];
    
    return 0;
}
#pragma mark UITableViewDelegate Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HGGSGroceryItem * groceryItem;
    
    if (tableView == self.tableView)
        groceryItem = [_currentGroceryList itemAt:[indexPath row]];
    else
        groceryItem = [_searchResults objectAtIndex:[indexPath row]];
    
    HGGSShoppingItemCellView* cell = [[self tableView] dequeueReusableCellWithIdentifier:@"CurrentItemCell"];
    
    [cell setGroceryItem:groceryItem];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //if (tableView != [self tableView])
    //    return;
    
    bool thisCellsItemWasChangedByUser = [(HGGSShoppingItemCellView*)cell saveValuesEnteredByUser];
    _changesToSave = _changesToSave || thisCellsItemWasChangedByUser ;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 83;
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}


#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _searchResults = [_currentGroceryList findItems:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma mark UISearchBarDelegate Methods
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    _searchResults = [_currentGroceryList findItems:[searchBar text]];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self saveChangedCellsStillDisplayed:[[self searchDisplayController] searchResultsTableView]];
    _searchResults = nil;
}

- (IBAction)setQuantity:(id)sender {
}

#pragma mark Private
-(void) handleReturnFromEditItemController:(HGGSEditGroceryItemViewController*) editController
{
    
    _changesToSave = _changesToSave || editController.actionTaken == saveChanges || editController.actionTaken == deleteItem || editController.actionTaken == replaceItem;
    if (editController.actionTaken == deleteItem)
    {
        [_currentGroceryList remove:[[editController groceryItem] name] ];
    }
    else if (editController.actionTaken == replaceItem)
    {
        [_currentGroceryList remove:[editController originalGroceryItemName] ];
        NSInteger lastRow = [_currentGroceryList addItem:[editController groceryItem]];
        if (lastRow < 0)
        {
            //todo: display alert that item could not be added
            return;
        }

    }
    if (_changesToSave)
    {
        UITableView* activeTableView;
        
        activeTableView = (_searchResults) ? [[self searchDisplayController] searchResultsTableView] : [self tableView];
        
        if (_searchResults)
            _searchResults = [_currentGroceryList findItems:[[[self searchDisplayController] searchBar] text]];
        
        [activeTableView reloadData ];
    }
    
}
-(void) handleReturnFromAddItemController:(HGGSEditGroceryItemViewController*) editController
{
    
    _changesToSave = _changesToSave || editController.actionTaken == saveChanges ;
    if (editController.actionTaken == saveChanges)
    {
        UITableView* activeTableView;
        bool addToMaster = [[editController groceryItem] selected];
        
        [[editController groceryItem] setSelected:YES];
        NSInteger lastRow = [_currentGroceryList addItem:[editController groceryItem]];
        if (lastRow < 0)
        {
            //todo: display alert that item could not be added
            return;
        }
        
        activeTableView = (_searchResults) ? [[self searchDisplayController] searchResultsTableView] : [self tableView];
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
        
        [activeTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ip ] withRowAnimation:UITableViewRowAnimationTop];
        [activeTableView reloadData ];
    
        if (addToMaster)
        {
            // todo: when adding an item to the current list, the 'selected' switch indicates that the items should be added
            // tot the master list as well
            
            HGGSStoreList *masterList = [_store getMasterList];
            [masterList addItem:[editController groceryItem]];
            [[HGGSGroceryStoreManager sharedStoreManager] saveMasterList:[self store]];
        }
    }
    
}
-(void) saveChangedCellsStillDisplayed:(UITableView *)tv
{
    bool thisItemWasChangedByUser ;
    for (HGGSShoppingItemCellView *cell in [tv visibleCells])
    {
        thisItemWasChangedByUser = [cell saveValuesEnteredByUser];
        _changesToSave = _changesToSave || thisItemWasChangedByUser;
    }
}

-(UITableView*)activeTableView
{
    return (_searchResults == nil) ? [self tableView] : [[self searchDisplayController] searchResultsTableView];
}


@end
