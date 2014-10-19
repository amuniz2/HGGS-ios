//
//  HGGSEditGroceryItemViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/10/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGGSCommon.h"
#import "HGGSBarCodeScannerViewController.h"

@class HGGSStoreItems;
@class HGGSGroceryItem;
@class HGGSGroceryStore;

typedef enum itemType
{
    pantryItem = 0,
    shoppingItem = 1,
    newShoppingItem = 2
} itemType;

@interface HGGSEditGroceryItemViewController : UIViewController <HGGSBarcodeScannerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

{
    //__weak IBOutlet UITextField *notes;
    __weak IBOutlet UITextField *quantity;
    __weak IBOutlet UITextField *units;
    __weak IBOutlet UITextView *name;
    __weak IBOutlet UITextField *grocerySection;
    __weak IBOutlet UISwitch *select;
    __weak IBOutlet UIToolbar *editToolbar;
    __weak IBOutlet UILabel *selectionLabel;
    __weak IBOutlet UIImageView *_imageView;

    __weak IBOutlet UITextView *_additionalNotes;
    

}
@property (nonatomic, strong)HGGSGroceryItem *groceryItem;

@property (nonatomic, weak) HGGSStoreItems *existingItems;
@property (nonatomic, copy) NSString *originalGroceryItemName;
@property (nonatomic, strong)NSArray* grocerySections;
@property (nonatomic, strong)HGGSGroceryStore *groceryStore;
@property itemType itemType;
@property (nonatomic, copy, readonly) NSString* selectionLabelText;
@property (readonly) bool saveToMasterList;
@property bool isNewItem;

@property (nonatomic, copy) void(^dismissBlock)(void);
@property HGGSModalAction actionTaken;
@property bool inEditMode;
- (IBAction)enterEditModeOrCancel:(id)sender;
- (IBAction)deleteItem:(id)sender;
- (IBAction)saveOrReturn:(id)sender;
@property BOOL newMedia;

-(IBAction) useCamera : (id)sender;
-(IBAction) useCameraRoll : (id)sender;

@end
