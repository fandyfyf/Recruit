//
//  YREmailGenerator.m
//  Recruit
//
//  Created by Yifan Fu on 7/1/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YREmailGenerator.h"
#import "YRAppDelegate.h"


@implementation YREmailGenerator

-(id) init
{
    self = [super init];
    
    if (self) {
        _keyWordsList = [[NSUserDefaults standardUserDefaults] objectForKey:kYREmailKeyWordsKey];
    }
    
    return self;
}

-(NSString*)generateEmail:(NSString*)defaultForm
{
    for (NSDictionary* dic in self.keyWordsList)
    {
        NSString* keyword = [dic allKeys][0];
        
        NSString* replacement;
        
        //need to change after getting actual keywords
        if ([keyword isEqualToString:@"studentRid"]) {
            replacement = self.selectedCandidate.code;
        }
        else if ([keyword isEqualToString:@"studentName"])
        {
            replacement = [NSString stringWithFormat:@"%@ %@",self.selectedCandidate.firstName, self.selectedCandidate.lastName];
        }
        else if ([keyword isEqualToString:@"studentEmail"])
        {
            replacement = self.selectedCandidate.emailAddress;
        }
        else if ([keyword isEqualToString:@"interviewerName"])
        {
            replacement = self.selectedInterviewer.name;
        }
        else if ([keyword isEqualToString:@"interviewerEmail"])
        {
            replacement = self.selectedInterviewer.email;
        }
        else if ([keyword isEqualToString:@"interviewStartTime"])
        {
            replacement = self.selectedAppointment.startTime;
        }
        else if ([keyword isEqualToString:@"interviewDuration"])
        {
            replacement = [(NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:kYRScheduleDurationKey] stringValue];
        }
        if (replacement != nil) {
            defaultForm = [defaultForm stringByReplacingOccurrencesOfString:keyword withString:replacement];
        }
    }
    return defaultForm;
}

@end
