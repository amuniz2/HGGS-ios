//
//  HGGSShoppingItemCellView.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/2/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGSGroceryItem;

@interface HGGSShoppingItemCellView : UITableViewCell
{
}
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UISwitch *itemSelected;
@property (weak, nonatomic) IBOutlet UIStepper *quantityStepper;
@property (nonatomic) HGGSGroceryItem *groceryItem;
@property (nonatomic, copy) NSString *unitText;
- (IBAction)setQuantity:(id)sender;
-(bool) saveValuesEnteredByUser;
@end
