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
NSString* const kYREngineerEmailFormsKey = @"engineerEmailForms";

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
                         @{@"appLinkIntern" : @"{applicationLinkIntern}"},
                         @{@"appLinkNCG" : @"{applicationLinkNCG}"},
                         @{@"interviewDuration" : @"{interviewDuration}"},
                         @{@"engineerName" : @"{engineerName}"},
                         @{@"scheduleGrid" : @"{ScheduleGrid}"},
                         @{@"resume" : @"{resume}"}];
        
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kYREmailKeyWordsKey];
    }
    
    //set up email template list
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kYREmailFormsKey] == nil) {
        NSArray* dic = @[@{@"Intern Apply Online": @"<subject:Yahoo is Interested in Speaking with You! - {studentFirstName} {studentLastName}>\nHi {studentFirstName}!\n\nIt was great meeting you at today's career fair!\n\nWe are excited that you are interested in internship employment opportunities with Yahoo. To be considered further, you must apply online within 48 hours via the following link: {applicationLinkIntern}\n\nWe look forward to your application and speaking with you again in the future.\n\nYahoo Campus Recruiting"},
                         @{@"NCG Apply Online": @"<subject:Yahoo is Interested in Speaking with You! - {studentFirstName} {studentLastName}>\nHi {studentFirstName}!\n\nIt was great meeting you at today's career fair!\n\nWe are excited that you are interested in full-time employment opportunities with Yahoo. To be considered further, you must apply online within 48 hours via the following link: {applicationLinkNCG}\n\nWe look forward to your application and speaking with you again in the future.\n\nYahoo Campus Recruiting"},
                         //@{@"Invitation" : @"<subject:Yahoo is Interested in Speaking with You! - {studentFirstName} {studentLastName}>\nHi {studentFirstName},<br /><br />We have received your resume and we are impressed with your qualifications! Yahoo is interested in speaking with you about internship opportunities for 2014.<br /><br />We'd like to set up sometime for you to chat over the phone with one of the members of our hiring team.<br /><br />It'd be my pleasure to assist you with setting up this initial phone interview. Please reply back to me within 48 hours, with the following information:<br /><br />   -   Your availability(in PST) for 2 weeks<br />   -   The best phone number to reach you<br />   -   Current Resume-make sure GPA is noted<br /><br />Once I have your availability, I'll confirm the logistics and email you the final details. If by chance you're not interested in pursuing this opportunity please let me know so we can proceed accordingly. Please note, Yahoo is an E-verify employer.<br /><br />To learn more about our campus recruiting schedule, job opportunities and what it's like to work at Yahoo follow our Facebook fan page at <a href = 'https://www.facebook.com/YahooUniversityRecruiting?ref=sgm'>Yahoo University Recruit</a><br /><br />I look forward to hearing back from you!<br /><br />Best regards,<br /><br />Signature"},
                         @{@"Intern Confirm" : @"<subject:Yahoo is Interested in Speaking with You! - {studentFirstName} {studentLastName}>\nHello {studentFirstName}!\n\nWe are excited to have you interview with Yahoo on your school Campus. You will meet with members of our hiring team, who are eager to learn more about you and your professional goals.\n\nYour interview has been confirmed. Specific details can be found below along with application instructions and job description. We hope that you have a wonderful interivew experience with Yahoo. And of course, don't hesitate to email or call me if you have any questions.\n\n\nBest of luck!\n\nsignature\n\nINTERVIEW DETAILS:\n\n{appointments}\nAPPLICATION INSTRUCTIONS:\n\nPrior to your interview, please review the job description and apply online via the following link: {applicationLinkIntern}"},
                         @{@"NCG Confirm" : @"<subject:Yahoo is Interested in Speaking with You! - {studentFirstName} {studentLastName}>\nHello {studentFirstName}!\n\nWe are excited to have you interview with Yahoo on your school Campus. You will meet with members of our hiring team, who are eager to learn more about you and your professional goals.\n\nYour interview has been confirmed. Specific details can be found below along with application instructions and job description. We hope that you have a wonderful interivew experience with Yahoo. And of course, don't hesitate to email or call me if you have any questions.\n\n\nBest of luck!\n\nsignature\n\nINTERVIEW DETAILS:\n\n{appointments}\nAPPLICATION INSTRUCTIONS:\n\nPrior to your interview, please review the job description and apply online via the following link: {applicationLinkNCG}"},
                         @{@"Engineer Confirm" : @"<subject:Upcoming Interview Schedule>\nHello {engineerName}!\n\nAttached you will find the resumes for your upcoming interviews. The interview schedule is as follows:\n\n{ScheduleGrid}\n\nDon't hesitate to email me if you have any questions.\n\nThanks!\n\nSignature"}];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kYREmailFormsKey];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:kYREngineerEmailFormsKey] == nil) {
        NSArray* dic = @[@{@"Engineer Confirm" : @"<subject:Upcoming Interview Schedule>\nHello {engineerName}!\n\nAttached you will find the resumes for your upcoming interviews. The interview schedule is as follows:\n\n{ScheduleGrid}Don't hesitate to email me if you have any questions.\n\nThanks!\n\nSignature"}];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:kYREngineerEmailFormsKey];
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
    if (self.mcManager.isHost) {
        //Host enter background
        for (NSDictionary *peerSession in self.mcManager.activeSessions) {
            [[peerSession valueForKey:@"session"] disconnect];
        }
        [self.mcManager.activeSessions removeAllObjects];
        //stop advertising
        [self.mcManager advertiseSelf:NO];
    }
    else
    {
        //Client enter background
        [self.mcManager.session disconnect];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    if (self.mcManager.isHost) {
        NSLog(@"Host entering...");
        
        if (self.mcManager.isAdvertising) {
            [self.mcManager advertiseSelf:YES];
        }
    }
    else
    {
        NSLog(@"Client entering...");
        //don't need to do anything since the client will try to reconnect upon failure in sending the packets
        
        if (self.mcManager.isDebriefing && !self.mcManager.isBrowsing)
        {
            [self.mcManager.autoBrowser startBrowsingForPeers];
            [self.mcManager setBrowsing:YES];
        }
    }
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
