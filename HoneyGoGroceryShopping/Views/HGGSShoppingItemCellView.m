//
//  HGGSShoppingItemCellView.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/2/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSShoppingItemCellView.h"
#import "HGGSGroceryItem.h"

@implementation HGGSShoppingItemCellView
{
    double _initialQuantity;
    bool _initiallySelected;
}
-(void) setGroceryItem:(HGGSGroceryItem *)groceryItem
{
    [_nameLabel setAdjustsFontSizeToFitWidth:YES];
    [_quantityLabel setAdjustsFontSizeToFitWidth:YES];
    _initiallySelected = [groceryItem selected];
    _initialQuantity = [groceryItem quantity];
    [_nameLabel setText:[groceryItem name]];
    
    [_quantityLabel setText:[NSString stringWithFormat:@"%g %@", [groceryItem quantity], [groceryItem unit]]];
    [_quantityStepper setValue:_initialQuantity];
    _unitText = [groceryItem unit];
    [_itemSelected  setOn:_initiallySelected];
    _groceryItem = groceryItem;

}
- (IBAction)setQuantity:(id)sender
{
 
    [_quantityLabel setText:[NSString stringWithFormat:@"%g %@", [_quantityStepper value], _unitText]];

}
-(bool) saveValuesEnteredByUser
{
    double quantitySetByUser = [_quantityStepper value];
    if (quantitySetByUser != [_groceryItem quantity])
    {
        [_groceryItem setQuantity:quantitySetByUser];
    }
    bool selectedByUser = [_itemSelected isOn];
    if (selectedByUser != [_groceryItem selected])
    {
        [_groceryItem setSelected:selectedByUser];
    }
    return (quantitySetByUser != _initialQuantity) || (selectedByUser != _initiallySelected);
}
@end
