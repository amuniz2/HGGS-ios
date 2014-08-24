//
//  HGGSMasterListViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/9/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSMasterListViewController.h"
#import "HGGSGroceryStore.h"
#import "HGGSMasterItemCellView.h"
#import "HGGSEditGroceryItemViewController.h"
#import "HGGSGroceryStoreManager.h"
#import "HGGSStoreItems.h"

@interface HGGSMasterListViewController ()
{
    NSArray* _searchResults;
    bool _changesToSave;
    HGGSStoreItems* _masterGroceryList;
}

@end

@implementation HGGSMasterListViewController
#pragma mark Initialization
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark Lifecyle
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UINavigationItem *navItem = [self navigationItem];
    
    [navItem setTitle:[NSString stringWithFormat:@"%@ List",[_store name]]];
    _changesToSave = NO;
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroceryItem:)];
    [navItem setRightBarButtonItem:addButton];
    
 }
-(void)dealloc
{
    if (_changesToSave)
    {
        HGGSGroceryStoreManager* storeManager = [HGGSGroceryStoreManager sharedStoreManager];
        [storeManager saveMasterList:[self store]];
        _changesToSave =NO;
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    
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
    if ([segue.identifier isEqualToString:@"toEditGroceryItem"])
    {
        [editItemController setGroceryStore:_store];
        [editItemController setGrocerySections:[_store grocerySections]];
        [editItemController setIsNewItem:_addNewItem];
        if ( _addNewItem)
        {
            groceryItem = [[HGGSGroceryItem alloc] init];
            [editItemController setInEditMode:YES];
            [editItemController setExistingItems:_masterGroceryList];
            _addNewItem = NO;
            [editItemController setGroceryItem:groceryItem];
            
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
                groceryItem = [_masterGroceryList itemAt:[activeTableView indexPathForSelectedRow].row];
        
            [editItemController setGroceryItem:groceryItem];
            [editItemController setItemType:pantryItem];
            
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

#pragma mark UITableViewDataSource Methods
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        _masterGroceryList = [[self store] getMasterList];
        return [_masterGroceryList itemCount];
    }
    if (_searchResults)
        return [_searchResults count];
    
    return 0;
}
#pragma mark UITableViewDelegate Methods

/*-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self searchBar];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return [[self searchBar] bounds].size.height;
}
*/

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //check for cell that can be reused:
    HGGSGroceryItem * groceryItem;
    
    if (tableView == self.tableView)
        groceryItem = [_masterGroceryList itemAt:[indexPath row]];
    else
        groceryItem = [_searchResults objectAtIndex:[indexPath row]];
    
    HGGSMasterItemCellView* cell = [[self tableView] dequeueReusableCellWithIdentifier:@"MasterItemCell"];
    [cell setGroceryItem:groceryItem];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HGGSGroceryItem *itemInRow = [self groceryItemAt:indexPath tableView:tableView];
    
    return [self heightNeededForText:[itemInRow name] font:[UIFont boldSystemFontOfSize:15] widthOfTextField:283 ] +
    [self heightNeededForText:[itemInRow notes] font:[UIFont italicSystemFontOfSize:12] widthOfTextField:283 ] + 8;
    
}


#pragma mark Actions
-(IBAction) addGroceryItem:(id)sender
{
    _addNewItem = YES;
    [self performSegueWithIdentifier:@"toEditGroceryItem" sender:self];

}
#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _searchResults = [_masterGroceryList findItems:searchString];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma mark UISearchBarDelegate Methods
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _searchResults = nil;
}


#pragma mark Private
-(HGGSGroceryItem *)groceryItemAt:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    if (tableView == self.tableView)
        return [_masterGroceryList itemAt:[indexPath row]];
    
    return [_searchResults objectAtIndex:[indexPath row]];
    
}

-(void) handleReturnFromEditItemController:(HGGSEditGroceryItemViewController*) editController
{
    bool itemHasChanged = (editController.actionTaken == saveChanges) || (editController.actionTaken == deleteItem) || (editController.actionTaken == replaceItem);
    _changesToSave = _changesToSave || itemHasChanged;
    
    if (editController.actionTaken == deleteItem)
    {
        [_masterGroceryList remove:[[editController groceryItem] name] ];
    }
    else if (editController.actionTaken == replaceItem)
    {
        [_masterGroceryList remove:[editController originalGroceryItemName]];
        NSInteger lastRow = [_masterGroceryList addItem:[editController groceryItem]];
                                    
        if (lastRow < 0)
        {
            //todo: display alert that item could not be added
            return;
        }
                                    
    }
    if (itemHasChanged)
    {
        UITableView* activeTableView;
        
        activeTableView = (_searchResults) ? [[self searchDisplayController] searchResultsTableView] : [self tableView];
        
        if (_searchResults)
            _searchResults = [_masterGroceryList findItems:[[[self searchDisplayController] searchBar] text]];

        [activeTableView reloadData ];
    }
    
}

-(void) handleReturnFromAddItemController:(HGGSEditGroceryItemViewController*) editController
{

    _changesToSave = _changesToSave || editController.actionTaken == saveChanges ;
    if (editController.actionTaken == saveChanges)
    {
        UITableView* activeTableView;
        /* todo: delete if addItem works after allowing name change
        */
        NSInteger lastRow = [_masterGroceryList addItem:[editController groceryItem]];
        
        if (lastRow < 0)
        {
            //todo: display alert that item could not be added
            return;
        }
        activeTableView = (_searchResults) ? [[self searchDisplayController] searchResultsTableView] : [self tableView];
        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
        
        [activeTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ip ] withRowAnimation:UITableViewRowAnimationTop];
        [activeTableView reloadData ];
    }
    
}
-(int)heightNeededForText:(NSString*)text font:(UIFont *)font widthOfTextField:(int)maxWidth
{
    NSAttributedString * attributedText = [[NSAttributedString alloc] initWithString:text
                                                                          attributes:[[NSDictionary alloc] initWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    CGSize maximumSize = CGSizeMake(maxWidth, CGFLOAT_MAX);
    return [attributedText boundingRectWithSize:maximumSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size.height;
    
}


@end
