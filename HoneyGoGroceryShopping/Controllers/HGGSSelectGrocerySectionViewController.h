//
//  HGGSSelectGrocerySectionViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 1/19/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGSGrocerySection;
@class HGGSStoreAisles;

@interface HGGSSelectGrocerySectionViewController : UIViewController <UISearchResultsUpdating, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    
}
//@property IBOutlet UISearchBar *searchBar;
@property IBOutlet UITableView *tableView;
@property (strong, nonatomic) UISearchController *searchController;

@property (nonatomic, strong)HGGSStoreAisles * groceryAisles;
//@property (nonatomic, strong)NSArray* grocerySections;
@property (nonatomic, copy) NSString* selectedSectionName;
@property (nonatomic, strong) HGGSGrocerySection* selectedSection;
@property (nonatomic, copy) void(^dismissBlock)(void);
- (IBAction)addNewSection:(id)sender;

@end
