//
//  HGGSAisleHeaderCellViewTableViewCell.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/29/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGGSAisleHeaderCellViewTableViewCell : UITableViewCell
{
    __weak IBOutlet UILabel *aisleNumberLabel;
}
@property (nonatomic) NSInteger aisleNumber;

@end
