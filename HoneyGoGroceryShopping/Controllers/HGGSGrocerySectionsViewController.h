//
//  HGGSGrocerySectionsViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/16/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HGGSGroceryStore;

@interface HGGSGrocerySectionsViewController : UITableViewController <UISearchResultsUpdating, UISearchBarDelegate>

{
    
}
@property (nonatomic, strong) HGGSGroceryStore* store;
@property (strong, nonatomic) UISearchController *searchController;

-(IBAction) toggleDeleteMode:(id)sender;
-(IBAction) toggleEditMode:(id)sender;
//-(IBAction)addGrocerySection:(id)sender;
- (IBAction)setAisleNumber:(id)sender;
-(IBAction) doneEditing:(id)sender;

@end
