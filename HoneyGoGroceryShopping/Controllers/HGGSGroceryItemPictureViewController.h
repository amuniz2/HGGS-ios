//
//  HGGSGroceryItemPictureViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 9/17/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HGGSGroceryItemPictureViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIImageView *_imageView;
}
@property BOOL newMedia;

-(IBAction) useCamera : (id)sender;
-(IBAction) useCameraRoll : (id)sender;

@end
