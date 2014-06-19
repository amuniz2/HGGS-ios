//
//  HGGSGrocerySection.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/30/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSGrocerySection.h"

@implementation HGGSGrocerySection

-(id)initWithDetails:(NSString*)name aisle:(int)aisle order:(int)order
{
    self = [super init];
    if (self)
    {
        [self setName:name];
        [self setAisle:aisle];
        [self setOrder:order];        
    }
    return self;
}

-(id)initWithOldDetails:(NSString*)name aisle:(int)aisle order:(int)order sectionId:(NSString*)sectionId
{
    self = [self initWithDetails:name aisle:aisle order:order];
    if (self)
    {
        [self setSectionId:sectionId];
    }
    return self;
    
}
-(id)initFromDictionary:(NSDictionary*)itemAttributes
{
    self = [self initWithOldDetails:[itemAttributes objectForKey:@"name"]
                              aisle:[[itemAttributes objectForKey:@"aisle" ] intValue]
                              order:[[itemAttributes objectForKey:@"order" ] intValue]
                          sectionId:[itemAttributes objectForKey:@"category"]
            ];
    
    return self;
}

@end
