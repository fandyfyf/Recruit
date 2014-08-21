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
        _selectedCandidate = nil;
        _selectedInterviewer = nil;
    }
    
    return self;
}

-(NSDictionary*) generateEmail:(NSString*)defaultForm
{
    NSNumber* pdfFlag = [NSNumber numberWithBool:NO];
    
    //grab subject
    
    NSRange left = [defaultForm rangeOfString:@"<subject:"];
    NSRange right = [defaultForm rangeOfString:@">"];
    
    NSString* subjectString = nil;
    
    //================================try to form subject string====================================
    if (left.location != NSNotFound && right.location != NSNotFound) {
        NSRange key = NSMakeRange(left.location + left.length, right.location - left.location - left.length);
        
        subjectString = [defaultForm substringWithRange:key];
        
        defaultForm = [defaultForm stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"<subject:%@>",subjectString] withString:@""];
        
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
                
                subjectString = [subjectString stringByReplacingOccurrencesOfString:keyword withString:replacement];
            }
        }
    }
    //======================================================================================
    
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
                    NSString* interviewerName = ap.interviewers.name;
                    NSString* interviewerLocation = self.eventAddress;
                    
                    if (interviewerName == nil) {
                        interviewerName = @"--- pending ---";
                    }
                    
                    if (interviewerLocation == nil) {
                        interviewerLocation = @"--- pending ---";
                    }
                    
                    replacement = [replacement stringByAppendingString:[NSString stringWithFormat:@"Date: %@<br />Time: %@<br />Interviewer: %@<br />Location: %@<br /><br />",[format stringFromDate:ap.date],ap.startTime,interviewerName,interviewerLocation]];
                }
            }
            else
            {
                replacement = @" --- pending --- <br />";
            }
        }
        else if ([keyword isEqualToString:@"{applicationLinkIntern}"])
        {
            //replacelink
            replacement = @"<a href=' https://tas-yahoo.taleo.net/careersection/yahoo_us_cs/jobdetail.ftl?lang=en&amp;job=1448872'>Application Link</a>";
        }
        else if ([keyword isEqualToString:@"{applicationLinkNCG}"])
        {
            //replacelink
            replacement = @"<a href='https://tas-yahoo.taleo.net/careersection/yahoo_us_cs/jobdetail.ftl?lang=en&amp;job=1448866'>Application Link</a>";
        }
        
        if (replacement != nil) {

            defaultForm = [defaultForm stringByReplacingOccurrencesOfString:keyword withString:replacement];
        }
    }
    //switch to HTML file
    defaultForm = [defaultForm stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
    
    self.selectedCandidate = nil;
    
    NSDictionary* result = nil;
    
    if (subjectString == nil) {
        result = @{@"message" : defaultForm, @"pdfFlag" : pdfFlag, @"subject" : @"No Subject"};
    }
    else
    {
        result = @{@"message" : defaultForm, @"pdfFlag" : pdfFlag, @"subject" : subjectString};
    }
    
    return result;
}

@end
