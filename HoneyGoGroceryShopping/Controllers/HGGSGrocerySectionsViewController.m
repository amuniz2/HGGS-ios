//
//  HGGSGrocerySectionsViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/16/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSGrocerySectionsViewController.h"
#import "HGGSGroceryStore.h"
#import "HGGSCommon.h"
#import "HGGSGroceryAisle.h"
#import "HGGSGrocerySection.h"
#import "HGGSGroceryStoreManager.h"
#import "HGGSStoreAisles.h"

#define EDIT_CELL_ID  @"EditGrocerySectionCell"

@interface HGGSGrocerySectionsViewController  ()<UISearchBarDelegate, UISearchDisplayDelegate, HGGSGroceryStoreDelegate>
{
    NSArray* _searchResults;
    HGGSGrocerySection *_currentGrocerySection;
    NSIndexPath *_ipBeingEdited;
    UITableViewCell *_cellBeingEdited;
    bool _editIsDeleting;
    bool _changesToSave;

}

@end

@implementation HGGSGrocerySectionsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
#pragma mark View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    //self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;

    //UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGrocerySection:)];
    //self.navigationItem.rightBarButtonItem = addButtonItem;
    
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ Aisles",[_store name]]];
    
    //[[self store] loadList:AISLE_CONFIG];
    [[self store] setDelegate:self];

    self.editing = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated
{
    if (_changesToSave)
    {
        
        HGGSGroceryStoreManager* storeManager = [HGGSGroceryStoreManager sharedStoreManager];
        [storeManager saveGroceryAisles:_store ];
        _changesToSave =NO;
    }
    
}

#pragma mark Actions
/*-(IBAction)addGrocerySection:(id)sender
{
    int currentSection = 0;
    HGGSGrocerySection* newSection = [[self store] createGrocerySection:@"" inAisle:currentSection];
    NSInteger newRow = [[self.store itemsInList:AISLE_CONFIG] indexOfObject:newSection];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:newRow inSection:currentSection];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
}*/
-(IBAction) toggleEditMode:(id)sender
{
    UITableView *tv = [self activeTableView];
    bool isCurrentlyEditing = [tv isEditing];
    _editIsDeleting = NO;
    [tv setEditing:!isCurrentlyEditing];
    [self reloadDataForTableView:tv];
}

- (IBAction)setAisleNumber:(id)sender
{
    UIStepper *stepper = (UIStepper*)[_cellBeingEdited viewWithTag:3];
    UITextField* aisleField = (UITextField*)[_cellBeingEdited viewWithTag:2];
    [aisleField setText:[NSString stringWithFormat:@"%i",(int)[stepper value]]];
    //[_currentGrocerySection setAisle:[stepper value]];
    [aisleField setNeedsDisplay];
}
-(IBAction) doneEditing:(id)sender;
{

    //NSIndexPath* ipBeingEdited = [_ipBeingEdited copy];
    UITableView *tv = [self activeTableView];
    UITextField *sectionField = (UITextField*)[_cellBeingEdited viewWithTag:1] ;
    UITextField *aisleField = (UITextField*)[_cellBeingEdited viewWithTag:2] ;
    NSIndexPath* ipOfCellEdited = [_ipBeingEdited copy];
    [aisleField resignFirstResponder];
    [sectionField resignFirstResponder];
    _changesToSave = YES;
    NSString * newSectionName = [sectionField text];
    
    // we should move this to right after user finishes entering text....
    if ((newSectionName) && (![newSectionName isEqualToString:@""]))
    {
        if (![newSectionName isEqualToString:[_currentGrocerySection name]])
        {
            if (![self isSectionNameUnique:newSectionName])
            {
                UIAlertView *errorAlert = [[UIAlertView alloc]
                 initWithTitle:@"Section Name Already Exists" message:@"Please specify a unique grocery section" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles: nil];
                errorAlert.alertViewStyle = UIAlertViewStyleDefault;
                [errorAlert show];
                return;
            }
            else
                [_currentGrocerySection setName:newSectionName];
        }
        
        [_currentGrocerySection setAisle:[[aisleField text] integerValue]];
        [self endEditingOfCell];
        [self reloadCellAt:ipOfCellEdited];
    }
    else
    {
        
        [_store removeGrocerySection:_currentGrocerySection fromAisle:[self aisleAt:ipOfCellEdited inTableView:tv]];
        
        [self endEditingOfCell];
        [tv reloadData];
        [tv reloadInputViews];
    }

    
}

-(UITableView*)activeTableView
{
    return (_searchResults ? [[self searchDisplayController] searchResultsTableView] : [self tableView]);
}
-(IBAction) toggleDeleteMode:(id)sender
{
    UITableView *tv = [self activeTableView];
    bool isCurrentlyEditing = [tv isEditing];
   
    [self setDeleteMode:!isCurrentlyEditing for:tv];
    
}
-(void)setDeleteMode:(bool)on for:(UITableView *)tv
{
    _editIsDeleting = on;
    [tv setEditing:on];
    [self reloadDataForTableView:tv];

}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    //return 1;
    if (tableView == self.tableView)
        return [[_store getGroceryAisles] itemCount];
    else
        return [_searchResults count];
}
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCellBeingEdited:indexPath])
    {
        return UITableViewCellEditingStyleNone;
    }
    else
    {
        return (_editIsDeleting) ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert ; //UITableViewCellEditingStyleDelete;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @try {
        if (tableView == self.tableView)
        {
           
            NSArray* aisles = [[[self store] getGroceryAisles] list];
            HGGSGroceryAisle* aisle = [aisles objectAtIndex:section];
            return [[aisle grocerySections ] count];
        }
        else if (_searchResults)
        {
            return [[[_searchResults objectAtIndex:section] grocerySections] count];
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in numberOfRowsInSection:");
    }
    
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"GrocerySectionCell";
    HGGSGrocerySection * grocerySection;
    
    grocerySection = [self grocerySectionAt:indexPath inTableView:tableView];
    if ([self isCellBeingEdited:indexPath])
    {
        if ([tableView isEditing] || _searchResults)
            cellIdentifier = EDIT_CELL_ID;
        else
        {
            _ipBeingEdited = nil;
        }
    }
    
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if ([cellIdentifier  isEqualToString:EDIT_CELL_ID])
    {
        NSString* name = [grocerySection name];
        UITextField *sectionField = (UITextField*)[cell viewWithTag:1] ;
        UITextField *aisleField = (UITextField*)[cell viewWithTag:2] ;
        UIStepper *stepper = (UIStepper*)[cell viewWithTag:3];
        [sectionField setText:name];
        [aisleField setText:[NSString stringWithFormat:@"%li",(long)[grocerySection aisle]]];
        [stepper setValue:[grocerySection aisle]];
        [self editGrocerySectionAt:indexPath inTableView:tableView];
        _cellBeingEdited = cell;
        if ( name == nil || [name length] == 0)
        {
            [sectionField becomeFirstResponder];
        }
    }
    else
    {
        [[cell textLabel] setText:[grocerySection name]];
              
    }
    //set text...
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isCellBeingEdited:indexPath])
        return 88;
    else
        return 44;
}

-(UITableViewCell*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
//return [[[[self searchDisplayController] searchResultsTableView] tableHeaderView] view;
    
    NSString *cellIdentifier;
    HGGSGroceryAisle* aisle;
    
    if ((tableView == [self tableView]) && (section == 0))
    {
        cellIdentifier = (tableView.isEditing)  ? @"EditngAislesConfigHeaderCell" : @"AislesConfigHeaderCell";
    }
    else
        cellIdentifier =  @"GrocerySectionHeaderCell";
        
    UITableViewCell *cell= [[self tableView] dequeueReusableCellWithIdentifier:cellIdentifier];
    UILabel *aisleLabel = (UILabel*)[cell viewWithTag:1] ;
    @try
    {
        if (tableView == [self tableView])
        {
            aisle = [[_store getGroceryAisles] itemAt:section];
        }
        else
        {
            aisle = [_searchResults objectAtIndex:section];
        }
        NSString *aisleLabelText = [NSString stringWithFormat:@"Aisle %li",(long)[aisle number]];
        [aisleLabel setText:aisleLabelText];
        [aisleLabel setAccessibilityValue:aisleLabelText];
        [aisleLabel setAccessibilityLabel:aisleLabelText];
        
    }
    @catch (NSException *e)
    {
        NSLog(@"exception in viewForHeaderInSection: %@", e);
    }
    return cell;
}

 -(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((tableView == [self tableView]) && (section == 0))
        return 88;
    else
        return 44;
}
/*
-(UITableViewCell*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    NSString *cellIdentifier = (_deleting) ? @"AisleConfigDelFooterCell" : @"AisleConfigRegFooterCell";
    return [[self tableView] dequeueReusableCellWithIdentifier:cellIdentifier];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 44;
}
*/

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    //if ((_ipBeingEdited) && (_ipBeingEdited.row == indexPath.row))
    //    return NO;
    //else
    return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_ipBeingEdited) || (_editIsDeleting))
        return;
    
    if ((tableView == [[self searchDisplayController] searchResultsTableView]) ||
        ([tableView isEditing]))
    {
        HGGSGrocerySection * section = [self grocerySectionAt:indexPath inTableView:tableView];
        
        if  (![[section name] isEqualToString:DEFAULT_GROCERY_SECTION_NAME] )
        {
            [self editGrocerySectionAt:indexPath inTableView:tableView];
            [self reloadDataAtIndexPaths:[NSArray arrayWithObject:indexPath ] forTableView:tableView];
        }
    }
        
}
- (BOOL)tableView:(UITableView *)tableView
shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if ([self isCellBeingEdited:indexPath])
        return NO;
    else
        return [tableView isEditing];
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    _changesToSave = YES;
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [_store removeGrocerySection:[self grocerySectionAt:indexPath inTableView:tableView] fromAisle:[self aisleAt:indexPath inTableView:tableView]];
        
        [tableView reloadData];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        NSInteger precedingRow = [indexPath row];
        NSInteger currentSectionIndex = [indexPath section];
        
        HGGSGrocerySection *precedingGrocerySection = [self grocerySectionAt:[NSIndexPath indexPathForRow:precedingRow inSection:indexPath.section] inTableView:tableView];
        HGGSStoreAisles *storeAisles = [[self store] getGroceryAisles];
        
        _currentGrocerySection = [storeAisles insertNewGrocerySection:@"" inAisle:[precedingGrocerySection aisle] atSectionIndex:(precedingRow +1)];
        NSIndexPath *ip = [NSIndexPath indexPathForRow:(precedingRow + 1) inSection:currentSectionIndex];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
        [self editGrocerySectionAt:ip inTableView:tableView];
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationAutomatic];

    }
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

#pragma mark - UISearchDisplayController Delegate Methods

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    _searchResults = [_store findGrocerySections:searchString inAisles:YES];
    
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}


#pragma mark UISearchBarDelegate Methods
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    [self endEditingOfCell];
    [self exitSearchMode];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self exitSearchMode];
}

#pragma mark HGGSGroceryStoreDelegegate
-(void)didHaveAisleChange:(HGGSGrocerySection*)section fromAisle:(HGGSGroceryAisle*)fromAisle toAisle:(HGGSGroceryAisle*)toAisle
{
    if (_searchResults)
    {
        _searchResults = [_store findGrocerySections:[[[self searchDisplayController] searchBar] text] inAisles:true];
        [self reloadDataForTableView:[[self searchDisplayController] searchResultsTableView]];
    }
    [self reloadDataForTableView:[self tableView]];
}
-(void)didRemoveGroceryAisle:(HGGSGroceryAisle*)aisle
{
    if (_searchResults)
    {
        _searchResults = [_store findGrocerySections:[[[self searchDisplayController] searchBar] text] inAisles:true];
        [self reloadDataForTableView:[[self searchDisplayController] searchResultsTableView]];
    }
    [self reloadDataForTableView:[self tableView]];
}

#pragma mark Private Methods
-(HGGSGroceryAisle *)aisleAt:(NSIndexPath*)indexPath inTableView:(UITableView*)tableView
{
    @try {
        if (tableView == self.tableView)
            return [[_store getGroceryAisles] itemAt:indexPath.section];
        else
            return [_searchResults objectAtIndex:indexPath.section];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception caught in aisleAt:inTableView:");
    }
}

-(void) editGrocerySectionAt:(NSIndexPath*)indexPath inTableView:(UITableView*)tableView
{
    _currentGrocerySection = [self grocerySectionAt:indexPath inTableView:tableView];
    
    NSIndexPath* previousIndexPath;
    if (_ipBeingEdited)
        previousIndexPath = [_ipBeingEdited copy];
    
    _ipBeingEdited = [indexPath copy];
   
    
}
-(void)endEditingOfCell
{
    _ipBeingEdited = nil;
    _cellBeingEdited = nil;
    _currentGrocerySection = nil;
   
}
-(void)exitSearchMode
{
    _searchResults = nil;
}
-(HGGSGrocerySection*)grocerySectionAt:(NSIndexPath*)indexPath inTableView:(UITableView*)tableView
{
    @try
    {
        HGGSGroceryAisle* aisle = [self aisleAt:indexPath inTableView:tableView];
        return [[aisle grocerySections]  objectAtIndex:indexPath.row];
        //DEFAULT_GROCERY_SECTION_NAME
    }
    @catch (NSException *e)
    {
        NSLog(@"exception in grocerySectionAt:inTableView:%@", e);
    }

}
-(bool)isCellBeingEdited:(NSIndexPath*)indexPath
{
    return (_ipBeingEdited ) && (indexPath.row == _ipBeingEdited.row) && (indexPath.section == _ipBeingEdited.section);
}
-(bool) isSectionNameUnique:(NSString*)proposedName
{
    HGGSStoreAisles * aisles = [_store getGroceryAisles];
    return ([aisles findGrocerySection:proposedName] == nil);
    
}

-(void)reloadCellAt:(NSIndexPath*)indexPath
{
    /*
    [[self activeTableView] reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    */
    [self reloadDataForTableView:[self activeTableView]];
}

-(void)reloadDataForTableView:(UITableView*)tableView
{
    [tableView reloadData];
}

-(void)reloadDataAtIndexPaths:(NSArray*)indexPaths forTableView:(UITableView*)tableView
{
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end
