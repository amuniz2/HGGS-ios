//
//  HGGSAisleConfigurationControllerViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/14/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGGSCommon.h"

@class HGGSGroceryStore;

@interface HGGSAisleConfigurationControllerViewController : UITableViewController
{

}
@property (nonatomic, strong) HGGSGroceryStore* store;
@property (nonatomic, copy) void(^dismissBlock)(void);
@property HGGSModalAction actionTaken;
@property IBOutlet UISearchBar *searchBar;

-(IBAction)enterDeletingMode:(id)sender;
-(IBAction)addGrocerySection:(id)sender;
-(IBAction)saveAndReturn:(id)sender;
-(IBAction)exitDeletingMode:(id)sender;
@end
