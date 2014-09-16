//
//  GroceryItem.m
//  Grocery List Single View
//
//  Created by Ana Muniz on 9/19/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/NSJSONSerialization.h>
#import "HGGSGroceryItem.h"
#import "HGGSDate.h"

@implementation HGGSGroceryItem
#pragma mark Initialization Methods
-(id)initFromDictionary:(NSDictionary*)itemAttributes
{
    double quantity =(double)[[itemAttributes objectForKey:@"quantity" ] doubleValue];
    
    self = [self initWithOldDetails:[itemAttributes objectForKey:@"name"]
                        quantity:quantity
                        unit:[itemAttributes objectForKey:@"unit"]
                        section:[itemAttributes objectForKey:@"section"]
                        notes:[itemAttributes objectForKey:@"notes"]
                        select:[HGGSBool stringAsBool:[itemAttributes objectForKey:@"selected"]]
                        lastPurchasedOn:[HGGSDate stringAsDate:[itemAttributes objectForKey:@"lastPurchasedDate"]]
                        sectionId:[itemAttributes objectForKey:@"category"]
            ];
    
    return self;
}

-(id)initWithOldDetails:(NSString*)name quantity:(double)amount unit:(NSString *)unitDescription section:(NSString *)grocerySection notes:(NSString*)notes select:(bool)selected lastPurchasedOn:(NSDate*)lastPurchasedDate sectionId:(NSString *)sectionId
{
    self = [self initWithDetails:name quantity:amount unit:unitDescription section:grocerySection notes:notes select:selected lastPurchasedOn:lastPurchasedDate];
    if (self)
    {
        [self setSectionId:sectionId];
    
    }
    return self;
}

-(id)initWithDetails:(NSString*)name quantity:(double)amount unit:(NSString *)unitDescription section:(NSString *)grocerySection notes:(NSString*)notes select:(bool)selected lastPurchasedOn:(NSDate*)lastPurchasedDate
{
    
    self = [super init];
    if (self)
    {
        [self setLastPurchasedDate:lastPurchasedDate];
        _name = name;
        [self setNotes:notes];
        [self setQuantity:amount];
        [self setUnit:unitDescription];
        [self setSection:grocerySection];
        [self setSelected:selected];
        [self setLastPurchasedDate:lastPurchasedDate];
        
    }
    return self;
}
-(id)init
{
    NSString* emptyString = @"";
    self = [self initWithDetails:emptyString quantity:1 unit:emptyString section:emptyString notes:emptyString select:YES lastPurchasedOn:nil];
    if (self)
    {
        [self setSectionId:emptyString];
    }
    return self;
}

#pragma mark Public Methods
-(NSDictionary*)asDictionary
{
    _asDictionary =[[NSDictionary alloc] initWithObjectsAndKeys:
                    _name,@"name",
                    [NSNumber numberWithDouble:_quantity],@"quantity",
                    (_unit == nil) ? @"" : _unit, @"unit",
                    (_notes == nil) ? @"" : _notes, @"notes",
                    [HGGSBool boolAsString:_selected], @"selected",
                    /*(_sectionId == nil) ? @"" : _sectionId, @"category",*/
                    (_section == nil) ? @"" : _section, @"section",
                    [HGGSDate dateAsString:_lastPurchasedDate], @"lastPurchasedDate",
                    nil];
    return _asDictionary;
}

#pragma mark NSObject Overrides
-(NSString *)description
{
    return [self name];
}
- (BOOL)isEqual:(id)someItem
{
    return [[self name] isEqual:[someItem name]];
}

#pragma mark NSCopying 
-(id)copyWithZone:(NSZone *)zone
{
    HGGSGroceryItem *copy = [[HGGSGroceryItem alloc] initWithDetails:[self name]
                                                            quantity:[self quantity]
                                                                unit:[self unit]
                                                             section:[self section]
                                                               notes:[self notes]
                                                              select:[self selected]
                                                     lastPurchasedOn:[self lastPurchasedDate]];
    
    [copy setSectionId:[self sectionId]];
    
    return copy;
}

#pragma mark Private
- (NSComparisonResult) compareWithAnotherItem:(HGGSGroceryItem*) anotherItem
{
    NSComparisonResult sectionResult = [[self section] compare:[anotherItem section] options:NSCaseInsensitiveSearch];
    if (sectionResult != NSOrderedSame)
        return sectionResult;
    
    //return [[self name] caseInsensitiveCompare:[anotherItem name]];
    return [[self name] compare:[anotherItem name] options:NSCaseInsensitiveSearch];
}

@end

