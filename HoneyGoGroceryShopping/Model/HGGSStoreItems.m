//
//  HGGSStoreList.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSGroceryItem.h"
#import "HGGSGroceryAisle.h"
#import "HGGSGrocerySection.h"
#import "HGGSStoreItems.h"



@implementation HGGSStoreItems
{
    NSMutableDictionary *_list;
    NSMutableArray * _sortedList;
}
#pragma mark Class Methods
+(HGGSStoreItems*) createList:(NSString *)fileName store:(id)store list:(NSMutableArray*)list
{
    return [[HGGSStoreItems alloc] initWithFile:fileName store:store];
}

+(NSMutableDictionary*)convertItemsToDictionary:(NSArray*)items
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    for (HGGSGroceryItem * item in items)
    {
        [keys addObject:[item name]];
    }
    return [NSMutableDictionary dictionaryWithObjects:items forKeys:keys];
}

#pragma mark Initializers
-(id)initWithFile:(NSString*)fileName store:(id)store
{
    
    self = [super initWithFile:fileName store:store];
    _sortedList = nil;
    return self;
}
#pragma mark Property Overrides
-(NSUInteger) itemCount
{
    return [_list count];
    
}

-(NSArray*)list
{
    if (_sortedList == nil)
        [self sortList];
    
    return _sortedList;
}

-(void)setList:(NSMutableArray *)listAsArray
{
    _list = [HGGSStoreItems convertItemsToDictionary:listAsArray];
    [self sortList];
}
-(bool)exists
{
    return (_list != nil);
}

#pragma mark Public Methods

-(NSInteger)addItem:(HGGSGroceryItem *)newItem
{
    HGGSGroceryItem* existingItem = [_list objectForKey:[newItem name]];
    if (existingItem != nil)
        return -1;

    [newItem setImagesFolder:[[self store] imagesFolder] ];
    [_list addEntriesFromDictionary:[NSDictionary dictionaryWithObject:newItem forKey:[newItem name]]];
    [self sortList];
    
    return [[self list] indexOfObject:newItem];
 
}
-(NSInteger)getAisleNumberForItem:(HGGSGroceryItem *)item
{
    return [[self delegate] getAisleForItem:item];
}

-(void)sortList
{
    _sortedList = [[NSMutableArray alloc] init];
    
    //NSArray* sortedKeys = [_list keysSortedByValueUsingSelector:@selector(compareWithAnotherItem:)];
    
    NSArray* sortedKeys = [_list keysSortedByValueUsingComparator: ^(id obj1, id obj2)
    {
        NSInteger obj1Aisle = [self getAisleNumberForItem:obj1];
        NSInteger obj2Aisle = [self getAisleNumberForItem:obj2];
        
        if (obj1Aisle == obj2Aisle)
            return [obj1 compareWithAnotherItem:obj2];
        
        if (obj2Aisle > obj1Aisle)
            return NSOrderedAscending;
        
        return NSOrderedDescending;
            
    }];
    
    for (NSString* key in sortedKeys)
    {
        [_sortedList addObject:[_list objectForKey:key]];
    }
    
}

-(NSMutableArray*)copyOfList
{
    return[[NSMutableArray alloc] initWithArray:[self list]  copyItems:YES ];
}


-(NSArray*)findItems:(NSString*)stringToSearchFor
{
    if ([stringToSearchFor length] == 0)
        return [self list];
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    NSRange locationOfString;
    
    NSEnumerator *keyEnumerator = [_list keyEnumerator];
    
    for (NSString * itemName in keyEnumerator)
    {
        locationOfString =[itemName rangeOfString:stringToSearchFor options:NSCaseInsensitiveSearch];
        if (locationOfString.location != NSNotFound)
        {
            [results addObject:[_list objectForKey:itemName]];
        }
    }
    
    return results;
}


-(id) itemAt:(NSInteger)index
{
    return [[self list] objectAtIndex:index];
    
}
-(HGGSGroceryItem*) itemWithKey:(NSString *)key
{
    return [_list objectForKey:key ];
    
}
-(bool) itemExists:(NSString *)key
{
    return ([self itemWithKey:key] != nil);
}

-(void)remove:(NSString *)key
{
    [_list removeObjectForKey:key];
    [self sortList];
    
 }
-(void)removeItem:(id)item
{
    [self remove:[item name]];
}



-(void)loadListFromString:(NSString*)fileContents
{
    _list = [HGGSStoreItems convertItemsToDictionary:[self loadGroceryItemsFromString:fileContents]];
    
 }



-(NSString*)serializeList
{
    return [self serializeGroceryItemList];
}


-(void)unload
{
    _list = nil;
}

#pragma mark Private

-(NSMutableArray *)loadGroceryItemsFromString:(NSString *) jsonString
{
    NSMutableArray *listAsArray = [[NSMutableArray alloc] init];
    
    if (jsonString == nil)
        return listAsArray;

    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSArray* items = [NSJSONSerialization
                      JSONObjectWithData:jsonData //1
                      options:kNilOptions
                      error:&error];
    
    for (NSDictionary *item in items)
    {
        HGGSGroceryItem * groceryItem = [[HGGSGroceryItem alloc] initFromDictionary:item imagesFolder:[[self store]  imagesFolder]];
        
        [listAsArray addObject:groceryItem];
        
        //todo: if sectionId is used vs section, set the section using the sectionId
        [[self delegate] setSectionIfSectionIdIsUsed:groceryItem];
        //todo: remove logic from the EditGroceryItemController...
    }
    //[listAsArray sortUsingSelector:@selector(compareWithAnotherItem:)];
    return listAsArray;
}

-(NSString*)serializeGroceryItemList
{
    NSError* error;
    
    NSMutableArray * arrayOfSerialiableItems = [[NSMutableArray alloc] init];
    for (HGGSGroceryItem *item in [self list])
    {
        [arrayOfSerialiableItems addObject:[item asDictionary]];
    }
    NSData* jsonData = [NSJSONSerialization
                        dataWithJSONObject:arrayOfSerialiableItems
                        options:kNilOptions
                        error:&error];
    
    return [[NSString alloc]  initWithBytes:[jsonData bytes]
                                     length:[jsonData length] encoding: NSUTF8StringEncoding];
    
}

@end
