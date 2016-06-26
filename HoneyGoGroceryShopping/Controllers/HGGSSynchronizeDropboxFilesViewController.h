//
//  HGGSSynchronizeDropboxFilesViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/20/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGGSDropboxClient.h"

@class HGGSGroceryStore;


typedef void (^dismissBlock)(DbFileSynchOption);

@interface HGGSSynchronizeDropboxFilesViewController : UIViewController<UIPickerViewDataSource, UIPickerViewDelegate,HGGSDropboxControllerDelegate> //HGGSDropboxClientViewController<UIPickerViewDataSource, UIPickerViewDelegate>
{
    __weak IBOutlet UILabel *synchInstructionsLabel;
    __weak IBOutlet UIButton *actionButton;
    __weak IBOutlet UIPickerView *synchOptionSelector;
}
@property DbFileSynchOption synchOptionSelected;
@property (nonatomic, copy) void(^dismissBlock)(void);
//@property (nonatomic, strong) DBRestClient *restClient;
@property (weak,nonatomic) HGGSGroceryStore * groceryStore;

- (IBAction)SynchronizeWithDropbox:(id)sender;

@end
