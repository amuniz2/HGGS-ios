//
//  HGGSShoppingItemCell.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/10/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
@class HGGSGroceryItem;

@protocol HGGSShowGroceryItemPictureDelegate <NSObject>
//-(void)didFinishScanningWithBarcode:(NSString*)barCode;
-(void)didRequestZoomOf:(HGGSGroceryItem*)groceryItem;
@end

@interface HGGSShoppingItemCell : UITableViewCell
{
}
@property (weak, nonatomic) IBOutlet UIButton *completed;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *notes;
@property (weak, nonatomic) IBOutlet UILabel *quantity;
@property (weak, nonatomic) IBOutlet UIImageView *itemPictureView;


//@property (weak, nonatomic, readonly) IBOutlet UIImageView *imageView;

@property (nonatomic) HGGSGroceryItem *groceryItem;

- (IBAction)toggleSelectState:(id)sender;
-(void) saveUserValuesEnteredByUser;
-(IBAction)zoomPicture:(id)sender;
+(CGFloat)heightNeeded:(HGGSGroceryItem *)item;
@property (weak) id <HGGSShowGroceryItemPictureDelegate> delegate;

@end
