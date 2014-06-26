//
//  YRInterviewAppointmentInfo.m
//  Recruit
//
//  Created by Yifan Fu on 6/25/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRInterviewAppointmentInfo.h"

@implementation YRInterviewAppointmentInfo

-(id)init
{
    self = [super init];
    
    if (self) {
        _candidateName = [NSMutableString new];
        _interviewerName = [NSMutableString new];
        _candidateRid = [NSMutableString new];
        _taken = NO;
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    self.candidateRid = [aDecoder decodeObjectForKey:@"candidateRid"];
    self.candidateName = [aDecoder decodeObjectForKey:@"candidateName"];
    self.interviewerName = [aDecoder decodeObjectForKey:@"interviewerName"];
    self.taken = [aDecoder decodeBoolForKey:@"taken"];
    
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.candidateRid forKey:@"candidateRid"];
    [aCoder encodeObject:self.candidateName forKey:@"candidateName"];
    [aCoder encodeObject:self.interviewerName forKey:@"interviewerName"];
    [aCoder encodeBool:self.taken forKey:@"taken"];
}

@end
