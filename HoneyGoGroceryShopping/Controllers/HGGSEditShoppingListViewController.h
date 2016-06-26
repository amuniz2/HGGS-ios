//
//  HGGSEditShoppingListViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/2/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGGSDropboxClient.h"

@class HGGSGroceryStore;

@interface HGGSEditShoppingListViewController : UITableViewController <UISearchResultsUpdating, UISearchBarDelegate, HGGSDropboxControllerDelegate>
{
    
}
@property (nonatomic, strong) HGGSGroceryStore* store;
@property bool startNewList;
@property (strong, nonatomic) UISearchController *searchController;

@end
