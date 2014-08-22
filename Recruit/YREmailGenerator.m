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
            
            if (self.selectedCandidate != nil) {
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

        if (self.selectedCandidate != nil) {
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
        }
        
        if (self.selectedInterviewer != nil) {
            if ([keyword isEqualToString:@"{engineerName}"]) {
                replacement = self.selectedInterviewer.name;
            }
            else if ([keyword isEqualToString:@"{ScheduleGrid}"])
            {
                replacement = @"Here is a table!!!";
                //get room configuration
                
                replacement = @"";
                
                NSNumber *yrRowNumber = [NSNumber numberWithInt:15];
                NSNumber *yrColumNumber = [[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleColumsKey];
                NSDate *startDate = (NSDate*)[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleStartDateKey];
                NSNumber *numberOfDay = (NSNumber*)[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleNumberOfDayKey];
                
                //fetch all schedule information
                
                NSFetchRequest * request = [[NSFetchRequest alloc] init];
                
                [request setEntity:[NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext]]];
                
                NSError* error = nil;
                NSArray* appointments = [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext] executeFetchRequest:request error:&error];
                
                NSDateFormatter* format = [[NSDateFormatter alloc] init];
                [format setDateFormat:@"MM/dd/yyy"];
                
                for (int i = 0; i < [numberOfDay intValue]; i++) {
                    NSDate* date = [NSDate dateWithTimeInterval:24*60*60*i sinceDate:startDate];
                
                    replacement = [replacement stringByAppendingString:@"<table border='1' style='width:300px'>"];
                    
                    replacement = [replacement stringByAppendingString:[NSString stringWithFormat:@"<tr><td>  %@  </td>",[format stringFromDate:date]]];
                    for (int k = 0; k < [yrColumNumber intValue]; k++  ) {
                        replacement = [replacement stringByAppendingString:[NSString stringWithFormat:@"<td>Room %d</td>",k+1]];
                    }
                    replacement = [replacement stringByAppendingString:@"</tr>"];
                    
                    int hour = [[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleStartTimeKey] intValue];
                    int min = 0;
                    int period = [[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleDurationKey] intValue];
                    
                    NSString* AMPM = @"AM";
                    
                    for (int j = 0; j < [yrRowNumber intValue]; j++) {
                        
                        //each row
                        NSString *timeLabel;
                        
                        if (min < 10) {
                            timeLabel = [NSString stringWithFormat:@"%d : 0%d %@",hour,min,AMPM];
                        }
                        else
                        {
                            timeLabel = [NSString stringWithFormat:@"%d : %d %@",hour,min,AMPM];
                        }
                        min = min + period;
                        if (min >= 60) {
                            hour ++;
                            min = min%60;
                        }
                        //change hour standard to 12-hour-standard
                        
                        if (hour > 12) {
                            hour = hour%12;
                        }
                        
                        if (hour >= 12) {
                            AMPM = @"PM";
                        }

                        replacement = [replacement stringByAppendingString:[NSString stringWithFormat:@"<tr><td> %@ </td>",timeLabel]];
                        
                        for (int m = 0; m < [yrColumNumber intValue]; m++) {
                            BOOL exist = NO;
                            for (Appointment* app in appointments) {
                                NSLog(@"%@",app);
                                if ([[format stringFromDate:app.date] isEqualToString:[format stringFromDate:date]] && [app.startTime isEqualToString:timeLabel] && [app.apIndex_x intValue] == m) {
                                    //put details in
                                    replacement = [replacement stringByAppendingString:[NSString stringWithFormat:@"<td>%@<br /><br />%@</td>",[NSString stringWithFormat:@"%@ %@",app.candidate.firstName,app.candidate.lastName],app.interviewers.name]];
                                    exist = YES;
                                    break;
                                }
                            }
                            if (!exist) {
                                replacement = [replacement stringByAppendingString:@"<td>              </td>"];
                            }
                        }
                        replacement = [replacement stringByAppendingString:@"</tr>"];
                    }
                    replacement = [replacement stringByAppendingString:@"</table><br /><br />"];
                }
            }
        }
        
        if (replacement != nil) {

            defaultForm = [defaultForm stringByReplacingOccurrencesOfString:keyword withString:replacement];
        }
    }
    //switch to HTML file
    defaultForm = [defaultForm stringByReplacingOccurrencesOfString:@"\n" withString:@"<br />"];
    
    self.selectedCandidate = nil;
    self.selectedInterviewer = nil;
    
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
