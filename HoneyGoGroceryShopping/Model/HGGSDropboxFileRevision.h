//
//  HGGSDropboxFileRevision.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 3/6/16.
//  Copyright © 2016 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HGGSDropboxFileRevision : NSObject <NSCoding>
{
}
@property NSString *fileName;
@property NSString *revision;

@end
