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

@interface HGGSShoppingListViewController ()
{
    NSArray* _searchResults;
//    bool _changesToSave;
    HGGSStoreList* _shoppingList;
    
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
    //_changesToSave = NO;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    if (![_store shoppingListIsMoreRecentThanCurrentList] )
        [_store createShoppingList];
    
    _shoppingList = [_store getShoppingList];

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
    [storeManager saveShoppingList:[self store]];
    //_changesToSave = NO;
    
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView != [self tableView])
        return;
    
    [(HGGSShoppingItemCell*)cell saveUserValuesEnteredByUser];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.tableView)
        return [_shoppingList itemCount];
    else
        return [_searchResults count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @try {
        if (tableView == self.tableView)
        {
            HGGSGroceryAisle* aisle = [_shoppingList itemAt:section];
            return [aisle  groceryItemCount];
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
    @try
    {
        NSString *cellIdentifier = @"ShoppingItemCell";
        HGGSGroceryItem * groceryItem = [self groceryItemAt:indexPath inTableView:tableView];
        HGGSShoppingItemCell *cell = [self.tableView dequeueReusableCellWithIdentifier:cellIdentifier];
 
        [cell setGroceryItem:groceryItem];
  
        //set text...
        return cell;
    }
    @catch (NSException *e)
    {
        NSLog(@"exception in cellForRowAtIndexPath:%@", e);
    }

}


-(UITableViewCell*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    NSString *cellIdentifier = @"ShoppingAisleHeaderCell";
    HGGSGroceryAisle* aisle;
    
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
        [aisleLabel setText:[NSString stringWithFormat:@"Aisle %li",(long)[aisle number]]];
        
    }
    @catch (NSException *e)
    {
        NSLog(@"exception in viewForHeaderInSection: %@", e);
    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
          return 44;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HGGSGroceryItem *itemInRow = [self groceryItemAt:indexPath inTableView:tableView];
    
    return [self heightNeededForText:[itemInRow name] font:[UIFont systemFontOfSize:15] ] +
    [self heightNeededForText:[itemInRow notes] font:[UIFont italicSystemFontOfSize:13] ] + 6;
    
}

#pragma mark Private
-(HGGSGroceryItem*)groceryItemAt:(NSIndexPath*)indexPath inTableView:(UITableView*)tableView
{
    @try
    {
        HGGSGroceryAisle* aisle = [_shoppingList itemAt:[indexPath section]];
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
    @catch (NSException *e)
    {
        NSLog(@"exception in groceryItemAt:inTableView:%@", e);
    }
    
}

-(int)heightNeededForText:(NSString*)text font:(UIFont *)font
{
    NSAttributedString * attributedText = [[NSAttributedString alloc] initWithString:text
                                                                          attributes:[[NSDictionary alloc] initWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    CGSize maximumSize = CGSizeMake(210, CGFLOAT_MAX);
    return [attributedText boundingRectWithSize:maximumSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size.height;
    
}


@end
