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
    UpdateToLatestFile,
    DoNotShareFile
} DbFileSynchOption;

typedef enum DbSynchStatus
{
    Idle,
    CopyingSetupFile,
    CopyingItems,
    CopyingImages
} SynchStatus;

@interface HGGSDropboxClientViewController : UIViewController <DBRestClientDelegate>
{
    
}
-(void) copyStoreToDropbox;

-(void) copyStoreFromDropbox;
-(void)synchActivityCompleted:(BOOL) succeeded;
@property (strong,nonatomic) HGGSGroceryStore * groceryStore;
@property CGPoint activityIndicatorCenter;
@end
