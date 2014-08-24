//
//  MasterItemCellView.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 9/29/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSMasterItemCellView.h"
#import "HGGSGroceryItem.h"

@implementation HGGSMasterItemCellView

-(void) setGroceryItem:(HGGSGroceryItem *)groceryItem
{
    [_nameLabel setAdjustsFontSizeToFitWidth:YES];
    [_notesLabel setAdjustsFontSizeToFitWidth:YES];
    
    [_nameLabel setText:[groceryItem name]];
    [_notesLabel setText:[groceryItem notes]];
    
    _groceryItem = groceryItem;
    
}

@end
