//
//  UIImage+UIImageResizable.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/19/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import "UIImage+UIImageResizable.h"

@implementation UIImage (UIImageResizable)
-(CGSize) proportionateReducedSize:(CGSize)maxSize
{
    CGSize proportionateSize;
    
    float heightToWidthRatio = (self.size.height / self.size.width);
    float widthToHeightRatio = (self.size.width / self.size.height);
    float heightFactor = maxSize.height / self.size.height ;
    float widthFactor = maxSize.width / self.size.width;
    if (heightFactor < widthFactor)
    {
        proportionateSize.height = MIN(maxSize.height, self.size.height);
        proportionateSize.width = proportionateSize.height * widthToHeightRatio;
    }
    else
    {
        proportionateSize.width = MIN(maxSize.width, self.size.width);
        proportionateSize.height = proportionateSize.width * heightToWidthRatio;
    }
    return proportionateSize;
}
- (UIImage *)resize:(CGSize)newSize origin:(CGPoint)origin {
 
    UIGraphicsBeginImageContextWithOptions(newSize,  NO, 0.0);
    [self drawInRect:CGRectMake(origin.x, origin.y, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage *)resizeImageToMaxSize:(CGSize)maxSize origin:(CGPoint)origin
{
    CGSize newSize = [self proportionateReducedSize:maxSize];
    return [self resize:newSize origin:origin];
}
@end
