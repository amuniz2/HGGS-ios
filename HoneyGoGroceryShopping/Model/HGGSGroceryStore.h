//
//  HGGSGroceryStore.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 9/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGGSGroceryItem.h"


typedef enum storeFileType
{
    STORE,
    MASTER_LIST
    
} storeFileType;

@protocol HGGSGroceryStoreDelegate <NSObject>

-(void)didSaveList:(storeFileType)listType storeName:(NSString*)storeName ;

@end


@interface HGGSGroceryStore : NSObject
{
    //NSMutableArray *_groceryItemsInMasterList;
    NSDictionary *_storeLists;
}
@property (retain) id <HGGSGroceryStoreDelegate> delegate;

+(HGGSGroceryStore *)createStore:(NSString*)storeName;
+(void)deleteStore:(HGGSGroceryStore *)storeToDelete;
+(NSString*)getFileNameComponent:(storeFileType)fileType;
+(NSString *)getGroceryStorePath:(NSString *) storeName;
@property(nonatomic, copy)NSString *Name;
@property Boolean ShareLists;
@property(nonatomic, copy)NSDate* lastSyncDate;

-(id)initWithStoreName:(NSString *)storeName;

-(bool)anyListsLoaded;
-(HGGSGroceryItem *) createGroceryItemWithDetailsInList:(storeFileType)listType name:(NSString*) name quantity:(int)quantity unit:(NSString *)unit section:(NSString *) section notes:(NSString *)notes ;
-(HGGSGroceryItem *) createGroceryItemWithDetailsInList:(storeFileType)listType name:(NSString*) name quantity:(int)quantity unit:(NSString *)unit section:(NSString *) section notes:(NSString *)notes select:(bool)selected lastPurchasedOn:(NSDate*)lastPurchasedDate;
-(NSString*)getFileName:(storeFileType)storeFileType;
-(NSArray *) getSharedFileNameComponents;
-(NSString *)getGroceryListArchivePath;
-(NSArray*)getGroceryListsFileNames:(NSString *) storeName;
-(NSMutableArray*)itemsInList:(storeFileType)listType;
-(NSMutableArray *)loadList:(storeFileType)listType;
-(void)reloadLists;
-(void)removeItem:(HGGSGroceryItem*)item fromList:(storeFileType)listType;
-(void)save;
-(BOOL)saveList:(storeFileType)listType;
-(void) saveStoreInfo;
-(void)unloadLists;
-(NSArray*)findItems:(NSString*)stringToSearchFor inList:(storeFileType)listType;

@end
