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
    NSInteger quantity =[[itemAttributes objectForKey:@"quantity" ] intValue];
    
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

-(id)initWithOldDetails:(NSString*)name quantity:(int)amount unit:(NSString *)unitDescription section:(NSString *)grocerySection notes:(NSString*)notes select:(bool)selected lastPurchasedOn:(NSDate*)lastPurchasedDate sectionId:(NSString *)sectionId
{
    self = [self initWithDetails:name quantity:amount unit:unitDescription section:grocerySection notes:notes select:selected lastPurchasedOn:lastPurchasedDate];
    if (self)
    {
        [self setSectionId:sectionId];
    }
    return self;
}
-(id)initWithDetails:(NSString*)name quantity:(int)amount unit:(NSString *)unitDescription section:(NSString *)grocerySection notes:(NSString*)notes select:(bool)selected lastPurchasedOn:(NSDate*)lastPurchasedDate
{
    
    self = [super init];
    if (self)
    {
        [self setLastPurchasedDate:lastPurchasedDate];
        [self setName:name];
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
    self = [self initWithDetails:emptyString quantity:0 unit:emptyString section:emptyString notes:emptyString select:NO lastPurchasedOn:nil];
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
                    [NSNumber numberWithInt:_quantity],@"quantity",
                    _unit, @"unit",
                    _notes, @"notes",
                    [HGGSBool boolAsString:_selected], @"selected",
                    _sectionId, @"category",
                    _section, @"section",
                    [HGGSDate dateAsString:_lastPurchasedDate], @"lastPurchasedDate",
                    nil];
    return _asDictionary;
}
-(NSString *)ToJson
{
   
    bool validJsonObject = [NSJSONSerialization isValidJSONObject:self];
    
    if (validJsonObject)
    {
        return _name;
//        return [NSJSONSerialization dataWithJSONObject:self  options:
        //<#(NSJSONWritingOptions)#> error:<#(NSError *__autoreleasing *)#>]
    }
    return _name;

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
@end

