//
//  HGGSBarCodeScannerViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 1/6/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HGGSBarcodeScannerDelegate <NSObject>
    //-(void)didFinishScanningWithBarcode:(NSString*)barCode;
    -(void)didGetProductDescription:(NSString*)productDescription;
@end

@interface HGGSBarCodeScannerViewController : UIViewController
{
    IBOutlet UIView *_highlightView;
    __weak IBOutlet UIPickerView *_productSelector;
    __weak IBOutlet UIView *_selectSingleProductView;
    __weak IBOutlet UIButton *cancelScanButton;
    __weak IBOutlet UIButton *doneButton;
}
@property (weak) id <HGGSBarcodeScannerDelegate> delegate;
- (IBAction)ProductSelected:(id)sender;
-(IBAction) Cancel:(id)sender;
@end
