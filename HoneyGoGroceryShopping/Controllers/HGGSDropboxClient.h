//
//  HGGSDropboxClientControllerViewController.h
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 12/6/15.
//  Copyright © 2015 Ana Muniz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HGGSDbGroceryFilesStore.h"

typedef enum DbFileSynchOptions
{
    ShareDropboxFile,
    ShareLocalFile,
    //UpdateToLatestFile,
    DoNotShareFile
} DbFileSynchOption;

typedef enum DbSynchStatus
{
    Idle,
    CopyingSetupFile,
    CopyingSetupOnlyfile,
    CopyingItems,
    CopyingImages
} SynchStatus;

@protocol HGGSDropboxControllerDelegate <NSObject>
-(void)synchActivityCompleted:(BOOL)succeeded error:(NSString *)errorMessage;
@optional
@end

@interface HGGSDropboxClient: NSObject <DBRestClientDelegate> //UIViewController <DBRestClientDelegate>
{
    NSString *_dbRootFolder;
}
+(id)CreateFromController:(UIViewController*)controller forStore:(HGGSGroceryStore*)store;

-(void) copyStoreToDropbox;
-(void) copyStoreFromDropbox;
-(void) copySetupOnlyFromDropbox;
-(void) copySetupOnlyToDropbox;
-(void) copyListFromDropbox;
-(void) copyListToDropbox;

@property (weak,nonatomic) HGGSGroceryStore * groceryStore;
@property CGPoint activityIndicatorCenter;
@property (weak, nonatomic) id <HGGSDropboxControllerDelegate> delegate;
@property (weak, nonatomic) UIViewController *clientController;
@property BOOL filesExistInDropbox;
@end
