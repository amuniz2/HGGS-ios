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
#import "NSString+SringExtensions.h"

//#IMPORT "HGGSAisleHeaderCellViewTableViewCell.h"

#define EDIT_CELL_ID  @"EditGrocerySectionCell"

@interface HGGSGrocerySectionsViewController  ()<UISearchBarDelegate, UISearchDisplayDelegate, HGGSGroceryStoreDelegate>
{
    HGGSGrocerySection *_currentGrocerySection;
    NSIndexPath *_ipBeingEdited;
    UITableViewCell *_cellBeingEdited;
    bool _editIsDeleting;
    bool _changesToSave;

    NSString *_filter;
    NSMutableArray *_aisles;
    NSMutableArray *_aislesDisplayed;
    
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

    // Register the class for a header view reuse.
    [[self tableView] registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"GroceryAisleHeaderViewIdentifier"];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    
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

-(void)viewWillDisappear:(BOOL)animated
{
    if (_changesToSave)
    {
        HGGSGroceryStoreManager* storeManager = [HGGSGroceryStoreManager sharedStoreManager];
        [storeManager saveGroceryAisles:_store ];
        _changesToSave =NO;
    }
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    if (_changesToSave)
    {
        HGGSGroceryStoreManager* storeManager = [HGGSGroceryStoreManager sharedStoreManager];
        [storeManager saveGroceryAisles:_store];
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

    if (!isCurrentlyEditing)
        _changesToSave = YES;
    _editIsDeleting = NO;
    [tv setEditing:!isCurrentlyEditing];
    [tv reloadData];
 
    
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
        
        [_store removeGrocerySection:_currentGrocerySection fromAisle:[self aisleAt:ipOfCellEdited]];
        
        [self endEditingOfCell];
        [tv reloadData];
        [tv reloadInputViews];
    }

    
}

-(UITableView*)activeTableView
{
//    return (_searchResults ? [[self searchDisplayController] searchResultsTableView] : [self tableView]);
    return [self tableView];
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
    [tv reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_aislesDisplayed count];
}

//NOTE / TODO: IF CHANGING TO SWIPE BEHAVIOR, THIS METHOD NEEDS TO BE CHANGED AND POSSIBLY REMOVED
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
        HGGSGroceryAisle * aisle = [_aislesDisplayed objectAtIndex:section];
        
        return [[aisle grocerySections] count];
       
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
    
    grocerySection = [self grocerySectionAt:indexPath];
    if ([self isCellBeingEdited:indexPath])
    {
        if ([tableView isEditing])
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
        [self editGrocerySectionAt:indexPath];
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
    
    HGGSGrocerySection * section=[self grocerySectionAt:indexPath];
    int fieldWidth = (_editIsDeleting) ? 200 : 290;
    int heightForSectionName = MAX(44, [self heightNeededForText:[section name] font:[UIFont systemFontOfSize:17] fieldWidth:fieldWidth]);
    
    if ([self isCellBeingEdited:indexPath])
        return heightForSectionName + 44 ;
    else
        return heightForSectionName;

    //return ;
    
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{    
    NSString *cellIdentifier;
    HGGSGroceryAisle* aisle = [_aislesDisplayed objectAtIndex:section];
    
    NSString *aisleLabelText = [NSString stringWithFormat:@"Aisle %li",(long)[aisle number]];
    
    if ((tableView == [self tableView]) && (section == 0))
    {
        cellIdentifier = (tableView.isEditing)  ? @"EditngAislesConfigHeaderCell" : @"AislesConfigHeaderCell";


    }
    else
    {
        cellIdentifier =  @"GrocerySectionHeaderCell";
        
        /*static NSString *headerReuseIdentifier = @"GroceryAisleHeaderViewIdentifier";
        
        // Reuse the instance that was created in viewDidLoad, or make a new one if not enough.
        UITableViewHeaderFooterView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerReuseIdentifier];
        sectionHeaderView.textLabel.text = aisleLabelText;
        
        return sectionHeaderView;*/
    }
    UITableViewCell *cell= [[self tableView] dequeueReusableCellWithIdentifier:cellIdentifier];
    //cell.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin;
    
    UILabel *aisleLabel = (UILabel*)[cell viewWithTag:1] ;
    [aisleLabel setText:aisleLabelText];
    [aisleLabel setAccessibilityValue:aisleLabelText];
    [aisleLabel setAccessibilityLabel:aisleLabelText];
    
    return cell.contentView;
}

 -(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if ((tableView == [self tableView]) && (section == 0))
        return 88;
    else
        return 44;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    if ((_ipBeingEdited) && (_ipBeingEdited.row == indexPath.row) && (_ipBeingEdited.section == indexPath.section))
        return NO;
    else
        return YES;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ((_ipBeingEdited) || (_editIsDeleting))
        return;
    
    if ((tableView == [[self searchDisplayController] searchResultsTableView]) ||
        ([tableView isEditing]))
    {
        HGGSGrocerySection * section = [self grocerySectionAt:indexPath];
        
        if  (![[section name] isEqualToString:DEFAULT_GROCERY_SECTION_NAME] )
        {
            [self editGrocerySectionAt:indexPath];
            [self reloadDataAtIndexPaths:[NSArray arrayWithObject:indexPath ] forTableView:tableView];
        }
    }
        
}
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
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
        [_store removeGrocerySection:[self grocerySectionAt:indexPath] fromAisle:[self aisleAt:indexPath]];
 
//        HGGSGroceryAisle * aisle = [_aislesDisplayed objectAtIndex:indexPath.section];
        
        [tableView reloadData];
        
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        NSInteger precedingRow = [indexPath row];
        NSInteger currentSectionIndex = [indexPath section];
        
        HGGSGrocerySection *precedingGrocerySection = [self grocerySectionAt:[NSIndexPath indexPathForRow:precedingRow inSection:indexPath.section]];
        HGGSStoreAisles *storeAisles = [[self store] getGroceryAisles];
        
        _currentGrocerySection = [storeAisles insertNewGrocerySection:@"" inAisle:[precedingGrocerySection aisle] atSectionIndex:(precedingRow +1)];
        NSIndexPath *ip = [NSIndexPath indexPathForRow:(precedingRow + 1) inSection:currentSectionIndex];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
        [self editGrocerySectionAt:ip];
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


#pragma mark UISearchBarDelegate Methods
//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//    _searchResults = [_store findGrocerySections:searchString inAisles:YES];
//    
//    // Return YES to cause the search result table view to be reloaded.
//    return YES;
//}


- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar
{
    [self endEditingOfCell];
    [self exitSearchMode];
    
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self exitSearchMode];
}

#pragma mark UISearchResultsUpdatingDelegate Methods
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    _filter = searchController.searchBar.text;
    [self prepareList:NO];
    [self.tableView reloadData];
}


#pragma mark HGGSGroceryStoreDelegegate
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

#pragma mark Private Methods
-(HGGSGroceryAisle *)aisleAt:(NSIndexPath*)indexPath
{
    @try {
        return [_aislesDisplayed objectAtIndex:indexPath.section];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception caught in aisleAt:inTableView:");
    }
}

-(void) editGrocerySectionAt:(NSIndexPath*)indexPath
{
    _currentGrocerySection = [self grocerySectionAt:indexPath];
    
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
    _filter = nil;
    [self prepareList:NO];
    [self.tableView reloadData];
}
-(HGGSGrocerySection*)grocerySectionAt:(NSIndexPath*)indexPath
{
    @try
    {
        HGGSGroceryAisle* aisle = [self aisleAt:indexPath];
        
        return [[aisle grocerySections]  objectAtIndex:indexPath.row];
        //DEFAULT_GROCERY_SECTION_NAME
    }
    @catch (NSException *e)
    {
        NSLog(@"exception in grocerySectionAt:inTableView:%@", e);
    }

}
-(int)heightNeededForText:(NSString*)text font:(UIFont *)font fieldWidth:(float)fieldWidth
{
    NSAttributedString * attributedText = [[NSAttributedString alloc] initWithString:text
                                                                          attributes:[[NSDictionary alloc] initWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    CGSize maximumSize = CGSizeMake(fieldWidth, CGFLOAT_MAX);
    return [attributedText boundingRectWithSize:maximumSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size.height;
    
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
    [self.tableView reloadData];
}


-(void)reloadDataAtIndexPaths:(NSArray*)indexPaths forTableView:(UITableView*)tableView
{
    [tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void) prepareList:(bool)reloadAisles
{
    if (_aisles == nil)
        self.tableView.tableHeaderView = self.searchController.searchBar;
    if (_aisles == nil || reloadAisles)
    {
        _aisles = [[NSMutableArray alloc] init];
        [_aisles addObjectsFromArray:[[_store getGroceryAisles] list]];
    }
    if ([NSString isEmptyOrNil:_filter])
        _aislesDisplayed = _aisles;
    else
    {
        _aislesDisplayed = [[_store getGroceryAisles] findItems:_filter];
    }
}

@end
