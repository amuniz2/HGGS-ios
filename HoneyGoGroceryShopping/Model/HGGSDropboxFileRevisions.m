//
//  HGGSDropboxFileRevisions.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 3/6/16.
//  Copyright © 2016 Ana Muniz. All rights reserved.
//

#import "HGGSDropboxFileRevision.h"
#import "HGGSDropboxFileRevisions.h"

@implementation HGGSDropboxFileRevisions
{
    NSString *_filePath;
}
#pragma mark Lifecycle methods
-(id)initFromFolder:(NSString*)folderPath
{
    if (self = [super init])
    {
        _filePath = [folderPath stringByAppendingPathComponent:@"DropboxFileRevisions.txt"];
    }
    return self;
}
#pragma Property Overrides
-(NSString *)filePath
{
    return _filePath;
}

#pragma mark Pesistence
//+(HGGSDropboxFileRevisions*)load
//{
//    HGGSDropboxFileRevisions * fileRevisions = [[HGGSDropboxFileRevisions alloc] initFromFolder:folderPath];
//    [fileRevisions load];
//    return fileRevisions;
//}

-(NSMutableDictionary *)loadLocalFileRevisions {
    
    if (_localFileRevisions != nil)
        return _localFileRevisions;
    
    NSArray * revisionsInFile = [NSKeyedUnarchiver unarchiveObjectWithFile:[self filePath]];
    if (revisionsInFile == nil)
        revisionsInFile = [[NSMutableArray alloc] init];

    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:[revisionsInFile count]];
    for (HGGSDropboxFileRevision *revision in revisionsInFile) {
        [dictionary setObject:revision forKey:revision.fileName];
    }
   
    [self setLocalFileRevisions:dictionary];
    
    return dictionary;
}
-(void) save
{
    if (_localFileRevisions == nil)
        return;

    [NSKeyedArchiver archiveRootObject:[[self localFileRevisions] allValues] toFile:[self filePath]];
}

- (void)deleteDoc {
    
    NSError *error;
    BOOL success = [[NSFileManager defaultManager] removeItemAtPath:[self filePath] error:&error];
    if (!success) {
        NSLog(@"Error removing document path: %@", error.localizedDescription);
    }
    
}
#pragma mark List Maintenance
-(HGGSDropboxFileRevision *)addOrUpdateRevisionTo:(NSString*)newRevision forFile:(NSString*)fileName
{
    HGGSDropboxFileRevision *existingFileRevision = [[self localFileRevisions] objectForKey:fileName] ;
    
    if(existingFileRevision == nil)
    {
        existingFileRevision = [[HGGSDropboxFileRevision alloc] init];
        [existingFileRevision setRevision:newRevision];
        [existingFileRevision setFileName:fileName];
        
        [[self localFileRevisions] setObject:existingFileRevision forKey:fileName];
    }
    else
    {
        [existingFileRevision setRevision:newRevision];
    }
    return existingFileRevision;
}
-(NSString*) getLocalFileRevisionFor:(NSString*)filename
{
    HGGSDropboxFileRevision *localRevision = [[self localFileRevisions] objectForKey:filename];
    
    if (localRevision == nil)
        return 0;
    
    return localRevision.revision;
}

-(void)addFileRevision:(HGGSDropboxFileRevision *)fileRevision
{
    [[self localFileRevisions] setObject:fileRevision forKey:fileRevision.fileName];
    //[self sortOptions];
    //[_options addEntriesFromDictionary:[NSDictionary dictionaryWithObject:option forKey:[option name]]];
}
-(void)deleteFileRevision:(HGGSDropboxFileRevision *)fileRevision
{
    [[self localFileRevisions] removeObjectForKey:fileRevision.fileName];
}

//-(NSString *)filePath
//{
//    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    
//    // for ios, there will only be one director in the list
//    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
//    
//    return [documentDirectory stringByAppendingPathComponent:kDataFile];
//    
//}
//
@end
