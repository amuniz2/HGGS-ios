//
//  HGGSSynchronizeDropboxFilesViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/20/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGSGroceryStore;

typedef enum DbFileSynchOptions
{
    ShareDropboxFile,
    ShareLocalFile,
    DoNotShareFile
} DbFileSynchOption;

typedef void (^dismissBlock)(DbFileSynchOption);

@interface HGGSSynchronizeDropboxFilesViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>
{
    UIActivityIndicatorView *_activityIndicator;
     __weak IBOutlet UILabel *synchInstructionsLabel;
    __weak IBOutlet UIButton *actionButton;
    __weak IBOutlet UIPickerView *synchOptionSelector;
 }
@property DbFileSynchOption synchOptionSelected;
@property (strong,nonatomic) HGGSGroceryStore * groceryStore;
@property (nonatomic, copy) void(^dismissBlock)(void);

- (IBAction)SynchronizeWithDropbox:(id)sender;

@end
