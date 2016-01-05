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
    //NSArray* _searchResults;
    bool _changesToSave;
    HGGSStoreItems* _masterGroceryList;
    NSArray* _listItems;
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

    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
//    self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"ScopeButtonCountry",@"Item"),
//                                                          NSLocalizedString(@"ScopeButtonCapital",@"Section")];
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
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
    
    if (_changesToSave)
    {
        HGGSGroceryStoreManager* storeManager = [HGGSGroceryStoreManager sharedStoreManager];
        [storeManager saveMasterList:[self store]];
        _changesToSave =NO;
    }
    [super viewWillDisappear:animated];
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


    activeTableView = [self tableView];
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
//            if (_searchResults)
//                groceryItem = [_listItems objectAtIndex:[activeTableView indexPathForSelectedRow].row];
//            else
                groceryItem = [_listItems objectAtIndex:[activeTableView indexPathForSelectedRow].row];
        
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
    if (_masterGroceryList == nil) {
        _masterGroceryList = [[self store] getMasterList];
        _listItems = [_masterGroceryList list];
    }
    return [_listItems count];
}

-(NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(nonnull NSString *)title atIndex:(NSInteger)index
{
    
    CGRect searchBarFrame = self.searchController.searchBar.frame;
    [self.tableView scrollRectToVisible:searchBarFrame animated:NO];
    return NSNotFound;
}
#pragma mark UITableViewDelegate Methods

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //check for cell that can be reused:
    HGGSGroceryItem * groceryItem = [_listItems objectAtIndex:[indexPath row]];
    
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
//#pragma mark - UISearchController Delegate Methods

//- (BOOL)searchDisplayController:(UISearchController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//    _searchResults = [_masterGroceryList findItems:searchString];
//    
//    // Return YES to cause the search result table view to be reloaded.
//    return YES;
//}


#pragma mark UISearchBarDelegate Methods
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    _listItems = [_masterGroceryList list];
    [self.tableView reloadData];
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

#pragma mark UISearchResultsUpdatingDelegate Methods
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    //[self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self searchForText:searchString];
    [self.tableView reloadData];
}

#pragma mark Private
- (void)searchForText:(NSString *)searchText
{
    _listItems = [_masterGroceryList findItems:searchText];
    
}

-(HGGSGroceryItem *)groceryItemAt:(NSIndexPath *)indexPath tableView:(UITableView *)tableView
{
    return [_listItems objectAtIndex:[indexPath row]];
    
}

-(void) handleReturnFromEditItemController:(HGGSEditGroceryItemViewController*) editController
{
    bool itemHasChanged = (editController.actionTaken == saveChanges) || (editController.actionTaken == deleteItem) || (editController.actionTaken == replaceItem);
    _changesToSave = _changesToSave || itemHasChanged;

    
    if (editController.actionTaken == deleteItem)
    {
        [_masterGroceryList remove:[[editController groceryItem] name] ];
        _listItems = [_masterGroceryList list];
    }
    else if (editController.actionTaken == replaceItem)
    {
        [_masterGroceryList remove:[editController originalGroceryItemName]];
        [_masterGroceryList addItem:[editController groceryItem]];
        _listItems = [_masterGroceryList list];        
    }
    if (itemHasChanged)
    {
        UITableView* activeTableView = [self tableView];
        [activeTableView reloadData ];
    }
    
}

-(void) handleReturnFromAddItemController:(HGGSEditGroceryItemViewController*) editController
{

    _changesToSave = _changesToSave || editController.actionTaken == saveChanges ;
    if (editController.actionTaken == saveChanges)
    {
        /* todo: delete if addItem works after allowing name change
        */
        NSInteger lastRow = [_masterGroceryList addItem:[editController groceryItem]];
        
        if (lastRow < 0)
        {
            //todo: display alert that item could not be added
            return;
        }
        _listItems = [_masterGroceryList list];
//        NSIndexPath *ip = [NSIndexPath indexPathForRow:lastRow inSection:0];
//        
//        [[self tableView] insertRowsAtIndexPaths:[NSArray arrayWithObject:ip ] withRowAnimation:UITableViewRowAnimationTop];
        
        // filter...
        [[self tableView] reloadData ];
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
