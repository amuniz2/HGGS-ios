//
//  HGGSGroceryAisle.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/18/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGGSGrocerySection;

@interface HGGSGroceryAisle : NSObject <NSCopying>
{}
@property NSInteger number;
@property NSMutableArray* grocerySections;
@property (readonly)NSInteger groceryItemCount;
+(id)createWithGrocerySection:(HGGSGrocerySection*)grocerySection;
-(NSMutableArray *)findMatchingGrocerySections:(NSString *)stringToMatch;
@end
