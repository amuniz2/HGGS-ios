//
//  HGGSGroceryStore.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 9/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSDate.h"
#import "HGGSCommon.h"
#import "HGGSGroceryAisle.h"
#import "HGGSGroceryItem.h"
#import "HGGSGrocerySection.h"
#import "HGGSGroceryStore.h"
#import "HGGSStoreAisles.h"
#import "HGGSStoreItems.h"

#define STORE_INFO_FILE @"StoreInfo.json"
#define MASTER_LIST_FILE @"master_list.json"
#define CURRENT_LIST_FILE @"current_list.json"
#define SHOPPING_LIST_FILE @"shopping_list.json"
#define AISLE_CONFIG_FILE @"category.json"

@interface HGGSGroceryStore () <NSCopying>
{
}

@end

@implementation HGGSGroceryStore

#pragma mark Class Methods
+(HGGSGroceryStore *)createStore:(NSString *)storeName
{
    NSError *error;
    HGGSGroceryStore* newStore = [[HGGSGroceryStore alloc] initWithStoreName:storeName];
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[newStore getLocalFolder] withIntermediateDirectories:YES attributes:nil error:&error])
    {
        NSLog(@"Error creating store %@ folder: %@", storeName, error);
    }
    else
    {
       // [[newStore getMasterList] create];
       // [[newStore getGroceryAisles] create];
       // [[NSFileManager defaultManager] createFileAtPath:[newStore getFileName:MASTER_LIST] contents:nil attributes:nil];
       // [[NSFileManager defaultManager] createFileAtPath:[newStore getFileName:AISLE_CONFIG] contents:nil attributes:nil];
    }
     
    return newStore;
}
+(void)deleteStore:(HGGSGroceryStore *)storeToDelete
{
    NSLog(@"store deleteStore called");

    NSError *error;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[storeToDelete getLocalFolder]] )
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[storeToDelete getFileName:MASTER_LIST]] )
        {
            
            if (![[NSFileManager defaultManager] removeItemAtPath:[storeToDelete getFileName:MASTER_LIST] error:&error])
                    NSLog(@"Error deleting store's master list: %@.  Error: %@", storeToDelete, error);

            if (![[NSFileManager defaultManager] removeItemAtPath:[storeToDelete getFileName:AISLE_CONFIG] error:&error])
                NSLog(@"Error deleting store's aisle information: %@.  Error: %@", storeToDelete, error);
           
            [[NSFileManager defaultManager] removeItemAtPath:[storeToDelete getFileName:CURRENT_LIST] error:&error];
            [[NSFileManager defaultManager] removeItemAtPath:[storeToDelete getFileName:SHOPPING_LIST] error:&error];
            
        }
                                                              
        if (![[NSFileManager defaultManager] removeItemAtPath:[storeToDelete getLocalFolder] error:&error])
            NSLog(@"Error deleting store's master list: %@.  Error: %@", storeToDelete, error);
    }
    
}

+(NSString*)getFileNameComponent:(storeFileType)fileType
{
    if (fileType == STORE)
        return STORE_INFO_FILE;
    else if (fileType == MASTER_LIST)
        return MASTER_LIST_FILE;
    else if (fileType == CURRENT_LIST)
        return CURRENT_LIST_FILE;
    else if (fileType == SHOPPING_LIST)
        return SHOPPING_LIST_FILE;
    else if (fileType == AISLE_CONFIG)
        return AISLE_CONFIG_FILE;
    return nil;
    
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
        NSString* folderName = [self getLocalFolder];
        _storeLists = [[NSDictionary alloc] initWithObjectsAndKeys:
                       [HGGSStoreItems createList:folderName store:self fileName:[HGGSGroceryStore getFileNameComponent:MASTER_LIST] list:nil ],[NSNumber  numberWithInt:MASTER_LIST],
                       [HGGSStoreAisles createList:folderName store:self fileName:[HGGSGroceryStore getFileNameComponent:AISLE_CONFIG] list:nil ],[NSNumber  numberWithInt:AISLE_CONFIG],
                       [HGGSStoreItems createList:folderName store:self fileName:[HGGSGroceryStore getFileNameComponent:CURRENT_LIST] list:nil ],[NSNumber  numberWithInt:CURRENT_LIST],
                       [HGGSStoreAisles createList:folderName store:self fileName:[HGGSGroceryStore getFileNameComponent:SHOPPING_LIST] list:nil ],[NSNumber  numberWithInt:SHOPPING_LIST],
                       nil];
    }
    return self;
}
#pragma mark Property Overrides
-(void)setName:(NSString*)name
{
    if (![name isEqualToString:_name])
    {
        if(_name && ([_name length]))
        {
            // rename the folder
            [self moveToNewStoreFolder:name];
        }
        _name = name;
    }
}

#pragma mark Public Methods
-(bool)anyListsLoaded
{
 
    NSEnumerator *enumerator = [_storeLists objectEnumerator];
    HGGSStoreList * storeList;
    bool listLoaded = NO;
    
    while ((storeList = [enumerator nextObject]) && !listLoaded)
    {
        listLoaded = [storeList exists];
    }
    return listLoaded;
}

-(void)createCurrentList
{
    HGGSStoreList *masterList = [self getMasterList];
    NSMutableArray* currentList = [masterList copyOfList];
    [self setItems:currentList listType:CURRENT_LIST];
}

-(bool)isPopulated:(NSString *)stringToTest
{
    if (!stringToTest)
        return false;
    
    return[[stringToTest stringByTrimmingCharactersInSet:
                             [NSCharacterSet whitespaceCharacterSet]] length] > 0;
    
}
-(void)createShoppingList
{
    HGGSGrocerySection* grocerySection = nil;
    HGGSGroceryItem *shoppingItem;
    NSMutableArray *shoppingList = [[self getGroceryAisles] copyOfList];
    HGGSStoreAisles * shoppingStoreList = [[self storeLists] objectForKey:[NSNumber numberWithInt:SHOPPING_LIST]];
    HGGSStoreItems *currentList = [self getCurrentList];
    
    [shoppingStoreList setList:shoppingList];
    if (![currentList exists])
        currentList = [self getMasterList];

    
    for (HGGSGroceryItem *item in [currentList list])
    {
        if ([item selected])
        {
            HGGSGroceryAisle* unknownSectionAisle = [shoppingStoreList itemAt:0 ];
            if  ([self isPopulated:[item section]])
            {
                grocerySection = [self findGrocerySection:[item section] inAisles:shoppingList];
                if (grocerySection == nil)
                {
                    //add the section to the unknown aisle
                    grocerySection = [[HGGSGrocerySection alloc] init];
                    [grocerySection setName:[item section]];
                    [grocerySection setAisle:[unknownSectionAisle number]];
                    [[unknownSectionAisle grocerySections] addObject:grocerySection];
                }
            }
            else
                grocerySection = [[unknownSectionAisle grocerySections] objectAtIndex:0];
            
            shoppingItem =[item copy];
            [shoppingItem setSelected:NO];
            if ([grocerySection groceryItems] == nil)
                [grocerySection setGroceryItems:[[NSMutableArray alloc ] initWithObjects:shoppingItem, nil]];
            else
                [[grocerySection groceryItems ] addObject:shoppingItem];
        }
    }
  
//    [self setItems:shoppingList listType:SHOPPING_LIST];
}
-(HGGSGrocerySection*)findGrocerySection:(NSString*)sectionName inAisles:(NSArray*)aisles
{
    NSRange locationOfString;
    
    for (HGGSGroceryAisle* aisle in aisles)
    {
        for (HGGSGrocerySection* section in [aisle grocerySections])
        {
            locationOfString =[[section name] rangeOfString:sectionName options:NSCaseInsensitiveSearch];
            if (locationOfString.location != NSNotFound)
            {
                return section;
            }
        }
    }
    return nil;
    
}
-(HGGSGrocerySection *)findGrocerySectionBySectionId:(NSString *)sectionId
{
    NSRange locationOfString;
    NSArray * aisleList = [[self getGroceryAisles] list];
    
    for (HGGSGroceryAisle* aisle in aisleList)
    {
        for (HGGSGrocerySection* section in [aisle grocerySections])
        {
            locationOfString =[[section sectionId] rangeOfString:sectionId options:NSCaseInsensitiveSearch];
            if ((locationOfString.location != NSNotFound) && (locationOfString.length == [sectionId length]))
            {
                return section;
            }
        }
    }
    return nil;

}

-(NSArray*)findGrocerySections:(NSString*)stringToSearchFor inAisles:(bool)inAisles
{
    NSMutableArray* results = [[NSMutableArray alloc] init];
    NSRange locationOfString;
    NSArray * aisleList = [[self getGroceryAisles] list];
    
    for (HGGSGroceryAisle* aisle in aisleList)
    {
        if (inAisles)
        {
            HGGSGroceryAisle* itemsFoundInAisle = nil;
            
            for (HGGSGrocerySection* section in [aisle grocerySections])
            {
                locationOfString =[[section name] rangeOfString:stringToSearchFor options:NSCaseInsensitiveSearch];
                if (locationOfString.location != NSNotFound)
                {
                    if (!itemsFoundInAisle)
                    {
                        itemsFoundInAisle = [[HGGSGroceryAisle alloc] init];
                        [itemsFoundInAisle setGrocerySections:[NSMutableArray arrayWithObject:section]];
                        [itemsFoundInAisle setNumber:[aisle number] ];
                        [results addObject:itemsFoundInAisle];
                    }
                    else
                        [[itemsFoundInAisle grocerySections] addObject:section];
                }
            }
        }
        else if ([stringToSearchFor integerValue] == [aisle number])
        {
            [results  addObject:aisle];
            break;
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
    return [[self getLocalFolder] stringByAppendingPathComponent:fileNameWithoutPath];
}

-(NSString *)getLocalFolder
{
        NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        // for ios, there will only be one director in the list
        NSString *documentDirectory = [documentDirectories objectAtIndex:0];
        
        return [documentDirectory stringByAppendingPathComponent:[self name]];
}

-(NSArray*) getGroceryListsFileNames
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
-(NSArray*) grocerySections
{
    NSArray* aisles = [[self getGroceryAisles] list];
    NSMutableArray* sections = [[NSMutableArray alloc] init];
    for (HGGSGroceryAisle* aisle in aisles)
    {
        [sections addObjectsFromArray:[aisle grocerySections]];
    }
    return sections;
    
}
-(NSArray *) getSharedFileNameComponents
{
    NSMutableArray* fileNameComponents = [[NSMutableArray alloc] init];
    NSEnumerator *enumerator = [_storeLists objectEnumerator];
    HGGSStoreList* storeList;
    
    while (storeList = [enumerator nextObject])
    {
        /* code that acts on the dictionary’s values */
        [fileNameComponents addObject:[storeList fileName]];
    }
    return fileNameComponents;
}

-(HGGSStoreAisles*)getGroceryAisles
{
    HGGSStoreAisles* storeAisles = [_storeLists objectForKey:[NSNumber numberWithInt:AISLE_CONFIG]];
    if (![storeAisles exists])
    {
        [storeAisles load];
        if ([storeAisles itemCount] == 0)
        {
            // add the uknown section in aisle 0
            HGGSGrocerySection * unknownGrocerySection = [[HGGSGrocerySection alloc] init];
            [unknownGrocerySection setName:DEFAULT_GROCERY_SECTION_NAME];
            HGGSGroceryAisle* defaultAisle = [HGGSGroceryAisle createWithGrocerySection:unknownGrocerySection];
            // todo: for compatibility with android version, set the id as well
            [storeAisles addItem:defaultAisle];
        }
    }
    return storeAisles;
}

-(HGGSStoreItems*)getCurrentList
{
    HGGSStoreItems* storeList = [_storeLists objectForKey:[NSNumber numberWithInt:CURRENT_LIST]];
    if (![storeList exists])
    {
        [storeList load];
    }
    return storeList;
}

-(HGGSStoreAisles*)getShoppingList
{
    HGGSStoreAisles* storeList = [_storeLists objectForKey:[NSNumber numberWithInt:SHOPPING_LIST]];
    if (![storeList exists])
    {
        [storeList load];
    }
    return storeList;
}

-(HGGSStoreItems*)getMasterList
{
    HGGSStoreItems* storeList = [_storeLists objectForKey:[NSNumber numberWithInt:MASTER_LIST]];
    if (![storeList exists])
    {
        [storeList load ];
    }
    return storeList;
}


-(void)setItems:(NSMutableArray*)items listType:(storeFileType)listType
{
    HGGSStoreList* storeList = [_storeLists objectForKey:[NSNumber numberWithInt:listType]];
    [storeList setList:items];
    
}


-(void)reloadLists
{
    HGGSStoreList* storeList = [_storeLists objectForKey:[NSNumber numberWithInt:MASTER_LIST]];
    [storeList reload];
    storeList = [_storeLists objectForKey:[NSNumber numberWithInt:CURRENT_LIST]];
    [storeList reload];
    storeList = [_storeLists objectForKey:[NSNumber numberWithInt:SHOPPING_LIST]];
    [storeList reload];
    storeList = [_storeLists objectForKey:[NSNumber numberWithInt:AISLE_CONFIG]];
    [storeList reload];
}
-(void)removeGrocerySection:(HGGSGrocerySection*)grocerySection fromAisle:(HGGSGroceryAisle *)aisle
{
    NSMutableArray* sections = [aisle grocerySections];
    [sections removeObject:grocerySection];
    if ([sections count] == 0)
    {
        [[self getGroceryAisles] removeItem:aisle];
        [_delegate didRemoveGroceryAisle:aisle];

    }
}

-(void) saveStoreInfo
{
    NSString *fileContents = [self serializeStoreInfo];
    [self saveFile:[[self getLocalFolder] stringByAppendingPathComponent:STORE_INFO_FILE] contents:fileContents ];
}

-(bool)saveCurrentList
{
    bool ret = [[self getCurrentList] save];
    [self deleteShoppingList];
    return ret;
}
-(void) deleteShoppingList
{
    [[self getShoppingList] deleteList];
}

-(bool)saveMasterList
{
    return [[self getMasterList] save];
}

-(bool)saveShoppingList
{
    return [[self getShoppingList] save];
}

-(bool)saveGroceryAisles
{
    return [[self getGroceryAisles] save];
}

-(bool)shoppingListIsMoreRecentThanCurrentList
{
    HGGSStoreList *currentList = [self getCurrentList];
    if (![currentList fileExists])
        return YES;
    
    HGGSStoreList *shoppingList = [self getShoppingList];
    if (![shoppingList fileExists])
        return NO;
    
    return [[shoppingList lastModificationDate] compare:[currentList lastModificationDate]] == NSOrderedDescending;
}

-(void)unloadLists
{
    NSEnumerator *enumerator = [_storeLists objectEnumerator];
    HGGSStoreList *storeList;
    
    
    while ((storeList = [enumerator nextObject])) {
        [storeList unload];
    }
    
}

#pragma mark HGGSGrocerySectionDelegate
-(void)didChangeAisle:(id)section fromAisleNumber:(NSInteger)fromAisleNumber toAisleNumber:(NSInteger)toAisleNumber
{
    NSArray* aisles = [[self getGroceryAisles] list];
    HGGSGroceryAisle* fromAisle;
    HGGSGroceryAisle* toAisle;
    for (HGGSGroceryAisle* aisle in aisles)
    {
        if (fromAisleNumber == [aisle number])
        {
            fromAisle = aisle;
        }
        else if (toAisleNumber == [aisle number])
        {
            toAisle = aisle;
        }
        if (fromAisle && toAisle)
            break;
    }
    [self removeGrocerySection:section fromAisle:fromAisle];
    if (!toAisle)
    {
        //toAisle = [HGGSGroceryAisle createWithGrocerySection:section];
        toAisle = [[self getGroceryAisles]insertGrocerySection:section atSectionIndex:0];
    }
    else
    {
        [[toAisle grocerySections] addObject:section];
    }
    
    if ([self delegate])
    {
        [[self delegate] didHaveAisleChange:section fromAisle:fromAisle toAisle:toAisle];
    }
    // todo: if no more sections in fromaisle, remove the aisle
    
}
#pragma mark NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    HGGSGroceryStore *copyOfSelf = [[HGGSGroceryStore alloc] init];
    NSEnumerator *enumerator = [_storeLists keyEnumerator];
    id key;
    
    
    while ((key = [enumerator nextObject]))
    {
        [copyOfSelf setItems:[[_storeLists objectForKey:key] copy] listType:[key intValue]];
    }
    
    [copyOfSelf setName:[self name]];
    [copyOfSelf setShareLists:[self shareLists]];
    
    return copyOfSelf;
}
#pragma mark Private Methods

-(NSArray*)findGroceryItems:(NSString*)stringToSearchFor inList:(NSArray*)list
{
    NSMutableArray* results = [[NSMutableArray alloc] init];
    NSRange locationOfString;
    
    for (HGGSGroceryItem* item in list)
    {
        locationOfString =[[item name] rangeOfString:stringToSearchFor options:NSCaseInsensitiveSearch];
        if (locationOfString.location != NSNotFound)
        {
            [results addObject:item];
        }
        
    }
    return results;
}

#pragma Mark HGGSStoreListDelegate

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

-(NSInteger)getAisleForItem:(HGGSGroceryItem*) groceryItem
{
    NSString *sectionName = [groceryItem section];
    
    if ((sectionName == nil) || ([sectionName length] == 0))
        return 0;
    
    NSArray * aisles = [self findGrocerySections:sectionName inAisles:YES];
    if ([aisles count] == 0)
        return 0;
    
    HGGSGroceryAisle* aisle= [aisles objectAtIndex:0];
    return [aisle number];
}

#pragma mark Private
-(void)loadStoreInfo
{
    NSString *fileContents = [self loadFile:[[self getLocalFolder] stringByAppendingPathComponent:STORE_INFO_FILE]];
    if (fileContents)
    {
        NSDate* date;
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
        {
            date = [HGGSDate stringAsDate:[storeAttributes objectForKey:@"LastSyncDate_MasterList"]];
            [[self getMasterList] setLastSyncDate:date];
            date = [HGGSDate stringAsDate:[storeAttributes objectForKey:@"LastSyncDate_GroceryAisles"]];
            [[self getGroceryAisles] setLastSyncDate:date];
            date = [HGGSDate stringAsDate:[storeAttributes objectForKey:@"LastSyncDate_CurrentList"]];
            [[self getCurrentList] setLastSyncDate:date];
            
        }
    }
}

-(void)moveToNewStoreFolder:(NSString*)newFolderName
{
    NSString *oldPath = [self getLocalFolder];
    NSString *newPath = [[oldPath stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFolderName];
    NSError *error = nil;
    [[NSFileManager defaultManager] moveItemAtPath:oldPath toPath:newPath error:&error];
    if (error) {
        NSLog(@"%@",error.localizedDescription);
    }
}

-(bool)saveFile:(NSString*)fileName contents:(NSString *) fileContents
{
    NSError *error  = nil;
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName])
    {
        NSFileManager *fm = [NSFileManager defaultManager];
        
        NSString *storeFolder = [self getLocalFolder];
        if (![fm fileExistsAtPath:storeFolder])
        {
            [fm createDirectoryAtPath:storeFolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
              
    }
    if ([fileContents writeToFile:fileName atomically:NO encoding:NSUTF8StringEncoding error:&error])
        return YES;
    
    if (error)
        NSLog(@"error writing to file: %@", error);
    else
        NSLog(@"failed to save file, but no error reported");
    
    return NO;
}
-(bool) saveSerializedListInFile:(NSString*)serializedListToSave fileName:(NSString*)fileName
{
    // [prior to saving, determine if anything has changed
    NSString *listInFile  = [self loadFile:fileName];
    if (![listInFile isEqualToString:serializedListToSave])
    {
        return [self saveFile:fileName contents:serializedListToSave];
    }
    return NO;
}
-(void)saveLists
{
    [self saveMasterList];
    [self saveGroceryAisles];
    [self saveCurrentList];
}

-(NSString*)serializeStoreInfo
{
    NSError* error;
    
    NSMutableDictionary * storeProperties = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[self name],@"Name",[NSNumber numberWithBool:[self shareLists]],@"ShareLists",
                [HGGSDate dateAsString:[[self getMasterList] lastSyncDate]], @"LastSyncDate_MasterList",
                [HGGSDate dateAsString:[[self getGroceryAisles] lastSyncDate]], @"LastSyncDate_GroceryAisles",
                [HGGSDate dateAsString:[[self getCurrentList] lastSyncDate]], @"LastSyncDate_CurrentList"
                                             
                                             ,nil ];
    
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
    return [[self name] isEqual:[someStore name]];
}

#pragma mark Private
-(void)setSectionIfSectionIdIsUsed:(HGGSGroceryItem*) groceryItem
{
    if (( [groceryItem section] == nil) && ([groceryItem sectionId] != nil))
    {
        HGGSGrocerySection* section = [self findGrocerySectionBySectionId:[groceryItem sectionId] ];
        [groceryItem setSection:[section name]];
    }
}

@end
