//
//  HGGSDropboxFileRevisions.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 3/6/16.
//  Copyright © 2016 Ana Muniz. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HGGSDropboxFileRevision;

@interface HGGSDropboxFileRevisions : NSObject
{
}
@property (readonly) NSString * filePath;
@property NSMutableDictionary *localFileRevisions;
//@property (readonly)NSArray * plans;

//- (void)load;
-(NSMutableDictionary *)loadLocalFileRevisions;
- (void)save;
- (void)deleteDoc;

//@property NSString* name;

-(id)initFromFolder:(NSString*)folderPath;

-(void)addFileRevision:(HGGSDropboxFileRevision*)newFile;
-(HGGSDropboxFileRevision *)addOrUpdateRevisionTo:(NSString*)revision forFile:(NSString*)fileName;
-(NSString*) getLocalFileRevisionFor:(NSString*)filename;
@end
