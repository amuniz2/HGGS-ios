//
//  HGGSGroceryStore.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 9/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HGGSGrocerySection.h"
#import "HGGSGroceryItem.h"
#import "HGGSStoreItems.h"
#import "HGGSStoreAisles.h"

@class HGGSGroceryAisle;
@class HGGSDropboxFileRevisions;

typedef enum storeFileType
{
    STORE,
//    MASTER_LIST,
//    CURRENT_LIST,
//    SHOPPING_LIST,
    LIST,
    AISLE_CONFIG
    
} storeFileType;

@protocol HGGSGroceryStoreDelegate <NSObject>
@optional
-(void)didHaveAisleChange:(HGGSGrocerySection*)section fromAisle:(HGGSGroceryAisle*)fromAisle toAisle:(HGGSGroceryAisle*)toAisle;
-(void)didRemoveGroceryAisle:(HGGSGroceryAisle*)aisle;
@end


@interface HGGSGroceryStore : NSObject <HGGSGrocerySectionDelegate, HGGSStoreListDelegate>
{
}
@property (weak) id <HGGSGroceryStoreDelegate> delegate;
@property (nonatomic, assign, readonly) NSArray* grocerySections;
@property (nonatomic, readonly) HGGSStoreItems* storeList;
@property (nonatomic, readonly) HGGSStoreAisles* aisles;
@property (nonatomic, copy, readonly) NSString* localFolder;
@property (nonatomic, copy, readonly) NSString* imagesFolder;
@property (nonatomic, copy) NSDate* lastImagesSyncDate;
@property (nonatomic, strong) HGGSDropboxFileRevisions *dropboxFileRevisions;
@property (nonatomic, copy) NSDate* saveImagesSavedAfter;

+(HGGSGroceryStore *)createStore:(NSString*)storeName;
+(void)deleteStore:(HGGSGroceryStore *)storeToDelete;
+(NSString*)getFileNameComponent:(storeFileType)fileType;
@property(nonatomic, copy)NSString *name;
@property Boolean shareLists;
@property(readonly, copy)NSDate* lastModificationDate;
@property BOOL preparedForWork;

-(id)initWithStoreName:(NSString *)storeName;
-(bool)anyListsLoaded;
-(void)resetCurrentList;
-(NSMutableArray*)createShoppingList:(BOOL)resetShoppingList;
-(HGGSGrocerySection*)findGrocerySection:(NSString*)sectionName inAisles:(NSArray*)aisles;
-(HGGSGrocerySection *)findGrocerySectionBySectionId:(NSString *)sectionId ;
-(NSArray*)findGrocerySections:(NSString*)stringToSearchFor inAisles:(bool)inAisles;
-(NSArray*)getGroceryListsFileNames;
//-(HGGSGrocerySection*) insertNewGrocerySection:(NSString*)name inAisle:(NSInteger)aisleNumber atSectionIndex:(NSInteger)sectionIndex;
-(HGGSStoreItems*) getGroceryList;
-(HGGSStoreAisles *) getGroceryAisles;
-(void)reloadLists;
-(void)removeGrocerySection:(HGGSGrocerySection*)grocerySection fromAisle:(HGGSGroceryAisle *)aisle;
-(bool)saveGroceryAisles;
-(bool)saveGroceryList;
//-(bool)saveShoppingList;
-(void) saveStoreInfo;
//-(bool) shoppingListIsMoreRecentThanCurrentList;
-(void)unload;
-(BOOL)noItemsLeftToShopFor;
-(void)converToNewStorage;
@end
