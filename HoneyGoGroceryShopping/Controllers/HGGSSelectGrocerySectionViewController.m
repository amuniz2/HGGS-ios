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
#import "HGGSNewGrocerySectionViewController.h"
#import "HGGSAisleHeaderCellView.h"

@interface HGGSSelectGrocerySectionViewController () <UISearchBarDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSMutableArray* _searchResults;
    NSInteger _aisleNumberToAddSectionTo;
}
@end

@implementation HGGSSelectGrocerySectionViewController

#pragma mark Lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    _searchResults = nil;
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
    [_tableView setDelegate:self];
    [_tableView setDataSource:self];
    [_searchBar setDelegate:self];
    [[self navigationItem] setTitle:@"Select Grocery Section"];
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
    
    [_tableView scrollToRowAtIndexPath:[self indexPathOfGrocerySection:[self selectedSection]] atScrollPosition:UITableViewScrollPositionTop animated:YES];
    
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
    if (tableView == self.tableView)
        return [_groceryAisles itemCount];
    
    return [_searchResults count];
    
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    HGGSGroceryAisle * aisle;
    if (tableView == self.tableView)
        aisle = [_groceryAisles itemAt:section];
    else
        aisle = [_searchResults objectAtIndex:section];
    
    return [[aisle grocerySections] count];

}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *aisleHeaderCellIdentifier = @"AisleHeaderCell";
    HGGSGroceryAisle *aisle;
    HGGSAisleHeaderCellView *cell;
    
    if (tableView == self.tableView)
    {
        aisle = [_groceryAisles itemAt:section];
        cell = [tableView dequeueReusableCellWithIdentifier:aisleHeaderCellIdentifier];
    }
    else
    {
        aisle = [_searchResults objectAtIndex:section];
        cell= [[self tableView] dequeueReusableCellWithIdentifier:aisleHeaderCellIdentifier];
        
    }
    [cell setAisleNumber:[aisle number]];
        
    return cell.contentView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SectionCell";
    UITableViewCell *cell;
    
    if (tableView == self.tableView)
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    else
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
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

#pragma mark UISearchBarDelegate
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    [self exitSearchMode];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self exitSearchMode];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self findGrocerySections:[searchBar text] ];
}

#pragma mark Private
-(UITableView *)activeTableView
{
    return (_searchResults) ? [[self searchDisplayController] searchResultsTableView] : [self tableView];
}
-(void)exitSearchMode
{
    [_searchResults removeAllObjects];
    _searchResults = nil;
    //[_sectionsDisplayed addObjectsFromArray:_grocerySections];
    [[self tableView] reloadData];
}

/*
 -(void)findGrocerySections:(NSString*)stringToSearchFor
{
    [_sectionsDisplayed removeAllObjects];
    
    NSRange locationOfString;
    
    for (HGGSGrocerySection* section in _grocerySections)
    {
        locationOfString =[[section name] rangeOfString:stringToSearchFor options:NSCaseInsensitiveSearch];
        if (locationOfString.location != NSNotFound)
        {
            [_sectionsDisplayed addObject:section];
        }
    }
    [self.searchDisplayController.searchResultsTableView reloadData];
 
}
 */
-(void)findGrocerySections:(NSString*)stringToSearchFor
{
    //todo:implement
    _searchResults = [_groceryAisles findItems:stringToSearchFor];
    
}

-(HGGSGrocerySection*) grocerySectionAt:(NSIndexPath *)indexPath
{
    @try
    {
        HGGSGroceryAisle *aisle = [_groceryAisles itemAt:[indexPath section]];
        return [[aisle grocerySections] objectAtIndex:[indexPath row]];
        //return [_sectionsDisplayed objectAtIndex:[indexPath row]];
    }
    @catch (NSException *ex) {
        NSLog(@"Exception getting section at: %@", indexPath);
    }
}
-(NSIndexPath *) indexPathOfGrocerySection:(HGGSGrocerySection *)section
{
    NSInteger sectionIndex;
    HGGSGroceryAisle *aisle = [_groceryAisles findAisleForGrocerySection:section];
    if (_searchResults == nil)
    {
        sectionIndex = [[_groceryAisles list] indexOfObject:aisle];
    }
    else
    {
        for (HGGSGroceryAisle *aisle in _searchResults)
        {
            sectionIndex = [[aisle grocerySections] indexOfObject:section];
            if (sectionIndex != NSNotFound)
                break;
        }
        
        sectionIndex = [_searchResults indexOfObject:aisle];
    }
    return [NSIndexPath indexPathForRow:[[aisle grocerySections] indexOfObject:section]  inSection:sectionIndex];
    
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

@end
