//
//  GroceryItem.h
//  Grocery List Single View
//
//  Created by Ana Muniz on 9/19/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGSGroceryItem : NSObject <NSCopying>
{
    //NSDictionary *someInstanceVariable;
}

@property double quantity;

//@property bool selected;
@property bool isPantryItem;
@property bool isInShoppingCart;
@property bool includeInShoppingList;
@property bool includeInShoppingListByDefault;

@property (nonatomic, copy) NSString *sectionId;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, copy)NSString *unit;
@property (nonatomic, copy)NSString *section;
@property (nonatomic, copy) NSString *notes;
@property (nonatomic, copy) NSDate *lastPurchasedDate;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString* imagesFolder;
@property(nonatomic, copy) NSString* imageName;
@property(nonatomic, strong) UIImage *smallImage;
@property bool imageModified;

-(id)initFromDictionary:(NSDictionary *)itemAttributes imagesFolder:(NSString*)imagesFolder;
@property(nonatomic,strong, readonly) NSDictionary *asDictionary;

-(id)initWithDetails:(NSString*)name quantity:(double)amount unit:(NSString *)unitDescription section:(NSString *)grocerySection notes:(NSString*)notes includeInPantry:(bool)includeInPantry selectByDefault:(bool)selectByDefault lastPurchasedOn:(NSDate*)lastPurchasedDate includeInShoppingList:(bool) includeInShoppingList isInShoppingCart:(bool) isInShoppingCart image:(NSString*)imageName;

//-(id)initWithOldDetails:(NSString*)name quantity:(double)amount unit:(NSString *)unitDescription section:(NSString *)grocerySection notes:(NSString*)notes select:(bool)selected lastPurchasedOn:(NSDate*)lastPurchasedDate sectionId:(NSString*)sectionId image:(NSString*)imageName;

- (NSComparisonResult) compareWithAnotherItem:(HGGSGroceryItem*) anotherItem;



@end
