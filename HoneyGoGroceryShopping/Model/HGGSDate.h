//
//  HGGSDate.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/27/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGSDate : NSObject
+(NSString*)dateAsString:(NSDate*)date;
+(NSDate*)stringAsDate:(NSString*)date;

@end

@interface HGGSBool : NSObject
+(NSString*)boolAsString:(bool)yesOrNo;
+(bool)stringAsBool:(NSString*)trueOrFalse;

@end
