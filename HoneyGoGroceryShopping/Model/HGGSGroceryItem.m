//
//  GroceryItem.m
//  Grocery List Single View
//
//  Created by Ana Muniz on 9/19/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/NSJSONSerialization.h>
#import "HGGSGroceryItem.h"
#import "HGGSDate.h"

@implementation HGGSGroceryItem
#pragma mark Initialization Methods
-(id)initFromDictionary:(NSDictionary*)itemAttributes imagesFolder:(NSString*)imagesFolder
{
    double quantity =(double)[[itemAttributes objectForKey:@"quantity" ] doubleValue];
    NSString * itemName = [itemAttributes objectForKey:@"name"];
    

    _imagesFolder = imagesFolder;
    
 //   _imageFileName = [[imagesFolder stringByAppendingPathComponent:itemName] stringByAppendingPathExtension:@"jpg"];
    
    self = [self initWithOldDetails:itemName
                        quantity:quantity
                        unit:[itemAttributes objectForKey:@"unit"]
                        section:[itemAttributes objectForKey:@"section"]
                        notes:[itemAttributes objectForKey:@"notes"]
                        select:[HGGSBool stringAsBool:[itemAttributes objectForKey:@"selected"]]
                        lastPurchasedOn:[HGGSDate stringAsDate:[itemAttributes objectForKey:@"lastPurchasedDate"]]
                        sectionId:[itemAttributes objectForKey:@"category"]
                        image:[itemAttributes objectForKey:@"image"]
            ];
    
;
    return self;
}

-(id)initWithOldDetails:(NSString*)name quantity:(double)amount unit:(NSString *)unitDescription section:(NSString *)grocerySection notes:(NSString*)notes select:(bool)selected lastPurchasedOn:(NSDate*)lastPurchasedDate sectionId:(NSString *)sectionId image:(NSString*)imageName
{
    self = [self initWithDetails:name quantity:amount unit:unitDescription section:grocerySection notes:notes select:selected lastPurchasedOn:lastPurchasedDate image:[self loadPicture:imageName inFolder:[self imagesFolder]]] ;
    if (self)
    {
        [self setSectionId:sectionId];
    
    }
    return self;
}

-(id)initWithDetails:(NSString*)name quantity:(double)amount unit:(NSString *)unitDescription section:(NSString *)grocerySection notes:(NSString*)notes select:(bool)selected lastPurchasedOn:(NSDate*)lastPurchasedDate image:(UIImage *)image
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
        [self setSelected:selected];
        [self setLastPurchasedDate:lastPurchasedDate];
        [self setImage:image];
        
    }
    return self;
}
-(id)init
{
    NSString* emptyString = @"";
    self = [self initWithDetails:emptyString quantity:1 unit:emptyString section:emptyString notes:emptyString select:YES lastPurchasedOn:nil image:nil];
    if (self)
    {
        [self setSectionId:emptyString];
    }
    return self;
}

#pragma mark Public Methods
-(NSDictionary*)asDictionary
{
    if ([self image] != nil)
        [self savePicture:[self image]];
    
    _asDictionary =[[NSDictionary alloc] initWithObjectsAndKeys:
                    _name,@"name",
                    [NSNumber numberWithDouble:_quantity],@"quantity",
                    (_unit == nil) ? @"" : _unit, @"unit",
                    (_notes == nil) ? @"" : _notes, @"notes",
                    [HGGSBool boolAsString:_selected], @"selected",
                    /*(_sectionId == nil) ? @"" : _sectionId, @"category",*/
                    (_section == nil) ? @"" : _section, @"section",
                    [HGGSDate dateAsString:_lastPurchasedDate], @"lastPurchasedDate",
                    [self imageName], @"image",
                    nil];
    
    // todo: add property that holds path to image; save image to grocery store folder
    //http://stackoverflow.com/questions/22428615/how-do-i-get-back-a-saved-picture-on-iphone-camera-roll
    
    return _asDictionary;
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
    if (([self image] != nil) && ([self name] != nil))
        return [NSString stringWithFormat:@"%lu",(unsigned long)[[self name] hash]];
    
    return nil;
}
#pragma mark NSCopying 
-(id)copyWithZone:(NSZone *)zone
{
    HGGSGroceryItem *copy = [[HGGSGroceryItem alloc] initWithDetails:[self name]
                                                            quantity:[self quantity]
                                                                unit:[self unit]
                                                             section:[self section]
                                                               notes:[self notes]
                                                              select:[self selected]
                                                     lastPurchasedOn:[self lastPurchasedDate]
                                                               image:[self image]];
    
    [copy setSectionId:[self sectionId]];
    
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
    NSString *imagePath = [[folderName stringByAppendingPathComponent:imageName] stringByAppendingPathExtension:@"jpg"];
    if( [[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO])
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
        if( [[NSFileManager defaultManager] fileExistsAtPath:imagePath isDirectory:NO])
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

