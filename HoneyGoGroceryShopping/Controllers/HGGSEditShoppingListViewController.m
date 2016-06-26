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
#import "NSString+SringExtensions.h"
#import "HGGSDropboxClient.h"

@interface HGGSEditShoppingListViewController () 
{
    bool _changesToSave;
    bool _addNewItem;
    
    NSMutableArray * _itemsDisplayed;
    NSMutableArray * _currentItems;
    HGGSStoreItems* _groceryList;
    NSString *_filter;
    HGGSDropboxClient *_dropboxClient;
    
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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([_store shareLists])
        [_dropboxClient copyListFromDropbox];
    
    
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
    
    if ([self startNewList] )
    {
        [_store resetCurrentList];
        _changesToSave = YES;
    }
    _groceryList = [_store getGroceryList];

    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
    [self prepareList];
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
    
    if (![[self store] shareLists])
        return;
    
    _dropboxClient = [HGGSDropboxClient CreateFromController:self forStore:_store];
    [_dropboxClient setDelegate:self];
    [_dropboxClient setActivityIndicatorCenter:CGPointMake(self.view.center.x, self.view.frame.origin.y + self.view.frame.size.height + 20)];

}
//-(void)dealloc
//{
//    if (_changesToSave)
//    {
//        HGGSGroceryStoreManager* storeManager = [HGGSGroceryStoreManager sharedStoreManager];
//        [storeManager saveGroceryList:[self store]];
//         
//        _changesToSave = NO;
//        
//    }
//}

-(void)viewWillDisappear:(BOOL)animated
{
    [self saveChangedCellsStillDisplayed:[self tableView]];

    if (_changesToSave)
    {
        HGGSGroceryStoreManager* storeManager = [HGGSGroceryStoreManager sharedStoreManager];
        [storeManager saveGroceryList:[self store]];
        
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
    if ([segue.identifier isEqualToString:@"toEditShoppingItem"])
    {
        [editItemController setGroceryStore:_store];
        [editItemController setGrocerySections:[_store grocerySections]];
        [editItemController setExistingItems:_groceryList];

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
            groceryItem = [_itemsDisplayed objectAtIndex:[activeTableView indexPathForSelectedRow].row];
            
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
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_itemsDisplayed count];
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
    HGGSGroceryItem * groceryItem = [_itemsDisplayed objectAtIndex:[indexPath row]];
    
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
    // 2 + ? + 2 + 29 + 4 = 37 + ?
    // minimum = 2 + 31 + 2 + 29 + 2 = 68
    
    HGGSGroceryItem *itemInRow = [self groceryItemAtIndexPath:indexPath];
    
    return MAX([self heightNeededForText:[itemInRow name] font:[UIFont boldSystemFontOfSize:15] ], 31) +
    37;
    
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

#pragma mark UISearchBarDelegate Methods
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    //[_pantryItems removeAllObjects]; //forces reload of all
    _filter = nil;
    [self prepareList];
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

    [self searchForText:searchString];
    [self.tableView reloadData];
}


#pragma mark Actions
- (IBAction)setQuantity:(id)sender {
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

#pragma mark Private

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

- (void)searchForText:(NSString *)searchText
{
    _filter = searchText;
    [self prepareList];
    
}

-(void) handleReturnFromEditItemController:(HGGSEditGroceryItemViewController*) editController
{
    bool itemHasChanged = (editController.actionTaken == saveChanges) || (editController.actionTaken == deleteItem) || (editController.actionTaken == replaceItem);
    _changesToSave = _changesToSave || itemHasChanged;
    
    if (editController.actionTaken == deleteItem)
    {
        [_groceryList remove:[[editController groceryItem] name] ];
        [_currentItems removeObject:[editController groceryItem]  ];
        [self prepareList];
    }
    else if (editController.actionTaken == replaceItem)
    {
        HGGSGroceryItem *originalItem = [_groceryList itemWithKey:[editController originalGroceryItemName]];
        
        [_groceryList remove:[editController originalGroceryItemName] ];
        [_currentItems removeObject:originalItem];
        
        [_groceryList addItem:[editController groceryItem]];
        [_currentItems addObject:[editController groceryItem]];
        [self prepareList];
    }
    if (itemHasChanged)
    {
        UITableView* activeTableView = [self tableView];
        [activeTableView reloadData ];
    }
    
}
//-(void)updateItemInMasterListIfInformationWasAdded:(HGGSGroceryItem *)item
//{
//    HGGSStoreList *masterList = [_store getMasterList];
//    HGGSGroceryItem * masterItem = [masterList itemWithKey:[item name]];
//    bool save = NO;
//    if (([masterItem imageName] == nil) && ([item imageName] != nil))
//    {
//        [masterItem setImageName:[item imageName]];
//        save = YES;
//    }
//    if (([masterItem notes] == nil) && ([item notes] != nil))
//    {
//        [masterItem setNotes:[item notes]];
//        save = YES;
//    }
//    if (([masterItem section] == nil) && ([item section] != nil))
//    {
//        [masterItem setSection:[item section]];
//        save = YES;
//    }
//    
//    [[HGGSGroceryStoreManager sharedStoreManager] saveMasterList:[self store]];
//    
//}
-(void) handleReturnFromAddItemController:(HGGSEditGroceryItemViewController*) editController
{
    
    _changesToSave = _changesToSave || (editController.actionTaken == saveChanges );
    if (editController.actionTaken == saveChanges)
    {
        UITableView* activeTableView = [self tableView];
        bool addToMaster = [[editController groceryItem] isPantryItem];
        
        [[editController groceryItem] setIncludeInShoppingList:YES];
        [_groceryList addItem:[editController groceryItem]];
        [_currentItems addObject:[editController groceryItem]];
        
     
        if (addToMaster)
        {
            // todo: when adding an item to the current list, the 'selected' switch indicates that the items should be added
            // tot the master list as well
            [[editController groceryItem] setIsPantryItem:YES];
        }
        [self prepareList];
        [activeTableView reloadData ];
       _changesToSave = YES;
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

-(int)heightNeededForText:(NSString*)text font:(UIFont *)font
{
    NSAttributedString * attributedText = [[NSAttributedString alloc] initWithString:text
                                                                          attributes:[[NSDictionary alloc] initWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    CGSize maximumSize = CGSizeMake(210, CGFLOAT_MAX);
    return [attributedText boundingRectWithSize:maximumSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size.height;
    
}

-(HGGSGroceryItem*) groceryItemAtIndexPath:(NSIndexPath*) indexPath
{
    return [_itemsDisplayed objectAtIndex:[indexPath row]];
    
}

-(void) prepareList
{
    if (_currentItems == nil)
    {
        self.tableView.tableHeaderView = self.searchController.searchBar;
        _currentItems = [[NSMutableArray alloc] init];
 
        for (HGGSGroceryItem *item in [_groceryList list])
        {
            [_currentItems addObject:item];
        }
    }
    NSString * upperCaseFilter = _filter;
    
    if ([NSString isEmptyOrNil:_filter])
        _itemsDisplayed = _currentItems;
        
    else
    {
        upperCaseFilter = [_filter uppercaseString];
        _itemsDisplayed = [[NSMutableArray alloc] init];
        for (HGGSGroceryItem *item in _currentItems)
        {
            if ([NSString isEmptyOrNil:upperCaseFilter] || [[item.name uppercaseString] containsString:upperCaseFilter] ||[[item.notes uppercaseString] containsString:upperCaseFilter])
                [_itemsDisplayed addObject:item];
        }
    }
}

@end
