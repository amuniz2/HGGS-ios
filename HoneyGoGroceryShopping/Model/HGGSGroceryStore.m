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
#import "NSString+SringExtensions.h"

#define STORE_INFO_FILE @"StoreInfo.json"
#define GROCERY_LIST_FILE @"grocery_list.json"
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
    
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[newStore localFolder] withIntermediateDirectories:YES attributes:nil error:&error])
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
    if ([[NSFileManager defaultManager] fileExistsAtPath:[storeToDelete localFolder]] )
    {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[storeToDelete getFileName:LIST]] )
        {
            
            if (![[NSFileManager defaultManager] removeItemAtPath:[storeToDelete getFileName:LIST] error:&error])
                    NSLog(@"Error deleting store's master list: %@.  Error: %@", storeToDelete, error);

            if (![[NSFileManager defaultManager] removeItemAtPath:[storeToDelete getFileName:AISLE_CONFIG] error:&error])
                NSLog(@"Error deleting store's aisle information: %@.  Error: %@", storeToDelete, error);
            
        }
                                                              
        if (![[NSFileManager defaultManager] removeItemAtPath:[storeToDelete localFolder] error:&error])
            NSLog(@"Error deleting store's grocery list: %@.  Error: %@", storeToDelete, error);
    }
    
}

+(void) deleteStoreImages:(HGGSGroceryStore*)store
{
    NSString* imagePath;
    
    NSArray *contentsOfFolder = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[store imagesFolder] error:nil];
    for (NSString * file in contentsOfFolder)
    {
        imagePath = [[store imagesFolder]stringByAppendingPathComponent:file ];
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    }
    [[NSFileManager defaultManager] removeItemAtPath:[store imagesFolder] error:nil];
}

+(NSString*)getFileNameComponent:(storeFileType)fileType
{
    if (fileType == STORE)
        return STORE_INFO_FILE;
    else if (fileType == AISLE_CONFIG)
        return AISLE_CONFIG_FILE;
    
    return GROCERY_LIST_FILE;
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
        [self setPreparedForWork:NO];
        [self setName:storeName];
        [self loadStoreInfo];
        
        _storeList = [HGGSStoreItems createList:[HGGSGroceryStore getFileNameComponent:LIST] store:self list:nil ];
        //TODO:?
        _aisles = (HGGSStoreAisles*)[HGGSStoreAisles createList:[HGGSGroceryStore getFileNameComponent:AISLE_CONFIG] store:self list:nil];
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

-(NSString *)localFolder
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // for ios, there will only be one director in the list
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:[self name]];
}

-(NSString *)imagesFolder
{
    NSString *folder = [[self localFolder] stringByAppendingPathComponent:@"images"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder])
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    return folder;

}

#pragma mark Public Methods
-(bool)anyListsLoaded
{
    return [_storeList exists];
}

-(void)resetCurrentList
{
    HGGSStoreItems *itemList = [self getGroceryList];
    NSMutableArray * itemsToRemove = [[NSMutableArray alloc] init];
    
    for (HGGSGroceryItem *item in [itemList list])
    {
        if ([item isPantryItem])
            [item setIncludeInShoppingList:[item includeInShoppingListByDefault]];
        else
            [itemsToRemove addObject:item];
    }

    for (HGGSGroceryItem * itemToRemove in itemsToRemove)
        [itemList  removeItem:itemToRemove];
    
}

-(bool)isPopulated:(NSString *)stringToTest
{
    return ![NSString isEmptyOrNil:stringToTest];
}
-(NSMutableArray *)createShoppingList:(bool)resetShoppingCart
{
    HGGSGrocerySection* grocerySection = nil;
    HGGSGroceryItem *shoppingItem;
    NSMutableArray *shoppingList = [[self getGroceryAisles] copyOfList];
    HGGSStoreItems *currentList = [self getGroceryList];
    
    HGGSGroceryAisle* unknownSectionAisle = [shoppingList  objectAtIndex:0];
    for (HGGSGroceryItem *item in [currentList list])
    {
        if ([item includeInShoppingList])
        {
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
            
            //shoppingItem =[item copy];
            shoppingItem =item;
            if (resetShoppingCart)
                [shoppingItem setIsInShoppingCart:NO];
            if ([grocerySection groceryItems] == nil)
                [grocerySection setGroceryItems:[[NSMutableArray alloc ] initWithObjects:shoppingItem, nil]];
            else
                [[grocerySection groceryItems ] addObject:shoppingItem];
        }
    }
    return shoppingList;
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
    else if (storeFileType == AISLE_CONFIG)
    {
        fileNameWithoutPath = AISLE_CONFIG_FILE;
    }
    else
        fileNameWithoutPath = [_storeList fileName];

    return [[self localFolder] stringByAppendingPathComponent:fileNameWithoutPath];
}


-(NSArray*) getGroceryListsFileNames
{
    NSMutableArray* fileNames = [[NSMutableArray alloc] init];
    
    /* code that acts on the dictionary’s values */
    [fileNames addObject:STORE_INFO_FILE];
    [fileNames addObject:AISLE_CONFIG_FILE];
    [fileNames addObject:GROCERY_LIST_FILE];
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

-(HGGSStoreAisles*)getGroceryAisles
{
    HGGSStoreAisles* storeAisles = [self aisles];
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

-(HGGSStoreItems*)getGroceryList
{
    if (![_storeList exists])
    {
        [_storeList load];
        
        if ([_storeList itemCount] == 0)
            [_storeList loadFromPreviousMasterFile];
    }
    return _storeList;
}
-(BOOL)noItemsLeftToShopFor
{
    NSArray *items = [[self storeList] list];
    
    for (HGGSGroceryItem *item in items) {
        if ([item includeInShoppingList] && ![item isInShoppingCart]  )
            return false;
    }
    return true;
}

-(void)reloadLists
{
    [_storeList reload];
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
    [self saveFile:[[self localFolder] stringByAppendingPathComponent:STORE_INFO_FILE] contents:fileContents ];
}

-(bool)saveCurrentList
{
    bool ret = [[self getGroceryList] save];
    [self resetShoppingCart];
    return ret;
}

-(bool)saveGroceryList
{
    return [[self getGroceryList] save];
}
-(void) resetShoppingCart
{
    HGGSStoreItems * groceryItems = [self getGroceryList];

    for (HGGSGroceryItem *item in [groceryItems list]) {
        item.isInShoppingCart = NO;
    }
}

-(bool)saveGroceryAisles
{
    return [[self getGroceryAisles] save];
}

//-(bool)shoppingListIsMoreRecentThanCurrentList
//{
//    HGGSStoreList *currentList = [self getCurrentList];
//    if (![currentList fileExists])
//        return YES;
//    
//    HGGSStoreList *shoppingList = [self getShoppingList];
//    if (![shoppingList fileExists])
//        return NO;
//    
//    return [[shoppingList lastModificationDate] compare:[currentList lastModificationDate]] == NSOrderedDescending;
//}

-(void)unload
{
    [self saveStoreInfo];
    if ([[self storeList] exists])
        [[self storeList] unload];
    [[self aisles] unload];
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
    //NSEnumerator *enumerator = [_storeLists keyEnumerator];
    //id key;
    
    [[copyOfSelf storeList] setList:[[self storeList] copy] ] ;
    [[copyOfSelf aisles] setList:[[self aisles] copy]];
    
//    while ((key = [enumerator nextObject]))
//    {
//        [copyOfSelf setItems:[[_storeLists objectForKey:key] copy] listType:[key intValue]];
//    }
    
    
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
    NSString *fileContents = [self loadFile:[[self localFolder] stringByAppendingPathComponent:STORE_INFO_FILE]];
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
            date = [HGGSDate stringAsDate:[storeAttributes objectForKey:@"LastSyncDate_GroceryList"]];
            [[self getGroceryList] setLastSyncDate:date];
            date = [HGGSDate stringAsDate:[storeAttributes objectForKey:@"LastSyncDate_GroceryAisles"]];
            [[self getGroceryAisles] setLastSyncDate:date];
        }
    }
}

-(void)moveToNewStoreFolder:(NSString*)newFolderName
{
    NSString *oldPath = [self localFolder];
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
        
        NSString *storeFolder = [self localFolder];
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
    [self saveGroceryList];
    [self saveGroceryAisles];
}

-(NSString*)serializeStoreInfo
{
    NSError* error;
    
    NSMutableDictionary * storeProperties = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[self name],@"Name",[NSNumber numberWithBool:[self shareLists]],@"ShareLists",
                [HGGSDate dateAsString:[[self getGroceryList] lastSyncDate]], @"LastSyncDate_GroceryList",
                [HGGSDate dateAsString:[[self getGroceryAisles] lastSyncDate]], @"LastSyncDate_GroceryAisles",
                [HGGSDate dateAsString:[self lastImagesSyncDate]], @"LastSyncDate_Images",
            nil ];
    
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
