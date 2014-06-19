//
//  HGGSAisleHeaderCellViewCell.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 3/2/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGGSAisleHeaderCellView : UITableViewCell
{
    __weak IBOutlet UIButton *addSectionButton;
    __weak IBOutlet UILabel *aisleNumberLabel;
}
@property (nonatomic) NSInteger aisleNumber;
@end
