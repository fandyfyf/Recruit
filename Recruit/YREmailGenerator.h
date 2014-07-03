//
//  YREmailGenerator.h
//  Recruit
//
//  Created by Yifan Fu on 7/1/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CandidateEntry.h"
#import "Interviewer.h"
#import "Appointment.h"

@interface YREmailGenerator : NSObject

@property (strong, nonatomic) CandidateEntry* selectedCandidate;
@property (strong, nonatomic) Interviewer* selectedInterviewer;
@property (strong, nonatomic) Appointment* selectedAppointment;
@property (strong, nonatomic) NSArray* keyWordsList;

-(id)init;

-(NSString*)generateEmail:(NSString*)defaultForm;

@end
