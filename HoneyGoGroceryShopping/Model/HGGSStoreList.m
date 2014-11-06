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

#import "HGGSGroceryStore.h"

@implementation HGGSStoreList
{
 
}
#pragma mark Class Methods

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
-(id)initWithFile:(NSString*)fileName store:(id)store
{
    self = [super init];
    if (self)
    {
        _fileName = fileName;
        _store = store;
        _delegate = store;
        //[self load];
    }
    return self;
}
#pragma mark Property Overrides
-(bool) fileExists
{
    NSString* localFilePath = [self filePath];
    return  [[NSFileManager defaultManager] fileExistsAtPath:localFilePath isDirectory:nil];
}

-(NSUInteger) itemCount
{
    return [_list count];
    
}
-(NSString*)filePath
{
    NSString *localFolder = [[self store] localFolder];
    return [localFolder stringByAppendingPathComponent:[self fileName]];
}
-(NSDate *)lastModificationDate
{
    NSString* localFilePath = [self filePath];
    NSDictionary *attrs = nil;
    
    if ([self fileExists])
        attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:localFilePath error:nil];
    
    if (!attrs)
        return [NSDate distantPast];
    
    return (NSDate *)[attrs objectForKey:NSFileModificationDate];
    
}
-(NSString *)storeName
{
    return [_store name];
}
#pragma mark Public Methods

-(NSMutableArray*)copyOfList
{
    return[[NSMutableArray alloc] initWithArray:[self list]  copyItems:YES ];
}


-(void)insertAisle:(HGGSGroceryAisle*)aisle atIndex:(NSInteger)index
{

}

-(void)load
{
    NSString *filePath = [[[self store  ]localFolder] stringByAppendingPathComponent:[self fileName]];
    NSString *fileContents = [_delegate loadFile:filePath];
    [self loadListFromString:fileContents ];
}
-(void)reload
{
    if ([self exists])
        [self load];
}

-(bool) save
{
    // [prior to saving, determine if anything has changed
    NSString *filePath = [[[self store] localFolder] stringByAppendingPathComponent:[self fileName]];
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
