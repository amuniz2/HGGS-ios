//
//  HGGSGroceryStore.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 9/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import "HGGSGroceryStore.h"
#import "HGGSGroceryItem.h"
#import "HGGSDate.h"
#import "HGGSStoreList.h"

#define STORE_INFO_FILE @"StoreInfo.json"
#define MASTER_LIST_FILE @"master_list.json"

@interface HGGSGroceryStore()
-(NSMutableArray*)loadGroceryItemsFromString:(NSString *) jsonString;

@end

@implementation HGGSGroceryStore

#pragma mark Class Methods
+(HGGSGroceryStore *)createStore:(NSString *)storeName
{
    NSError *error;
    HGGSGroceryStore* newStore = [[HGGSGroceryStore alloc] initWithStoreName:storeName];
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[newStore getGroceryListArchivePath] withIntermediateDirectories:YES attributes:nil error:&error])
    {
        NSLog(@"Error creating store %@ folder: %@", storeName, error);
    }
    else
    {
        [[NSFileManager defaultManager] createFileAtPath:[newStore getFileName:MASTER_LIST] contents:nil attributes:nil];
    }

    return newStore;
}
+(void)deleteStore:(HGGSGroceryStore *)storeToDelete
{
    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[storeToDelete getGroceryListArchivePath]] )
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[storeToDelete getFileName:MASTER_LIST]] )
        {
            
            if (![[NSFileManager defaultManager] removeItemAtPath:[storeToDelete getFileName:MASTER_LIST] error:&error])
                    NSLog(@"Error deleting store's master list: %@.  Error: %@", storeToDelete, error);
   
        }
                                                              
        if (![[NSFileManager defaultManager] removeItemAtPath:[storeToDelete getGroceryListArchivePath] error:&error])
            NSLog(@"Error deleting store's master list: %@.  Error: %@", storeToDelete, error);
    }
    
}

+(NSString*)getFileNameComponent:(storeFileType)fileType
{
    if (fileType == STORE)
        return STORE_INFO_FILE;
    else if (fileType == MASTER_LIST)
        return MASTER_LIST_FILE;
    
    return nil;
    
}

+(NSString *)getGroceryStorePath:(NSString *) storeName
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // for ios, there will only be one director in the list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:storeName];
}
#pragma mark Initializers
-(id)init
{
    return [super init ];
}
-(id)initWithStoreName:(NSString *)storeName
{
    self = [self init];
    if (self)
    {
        [self setName:storeName];
        [self loadStoreInfo];
        _storeLists = [[NSDictionary alloc] initWithObjectsAndKeys:
                       [HGGSStoreList create:[HGGSGroceryStore getFileNameComponent:MASTER_LIST] list:nil ],[NSNumber  numberWithInt:MASTER_LIST],
                       nil];

        
    }
    return self;
}
#pragma mark Public Methods
-(bool)anyListsLoaded
{
    if ([self itemsInList:MASTER_LIST])
        return YES;

    return NO;
}
-(HGGSGroceryItem *) createGroceryItemWithDetailsInList:(storeFileType)listType name:(NSString*) name quantity:(int)quantity unit:(NSString *)unit section:(NSString *) section notes:(NSString *)notes select:(bool)selected lastPurchasedOn:(NSDate*)lastPurchasedDate
{
    HGGSGroceryItem* newItem = [[HGGSGroceryItem alloc] initWithDetails:name quantity:quantity unit:unit section:section notes:notes select:selected lastPurchasedOn:lastPurchasedDate];
    if (newItem)
    {
        NSMutableArray* existingList = [[_storeLists objectForKey:[NSNumber numberWithInt:listType]] list];
        if (!existingList)
            existingList = [self loadList:listType];
        
        [existingList addObject:newItem];
    }
    return newItem;
}
-(HGGSGroceryItem *) createGroceryItemWithDetailsInList:(storeFileType)listType name:(NSString*) name quantity:(int)quantity unit:(NSString *)unit section:(NSString *) section notes:(NSString *)notes ;
{

    return[self createGroceryItemWithDetailsInList:listType name:name quantity:quantity unit:unit section:section notes:notes select:NO lastPurchasedOn:[NSDate distantPast] ];
}

-(NSArray*)findItems:(NSString*)stringToSearchFor inList:(storeFileType)listType
{
    NSMutableArray* results = [[NSMutableArray alloc] init];
    NSRange locationOfString;
    NSArray* itemsToSearch = [self itemsInList:listType];
    
    for (HGGSGroceryItem* item in itemsToSearch)
    {
        locationOfString =[[item name] rangeOfString:stringToSearchFor options:NSCaseInsensitiveSearch];
        if (locationOfString.location != NSNotFound)
        {
            [results addObject:item];
        }
        
    }
    return results;
}
-(NSString*)getFileName:(storeFileType)storeFileType
{
    NSString* fileNameWithoutPath;
    
    if (storeFileType == STORE)
        fileNameWithoutPath = STORE_INFO_FILE;
    else
    {
        HGGSStoreList* storeList = [_storeLists objectForKey:[NSNumber numberWithInt:storeFileType]];
        fileNameWithoutPath = [storeList fileName];
    }
    return [[self getGroceryListArchivePath] stringByAppendingPathComponent:fileNameWithoutPath];
}

-(NSString *)getGroceryListArchivePath
{
    return [HGGSGroceryStore getGroceryStorePath:[self Name]];
}
-(NSArray*) getGroceryListsFileNames:(NSString *)storeName
{
    NSMutableArray* fileNames = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator = [_storeLists keyEnumerator];
    id key;
    
    while ((key = [enumerator nextObject])) {
        /* code that acts on the dictionary’s values */
        [fileNames addObject:[self getFileName:[key intValue]]];
    }
    return fileNames;
}
-(NSArray *) getSharedFileNameComponents
{
    NSMutableArray* fileNameComponents = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator = [_storeLists objectEnumerator];
    HGGSStoreList* storeList;
    
    while (storeList = [enumerator nextObject]) {
        /* code that acts on the dictionary’s values */
        [fileNameComponents addObject:[storeList fileName]];
    }
    return fileNameComponents;
}
-(NSMutableArray*)itemsInList:(storeFileType)listType
{
 
    HGGSStoreList* storeList = [_storeLists objectForKey:[NSNumber numberWithInt:listType]];
    return [storeList list];
}
-(void)setItems:(NSMutableArray*)items listType:(storeFileType)listType
{
    HGGSStoreList* storeList = [_storeLists objectForKey:[NSNumber numberWithInt:listType]];
    [storeList setList:items];
    
}

-(NSMutableArray *)loadList:(storeFileType)listType
{
    NSMutableArray* list;
    NSString *fileContents = [self loadFile:[self getFileName:listType]];
    if (fileContents)
    {
        list = [self loadGroceryItemsFromString:fileContents];
    }
    else
    {
        list =  [[NSMutableArray alloc] init];
    }
    [self setItems:list listType:listType];
    return list;
}

-(void)reloadLists
{
    NSEnumerator *enumerator = [_storeLists keyEnumerator];
    id key;
    
    while ((key = [enumerator nextObject])) {
        /* code that acts on the dictionary’s values */
        [self loadList:[key intValue]];
    }
    
}
-(void)removeItem:(HGGSGroceryItem*)item fromList:(storeFileType)listType
{
    [[self itemsInList:listType] removeObject:item];
}


-(void)save
{
    NSEnumerator *enumerator = [_storeLists keyEnumerator];
    id key;

    [self saveStoreInfo];
    while ((key = [enumerator nextObject])) {
        /* code that acts on the dictionary’s values */
        [self saveList:[key intValue]];
    }
}

-(void) saveStoreInfo
{
    NSString *fileContents = [self serializeStoreInfo];
    [self saveFile:[[self getGroceryListArchivePath] stringByAppendingPathComponent:STORE_INFO_FILE] contents:fileContents ];
    
}

-(BOOL)saveList:(storeFileType) listType
{
    BOOL ret = [self saveListInFile:[self itemsInList:listType] fileName:[self getFileName:listType]];
    //[self setItems:nil listType:listType];
    /*if (ret)
        [[self delegate] didSaveList:listType storeName:_Name];
    */
    return ret;
}
-(void)unloadLists
{
    NSEnumerator *enumerator = [_storeLists keyEnumerator];
    id key;
    
    
    while ((key = [enumerator nextObject])) {
        [self setItems:nil listType:[key intValue]];
    }
    
}

#pragma mark Private Methods



-(NSString *) loadFile:(NSString *)fileName
{
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
        return nil;
 
    NSError *error;
    NSMutableString* stringContents = [[NSMutableString alloc] initWithContentsOfFile:fileName encoding:NSUTF8StringEncoding error:&error];
    [stringContents replaceOccurrencesOfString:@":true," withString:@":\"true\"," options:NSLiteralSearch range:NSMakeRange(0, [stringContents length])];
    [stringContents replaceOccurrencesOfString:@":false," withString:@":\"false\"," options:NSLiteralSearch range:NSMakeRange(0, [stringContents length])];
    return stringContents;
}
-(NSMutableArray*)loadGroceryItemsFromString:(NSString *) jsonString
{
    NSMutableArray *itemsLoaded = [[NSMutableArray alloc] init];
    NSData* jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError* error;
    NSArray* items = [NSJSONSerialization
                      JSONObjectWithData:jsonData //1
                      options:kNilOptions
                      error:&error];
    
    for (NSDictionary *item in items)
    {
        HGGSGroceryItem * groceryItem = [[HGGSGroceryItem alloc] initFromDictionary:item];
        
        [itemsLoaded addObject:groceryItem];
    }
    return itemsLoaded;
}

-(void)loadStoreInfo
{
    NSString *fileContents = [self loadFile:[[self getGroceryListArchivePath] stringByAppendingPathComponent:STORE_INFO_FILE]];
    if (fileContents)
    {
        NSData* jsonData = [fileContents dataUsingEncoding:NSUTF8StringEncoding];
        NSError* error;
        NSDictionary* storeAttributes = [NSJSONSerialization
                          JSONObjectWithData:jsonData //1
                          options:kNilOptions
                          error:&error];
        
        Boolean shareLists =[[storeAttributes objectForKey:@"ShareLists" ] boolValue];
        [self setShareLists:shareLists];
        [self setName:[storeAttributes objectForKey:@"Name"]];
        if (shareLists)
            [self setLastSyncDate:[HGGSDate stringAsDate:[storeAttributes objectForKey:@"LastSyncDate"]]];
        
    }
}
-(bool)saveFile:(NSString*)fileName contents:(NSString *) fileContents
{
    NSError *error  = nil;
    if ([fileContents writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:&error])
        return YES;
    
    if (error)
        NSLog(@"error writing to file: %@", error);
    else
        NSLog(@"failed to save file, but no error reported");
    
    return NO;
}
-(bool) saveListInFile:(NSArray*)listToSave fileName:(NSString*)fileName
{
    // [prior to saving, determine if anything has changed
    NSString *serializedList = [self serializeGroceryItemsToString:listToSave];
    NSString *listInFile  = [self loadFile:fileName];
    if (![listInFile isEqualToString:serializedList])
    {
        return [self saveFile:fileName contents:serializedList];
    }
    return NO;
}
-(void)saveLists
{
    [self saveList:MASTER_LIST];
}

-(NSString*)serializeGroceryItemsToString:(NSArray *) itemsToSerialize
{
    NSError* error;

    NSMutableArray * arrayOfSerialiableItems = [[NSMutableArray alloc] init];
    for (HGGSGroceryItem *item in itemsToSerialize)
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
-(NSString*)serializeStoreInfo
{
    NSError* error;
    
    NSMutableDictionary * storeProperties = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[self Name],@"Name",[NSNumber numberWithBool:[self ShareLists]],@"ShareLists",[HGGSDate dateAsString:[self lastSyncDate]], @"LastSyncDate",nil ];
    
    NSData* jsonData = [NSJSONSerialization
                        dataWithJSONObject:storeProperties
                        options:kNilOptions
                        error:&error];
    
    return [[NSString alloc]  initWithBytes:[jsonData bytes]
                                     length:[jsonData length] encoding: NSUTF8StringEncoding];
    
}


#pragma mark Overrides
- (BOOL)isEqual:(id)someStore
{
    return [[self Name] isEqual:[someStore Name]];
}

@end
