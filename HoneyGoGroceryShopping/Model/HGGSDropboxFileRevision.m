//
//  HGGSDropboxFileRevision.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 3/6/16.
//  Copyright © 2016 Ana Muniz. All rights reserved.
//

#import "HGGSDropboxFileRevision.h"

@implementation HGGSDropboxFileRevision
#pragma mark Lifecycle

-(id)initWithRevision:(NSString* )revision fileName:(NSString*)fileName
{
    if ((self = [super init]))
    {
        [self setFileName:fileName];
        [self setRevision:revision];
    }
    return self;
}

#pragma mark NSCoding

#define kFileName      @"FileName"
#define kRevision      @"Revision"

- (void) encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeObject:_fileName forKey:kFileName];
    [encoder encodeObject:_revision forKey:kRevision];
}

- (id)initWithCoder:(NSCoder *)decoder {
    
    NSString *fileName = [decoder decodeObjectForKey:kFileName];
    NSString * revision = [decoder decodeObjectForKey:kRevision];
    
    return [self initWithRevision:revision fileName:fileName];
}

@end
