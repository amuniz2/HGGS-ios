//
//  GroceryItem.m
//  Grocery List Single View
//
//  Created by Ana Muniz on 9/19/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/NSJSONSerialization.h>
#import "NSString+SringExtensions.h"

#import "HGGSGroceryItem.h"
#import "HGGSDate.h"

#define k_includeInShoppingListByDefault @"includeInShoppingListByDefault"
#define k_quantity @"quantity"
#define k_unit @"unit"
#define k_notes @"notes"
#define k_isPantryItem @"isPantryItem"
#define k_includeInShoppingList @"includeInShoppingList"
#define k_isInShoppingCart @"isInShoppingCart"
#define k_section @"section"
#define k_image @"image"
#define k_lastPurchasedDate @"lastPurchasedDate"

@implementation HGGSGroceryItem
{
    UIImage *_image;
}
#pragma mark Initialization Methods
-(id)initFromDictionary:(NSDictionary*)itemAttributes imagesFolder:(NSString*)imagesFolder
{
    _imagesFolder = imagesFolder;

    
    if (!itemAttributes[@"isPantryItem"])
        self = [self initFromOldItemAttributes:itemAttributes];
    else
    {
        double quantity =(double)[[itemAttributes objectForKey:k_quantity ] doubleValue];
        NSString * itemName = [itemAttributes objectForKey:@"name"];
    
        self = [self initWithDetails:itemName
                quantity:quantity
                unit:[itemAttributes objectForKey:k_unit]
                section:[itemAttributes objectForKey:k_section]
                notes:[itemAttributes objectForKey:k_notes]
                includeInPantry:[HGGSBool stringAsBool:[itemAttributes objectForKey:k_isPantryItem]]
                selectByDefault:[HGGSBool stringAsBool:[itemAttributes objectForKey:k_includeInShoppingListByDefault]]
                lastPurchasedOn:[HGGSDate stringAsDate:[itemAttributes objectForKey:k_lastPurchasedDate] ]
                includeInShoppingList:[HGGSBool stringAsBool:[itemAttributes objectForKey:k_includeInShoppingList]]
                isInShoppingCart:[HGGSBool stringAsBool:[itemAttributes objectForKey:k_isInShoppingCart]]
//                        sectionId:[itemAttributes objectForKey:@"category"]
                        image:[itemAttributes objectForKey:@"image"]
            ];
    
    }
    return self;
}

-(id)initFromOldItemAttributes:(NSDictionary*)itemAttributes
{
 /*
  {
		"unit": "",
		"selected": true,
		"lastPurchasedDate": "Sat Jul 04 10:24:36 EDT 2015",
		"name": "Cinnamon Sugar Pita Chips",
		"image": "1934971443",
		"quantity": 1,
		"notes": "Stacy's, Pita Chips, Cinnamon Sugar, 8oz Bag ",
		"section": "deli"
  },
  */
    double quantity =(double)[[itemAttributes objectForKey:@"quantity" ] doubleValue];
    NSString * itemName = [itemAttributes objectForKey:@"name"];
    
    self = [self initWithDetails:itemName
                        quantity:quantity
                            unit:[itemAttributes objectForKey:k_unit]
                         section:[itemAttributes objectForKey:k_section]
                           notes:[itemAttributes objectForKey:k_notes]
                 includeInPantry:YES
                 selectByDefault:[HGGSBool stringAsBool:[itemAttributes objectForKey:k_includeInShoppingListByDefault]]
                 lastPurchasedOn:[HGGSDate stringAsDate:[itemAttributes objectForKey:@"lastPurchasedDate"]]
                 includeInShoppingList:[HGGSBool stringAsBool:[itemAttributes objectForKey:k_includeInShoppingList]]
                 isInShoppingCart:[HGGSBool stringAsBool:[itemAttributes objectForKey:k_isInShoppingCart]]
                                                   image:[itemAttributes objectForKey:@"image"]
                                   
            //                        sectionId:[itemAttributes objectForKey:@"category"]
            ];
    
    
    return self;
}


//-(id)initWithOldDetails:(NSString*)name quantity:(double)amount unit:(NSString *)unitDescription section:(NSString *)grocerySection notes:(NSString*)notes select:(bool)selected lastPurchasedOn:(NSDate*)lastPurchasedDate sectionId:(NSString *)sectionId image:(NSString*)imageName
//{
//    self = [self initWithDetails:name quantity:amount unit:unitDescription section:grocerySection notes:notes select:selected lastPurchasedOn:lastPurchasedDate ] ;
//    if (self)
//    {
//        [self setImageName:imageName];
//        //[self setImage:[self loadPicture:imageName inFolder:[self imagesFolder]]];
//        [self setSectionId:sectionId];
//    
//    }
//    return self;
//}

-(id)initWithDetails:(NSString*)name quantity:(double)amount unit:(NSString *)unitDescription section:(NSString *)grocerySection notes:(NSString*)notes includeInPantry:(bool)includeInPantry selectByDefault:(bool)selectByDefault lastPurchasedOn:(NSDate*)lastPurchasedDate includeInShoppingList:(bool) includeInShoppingList isInShoppingCart:(bool) isInShoppingCart image:(NSString*)imageName
{
    
    self = [super init];
    if (self)
    {
        [self setLastPurchasedDate:lastPurchasedDate];
        _name = name;
        [self setNotes:notes];
        [self setQuantity:amount];
        [self setUnit:unitDescription];
        [self setSection:grocerySection];
        [self setIsPantryItem:includeInPantry];
        [self setIncludeInShoppingListByDefault:selectByDefault];
        [self setIsInShoppingCart:isInShoppingCart];
        [self setIncludeInShoppingList:includeInShoppingList];
        //[self setSelected:selected];
        [self setImageName:imageName];
        
    }
    return self;
}
-(id)init
{
    NSString* emptyString = @"";
    self = [self initWithDetails:emptyString quantity:1 unit:emptyString section:emptyString notes:emptyString includeInPantry:YES selectByDefault:NO lastPurchasedOn:nil includeInShoppingList:YES isInShoppingCart:NO image:emptyString];
    if (self)
    {
        [self setSectionId:emptyString];
    }
    return self;
}

#pragma mark Public Methods
-(NSDictionary*)asDictionary
{
    if ([self imageModified])
        [self savePicture:[self image]];
    
    NSString *imageName = [self imageName];
    
    NSDictionary *ret =[[NSDictionary alloc] initWithObjectsAndKeys:
                    _name, @"name",
                    [NSNumber numberWithDouble:_quantity], k_quantity,
                    (_unit == nil) ? @"" : _unit, k_unit,
                    (_notes == nil) ? @"" : _notes, k_notes,
                    [HGGSBool boolAsString:_isPantryItem], k_isPantryItem,
                        [HGGSBool boolAsString:_includeInShoppingListByDefault], k_includeInShoppingListByDefault,
                        [HGGSBool boolAsString:_includeInShoppingList], k_includeInShoppingList,
                        [HGGSBool boolAsString:_isInShoppingCart], k_isInShoppingCart,
                    (_section == nil) ? @"" : _section, k_section,
                        (_imageName == nil) ? @"" : imageName, k_image,
                        [HGGSDate dateAsString:_lastPurchasedDate], k_lastPurchasedDate,
                    nil];
    
    return ret;
}

#pragma mark NSObject Overrides
-(NSString *)description
{
    return [self name];
}
- (BOOL)isEqual:(id)someItem
{
    return [[self name] isEqual:[someItem name]];
}

#pragma mark Property Overrides
-(NSString *)imageName
{
    //if (([self image] == nil) || ([self name] == nil))
    //    return nil;
    
    if (_imageName == nil)
        _imageName = [self generateImageName];
    
    return _imageName;
}
-(UIImage *)image
{
    if ((_image == nil) && (_imageName != nil))
    {
        _image = [self loadPicture:[self imageName] inFolder:[self imagesFolder]];
        [self setImageModified:NO];
    }
    return _image;
        
}
-(void)setImage:(UIImage *)image
{
    if ((image == nil) && (image != _image))
    {
        _image = nil;
        _imageName = nil;
//        [self deletePicture:imageName];
        [self setImageModified:YES];
        return;
    }
    if (image != _image)
    {
        _image = image;
        [self setImageModified:YES];
    }
    if ([NSString isEmptyOrNil:_imageName])
        [self setImageName:[self generateImageName]];
}
-(NSString *)generateImageName
{
    return [NSString stringWithFormat:@"%lu",(unsigned long)[[self name] hash]];
}

#pragma mark NSCopying
-(id)copyWithZone:(NSZone *)zone
{
    HGGSGroceryItem *copy = [[HGGSGroceryItem alloc] initWithDetails:[self name]
                quantity:[self quantity]
                unit:[self unit]
                section:[self section]
                notes:[self notes]
                includeInPantry:[self  isPantryItem]
                selectByDefault:[self includeInShoppingListByDefault]
                lastPurchasedOn:[self lastPurchasedDate]
                includeInShoppingList:[self includeInShoppingList]
                isInShoppingCart:[self isInShoppingCart]
                                                               image:[self imageName]];
    
   // [copy setIsInShoppingCart:[self isInShoppingCart]];
   // [copy setIncludeInShoppingList:[self includeInShoppingList]];
   // [copy setImageName:[self imageName]];
    [copy setImage:[self image]];
    [copy setSectionId:[self sectionId]];
    [copy setImagesFolder:[self imagesFolder]];
    
    return copy;
}

#pragma mark Private
- (NSComparisonResult) compareWithAnotherItem:(HGGSGroceryItem*) anotherItem
{
    NSComparisonResult sectionResult = [[self section] compare:[anotherItem section] options:NSCaseInsensitiveSearch];
    if (sectionResult != NSOrderedSame)
        return sectionResult;
    
    //return [[self name] caseInsensitiveCompare:[anotherItem name]];
    return [[self name] compare:[anotherItem name] options:NSCaseInsensitiveSearch];
}
-(UIImage *) loadPicture:(NSString *)imageName inFolder:(NSString*) folderName
{
 //   return [[UIImage alloc ] init
    if (imageName == nil)
        return nil;
    
    [self setImageName:imageName];
    
    NSString *imagePath = [[folderName stringByAppendingPathComponent:imageName] stringByAppendingPathExtension:@"jpg"];
    if( [[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:nil])
        return[UIImage imageWithContentsOfFile:imagePath];
    
    return nil;
    
}
-(NSString *) savePicture:(UIImage *)image
{
    NSError *error;
    NSString *imagesFolder = [self imagesFolder];
    NSString *imagePath = [imagesFolder stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.jpg",[self imageName]] ];

    if (image == nil)
    {
        if( [[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:nil])
            [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
        
        return nil;
    }
    //NSString* imageName = [self imageName];
    
    
    NSData* jpeg = UIImageJPEGRepresentation(image,  0.5);
    
    if (jpeg == nil)
        return nil;
    
    if (![jpeg writeToFile:imagePath options:NSDataWritingAtomic error:&error])
    {
            NSLog(@"Error writing image: %@",error);
        return nil;
    }
    
    return [self imageName];
}
            
@end

