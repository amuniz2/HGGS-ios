//
//  HGGSShoppingListControllerViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/10/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "HGGSShoppingItemCell.h"

@class HGGSGroceryStore;

@interface HGGSShoppingListViewController : UITableViewController<HGGSShowGroceryItemPictureDelegate>//<UISearchResultsUpdating, UISearchBarDelegate,HGGSShowGroceryItemPictureDelegate>
{}
@property (nonatomic, strong) HGGSGroceryStore* store;
@property BOOL startNewShoppingList;
@end
