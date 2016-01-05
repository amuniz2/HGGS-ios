//
//  HGGSMasterListViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/9/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGSGroceryStore;

@interface HGGSMasterListViewController : UITableViewController <UISearchResultsUpdating, UISearchBarDelegate>
{
    //__weak IBOutlet UISearchBar *_searchBar;
    bool _addNewItem;
}
@property (nonatomic, strong) HGGSGroceryStore* store;
@property (strong, nonatomic) UISearchController *searchController;
@end
