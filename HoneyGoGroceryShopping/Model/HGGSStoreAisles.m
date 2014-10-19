//
//  HGGSStoreList.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSStoreAisles.h"
#import "HGGSGroceryItem.h"
#import "HGGSGroceryAisle.h"
#import "HGGSGrocerySection.h"



@implementation HGGSStoreAisles
{
    NSMutableArray *_list;
}
#pragma mark Class Methods
+(HGGSStoreList*) createList:(NSString*)storeFolder store:(id)store fileName:(NSString *)fileName list:(NSMutableArray*)list
{
    return [[HGGSStoreAisles alloc] initWithList:list fileName:fileName store:store storeFolder:storeFolder];
}

#pragma mark Initializers
-(id)initWithList:(NSMutableArray*)list fileName:(NSString*)fileName store:(id)store storeFolder:(NSString*)localFolder
{
    self = [super initWithFile:fileName store:store storeFolder:localFolder];
    if (self)
    {
        _list = list;
    }
    return self;
}
#pragma mark Property Overrides
-(NSUInteger) itemCount
{
    return [_list count];
    
}
-(bool)exists
{
    return (_list != nil);
}

-(NSMutableArray*)list
{
    return _list;
}

-(void)setList:(NSMutableArray *)listAsArray
{
    _list = listAsArray;
}

#pragma mark Public Methods
-(NSInteger)addItem:(id)newAisle
{
    NSInteger index = [self findAisleWithSameNumber:newAisle];
    if (index >= 0)
        return index;
    
    [_list addObject:newAisle];
    return [_list count] - 1 ;
    
}
-(NSInteger)findAisleWithSameNumber:(HGGSGroceryAisle *)newAisle
{
    NSInteger i = 0;
    for (HGGSGroceryAisle* aisle in _list)
    {
        if ([aisle number] == [newAisle number])
            return i;
        i++;
    }
    return -1;
    
}
-(HGGSGrocerySection *) findGrocerySection:(NSString*) name
{
    for(HGGSGroceryAisle* groceryAisle in [self list])
    {
        for(HGGSGrocerySection *section in [groceryAisle grocerySections])
        {
            if ([name isEqualToString:[section name]])
            {
                return section;
            }
        }
    }
    return nil;
}

-(HGGSGroceryAisle *)findAisleForGrocerySection:(HGGSGrocerySection*)section
{
    HGGSGroceryAisle* result = nil;
    
    for (HGGSGroceryAisle* aisle in _list)
    {
        if ([section aisle] == [aisle number])
        {
            result = aisle;
            break;
        }
    }
    return result;
}


-(NSMutableArray*)copyOfList
{
    return[[NSMutableArray alloc] initWithArray:[self list]  copyItems:YES ];
}


-(void)insertAisle:(HGGSGroceryAisle*)aisle atIndex:(NSInteger)index
{
    [_list insertObject:aisle atIndex:index];
}

#pragma mark Method Overrides
-(NSMutableArray *)findItems:(NSString *)stringToSearchFor
{
    NSMutableArray *searchResults = [[NSMutableArray alloc] init];
    NSMutableArray *matchingSectionsInAisle;
    HGGSGroceryAisle *aisleWithMatchingSections;
    
    for (HGGSGroceryAisle *aisle in _list)
    {
        matchingSectionsInAisle = [aisle findMatchingGrocerySections:stringToSearchFor];
        if (matchingSectionsInAisle != nil)
        {
            aisleWithMatchingSections = [[HGGSGroceryAisle alloc] init];
            [aisleWithMatchingSections setGrocerySections:matchingSectionsInAisle];
            [searchResults addObject:aisleWithMatchingSections];
            
        }
    }
    return searchResults;
}

-(id) itemAt:(NSInteger)index
{
    return [_list objectAtIndex:index];
    
}

-(void)removeItem:(HGGSGroceryAisle *)item
{
    [_list removeObject:item];
    
}


-(void)loadListFromString:(NSString*)fileContents
{
    
    _list = [self loadGrocerySectionsFromString:fileContents ];
 
}

#pragma mark Private
-(NSMutableArray*)loadGrocerySectionsFromString:(NSString *) jsonString
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    if (jsonString == nil)
        return list;
    
    HGGSGroceryAisle *currentAisle;
    NSMutableArray *sectionsInAisle;
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    
    NSArray* sections = [NSJSONSerialization
                         JSONObjectWithData:jsonData //1
                         options:kNilOptions
                         error:&error];
    
    NSInteger currentAisleNumber = -1;
    for (NSDictionary *sectionAsDictionary in sections)
    {
        HGGSGrocerySection * grocerySection = [[HGGSGrocerySection alloc] initFromDictionary:sectionAsDictionary imagesFolder:[[self store] imagesFolder]];
        
        [grocerySection setDelegate:[self store]];
        if (currentAisleNumber != [grocerySection aisle])
        {
            currentAisleNumber = [grocerySection aisle];
            currentAisle = [[HGGSGroceryAisle alloc] init];
            [currentAisle setNumber:currentAisleNumber];
            sectionsInAisle = [[NSMutableArray alloc] init];
            [currentAisle setGrocerySections:sectionsInAisle];
            [list addObject:currentAisle];
        }
        [sectionsInAisle addObject:grocerySection];
    }
    return [self sortGroceryAisles:list];
    //return list;
}


-(NSString*)serializeList
{
    return [self serializeGroceryAisles];
 
}


-(NSString*)serializeGroceryAisles
{
    NSError* error;
    
    NSMutableArray * arrayOfSerialiableItems = [[NSMutableArray alloc] init];
    for (HGGSGroceryAisle *aisle in _list)
    {
        for (HGGSGrocerySection *section in [aisle grocerySections])
        {
            [arrayOfSerialiableItems addObject:[section asDictionary]];
        }
    }
    NSData* jsonData = [NSJSONSerialization
                        dataWithJSONObject:arrayOfSerialiableItems
                        options:kNilOptions
                        error:&error];
    
    return [[NSString alloc]  initWithBytes:[jsonData bytes]
                                     length:[jsonData length] encoding: NSUTF8StringEncoding];
    
}
-(void)unload
{
    _list = nil;
}
#pragma mark Private
-(NSMutableArray*)sortGrocerySections:(NSArray*)sections
{
    NSSortDescriptor* sortByAisle = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    //NSSortDescriptor* sortByIndex = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    //NSSortDescriptor* sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    return [[NSMutableArray alloc] initWithArray:[sections sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortByAisle, /*sortByIndex, sortByName,*/ nil]]];
    
}

-(NSMutableArray*)sortGroceryAisles:(NSArray*)aisles
{
    NSSortDescriptor* sortByAisleNumber = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    //NSSortDescriptor* sortByIndex = [[NSSortDescriptor alloc] initWithKey:@"order" ascending:YES];
    //NSSortDescriptor* sortByName = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    
    return [[NSMutableArray alloc] initWithArray:[aisles sortedArrayUsingDescriptors:[NSArray arrayWithObjects:sortByAisleNumber, /*sortByIndex, sortByName,*/ nil]]];
    
}

-(HGGSGrocerySection*) insertNewGrocerySection:(NSString*)name inAisle:(NSInteger)aisleNumber atSectionIndex:(NSInteger)sectionIndex
{
    HGGSGrocerySection* newItem = [[HGGSGrocerySection alloc] init];
    [newItem setName:name];
    [newItem setAisle:aisleNumber] ;
    [newItem setDelegate:[self store]];
    
    [self insertGrocerySection:newItem atSectionIndex:sectionIndex];
    return newItem;
}
-(HGGSGroceryAisle*)insertGrocerySection:(HGGSGrocerySection*)section  atSectionIndex:(NSInteger)sectionIndex
{
    NSInteger aisleNumber = [section aisle];
    HGGSGroceryAisle* groceryAisleForSection = nil;
    NSInteger aisleIndex = 0;
    
    for(HGGSGroceryAisle* groceryAisle in [self list])
    {
        if (aisleNumber == [groceryAisle number])
        {
            groceryAisleForSection = groceryAisle;
            [[groceryAisle grocerySections] insertObject:section atIndex:sectionIndex];
            break;
        }
        else if (aisleNumber < [groceryAisle number])
        {
            // create new aisle
            break;
        }
        aisleIndex++;
    }
    if (!groceryAisleForSection)
    {
        groceryAisleForSection = [HGGSGroceryAisle createWithGrocerySection:section];
        [self insertAisle:groceryAisleForSection atIndex:aisleIndex];
    }
    return groceryAisleForSection;
    
}

@end
