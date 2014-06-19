//
//  HGGSNewGrocerySectionViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 3/2/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGGSCommon.h"

@interface HGGSNewGrocerySectionViewController : UIViewController
{
    __weak IBOutlet UITextField *aisleNumberField;
    __weak IBOutlet UITextField *sectionNameField;
    __weak IBOutlet UIStepper *aisleNumberStepper;
}
- (IBAction)addSection:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)increaseOrDecreaseAisleNumber:(id)sender;
@property (nonatomic, copy) void(^dismissBlock)(void);
@property (nonatomic) NSInteger aisleNumber;
@property (nonatomic, copy) NSString* sectionName;
@property HGGSModalAction actionTaken;
@end
