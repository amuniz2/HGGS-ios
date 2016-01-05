//
//  HGGSStoreList.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/28/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>
@class HGGSGroceryItem;
@class HGGSGroceryAisle;
@class HGGSGrocerySection;

typedef enum
{
    items,
    shoppingItems,
    aisles
} listType;

@protocol HGGSStoreListDelegate <NSObject>
-(NSString *) loadFile:(NSString *)fileName;
-(bool)saveFile:(NSString*)fileName contents:(NSString *) fileContents;
-(void)setSectionIfSectionIdIsUsed:(HGGSGroceryItem*) groceryItem;
-(NSInteger)getAisleForItem:(HGGSGroceryItem*) groceryItem;
@optional
-(void)didSaveList:(id)list ;
@end

@interface HGGSStoreList : NSObject 
{
}
@property (weak) id <HGGSStoreListDelegate> delegate;

//@property (nonatomic, readonly, copy) NSString* localFolder;
@property (nonatomic, readonly, copy) NSString* fileName;
@property (nonatomic, readonly) NSString *storeName;
@property (nonatomic, readonly, weak) id store;
@property (nonatomic, readonly, copy) NSDate* lastModificationDate;
@property (nonatomic, readonly) bool exists;
@property (nonatomic, readonly) bool fileExists;
@property (nonatomic, strong) NSArray* list;

@property (readonly) NSUInteger itemCount;
@property (nonatomic, copy) NSDate* lastSyncDate;


-(id)initWithFile:(NSString*)fileName store:(id)store;

-(void)load;
-(void)reload;
-(bool)save;
-(void)unload;
-(void)deleteList;

-(NSMutableArray*)copyOfList;

// abstract methods
-(NSInteger)addItem:(id)newItem;
-(NSMutableArray*)findItems:(NSString*)stringToSearchFor;
-(id) itemAt:(NSInteger)index;
-(id) itemWithKey:(NSString *) key;
-(void)loadListFromString:(NSString*)fileContents;
-(void)removeItem:(id)item;
-(NSString*) serializeList;

@end
