//
//  HGGSGrocerySectionCellView.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/14/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSGrocerySectionCellView.h"
#import "HGGSGrocerySection.h"

@implementation HGGSGrocerySectionCellView

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == _nameField)
    {
        [_nameField resignFirstResponder];
        return NO;
    }
    
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == _nameField)
    {
        [_grocerySection setName:[_nameField text]];
    }
    else if (textField == _aisleField)
    {
        [_grocerySection setAisle:[[_aisleField text] intValue]];
    }
        
}
-(void) addSubview:(UIView *)view
{
    [_nameField setDelegate:self];
    [_aisleField setDelegate:self];
}

-(void)setGrocerySection:(HGGSGrocerySection *)grocerySection
{
    _grocerySection = grocerySection;

    UILabel *lblName = (UILabel *)[self viewWithTag:1];
    [lblName setText:[grocerySection name]];

    UILabel *lblAisle = (UILabel *)[self viewWithTag:2];
    [lblAisle setText:[NSString stringWithFormat:@"%i",[grocerySection aisle]]];

//    [_nameField setText:[grocerySection name]];
//    [_aisleField setText:[NSString stringWithFormat:@"%i",[grocerySection aisle]]];

//    [nameLabel setDelegate:self];
//    [aisleLabel setDelegate:self];
    
}

@end
