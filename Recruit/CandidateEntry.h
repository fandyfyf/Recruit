//
//  CandidateEntry.h
//  Recruit
//
//  Created by Yifan Fu on 8/21/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment;

@interface CandidateEntry : NSManagedObject

@property (nonatomic, retain) NSString * businessUnit1;
@property (nonatomic, retain) NSString * businessUnit2;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSArray * fileNames;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSNumber * gpa;
@property (nonatomic, retain) NSString * interviewer;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * pdf;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * preference;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSNumber * resumeCounter;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSArray * tagList;
@property (nonatomic, retain) NSString * yday1;
@property (nonatomic, retain) NSString * yday2;
@property (nonatomic, retain) NSNumber * approved;
@property (nonatomic, retain) NSSet *appointments;
@end

@interface CandidateEntry (CoreDataGeneratedAccessors)

- (void)addAppointmentsObject:(Appointment *)value;
- (void)removeAppointmentsObject:(Appointment *)value;
- (void)addAppointments:(NSSet *)values;
- (void)removeAppointments:(NSSet *)values;

@end
