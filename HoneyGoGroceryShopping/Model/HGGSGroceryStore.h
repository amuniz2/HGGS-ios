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

typedef enum storeFileType
{
    STORE,
    MASTER_LIST,
    CURRENT_LIST,
    SHOPPING_LIST,
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
@property (nonatomic, readonly) NSDictionary* storeLists;
@property (nonatomic, copy, readonly) NSString* localFolder;
@property (nonatomic, copy, readonly) NSString* imagesFolder;

+(HGGSGroceryStore *)createStore:(NSString*)storeName;
+(void)deleteStore:(HGGSGroceryStore *)storeToDelete;
+(NSString*)getFileNameComponent:(storeFileType)fileType;
@property(nonatomic, copy)NSString *name;
@property Boolean shareLists;
@property(readonly, copy)NSDate* lastModificationDate;

-(id)initWithStoreName:(NSString *)storeName;
-(bool)anyListsLoaded;
-(void)createCurrentList;
-(void)createShoppingList;
-(HGGSGrocerySection*)findGrocerySection:(NSString*)sectionName inAisles:(NSArray*)aisles;
-(HGGSGrocerySection *)findGrocerySectionBySectionId:(NSString *)sectionId ;
-(NSArray*)findGrocerySections:(NSString*)stringToSearchFor inAisles:(bool)inAisles;
-(NSArray *) getSharedFileNameComponents;
-(NSArray*)getGroceryListsFileNames;
//-(HGGSGrocerySection*) insertNewGrocerySection:(NSString*)name inAisle:(NSInteger)aisleNumber atSectionIndex:(NSInteger)sectionIndex;
-(HGGSStoreItems*) getCurrentList;
-(HGGSStoreAisles *) getGroceryAisles;
-(HGGSStoreItems*) getMasterList;
-(HGGSStoreAisles*)getShoppingList;
-(void)reloadLists;
-(void)removeGrocerySection:(HGGSGrocerySection*)grocerySection fromAisle:(HGGSGroceryAisle *)aisle;
-(bool)saveCurrentList;
-(bool)saveGroceryAisles;
-(bool)saveMasterList;
-(bool)saveShoppingList;
-(void) saveStoreInfo;
-(bool) shoppingListIsMoreRecentThanCurrentList;
-(void)unloadLists;

@end
