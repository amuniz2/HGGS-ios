//
//  HGGSViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/9/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGSGroceryStore;

@interface HGGSMainViewController : UIViewController  <UIPickerViewDataSource, UIPickerViewDelegate>
{
    NSArray *_keys;
    bool _addNewStore;
    
}

@property (weak, nonatomic) IBOutlet UIPickerView *storeSelector;
-(IBAction) editStore : (id)sender;
-(IBAction) promptIfNewListShouldBeStarted:(id)sender;
-(void) addStore;
@end
