//
//  HGGSAppDelegate.m
//  HoneyGoGroceryShopping
//
//  Created by Ana Muniz on 11/9/13.
//  Copyright (c) 2013 Ana Muniz. All rights reserved.
//
#import <DropboxSDK/DropboxSDK.h>
#import "HGGSAppDelegate.h"
#import "HGGSGroceryStoreManager.h"

#define APP_KEY @"t7bb846jrivfl07"
#define APP_SECRET @"cmft478dvllzue3"

@implementation HGGSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // enable dropbox...
    DBSession *dbSession = [[DBSession alloc]
                            initWithAppKey:APP_KEY
                            appSecret:APP_SECRET
                            root:kDBRootAppFolder]; // either kDBRootAppFolder or kDBRootDropbox
    
    [DBSession setSharedSession:dbSession];

#if TARGET_IPHONE_SIMULATOR
    // where are you?
    NSLog(@"Documents Directory: %@", [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject]);
#endif
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[HGGSGroceryStoreManager sharedStoreManager] saveChanges];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark Dropbox API Methods
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
  sourceApplication:(NSString *)source annotation:(id)annotation {
    UIAlertView *alertView;
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            // At this point you can start making API calls
            alertView = [[UIAlertView alloc] initWithTitle:@"Successfully Linked with Dropbox."
                                                   message:@"You can now share your grocery lists across devices."
                         //delegate:[[[[self window] rootViewController] navigationController] visibleViewController]
                                                  delegate:[self dropboxViewController]
                                         cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            return YES;
        }
    }
    // Add whatever other url handling code your app requires here
    alertView = [[UIAlertView alloc] initWithTitle:@"Failed to link with Dropbox."
                                           message:@"Please verify that you have access to the internet."
                 //delegate:[[[[self window] rootViewController] navigationController] visibleViewController]
                                          delegate: [self dropboxViewController]
                                 cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
    
//    [alertView show];
    return NO;
}

@end
