//
//  NSString+SringExtensions.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 10/19/14.
//  Copyright (c) 2014 Ana Muniz. All rights reserved.
//

#import "NSString+SringExtensions.h"

@implementation NSString (SringExtensions)
- (BOOL)endsWith:(NSString *)end
{
    NSRange range = [self rangeOfString:end options:NSCaseInsensitiveSearch];
    
    return  ( range.location != NSNotFound &&
        range.location + range.length == [self length] );
}
+(BOOL) isEmptyOrNil:(NSString*)string
{
    if (string == nil)
        return YES;
    
    NSString* trimmedValue = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([trimmedValue  length] == 0)
        return YES;
    
    return NO;
}
@end
