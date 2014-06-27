//
//  Appointment.h
//  Recruit
//
//  Created by Yifan Fu on 6/27/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class CandidateEntry, Interviewer;

@interface Appointment : NSManagedObject

@property (nonatomic, retain) NSString * startTime;
@property (nonatomic, retain) NSNumber * apIndex_x;
@property (nonatomic, retain) NSNumber * apIndex_y;
@property (nonatomic, retain) CandidateEntry *candidate;
@property (nonatomic, retain) Interviewer *interviewers;

@end
