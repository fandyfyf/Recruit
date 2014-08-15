//
//  YRAppDelegate.m
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRAppDelegate.h"

NSString* const kYREmailKeyWordsKey = @"emailKeyWords";
NSString* const kYRScheduleColumsKey = @"scheduleColums";
NSString* const kYRScheduleStartTimeKey = @"scheduleStartTime";
NSString* const kYRScheduleDurationKey = @"scheduleDuration";
NSString* const kYRScheduleStartDateKey = @"scheduleStartDate";
NSString* const kYRScheduleNumberOfDayKey = @"scheduleNumberOfDay";
NSString* const kYREmailFormsKey = @"emailForms";

@implementation YRAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //create the mcManager at application launch
    self.mcManager = [YRMCManager new];
    
    // Room configuration initialization
    if([[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleColumsKey] == nil)
    {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:3] forKey:kYRScheduleColumsKey];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:8] forKey:kYRScheduleStartTimeKey];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:45] forKey:kYRScheduleDurationKey];
        [[NSUserDefaults standardUserDefaults] setValue:[NSDate date] forKey:kYRScheduleStartDateKey];
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:1] forKey:kYRScheduleNumberOfDayKey];
    }
    
    //set up email keyword list
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kYREmailKeyWordsKey] == nil) {
        NSArray* dic = @[@{@"studentRid" : @"{studentRid}"},
                         @{@"studentFirstName" : @"{studentFirstName}"},
                         @{@"studentLastName" : @"{studentLastName}"},
                         @{@"studentEmail" : @"{studentEmail}"},
                         @{@"appointments" : @"{appointments}"},
                         @{@"appLink" : @"{applicationLink}"},
                         @{@"interviewDuration" : @"{interviewDuration}"},
                         @{@"resume" : @"{resume}"}];
        
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kYREmailKeyWordsKey];
    }
    
    //set up email template list
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kYREmailFormsKey] == nil) {
        NSArray* dic = @[@{@"Apply Online": @"<subject:Yahoo is Interested in Speaking with You! - {studentFirstName} {studentLastName}>\nHi {studentFirstName}!\n\nIt was great meeting you at today's career fair!\n\nWe are excited that you are interested in opportunities with Yahoo. To be considered further, you must apply online via the following link within 48 hours: {applicationLink}\n\nWe look forward to your application and speaking with you again in the future.\n\nYahoo Campus Recruiting"},
                         @{@"Invitation" : @"<subject:Yahoo is Interested in Speaking with You! - {studentFirstName} {studentLastName}>\nHi {studentFirstName},\n\nWe have received your resume and we are impressed with your qualifications! Yahoo is interested in speaking with you about internship opportunities for 2014.\n\nWe'd like to set up sometime for you to chat over the phone with one of the members of our hiring team.\n\nIt'd be my pleasure to assist you with setting up this initial phone interview. Please reply back to me within 48 hours, with the following information:\n\n   -   Your availability(in PST) for 2 weeks\n   -   The best phone number to reach you\n   -   Current Resume-make sure GPA is noted\n\nOnce I have your availability, I'll confirm the logistics and email you the final details. If by chance you're not interested in pursuing this opportunity please let me know so we can proceed accordingly. Please note, Yahoo is an E-verify employer.\n\nTo learn more about our campus recruiting schedule, job opportunities and what it's like to work at Yahoo follow our Facebook fan page at https://www.facebook.com/YahooUniversityRecruiting?ref=sgm\n\nI look forward to hearing back from you!\n\nBest regards,\n\nSignature"},
                         @{@"Confirmation" : @"<subject:Yahoo is Interested in Speaking with You! - {studentFirstName} {studentLastName}>\nHello {studentFirstName}!\n\nWe are excited to have you interview with Yahoo on your school Campus. You will meet with members of our hiring team, who are eager to learn more about you and your professional goals.\n\nYour interview has been confirmed. Specific details can be found below along with application instructions and job description. We hope that you have a wonderful interivew experience with Yahoo. And of course, don't hesitate to email or call me if you have any questions.\n\n\nBest of luck!\n\nsignature\n\nINTERVIEW DETAILS:\n\n{appointments}\nAPPLICATION INSTRUCTIONS:\n\nPrior to your interview, please review the job description and apply online via the following link: {applicationLink}"},
                         @{@"Rejection" : @""}];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kYREmailFormsKey];
    }
    
    //save all the setting
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //create email generater
    self.emailGenerator = [[YREmailGenerator alloc] init];
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

    
    //    if (!self.mcManager.isHost) {
//        [self.mcManager.session disconnect];
//    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"will enter foreground");
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
//    if (!self.mcManager.isHost) {
//        NSLog(@"entering...");
//        //[[self mcManager] setupMCBrowser];
//        
//        
//        [self.mcManager.browser.browser startBrowsingForPeers];
//        
//        [self.mcManager.browser.browser invitePeer:self.mcManager.lastConnectionPeerID toSession:self.mcManager.session withContext:nil timeout:10];
//        //MCNearbyServiceBrowser* browser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.mcManager.peerID serviceType:@"files"];
//        
//        //[browser invitePeer:self.mcManager.lastConnectionPeerID toSession:self.mcManager.session withContext:nil timeout:10];
//    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    NSLog(@"did become active");
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [self saveContext];
}

- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - CoreData stack

-(NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return self.managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Recruit" withExtension:@"momd"];
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
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Recruit.sqlite"];
    
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
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

@end
