//
//  HGGSShoppingListControllerViewController.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/10/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSShoppingListViewController.h"
#import "HGGSGroceryStore.h"
#import "HGGSGroceryStoreManager.h"
#import "HGGSStoreList.h"
#import "HGGSGroceryAisle.h"
#import "HGGSGrocerySection.h"
#import "HGGSShoppingItemCell.h"
#import "HGGSZoomGroceryItemPictureViewController.h"

@interface HGGSShoppingListViewController ()
{
    //NSArray* _searchResults;
    NSMutableArray* _shoppingList;
    HGGSGroceryItem *_currentGroceryItem;
    HGGSStoreItems* _groceryItems;
}

@end

@implementation HGGSShoppingListViewController

#pragma mark Lifecycle 
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

    UINavigationItem *navItem = [self navigationItem];
    
    [navItem setTitle:[NSString stringWithFormat:@"%@ Shopping List",[_store name]]];
    _groceryItems = [_store getGroceryList];
    _shoppingList = [_store createShoppingList:_startNewShoppingList];
}


-(void) saveChangedCellsStillDisplayed
{
    for (HGGSShoppingItemCell *cell in [[self tableView] visibleCells])
    {
        [cell saveUserValuesEnteredByUser];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self saveChangedCellsStillDisplayed];
    
    HGGSGroceryStoreManager* storeManager = [HGGSGroceryStoreManager sharedStoreManager];
    [storeManager saveGroceryList:[self store]];
    //_changesToSave = NO;
    [super viewWillDisappear:animated];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    if ([segue.identifier isEqualToString:@"toZoomPicture"])
    {
        HGGSZoomGroceryItemPictureViewController *zoomController = segue.destinationViewController;
        
        [zoomController setGroceryItem:_currentGroceryItem];
    }
    else
    {
        NSLog(@"Unrecognized seque identifier: %@", segue.identifier);
    }
  }

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_shoppingList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @try {
            HGGSGroceryAisle* aisle = [_shoppingList objectAtIndex:section];
            return [aisle  groceryItemCount];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in numberOfRowsInSection:");
    }
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        HGGSGroceryItem * groceryItem = [self groceryItemAt:indexPath inTableView:tableView];
        NSString *cellIdentifier = ([groceryItem image] == nil) ? @"ShoppingItemCell" : @"ShoppingItemCellWithImage";
        HGGSShoppingItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
 
        //todo: distinguish between shopping item and grocery item?
        [cell bindGroceryItem:groceryItem tableView:tableView indexPath:indexPath];
        [cell setDelegate:self];
  
        //set text...
        return cell;

}


-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *cellIdentifier = @"ShoppingAisleHeaderCell";
    HGGSGroceryAisle* aisle;
    
    UITableViewCell *cell= [[self tableView] dequeueReusableCellWithIdentifier:cellIdentifier];
    UILabel *aisleLabel = (UILabel*)[cell viewWithTag:1] ;

    aisle = [[_store getGroceryAisles] itemAt:section];
    [aisleLabel setText:[NSString stringWithFormat:@"Aisle %li",(long)[aisle number]]];
        
    return cell.contentView;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
          return 44;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HGGSGroceryItem *itemInRow = [self groceryItemAt:indexPath inTableView:tableView];
 
    return [HGGSShoppingItemCell heightNeeded:itemInRow];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != [self tableView])
        return;
    
    [(HGGSShoppingItemCell*)cell saveUserValuesEnteredByUser];
}
/*- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //self.someProperty = [self.someArray objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"toZoomPicture" sender:self];
}*/
#pragma mark HGGSShowGroceryItemPictureDelegate
-(void) didRequestZoomOf:(HGGSGroceryItem *)groceryItem
{
    HGGSZoomGroceryItemPictureViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ZoomPicture"];
    
    [controller setGroceryItem:groceryItem];
    [self presentViewController:controller animated:YES completion:nil];
    
    //_currentGroceryItem = groceryItem;
    //[self performSegueWithIdentifier:@"toZoomPicture" sender:self];
    

}
#pragma mark Private
-(HGGSGroceryItem*)groceryItemAt:(NSIndexPath*)indexPath inTableView:(UITableView*)tableView
{
        HGGSGroceryAisle* aisle = [_shoppingList objectAtIndex:[indexPath section]];
        HGGSGroceryItem *item = nil;
        int currentIndex = 0;
        
        for (HGGSGrocerySection *section in [aisle grocerySections])
        {
            if (currentIndex + [[section groceryItems] count] > [indexPath row])
            {
                item = [[section groceryItems] objectAtIndex:([indexPath row] -currentIndex)];
                break;
            }
            else
            {
                currentIndex += [[section groceryItems] count];
            }
        }
        return item;
        
}


@end
