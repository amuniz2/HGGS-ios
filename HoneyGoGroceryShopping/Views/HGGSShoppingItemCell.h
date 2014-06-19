//
//  HGGSShoppingItemCell.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/10/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGSGroceryItem;

@interface HGGSShoppingItemCell : UITableViewCell
{
}
@property (weak, nonatomic) IBOutlet UIButton *completed;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *notes;
@property (weak, nonatomic) IBOutlet UILabel *quantity;
@property (nonatomic) HGGSGroceryItem *groceryItem;

- (IBAction)toggleSelectState:(id)sender;
-(void) saveUserValuesEnteredByUser;

@end
