//
//  YRInterviewAppointmentInfo.h
//  Recruit
//
//  Created by Yifan Fu on 6/25/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YRInterviewAppointmentInfo : NSObject <NSCoding>

@property (assign, getter = isTaken) BOOL taken;
@property (assign) int index;
@property (strong, nonatomic) NSMutableString * interviewerName;
@property (strong, nonatomic) NSMutableString * candidateName;
@property (strong, nonatomic) NSMutableString * candidateRid;

@end
