//
//  HGGSAisleHeaderCellViewCell.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 3/2/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import "HGGSAisleHeaderCellView.h"

@implementation HGGSAisleHeaderCellView

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setAisleNumber:(NSInteger)aisleNumber
{
    NSString *aisleLabelText = [NSString stringWithFormat:@"Aisle %li",(long)aisleNumber];
    
    _aisleNumber = aisleNumber;
    [aisleNumberLabel setText:aisleLabelText];
    [addSectionButton setTag:aisleNumber];
    
    [aisleNumberLabel setAccessibilityValue:aisleLabelText];
    [aisleNumberLabel setAccessibilityLabel:aisleLabelText];

}

- (IBAction)NewGrocerySection:(id)sender
{
    
}
@end
