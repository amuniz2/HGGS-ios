//
//  HGGSShoppingItemCell.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/10/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSShoppingItemCell.h"
#import "HGGSGroceryItem.h"

@implementation HGGSShoppingItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}



- (IBAction)toggleSelectState:(id)sender
{
    [_completed setSelected:![_completed isSelected]];
}

-(void) setGroceryItem:(HGGSGroceryItem *)groceryItem
{
    _groceryItem = groceryItem;
    
    [_name setText:[groceryItem name]];
    [_quantity setText:[NSString stringWithFormat:@"%g %@", [groceryItem quantity], [groceryItem unit]]];
    [_notes setText:[groceryItem notes]];
    [_completed setSelected:[groceryItem selected]];
    
}

-(void) saveUserValuesEnteredByUser
{
    [_groceryItem setSelected:[_completed isSelected]];
}

@end
