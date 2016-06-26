//
//  HGGSShoppingItemCell.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/10/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSShoppingItemCell.h"
#import "HGGSGroceryItem.h"
#import "UIImage+UIImageResizable.h"

@implementation HGGSShoppingItemCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
#pragma mark Property Overrides
-(void) bindGroceryItem:(HGGSGroceryItem *)groceryItem tableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath
{
    _groceryItem = groceryItem;
    
    [_name setText:[groceryItem name]];
    [_quantity setText:[NSString stringWithFormat:@"%g %@", [groceryItem quantity], [groceryItem unit]]];
    [_notes setText:[groceryItem notes]];
    [_completed setSelected:[groceryItem isInShoppingCart]];

    if (_itemPictureView == nil)
        return;
    
    _itemPictureView.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth);

    static UIImage * placeHolder;
    
    if (placeHolder == nil)
    {
        UIImage* placeHolderImage = [UIImage imageNamed:@"groceryItemPicturePlaceHolder.jpg"];
        placeHolder = [placeHolderImage
                       resize:[_itemPictureView bounds].size origin:[_itemPictureView bounds].origin];

    }
    if ([_groceryItem smallImage] != nil)
    {
        [_itemPictureView setImage:[groceryItem smallImage]];
        [_itemPictureView setContentMode:UIViewContentModeScaleAspectFit];
        [_itemPictureView setClipsToBounds:YES];
        return;
    }
    
    if ([_groceryItem smallImage] == nil)
    {
        _itemPictureView.image = placeHolder;
    
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            
            UIImage *itemImage = [groceryItem image];
            if (itemImage == nil)
                return;
        
     
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [groceryItem setSmallImage:[itemImage resize:[_itemPictureView bounds].size origin:[_itemPictureView bounds].origin]];
                
                if ([groceryItem smallImage] == nil)
                    return;
                
                HGGSShoppingItemCell *cell = (id)[tableView cellForRowAtIndexPath:indexPath];
                cell.itemPictureView.image = [groceryItem smallImage];
                cell.itemPictureView.contentMode = UIViewContentModeScaleAspectFit;
                cell.itemPictureView.clipsToBounds = YES;
            });                
        });
    }
}

#pragma mark Actions

- (IBAction)toggleSelectState:(id)sender
{
    [_completed setSelected:![_completed isSelected]];
}
-(IBAction)zoomPicture:(id)sender
{
    if (_delegate)
        [_delegate didRequestZoomOf:[self groceryItem]];
 
    
}
-(void) saveUserValuesEnteredByUser
{
    [_groceryItem setIsInShoppingCart:[_completed isSelected]];
}

#pragma mark Class Helper Methods
+(CGFloat)heightNeeded:(HGGSGroceryItem *)item
{
    if ([item image] != nil)
        return [HGGSShoppingItemCell heightNeededWithImage:item];
    
    float heightNeededForText =  MAX([HGGSShoppingItemCell heightNeededForText:[item name] font:[UIFont boldSystemFontOfSize:15] fieldWidth:208], [HGGSShoppingItemCell heightNeededForText:[item unit] font:[UIFont boldSystemFontOfSize:15] fieldWidth:64]) +
    [self heightNeededForText:[item notes] font:[UIFont italicSystemFontOfSize:13] fieldWidth:276] + 6;
    
    return  heightNeededForText;
}

+(CGFloat)heightNeededWithImage:(HGGSGroceryItem *)item
{
    float heightNeededForImage = 78.0;
    
    float heightNeededForText =  MAX([HGGSShoppingItemCell heightNeededForText:[item name] font:[UIFont boldSystemFontOfSize:15] fieldWidth:128], [HGGSShoppingItemCell heightNeededForText:[item unit] font:[UIFont boldSystemFontOfSize:15] fieldWidth:64]) +
    [HGGSShoppingItemCell heightNeededForText:[item notes] font:[UIFont italicSystemFontOfSize:13] fieldWidth:196] + 6;
    
    return MAX(heightNeededForImage, heightNeededForText);
}
+(int)heightNeededForText:(NSString*)text font:(UIFont *)font fieldWidth:(float)fieldWidth
{
    NSAttributedString * attributedText = [[NSAttributedString alloc] initWithString:text
                                                                          attributes:[[NSDictionary alloc] initWithObjectsAndKeys:font,NSFontAttributeName, nil]];
    CGSize maximumSize = CGSizeMake(fieldWidth, CGFLOAT_MAX);
    return [attributedText boundingRectWithSize:maximumSize options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading) context:nil].size.height;
    
}


@end
