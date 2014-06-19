//
//  HGGSGroceryAisle.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/18/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSGroceryAisle.h"
#import "HGGSGrocerySection.h"

@implementation HGGSGroceryAisle
{
    
}

+(id)createWithGrocerySection:(HGGSGrocerySection*)grocerySection
{
    HGGSGroceryAisle* newAisle =[[HGGSGroceryAisle alloc] init];

    [newAisle setNumber:[grocerySection aisle]];
    [newAisle setGrocerySections:[NSMutableArray arrayWithObject:grocerySection]];
    
    return newAisle;
    
}
-(id) init
{
    self = [super init];
    if (self)
    {
        _grocerySections = [[NSMutableArray alloc ] init];
    }
    return self;

}
-(NSInteger) groceryItemCount
{
    NSInteger count = 0;
    for (HGGSGrocerySection *section in _grocerySections)
    {
        count += [[section groceryItems] count];
    }
    return count;
}
#pragma mark Public Methods
-(NSMutableArray *)findMatchingGrocerySections:(NSString *)stringToMatch
{
    NSMutableArray *returnArray = nil;
    for (HGGSGrocerySection * section in [self grocerySections])
    {
        NSRange locationOfString =[[section name] rangeOfString:stringToMatch options:NSCaseInsensitiveSearch];
        if (locationOfString.location != NSNotFound)
        {
            if (returnArray == nil)
                returnArray = [[NSMutableArray alloc] init];
            
            [returnArray  addObject:section];
        }
    }
    return returnArray;

}

-(HGGSGrocerySection *)findGrocerySection:(NSString *)stringToMatch
{

    for (HGGSGrocerySection * section in [self grocerySections])
    {
        if ([[stringToMatch uppercaseString] isEqualToString:[[section name] uppercaseString]])
             return section;
    }
    return nil;
    
}

#pragma mark NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    HGGSGroceryAisle *copy = [[HGGSGroceryAisle alloc] init];
    NSMutableArray *copyOfSections = [[NSMutableArray alloc] initWithArray:[self grocerySections]  copyItems:YES ];
    [copy setNumber:[self number]];
    [copy setGrocerySections:copyOfSections];
    
    
    return copy;
}

@end
