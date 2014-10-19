//
//  UIImage+UIImageResizable.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/19/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UIImageResizable)
-(CGSize) proportionateReducedSize:(CGSize)newSize;
-(UIImage *)resize:(CGSize)newSize ;

@end
