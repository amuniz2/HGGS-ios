//
//  MasterItemCellView.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 9/29/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HGGSGroceryItem;

@interface HGGSMasterItemCellView : UITableViewCell
{

}
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *notesLabel;
@property (nonatomic) HGGSGroceryItem *groceryItem;

@end
