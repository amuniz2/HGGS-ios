//
//  HGGSGrocerySection.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/30/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSGrocerySection.h"
#import "HGGSGroceryItem.h"

@implementation HGGSGrocerySection
#pragma mark Initialization

-(id)initWithDetails:(NSString*)name aisle:(NSInteger)aisle order:(NSInteger)order groceryItemsInSection:(NSMutableArray*)groceryItems
{
    self = [super init];
    if (self)
    {
        [self setName:name];
        [self setAisle:aisle];
        [self setOrder:order];
        _groceryItems = [[NSMutableArray alloc] init];
        
        for (NSDictionary  *item in groceryItems)
        {
            [_groceryItems addObject:[[HGGSGroceryItem alloc] initFromDictionary:item imagesFolder:[self  imagesFolder]]];
        }
    }
    return self;
}

-(id)initWithOldDetails:(NSString*)name aisle:(int)aisle order:(int)order sectionId:(NSString*)sectionId groceryItemsInSection:(NSMutableArray*)groceryItems
{
    self = [self initWithDetails:name aisle:aisle order:order groceryItemsInSection:groceryItems];
    if (self)
    {
        [self setSectionId:sectionId];
    }
    return self;
    
}
-(id)initFromDictionary:(NSDictionary*)itemAttributes imagesFolder:(NSString *)imagesFolder
{
    _imagesFolder = imagesFolder;
    self = [self initWithOldDetails:[itemAttributes objectForKey:@"name"]
                              aisle:[[itemAttributes objectForKey:@"order" ] intValue]
                              order:[[itemAttributes objectForKey:@"index" ] intValue]
                          sectionId:[itemAttributes objectForKey:@"id"]
              groceryItemsInSection:[itemAttributes objectForKey:@"groceryItems"]
            ];
    
    return self;
}
#pragma mark Public Methods
-(NSDictionary*)asDictionary
{
    NSMutableArray * arrayOfSerialiableItems = nil;
    if ((_groceryItems !=nil) && ([_groceryItems count] > 0))
    {
        arrayOfSerialiableItems = [[NSMutableArray alloc] init];
        for (HGGSGroceryItem *item in _groceryItems)
        {
            [arrayOfSerialiableItems addObject:[item asDictionary]];
        }
    }

    _asDictionary =[[NSDictionary alloc] initWithObjectsAndKeys:
                    (_sectionId) ? _sectionId : [[NSUUID UUID] UUIDString] ,@"id",
                    _name, @"name",
                    [NSNumber numberWithInteger:_aisle],@"order",
                    [NSNumber numberWithInteger:_order],@"index",
                    arrayOfSerialiableItems, @"groceryItems",
                    nil];
    
    return _asDictionary;
}
-(void)setAisle:(NSInteger)aisle
{
    if (_aisle != aisle)
    {
        NSInteger  fromAisleNumber = _aisle;
        _aisle = aisle;
        [[self delegate] didChangeAisle:self fromAisleNumber:fromAisleNumber toAisleNumber:aisle];
        
    }
}
#pragma mark Overides
- (BOOL)isEqual:(id)someSection
{
    return [[self name] isEqual:[someSection name]];
}

#pragma mark NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    HGGSGrocerySection *copy = [[HGGSGrocerySection alloc] init];
    
    [copy setAisle:[self aisle]];
    [copy setName:[self name]];
    [copy setOrder:[self order]];
    [copy setSectionId:[self sectionId]];
    
    return copy;
}

@end
