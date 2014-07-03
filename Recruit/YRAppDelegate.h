//
//  YRAppDelegate.h
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YRMCManager.h"
#import "YRDataManager.h"
#import "YREmailGenerator.h"
//@class YRDataManager;
//@class YRMCManager;

FOUNDATION_EXPORT NSString* const kYREmailKeyWordsKey;
FOUNDATION_EXPORT NSString* const kYRScheduleDurationKey;
FOUNDATION_EXPORT NSString* const kYRScheduleColumsKey;
FOUNDATION_EXPORT NSString* const kYRScheduleStartTimeKey;

@interface YRAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) YRMCManager *mcManager;
@property (strong, nonatomic) YRDataManager *dataManager;
@property (strong, nonatomic) YREmailGenerator *emailGenerator;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

-(void)saveContext;
-(NSURL *) applicationDocumentsDirectory;


@end
