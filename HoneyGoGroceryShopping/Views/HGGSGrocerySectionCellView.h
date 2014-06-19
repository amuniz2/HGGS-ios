//
//  HGGSGrocerySectionCellView.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/14/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGGSGrocerySection;

@interface HGGSGrocerySectionCellView : UITableViewCell <UITextFieldDelegate>
{

}
@property (weak, nonatomic) HGGSGrocerySection* grocerySection;

@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *aisleField;


@end
