//
//  HGGSAisleConfigurationControllerViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/14/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSAisleConfigurationControllerViewController.h"
#import "HGGSCommon.h"
#import "HGGSGroceryStore.h"
#import "HGGSGroceryStoreManager.h"
#import "HGGSGrocerySection.h"
//#import "HGGSGrocerySectionCellView.h"

@interface HGGSAisleConfigurationControllerViewController ()
{
    NSArray* _searchResults;
    bool _deleting;
}


@end

@implementation HGGSAisleConfigurationControllerViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGrocerySection:)];
    self.navigationItem.rightBarButtonItem = addButtonItem;
    
    [self.navigationItem setTitle:[NSString stringWithFormat:@"%@ Aisles",[_store name]]];
    
    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addGroceryItem:)];
    //[navItem setRightBarButtonItem:addButton];
    
    [[self store] loadList:AISLE_CONFIG];
    
    self.editing = YES;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
        HGGSGroceryStoreManager* storeManager = [HGGSGroceryStoreManager sharedStoreManager];
        [storeManager saveStoreList:[self store] listType:AISLE_CONFIG];
    
}


#pragma mark Actions
-(IBAction)addGrocerySection:(id)sender
{
    int currentSection = 0;
    HGGSGrocerySection* newSection = [[self store] createGrocerySection:@"" inAisle:currentSection];
    NSInteger newRow = [[self.store itemsInList:AISLE_CONFIG] indexOfObject:newSection];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:newRow inSection:currentSection];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:ip] withRowAnimation:UITableViewRowAnimationTop];
}
-(IBAction)enterDeletingMode:(id)sender
{
    _deleting = YES;
    [self setEditing:YES animated:YES];
    [[self tableView] reloadData];
 }

-(IBAction)saveAndReturn:(id)sender
{
    // todo - save and dismiss
    _actionTaken = saveChanges;
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:_dismissBlock];
    
}
-(IBAction)exitDeletingMode:(id)sender
{
    _deleting = NO;
    [self setEditing:NO animated:YES];
    [[self tableView] reloadData];  
}



#pragma mark - Table view data source

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // todo: Return the number of sections.
    return 1;
}
*/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.tableView) {
        return [[[self store] itemsInList:AISLE_CONFIG] count];
    }
    if (_searchResults)
        return [_searchResults count];
    
    return 0;
}

/*
 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"GrocerySectionCell";
    //check for cell that can be reused:
    HGGSGrocerySection * grocerySection;
    
    if (tableView == self.tableView)
        grocerySection = [[[self store] itemsInList:AISLE_CONFIG] objectAtIndex:[indexPath row]];
    else
        grocerySection = [_searchResults objectAtIndex:[indexPath row]];
    
    HGGSGrocerySectionCellView* cell = [[self tableView] dequeueReusableCellWithIdentifier:CellIdentifier];
    [cell setGrocerySection:grocerySection];
  
    //set text...
    return cell;
}
 */
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

#pragma mark UITableViewDelegate

//-(UITableViewCell*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
//{
    //return [[[[self searchDisplayController] searchResultsTableView] tableHeaderView] view;
    //NSString *cellIdentifier = @"AisleConfigHeaderCell" ;
    //return [[self tableView] dequeueReusableCellWithIdentifier:cellIdentifier];
    
//}
/*
 -(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
 {
 return 44;
 }
*/
-(UITableViewCell*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    NSString *cellIdentifier = (_deleting) ? @"AisleConfigDelFooterCell" : @"AisleConfigRegFooterCell";
    return [[self tableView] dequeueReusableCellWithIdentifier:cellIdentifier];
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    
    return 44;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        HGGSGrocerySection* sectionToRemove = [[_store itemsInList:AISLE_CONFIG] objectAtIndex:[indexPath row]];
        [[self store] removeGrocerySection:sectionToRemove];
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    
    }
    /*else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    } */
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

@end
