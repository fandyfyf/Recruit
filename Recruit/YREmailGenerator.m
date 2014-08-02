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
        _selectedAppointments = [NSMutableArray new];
    }
    
    return self;
}

-(NSDictionary*) generateEmail:(NSString*)defaultForm
{
    NSNumber* pdfFlag = [NSNumber numberWithBool:NO];
    
    NSString* newDefaultForm = [defaultForm stringByReplacingOccurrencesOfString:@"{resume}" withString:@""];
    //same means pdf doesn't exist
    if (![newDefaultForm isEqualToString:defaultForm]) {
        pdfFlag = [NSNumber numberWithBool:YES];
        defaultForm = newDefaultForm;
    }
    
    for (NSDictionary* dic in self.keyWordsList)
    {
        NSString* keyword = [dic allValues][0];
        
        NSString* replacement;

        //need to change after getting actual keywords
        if ([keyword isEqualToString:@"{studentRid}"]) {
            replacement = self.selectedCandidate.code;
        }
        else if ([keyword isEqualToString:@"{studentFirstName}"])
        {
            replacement = self.selectedCandidate.firstName;
        }
        else if ([keyword isEqualToString:@"{studentLastName}"])
        {
            replacement = self.selectedCandidate.lastName;
        }
        else if ([keyword isEqualToString:@"{studentEmail}"])
        {
            replacement = self.selectedCandidate.emailAddress;
        }
//        else if ([keyword isEqualToString:@"#interviewerName#"])
//        {
//            replacement = self.selectedInterviewer.name;
//        }
//        else if ([keyword isEqualToString:@"#interviewerEmail#"])
//        {
//            replacement = self.selectedInterviewer.email;
//        }
//        else if ([keyword isEqualToString:@"#interviewStartTime#"])
//        {
//            replacement = self.selectedAppointment.startTime;
//        }
        else if ([keyword isEqualToString:@"{interviewDuration}"])
        {
            replacement = [(NSNumber*)[[NSUserDefaults standardUserDefaults] objectForKey:kYRScheduleDurationKey] stringValue];
        }
        else if ([keyword isEqualToString:@"{appointments}"])
        {
            //replacement is ...
            if ([self.selectedAppointments count] > 0) {
                replacement = @"";
                
                NSDateFormatter* format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"MM/dd/yyy"];
                
                for (Appointment* ap in self.selectedAppointments)
                {
                    replacement = [replacement stringByAppendingString:[NSString stringWithFormat:@"Date: %@\nTime: %@\nInterviewer: %@\nLocation: %@\n\n",[format stringFromDate:ap.date],ap.startTime,ap.interviewers.name,self.eventAddress]];
                }
            }
            else
            {
                replacement = @" --- pending --- \n";
            }
        }
        else if ([keyword isEqualToString:@"{applicationLink}"])
        {
            //replacelink
        }
        
        if (replacement != nil) {

            defaultForm = [defaultForm stringByReplacingOccurrencesOfString:keyword withString:replacement];
        }
    }
    
    NSDictionary* result = @{@"message" : defaultForm, @"pdfFlag" : pdfFlag};
    
    return result;
}

@end
