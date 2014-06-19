//
//  CandidateEntry.h
//  Recruit
//
//  Created by Yifan Fu on 6/19/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface CandidateEntry : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * emailAddress;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSNumber * gpa;
@property (nonatomic, retain) NSString * interviewer;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSNumber * maxgpa;
@property (nonatomic, retain) NSString * notes;
@property (nonatomic, retain) NSNumber * pdf;
@property (nonatomic, retain) NSString * position;
@property (nonatomic, retain) NSString * preference;
@property (nonatomic, retain) NSNumber * rank;
@property (nonatomic, retain) NSNumber * ratio;
@property (nonatomic, retain) NSNumber * recommand;
@property (nonatomic, retain) NSString * status;

@end
