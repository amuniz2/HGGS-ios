//
//  HGGSSelectGrocerySectionViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 1/19/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import "HGGSSelectGrocerySectionViewController.h"
#import "HGGSGrocerySection.h"
#import "HGGSStoreAisles.h"
#import "HGGSGroceryAisle.h"
#import "HGGSGroceryStore.h"
#import "HGGSNewGrocerySectionViewController.h"
#import "HGGSAisleHeaderCellView.h"
#import "NSString+SringExtensions.h"

@interface HGGSSelectGrocerySectionViewController () <UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, /*UITableViewDelegate,*/ HGGSGroceryStoreDelegate>
{
    NSString *_filter;
    NSInteger _aisleNumberToAddSectionTo;
    NSMutableArray *_aisles;
    NSMutableArray *_aislesDisplayed;
}
@end

@implementation HGGSSelectGrocerySectionViewController

#pragma mark Lifecycle
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

    [[self navigationItem] setTitle:@"Select Grocery Section"];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];

    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;

    [[_groceryAisles store] setDelegate:self];
   
    [self prepareList:YES];
    self.searchController.searchBar.delegate = self;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //[_tableView reloadData];
    
}
-(bool)sectionIsVisible:(HGGSGrocerySection *)section
{
    for (HGGSGroceryAisle * aisle in _aislesDisplayed)
    {
        if ([[aisle grocerySections] containsObject:section])
             return YES;
    }
    return NO;
}
#pragma mark Navigation
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"toNewGrocerySection"])
    {
        HGGSNewGrocerySectionViewController *newSectionController = segue.destinationViewController;
        [newSectionController setAisleNumber:_aisleNumberToAddSectionTo];
        
        __weak HGGSNewGrocerySectionViewController *weakRefToController = newSectionController;
        
        [newSectionController setDismissBlock:^{
            [self handleReturnFromAddGrocerySectionController:weakRefToController];
        }];
        
        
    }
}
#pragma mark Actions
-(IBAction)addNewSection:(id)sender
{
    UIButton* buttonSendingMessage = sender;
    _aisleNumberToAddSectionTo = [buttonSendingMessage tag];
}

#pragma mark Property Overrides
-(NSString*)selectedSectionName
{
    return [[self selectedSection] name];
}
-(void)setSelectedSectionName:(NSString*) selectedSectionName
{
    if ((selectedSectionName == nil) || ([selectedSectionName length] == 0))
    {
        [self setSelectedSectionName:DEFAULT_GROCERY_SECTION_NAME];
        return;
    }
    
    HGGSGrocerySection *section = [_groceryAisles  findGrocerySection:selectedSectionName];

    
    if (section == nil)
    {
        // creae the grocery section in unknown aisle
        section = [[HGGSGrocerySection alloc] init];
        [section setName:selectedSectionName];
        [section setAisle:0];
        HGGSGroceryAisle * unknownAisle = [[self groceryAisles] itemAt:0];
        [[unknownAisle grocerySections] addObject:section];
        [_groceryAisles save];
    }
    
    [self setSelectedSection:section];
    


}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [_aislesDisplayed count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    HGGSGroceryAisle * aisle = [_aislesDisplayed objectAtIndex:section];
    
    return [[aisle grocerySections] count];

}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *aisleHeaderCellIdentifier = @"AisleHeaderCell";
    
    HGGSGroceryAisle *aisle = [_aislesDisplayed objectAtIndex:section];
    HGGSAisleHeaderCellView *cell = [[self tableView] dequeueReusableCellWithIdentifier:aisleHeaderCellIdentifier];
        
    [cell setAisleNumber:[aisle number]];
        
    return cell.contentView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SectionCell";
    UITableViewCell *cell =[self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    HGGSGrocerySection* section = [self grocerySectionAt:indexPath];
 
    // Configure the cell...
    [[cell textLabel] setText:[section name]];
    if ([[section name] isEqualToString:[_selectedSection name]])
    {
        //[tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionMiddle];
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    }
    return cell;
}
#pragma mark UITableViewDelegate
-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // set selectedGrocerySection and return
    [self setSelectedSection:[self grocerySectionAt:indexPath] ];
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 46;
}

-(void)tableView:(UITableView *)tableView didEndDisplayingFooterView:(nonnull UIView *)view forSection:(NSInteger)section
{
    if ([self sectionIsVisible:[self selectedSection]])
    {
        [[self tableView] scrollToRowAtIndexPath:[self indexPathOfGrocerySection:[self selectedSection]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
}

#pragma mark UISearchBarDelegate
//- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
//{
//    //?
//    [self exitSearchMode];
//    
//}

- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    //[self endEditingOfCell];
    [self exitSearchMode];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self exitSearchMode];
}

//- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
//{
//    [self findGrocerySections:[searchBar text] ];
//}

#pragma mark UISearchResultsUpdatingDelegate Methods
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    _filter = searchController.searchBar.text;
    [self prepareList:NO];
    [self.tableView reloadData];
}

#pragma mark HGGSGroceryStoreDelegate
-(void)didHaveAisleChange:(HGGSGrocerySection*)section fromAisle:(HGGSGroceryAisle*)fromAisle toAisle:(HGGSGroceryAisle*)toAisle
{
    [self prepareList:YES];
    [self.tableView reloadData];
}
-(void)didRemoveGroceryAisle:(HGGSGroceryAisle*)aisle
{
    
    [self prepareList:NO];
    [self.tableView reloadData];
}


#pragma mark Private
-(UITableView *)activeTableView
{
    return [self tableView];
}

//-(void)findGrocerySections:(NSString*)stringToSearchFor
//{
//    //todo:implement
//    _searchResults = [_groceryAisles findItems:stringToSearchFor];
//    
//}

-(HGGSGrocerySection*) grocerySectionAt:(NSIndexPath *)indexPath
{

    HGGSGroceryAisle *aisle = [_aislesDisplayed objectAtIndex:[indexPath section]];
        return [[aisle grocerySections] objectAtIndex:[indexPath row]];
        //return [_sectionsDisplayed objectAtIndex:[indexPath row]];
}
-(NSIndexPath *) indexPathOfGrocerySection:(HGGSGrocerySection *)section
{
    HGGSGroceryAisle *aisle = [_groceryAisles findAisleForGrocerySection:section];
    NSInteger  sectionIndex = [_aislesDisplayed indexOfObject:aisle];
    NSIndexPath * ip =  [NSIndexPath indexPathForRow:[[aisle grocerySections] indexOfObject:section]  inSection:sectionIndex];
    
    return ip;
    
}

-(void) handleReturnFromAddGrocerySectionController:(HGGSNewGrocerySectionViewController*)addSectionController
{
    
    if (addSectionController.actionTaken == saveChanges)
    {        
        HGGSGrocerySection * newSection = [_groceryAisles insertNewGrocerySection:[addSectionController sectionName] inAisle:[addSectionController aisleNumber] atSectionIndex:0];
        [self setSelectedSection:newSection];
        
        //need to save aisles information, since a new section has been added
        [_groceryAisles save];
        [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
        
    }
}

-(void)exitSearchMode
{
    _filter = nil;
    [self prepareList:NO];
    [self.tableView reloadData];
}

-(void) prepareList:(bool)reloadAisles
{
    if (_aisles == nil)
        self.tableView.tableHeaderView = self.searchController.searchBar;
    if (_aisles == nil || reloadAisles)
    {
        _aisles = [[NSMutableArray alloc] init];
        [_aisles addObjectsFromArray:[_groceryAisles list]];
    }
    if ([NSString isEmptyOrNil:_filter])
        _aislesDisplayed = _aisles;
    else
    {
        _aislesDisplayed = [_groceryAisles findItems:_filter];
    }
}

@end
