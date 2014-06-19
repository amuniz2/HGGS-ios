//
//  HGGSStoreList.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSStoreList.h"
#import "HGGSGroceryItem.h"
#import "HGGSGroceryAisle.h"
#import "HGGSGrocerySection.h"



@implementation HGGSStoreList
{
 
}
#pragma mark Class Methods
/*
 +(HGGSStoreList*) createListOfGroceryItems:(NSString*)storeFolder store:(id)store fileName:(NSString *)fileName list:(NSMutableArray*)list
{
    return [[HGGSStoreList alloc] initWithList:[HGGSStoreList convertItemsToDictionary:list] fileName:fileName store:store storeFolder:storeFolder typeOfList:items];
}

+(HGGSStoreList*) createListOfGroceryAisles:(NSString*)storeFolder store:(id)store fileName:(NSString *)fileName list:(NSMutableArray*)list
{
    return [[HGGSStoreList alloc] initWithList:[HGGSStoreList convertAisleSectionsToDictionary:list] fileName:fileName store:store storeFolder:storeFolder typeOfList:aisles];
}
+(HGGSStoreList*) createListOfShoppingItems:(NSString*)storeFolder store:(id)store fileName:(NSString *)fileName list:(NSMutableArray*)list
{
    return [[HGGSStoreList alloc] initWithList:[HGGSStoreList convertAisleSectionsToDictionary:list] fileName:fileName store:store storeFolder:storeFolder typeOfList:shoppingItems];
}
*/
+(NSMutableDictionary*)convertItemsToDictionary:(NSArray*)items
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    for (HGGSGroceryItem * item in items)
    {
        [keys addObject:[item name]];
    }
    return [NSMutableDictionary dictionaryWithObjects:items forKeys:keys];
}
+(NSMutableDictionary*)convertAisleSectionsToDictionary:(NSArray*)aisles
{
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    for (HGGSGroceryAisle * aisle in aisles)
    {
        [keys addObject:[NSNumber numberWithInteger:[aisle number]]];
    }
    return [NSMutableDictionary dictionaryWithObjects:aisles forKeys:keys];
}

#pragma mark Initializers
-(id)initWithFile:(NSString*)fileName store:(id)store storeFolder:(NSString*)localFolder
{
    self = [super init];
    if (self)
    {
        _fileName = fileName;
        _store = store;
        _delegate = store;
        _localFolder = localFolder;
        //[self load];
    }
    return self;
}
#pragma mark Property Overrides
-(bool) fileExists
{
    NSString* localFilePath = [self filePath];
    return  [[NSFileManager defaultManager] fileExistsAtPath:localFilePath isDirectory:NO];
}

-(NSUInteger) itemCount
{
    return [_list count];
    
}
-(NSString*)filePath
{
    return [[self localFolder] stringByAppendingPathComponent:[self fileName]];
}
-(NSDate *)lastModificationDate
{
    NSDate* date = nil;
    NSString* localFilePath = [self filePath];
    NSDictionary *attrs = nil;
    
    if ([self fileExists])
        attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:localFilePath error:nil];
    
    if (!attrs)
        return [NSDate distantPast];
    
    return (NSDate *)[attrs objectForKey:NSFileModificationDate];
    
}
/*
-(NSArray*)list
{
    return [_groceryItems allValues];
}
-(void)setList:(NSArray *)listAsArray
{
    switch ([self typeOfList] )
    {
        case items:
            _list = [HGGSStoreList convertItemsToDictionary:listAsArray];
            break;
        case shoppingItems:
        case aisles:
            _list = [HGGSStoreList convertAisleSectionsToDictionary:listAsArray];
            break;
    }
}
*/
-(NSString *)storeName
{
    return [_store name];
}
#pragma mark Public Methods
/*
 -(NSInteger)addAisle:(HGGSGroceryAisle *)newAisle
{
    NSNumber *key = [NSNumber numberWithInteger:[newAisle number]];
    HGGSGroceryAisle* existingItem = [_groceryItems objectForKey:key];
    if (existingItem != nil)
        return -1;
    
    [_groceryItems addEntriesFromDictionary:[NSDictionary dictionaryWithObject:newAisle forKey:key]];
    return [_list count] - 1 ;
    
}

-(NSInteger)addItem:(HGGSGroceryItem *)newItem
{
    HGGSGroceryItem* existingItem = [_list objectForKey:[newItem name]];
    if (existingItem != nil)
        return -1;
    
    [_groceryItems addEntriesFromDictionary:[NSDictionary dictionaryWithObject:newItem forKey:[newItem name]]];
    return [_list count] - 1 ;
 
}
*/
-(NSMutableArray*)copyOfList
{
    return[[NSMutableArray alloc] initWithArray:[self list]  copyItems:YES ];
}


-(void)insertAisle:(HGGSGroceryAisle*)aisle atIndex:(NSInteger)index
{

}

/*
 -(HGGSGroceryItem*) itemAt:(NSUInteger)index
{
    return [[_groceryItems allKeys] objectAtIndex:index];
    
}
-(HGGSGroceryItem*) item:(NSString *)key
{
    return [_groceryItems objectForKey:key ];
    
}

-(void)remove:(NSString *)key
{
    [_groceryItems removeObjectForKey:key];
    
    //[_list removeObject:item];
}
-(void)removeItem:(HGGSGroceryItem *)item
{
    // todo: changing name of an item requires us to remove previous key and add new one
    [_groceryItems removeObjectForKey:[item name]];
    
    //[_list removeObject:item];
}

-(HGGSGroceryAisle*) aisleAt:(NSUInteger)index
{
    return [[_groceryItems allKeys] objectAtIndex:index];
    
}
*/
-(void)load
{
    NSString *filePath = [[self localFolder] stringByAppendingPathComponent:[self fileName]];
    NSString *fileContents = [_delegate loadFile:filePath];
    [self loadListFromString:fileContents ];
}
/*
-(NSMutableDictionary *)loadListFromString:(NSString*)fileContents
{
    switch (_typeOfList)
    {
        case items:
            return [HGGSStoreList convertItemsToDictionary:[self loadGroceryItemsFromString:fileContents]];
            
            
        case shoppingItems:
            return [HGGSStoreList convertAisleSectionsToDictionary:[self loadGrocerySectionsFromString:fileContents ]];
            
        case aisles:
            return [HGGSStoreList convertAisleSectionsToDictionary:[self loadGrocerySectionsFromString:fileContents ]];
    }
}


-(NSMutableArray *)loadGroceryItemsFromString:(NSString *) jsonString
{
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSArray* items = [NSJSONSerialization
                      JSONObjectWithData:jsonData //1
                      options:kNilOptions
                      error:&error];
    
    for (NSDictionary *item in items)
    {
        HGGSGroceryItem * groceryItem = [[HGGSGroceryItem alloc] initFromDictionary:item];
        
        [list addObject:groceryItem];
        
        //todo: if sectionId is used vs section, set the section using the sectionId
        [_delegate setSectionIfSectionIdIsUsed:groceryItem];
        //todo: remove logic from the EditGroceryItemController...
    }
    return list;
}

-(NSMutableArray*)loadGrocerySectionsFromString:(NSString *) jsonString
{
    HGGSGroceryAisle *currentAisle;
    NSMutableArray *sectionsInAisle;
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSMutableArray *list = [[NSMutableArray alloc] init];
    NSArray* sections = [NSJSONSerialization
                         JSONObjectWithData:jsonData //1
                         options:kNilOptions
                         error:&error];
    
    NSInteger currentAisleNumber = -1;
    for (NSDictionary *sectionAsDictionary in sections)
    {
        HGGSGrocerySection * grocerySection = [[HGGSGrocerySection alloc] initFromDictionary:sectionAsDictionary];
        [grocerySection setDelegate:_store];
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
*/
-(void)reload
{
    if ([self exists])
        [self load];
}

-(bool) save
{
    // [prior to saving, determine if anything has changed
    NSString *filePath = [[self localFolder] stringByAppendingPathComponent:[self fileName]];
    NSString *listInFile  = [_delegate loadFile:filePath];
    NSString *serializedList = [self serializeList];
    if (![listInFile isEqualToString:serializedList])
    {
        return [_delegate saveFile:filePath contents:serializedList];
    }
    return NO;
}
-(void) deleteList
{
    if ([self fileExists])
        [[NSFileManager defaultManager] removeItemAtPath:[self filePath] error:nil];
}
/*
-(NSString*)serializeList:(listType)typeOfList
{
    switch(_typeOfList)
    {
        case items:
            return [self serializeGroceryItemList];
        
        case shoppingItems:
            // todo:
            return [self serializeGroceryAisles];

        case aisles:
            return [self serializeGroceryAisles];
    }
    return nil;
}
*/
-(NSString*)serializeGroceryItemList
{
    NSError* error;
    
    NSMutableArray * arrayOfSerialiableItems = [[NSMutableArray alloc] init];
    for (HGGSGroceryItem *item in _list)
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
-(NSInteger)addItem:(HGGSGroceryItem *)newItem
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(HGGSGroceryItem*) itemAt:(NSInteger)index
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
    
}

-(void)removeItem:(HGGSGroceryItem *)item
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}


-(NSString*) serializeList
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}
-(void)loadListFromString:(NSString*)fileContents
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}
-(NSMutableArray*)findItems:(NSString*)stringToSearchFor
{
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

@end
