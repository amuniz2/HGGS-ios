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

@interface HGGSSelectGrocerySectionViewController : UIViewController
{
    
}
@property (nonatomic, strong)HGGSStoreAisles * groceryAisles;
//@property (nonatomic, strong)NSArray* grocerySections;
@property (nonatomic, copy) NSString* selectedSectionName;
@property (nonatomic, strong) HGGSGrocerySection* selectedSection;
@property (nonatomic, copy) void(^dismissBlock)(void);
@property IBOutlet UISearchBar *searchBar;
@property IBOutlet UITableView *tableView;
- (IBAction)addNewSection:(id)sender;

@end
