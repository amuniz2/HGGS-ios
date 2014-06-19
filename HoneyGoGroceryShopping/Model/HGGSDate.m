//
//  HGGSDate.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/27/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//

#import "HGGSDate.h"

@implementation HGGSDate
+(NSString*)dateAsString:(NSDate*)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    [formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
    [formatter setTimeStyle:NSDateFormatterShortStyle ];
    [formatter setDateStyle:NSDateFormatterShortStyle];

    return [formatter stringFromDate:date];
}

+(NSDate*)stringAsDate:(NSString*)date
{
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    
    [formatter setFormatterBehavior: NSDateFormatterBehavior10_4];
    [formatter setTimeStyle:NSDateFormatterShortStyle ];
    [formatter setDateStyle:NSDateFormatterShortStyle];
    
    return [formatter dateFromString:date];
}

@end

@implementation HGGSBool
+(NSString*)boolAsString:(bool)yesOrNo
{
    return yesOrNo ? @"true" :  @"false";
}

+(bool)stringAsBool:(NSString*)trueOrFalse
{
    return [trueOrFalse isEqualToString:@"true"] ? YES : NO;
}

@end
