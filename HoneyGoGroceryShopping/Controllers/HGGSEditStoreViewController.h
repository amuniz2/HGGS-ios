//
//  HGGSEditStoreViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/9/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGSGroceryStore;

@interface HGGSEditStoreViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>
{
    IBOutlet UIButton *_dropboxButton;
    IBOutlet UIButton *_editMasterListButton;
    IBOutlet UIButton *_editAislesButton;
    
    UIActivityIndicatorView *_activityIndicator;
    BOOL _isLinked;
    __weak IBOutlet UIToolbar *_editToolbar;
    bool _inEditMode;
}
@property (strong, readonly) UIAlertView *confirmDeleteStoreAlertView;
@property (weak, nonatomic) IBOutlet UITextField *groceryStoreName;
@property (weak, nonatomic) HGGSGroceryStore* groceryStore;
@property bool addStore;

//-(IBAction)editMasterList:(id)sender;
-(IBAction)linkToDropbox:(id)sender;
-(IBAction)enterOrExitEditMode:(id)sender;
-(void)confirmDeleteStore;
@end
