//
//  Interviewer.h
//  Recruit
//
//  Created by Yifan Fu on 6/27/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Appointment;

@interface Interviewer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * interviewerId;
@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSSet *appointments;
@end

@interface Interviewer (CoreDataGeneratedAccessors)

- (void)addAppointmentsObject:(Appointment *)value;
- (void)removeAppointmentsObject:(Appointment *)value;
- (void)addAppointments:(NSSet *)values;
- (void)removeAppointments:(NSSet *)values;

@end
