//
//  HGGSAisleHeaderCellViewTableViewCell.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/29/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import "HGGSGroceryAisleHeaderCellView.h"

@implementation HGGSGroceryAisleHeaderCellView

- (void)awakeFromNib {
    // Initialization code
    //self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    //[aisleNumberLabel setAutoresizingMask:UIViewAutoresizingFlexibleRightMargin];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)willTransitionToState:(UITableViewCellStateMask)state
{
    [super willTransitionToState:state];
    if (state == UITableViewCellStateShowingEditControlMask)
    {
        [self layoutSubviews];
    }

    if (state == UITableViewCellStateShowingDeleteConfirmationMask)
    {
        [self layoutSubviews];
    }
}
-(void)layoutSubviews
{
    [super layoutSubviews];
}

#pragma mark Property Overrides
-(void)setAisleNumber:(NSInteger)aisleNumber
{
    _aisleNumber = aisleNumber;
    
    NSString *aisleLabelText = [NSString stringWithFormat:@"Aisle %li",(long)aisleNumber];
    [aisleNumberLabel setText:aisleLabelText];
    [aisleNumberLabel setAccessibilityValue:aisleLabelText];
    [aisleNumberLabel setAccessibilityLabel:aisleLabelText];
    
}
@end
