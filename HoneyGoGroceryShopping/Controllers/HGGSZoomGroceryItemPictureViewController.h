//
//  HGGSZoomGroceryItemPictureViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/20/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGSGroceryItem;

@interface HGGSZoomGroceryItemPictureViewController : UIViewController
{
    IBOutlet UIImageView *groceryItemPicture;
    IBOutlet UITextView *groceryItemName;
}
-(IBAction) finishedViewing : (id)sender;

@property (nonatomic, strong) HGGSGroceryItem *groceryItem;

@end
