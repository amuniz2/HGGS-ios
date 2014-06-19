//
//  HGGSEditShoppingListViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/2/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HGGSGroceryStore;

@interface HGGSEditShoppingListViewController : UITableViewController
{
    __weak IBOutlet UISearchBar *_searchBar;
    
}
@property (nonatomic, strong) HGGSGroceryStore* store;

@end
