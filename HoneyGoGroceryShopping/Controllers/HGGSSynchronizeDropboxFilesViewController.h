//
//  HGGSSynchronizeDropboxFilesViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/20/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGGSDropboxClientViewController.h"

@class HGGSGroceryStore;


typedef void (^dismissBlock)(DbFileSynchOption);

@interface HGGSSynchronizeDropboxFilesViewController : HGGSDropboxClientViewController <UIPickerViewDataSource, UIPickerViewDelegate>

{
    __weak IBOutlet UILabel *synchInstructionsLabel;
    __weak IBOutlet UIButton *actionButton;
    __weak IBOutlet UIPickerView *synchOptionSelector;
}
@property DbFileSynchOption synchOptionSelected;
@property (nonatomic, copy) void(^dismissBlock)(void);
@property (nonatomic, strong) DBRestClient *restClient;

- (IBAction)SynchronizeWithDropbox:(id)sender;

@end
