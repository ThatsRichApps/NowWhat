//
//  NowWhatAppDelegate.m
//  NowWhat
//
//  Created by Rich Humphrey on 10/14/13.
//  Copyright (c) 2013 Rich Humphrey. All rights reserved.
//

#import "NowWhatAppDelegate.h"

#import "NowWhatMasterViewController.h"
#import "MainScheduleViewController.h"
#define kViewNSDate @"viewNSDate"
#define kTimeLoaded @"timeLoaded"
#define kLastLoaded @"lastLoaded"
#define kLockReset @"lockReset"
#define kNotificationTime @"notificationTime"


@implementation NowWhatAppDelegate {
    
    MainScheduleViewController *scheduleController;
    
}

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    // set the user defaults to their default values
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    
    if (![defaults integerForKey:kNotificationTime]) {
        
        // if the defaults are not set, set them here
        
        [defaults setInteger:1 forKey:kNotificationTime];
        [defaults synchronize];
        
    };
    
    //NSLog (@"didFinishLaunchingWithOptions");
    
    // Override point for customization after application launch.
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        //UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
        //splitViewController.delegate = (id)navigationController.topViewController;
        
        UINavigationController *masterNavigationController = splitViewController.viewControllers[0];
        //NowWhatMasterViewController *controller = (NowWhatMasterViewController *)masterNavigationController.topViewController;
        scheduleController = (MainScheduleViewController *)masterNavigationController.topViewController;

        scheduleController.managedObjectContext = self.managedObjectContext;
    
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
        
        
    } else {
        
        // changed this when we added schedules
        //UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        //NowWhatMasterViewController *controller = (NowWhatMasterViewController *)navigationController.topViewController;
        //controller.managedObjectContext = self.managedObjectContext;

        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        scheduleController = (MainScheduleViewController *)navigationController.topViewController;
        scheduleController.managedObjectContext = self.managedObjectContext;
         
    }
    
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
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
    //NSLog(@"application did become active");
    
    NSUserDefaults *defaults =  [NSUserDefaults standardUserDefaults];
    NSDate *timeNow = [NSDate date];
    
    //[defaults setObject:nil forKey:kTimeLoaded];
    
    NSDate *lastLoaded =  (NSDate *)[defaults objectForKey:kTimeLoaded];
    
    if (lastLoaded==nil)
    {
        //NSLog (@"First launch! Load up previous database in background, then delete it");
        
        [scheduleController importOldDatabase];
        
    }
    else
    {
        
        //NSTimeInterval timeSinceUnload = [timeNow timeIntervalSinceDate:lastUnload]/3600.0;
        NSTimeInterval timeSinceLastLoaded = [timeNow timeIntervalSinceDate:lastLoaded];
        
        //NSLog (@"Time since last reload was %.1f seconds", timeSinceLastLoaded);
        
        //do your stuff - treat NSTimeInterval as double
        // this sets the time interval (in seconds) where we should reset to the current day
        
        // set this to 15 minutes for initial release
        
        if (timeSinceLastLoaded > 900.0)
        {
            
           //NSLog(@"reset the viewNSDate");
            // if it's been a while, reset viewNSDate to now
            
            // this doesn't work because the view is still loaded, changing the basetime won't reload it
            
            //NSDate *baseTime = [Event resetToBaseTime:timeNow];
            //[defaults setObject:baseTime forKey:kViewNSDate];
            
            [scheduleController resetDateTo:timeNow];
            
        }
    }
    
    BOOL lockReset = [defaults boolForKey:kLockReset];
    //NSLog(@"reset value is %hhd", lockReset);
    
    if (lockReset) {
        
        [scheduleController resetLock];
        // now reset the value to default (0)
        [defaults setObject:0 forKey:kLockReset];
        
    }
    

    // reset the time to now
    [defaults setObject:timeNow forKey:kTimeLoaded];
    [defaults setObject:lastLoaded forKey:kLastLoaded];
    [defaults synchronize];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
             // Replace this implementation with code to handle the error appropriately.
             // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
           //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"NowWhat" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"NowWhat.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        //NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }    
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
    //NSLog (@"The didReceiveLocalNotification method in the app delegate was called, hooray.");
    
    // pop up an alert view
    UIAlertView *emptyTextAlert;
    
    emptyTextAlert = [[UIAlertView alloc]
                      initWithTitle:[NSString stringWithFormat:@"Notification:"]
                      message:[NSString stringWithFormat:@"%@", notification.alertBody]
                      delegate:self
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil];
    
    [emptyTextAlert show];
    
    
    
}



-(BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    //NSLog(@"sending message from app delegate to open url");
    
    // we need to get to the schedule controller
    
    
    //UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    
    //MainScheduleViewController *controller = (MainScheduleViewController *)[navigationController.viewControllers objectAtIndex:0];;
    
    
    if (url != nil && [url isFileURL]) {
        [scheduleController handleOpenURL:url];
    }
    
    return YES;

}


- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}


@end
