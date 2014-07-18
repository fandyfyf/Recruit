//
//  YRSchedulingViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/24/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRSchedulingViewController.h"
#import "CandidateEntry.h"
#import "Interviewer.h"
#import "Appointment.h"
#import "YRHostTimeCardViewController.h"

@interface YRSchedulingViewController ()

-(void)cancelDetail;
-(void)saveDetail;
-(void)deleteDetail;
-(void)fetch;
-(BOOL)checkCandidateAvailability:(CandidateEntry*)candidate atTime:(NSString*)time;
-(BOOL)checkInterviewerAvailability:(Interviewer*)interviewer atTime:(NSString*)time;
-(void)addContent:(UIControl*)owner;

@end

@implementation YRSchedulingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //=================set up UI===================//
    UILabel* candidateTitleLabel;
    UILabel* interviewerTitleLabel;
    UILabel* startTimeTitleLabel;
    UILabel* roomNumberTitleLabel;
    UILabel* candidateLabel;

    NSLog(@"view did load");
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 650, self.view.frame.size.width, 325)];
        [[self.view layer] setCornerRadius:10];
        
        candidateTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 20, 200, 30)];
        candidateTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 23];
        
        interviewerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x + 130, 20, 200, 30)];
        interviewerTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 23];
        
        startTimeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 40, 200, 30)];
        startTimeTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 23];
        
        roomNumberTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 120, 200, 30)];
        roomNumberTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 23];
        
        self.startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 70, 100, 30)];
        self.startTimeLabel.font = [UIFont fontWithName:@"Helvetica" size: 23];
        
        self.roomLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 150, 100, 30)];
        self.roomLabel.font = [UIFont fontWithName:@"Helvetica" size: 23];
        
        if (!self.isDataReady) {
            self.candidatesPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(200, 50, self.view.frame.size.width-200, 300)];
        }
        else
        {
            self.candidatesPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(470, 50, self.view.frame.size.width-470, 300)];
            
            candidateLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 80, 200, 30)];
            candidateLabel.font = [UIFont fontWithName:@"Helvetica" size: 23];
        }
        
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.view = [[UIView alloc] initWithFrame:CGRectMake(0, 300, self.view.frame.size.width, 219)];
        [[self.view layer] setCornerRadius:5];
        
        candidateTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 100, 20)];
        candidateTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12];
        
        interviewerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 10, 100, 20)];
        interviewerTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12];
        
        startTimeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 80, 20)];
        startTimeTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12];
        
        roomNumberTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 100, 50, 20)];
        roomNumberTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12];
        
        self.startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 50, 20)];
        self.startTimeLabel.font = [UIFont fontWithName:@"Helvetica" size: 12];
        
        self.roomLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 50, 20)];
        self.roomLabel.font = [UIFont fontWithName:@"Helvetica" size: 12];
        
        if (!self.isDataReady) {
            self.candidatesPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(80, 20, self.view.frame.size.width-80, 150)];
        }
        else
        {
            self.candidatesPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(200, 20, self.view.frame.size.width-200, 150)];
            
            candidateLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 80, 100, 20)];
            candidateLabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
        }

    }
    
    //common set up
    self.view.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    
    [candidateTitleLabel setText:@"Candidates:"];
    candidateTitleLabel.textAlignment = NSTextAlignmentCenter;
    candidateTitleLabel.textColor = [UIColor purpleColor];
    candidateTitleLabel.alpha = 0.9;
    [self.view addSubview:candidateTitleLabel];
    
    [interviewerTitleLabel setText:@"Interviewers:"];
    interviewerTitleLabel.textAlignment = NSTextAlignmentCenter;
    interviewerTitleLabel.textColor = [UIColor purpleColor];
    interviewerTitleLabel.alpha = 0.9;
    [self.view addSubview:interviewerTitleLabel];
    
    [startTimeTitleLabel setText:@"Start Time:"];
    startTimeTitleLabel.textAlignment = NSTextAlignmentLeft;
    startTimeTitleLabel.textColor = [UIColor purpleColor];
    startTimeTitleLabel.alpha = 0.9;
    [self.view addSubview:startTimeTitleLabel];
    
    [roomNumberTitleLabel setText:@"Room:"];
    roomNumberTitleLabel.textAlignment = NSTextAlignmentLeft;
    roomNumberTitleLabel.textColor = [UIColor purpleColor];
    roomNumberTitleLabel.alpha = 0.9;
    [self.view addSubview:roomNumberTitleLabel];
    
    [self.startTimeLabel setText:self.yrTriggeringView.interviewStartTime];
    self.startTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.startTimeLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.startTimeLabel];
    
    [self.roomLabel setText:[NSString stringWithFormat:@"%d",self.yrTriggeringView.roomIndex+1]];
    self.roomLabel.textAlignment = NSTextAlignmentCenter;
    self.roomLabel.textColor = [UIColor blackColor];
    [self.view addSubview:self.roomLabel];
    
    if (self.isDataReady) {
        candidateLabel.textAlignment = NSTextAlignmentCenter;
        candidateLabel.textColor = [UIColor blackColor];
        candidateLabel.text = [self.yrTriggeringView candidateNameLabel].text;
        [self.view addSubview:candidateLabel];
    }
    
    self.candidatesPickerView.delegate = self;
    self.candidatesPickerView.dataSource = self;
    [self.view addSubview:self.candidatesPickerView];
    
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton* deleteButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
        doneButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
        deleteButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
        
        [cancelButton setFrame:CGRectMake(50, 270, 100, 40)];
        [doneButton setFrame:CGRectMake(self.view.frame.size.width-130, 270, 100, 40)];
        [deleteButton setFrame:CGRectMake(self.view.center.x - 50, 270, 100, 40)];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        doneButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        deleteButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        
        [cancelButton setFrame:CGRectMake(20, 180, 60, 30)];
        [doneButton setFrame:CGRectMake(self.view.frame.size.width-80, 180, 60, 30)];
        [deleteButton setFrame:CGRectMake(self.view.center.x-30, 180, 60, 30)];
    }
    [cancelButton setTintColor:[UIColor purpleColor]];
    [cancelButton addTarget:self action:@selector(cancelDetail) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [[cancelButton layer] setCornerRadius:10];
    [[cancelButton layer] setBorderColor:[[UIColor purpleColor] CGColor]];
    [[cancelButton layer] setBorderWidth:1];
    [self.view addSubview:cancelButton];
    
    [doneButton setTintColor:[UIColor purpleColor]];
    [doneButton addTarget:self action:@selector(saveDetail) forControlEvents:UIControlEventTouchUpInside];
    [doneButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [[doneButton layer] setCornerRadius:10];
    [[doneButton layer] setBorderColor:[[UIColor purpleColor] CGColor]];
    [[doneButton layer] setBorderWidth:1];
    
    [self.view addSubview:doneButton];
    
    [deleteButton setTintColor:[UIColor purpleColor]];
    [deleteButton addTarget:self action:@selector(deleteDetail) forControlEvents:UIControlEventTouchUpInside];
    [deleteButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [[deleteButton layer] setCornerRadius:10];
    [[deleteButton layer] setBorderColor:[[UIColor purpleColor] CGColor]];
    [[deleteButton layer] setBorderWidth:1];
    
    [self.view addSubview:deleteButton];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self fetch];
    [self.candidatesPickerView reloadAllComponents];
    //[self.interviewerPickerView reloadAllComponents];
    
    //setting default appearance of picker view
    
    if (!self.isDataReady) {
        if ([self.yrTriggeringView candidateNameLabel].text != nil) {
            if (![[self.yrTriggeringView candidateNameLabel].text isEqualToString:@""]) {
                //setting default at the beginning
                self.selectedCandidate = [self.yrTriggeringView candidateNameLabel].text;
                self.selectedCode = [self.yrTriggeringView codeLabel].text;
                int index = 0;
                for (int i = 0; i<[self.yrdataEntry count];i++) {
                    if ([[NSString stringWithFormat:@"%@ %@",[(CandidateEntry*)[self.yrdataEntry objectAtIndex:i] firstName],[(CandidateEntry*)[self.yrdataEntry objectAtIndex:i] lastName]] isEqualToString:[self.yrTriggeringView candidateNameLabel].text]  ) {
                        index = i;
                    }
                }
                [self.candidatesPickerView selectRow:index+1 inComponent:0 animated:YES];
            }
            else
            {
                [self.candidatesPickerView selectRow:0 inComponent:0 animated:YES];
            }
        }
        else
        {
            [self.candidatesPickerView selectRow:0 inComponent:0 animated:YES];
        }
        
        
        if ([self.yrTriggeringView interviewerNameLabel].text != nil) {
            if (![[self.yrTriggeringView interviewerNameLabel].text isEqualToString:@""]) {
                //setting default at the beginning
                self.selectedInterviewer = [self.yrTriggeringView interviewerNameLabel].text;
                int index = 0;
                for (int i = 0; i<[self.yrinterviewerEntry count];i++) {
                    if ([[[self.yrinterviewerEntry objectAtIndex:i] name] isEqualToString:[self.yrTriggeringView interviewerNameLabel].text]) {
                        index = i;
                    }
                }
                [self.candidatesPickerView selectRow:index+1 inComponent:1 animated:YES];
            }
            else
            {
                [self.candidatesPickerView selectRow:0 inComponent:1 animated:YES];
            }
        }
        else
        {
            [self.candidatesPickerView selectRow:0 inComponent:1 animated:YES];
        }
    }
    else
    {
        self.selectedCandidate = [self.yrTriggeringView candidateNameLabel].text;
        self.selectedCode = [self.yrTriggeringView codeLabel].text;
        if ([self.yrTriggeringView interviewerNameLabel].text != nil) {
            if (![[self.yrTriggeringView interviewerNameLabel].text isEqualToString:@""]) {
                //setting default at the beginning
                self.selectedInterviewer = [self.yrTriggeringView interviewerNameLabel].text;
                int index = 0;
                for (int i = 0; i<[self.yrinterviewerEntry count];i++) {
                    if ([[[self.yrinterviewerEntry objectAtIndex:i] name] isEqualToString:[self.yrTriggeringView interviewerNameLabel].text]) {
                        index = i;
                    }
                }
                [self.candidatesPickerView selectRow:index+1 inComponent:0 animated:YES];
            }
            else
            {
                [self.candidatesPickerView selectRow:0 inComponent:0 animated:YES];
            }
        }
        else
        {
            [self.candidatesPickerView selectRow:0 inComponent:0 animated:YES];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)cancelDetail
{
    [[(YRHostTimeCardViewController*)self.source grayView] removeFromSuperview];
    [self.view removeFromSuperview];
    self.yrTriggeringView.candidateLock = NO;
}

-(void)saveDetail
{
    [self addContent:self.yrTriggeringView];
    [[(YRHostTimeCardViewController*)self.source grayView] removeFromSuperview];
    [self.view removeFromSuperview];
    self.yrTriggeringView.candidateLock = NO;
}

-(void)deleteDetail
{
    self.selectedCode = @"";
    
    [self addContent:self.yrTriggeringView];
    
    [[(YRHostTimeCardViewController*)self.source grayView] removeFromSuperview];
    [self.view removeFromSuperview];
    self.yrTriggeringView.candidateLock = NO;
}

-(void)fetch
{
    [self.yrdataEntry removeAllObjects];
    [self.yrinterviewerEntry removeAllObjects];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
    
    [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES]]];
    
    NSError* error = nil;
    NSMutableArray* mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    [self setYrdataEntry:mutableFetchResults];
    
    fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@",[[NSUserDefaults standardUserDefaults] valueForKey:@"eventCode"]]];
    
    NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    self.yrinterviewerEntry = [FetchResults mutableCopy];
}

-(BOOL)checkCandidateAvailability:(CandidateEntry*)candidate atTime:(NSString*)time
{
    for (Appointment* ap in candidate.appointments) {
        if ([ap.startTime isEqualToString:time]) {
            return NO;
        }
    }
    return YES;
}

-(BOOL)checkInterviewerAvailability:(Interviewer*)interviewer atTime:(NSString*)time
{
    for (Appointment* ap in interviewer.appointments) {
        if ([ap.startTime isEqualToString:time]) {
            return NO;
        }
    }
    return YES;
}

-(void)addContent:(UIControl*)owner
{
    NSString* previousCode = [(YRTimeCardView*)owner codeLabel].text;
    //NSString* previousCandidate = [(YRTimeCardView*)owner candidateNameLabel].text;
    NSString* previousViewer = [(YRTimeCardView*)owner interviewerNameLabel].text;
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"apIndex_x = %d and apIndex_y = %d",[(YRTimeCardView*)owner roomIndex],[(YRTimeCardView*)owner slotIndex]]];
    
    NSError* error = nil;
    NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    if ([FetchResults count] == 0) {
        //the appointment doesn't exist
        if (![self.selectedCode isEqualToString:@""]) {
            //when the candidate is set, save the data
            
            NSFetchRequest *fetchRequestC = [[NSFetchRequest alloc] init];
            [fetchRequestC setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequestC setPredicate:[NSPredicate predicateWithFormat:@"code = %@",self.selectedCode]];
            
            NSArray* candidate = [self.managedObjectContext executeFetchRequest:fetchRequestC error:&error];
            
            NSFetchRequest *fetchRequestI = [[NSFetchRequest alloc] init];
            [fetchRequestI setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequestI setPredicate:[NSPredicate predicateWithFormat:@"name = %@ && code = %@",self.selectedInterviewer,[[NSUserDefaults standardUserDefaults] valueForKey:@"eventCode"]]];
            
            NSArray* interviewer = [self.managedObjectContext executeFetchRequest:fetchRequestI error:&error];
            
            
            if ([candidate count] != 0) {
                //check availability
                if ([self checkCandidateAvailability:(CandidateEntry*)[candidate objectAtIndex:0] atTime:[(YRTimeCardView*)owner interviewStartTime]]) {
                    
                    Appointment* item = (Appointment*)[NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:self.managedObjectContext];
                    item.startTime = [(YRTimeCardView*)owner interviewStartTime];
                    item.apIndex_x = [NSNumber numberWithInt:[(YRTimeCardView*)owner roomIndex]];
                    item.apIndex_y = [NSNumber numberWithInt:[(YRTimeCardView*)owner slotIndex]];
                        
                    item.candidate = (CandidateEntry*)[candidate objectAtIndex:0];
                    
                    [[(YRTimeCardView*)owner codeLabel] setText:self.selectedCode];
                    [[(YRTimeCardView*)owner candidateNameLabel] setText:self.selectedCandidate];
                    
                    if ([interviewer count] != 0)
                    {
                        if ([self checkInterviewerAvailability:(Interviewer*)[interviewer objectAtIndex:0] atTime:[(YRTimeCardView*)owner interviewStartTime]]) {
                            item.interviewers = (Interviewer*)[interviewer objectAtIndex:0];
                            
                            [[(YRTimeCardView*)owner interviewerNameLabel] setText:[NSString stringWithFormat:@"%@",self.selectedInterviewer]];
                        }
                        else
                        {
                            NSLog(@"There is a conflict with interviewer");
                            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:[NSString stringWithFormat:@"Interviewer %@ has a conflict schedule",[(Interviewer*)[interviewer objectAtIndex:0] name]] delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                            [alert show];
                            
                            [[(YRTimeCardView*)owner interviewerNameLabel] setText:@""];
                        }
                    }
                    else
                    {
                        //interviewer is not set
                        [[(YRTimeCardView*)owner interviewerNameLabel] setText:@""];
                    }
                    
                    [item.candidate setStatus:@"scheduled"];
                    
                    if (![[self managedObjectContext] save:&error]) {
                        NSLog(@"ERROR -- saving coredata");
                    }
                }
                else
                {
                    NSLog(@"There is a conflict with candidate");
                    
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:[NSString stringWithFormat:@"Candidate %@ has a conflict schedule",[NSString stringWithFormat:@"%@ %@",[(CandidateEntry*)[candidate objectAtIndex:0] firstName],[(CandidateEntry*)[candidate objectAtIndex:0] lastName]]] delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                    [alert show];
                    
                    [[(YRTimeCardView*)owner codeLabel] setText:@""];
                    
                    [[(YRTimeCardView*)owner candidateNameLabel] setText:@""];
                    
                    [[(YRTimeCardView*)owner interviewerNameLabel] setText:@""];
                }
            }
            else
            {
                NSLog(@"The candidate doesn't exist 2");
            }
        }
        else
        {
            //when candidate is not set, don't save the data
        }
    }
    else
    {
        //appointment need to be modifyed
        Appointment* selectedAppointment = [FetchResults objectAtIndex:0];
        if ([self.selectedCode isEqualToString:@""]) {
            //candidate is not set, remove the data from previous Candidate
            NSFetchRequest *fetchRequestC = [[NSFetchRequest alloc] init];
            [fetchRequestC setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequestC setPredicate:[NSPredicate predicateWithFormat:@"code = %@",previousCode]];
            
            NSArray* candidate = [self.managedObjectContext executeFetchRequest:fetchRequestC error:&error];
            
            if ([candidate count] != 0) {
                CandidateEntry* previousCandidate = (CandidateEntry*)[candidate objectAtIndex:0];
                [previousCandidate removeAppointmentsObject:selectedAppointment];
                if ([[previousCandidate appointments] count] == 0) {
                    [previousCandidate setStatus:@"pending"];
                }
            }
            else
            {
                NSLog(@"The candidate doesn't exist 1");
            }
            
            NSFetchRequest *fetchRequestI = [[NSFetchRequest alloc] init];
            [fetchRequestI setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequestI setPredicate:[NSPredicate predicateWithFormat:@"name = %@ && code = %@",previousViewer,[[NSUserDefaults standardUserDefaults] valueForKey:@"eventCode"]]];
            
            NSArray* interviewer = [self.managedObjectContext executeFetchRequest:fetchRequestI error:&error];
            
            if ([interviewer count] != 0) {
                Interviewer* previousInterviewer = (Interviewer*)[interviewer objectAtIndex:0];
                [previousInterviewer removeAppointmentsObject:selectedAppointment];
            }
            
            //delete the appointment
            [self.managedObjectContext deleteObject:selectedAppointment];

            //save changes
            if (![[self managedObjectContext] save:&error]) {
                NSLog(@"ERROR -- saving coredata");
            }
            
            [[(YRTimeCardView*)owner codeLabel] setText:@""];
            
            [[(YRTimeCardView*)owner candidateNameLabel] setText:@""];
            
            [[(YRTimeCardView*)owner interviewerNameLabel] setText:@""];
        }
        else
        {
            if (![self.selectedCode isEqualToString:previousCode]) {
                //remove from previous Candidate
                NSFetchRequest *fetchRequestCP = [[NSFetchRequest alloc] init];
                [fetchRequestCP setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
                [fetchRequestCP setPredicate:[NSPredicate predicateWithFormat:@"code = %@",previousCode]];
                
                NSArray* candidateP = [self.managedObjectContext executeFetchRequest:fetchRequestCP error:&error];
                
                if ([candidateP count] != 0) {
                    CandidateEntry* previousCandidate = (CandidateEntry*)[candidateP objectAtIndex:0];
                    [previousCandidate removeAppointmentsObject:selectedAppointment];
                    if ([[previousCandidate appointments] count] == 0) {
                        [previousCandidate setStatus:@"pending"];
                    }
                }
                
                //add to selected Candidate
                NSFetchRequest *fetchRequestCC = [[NSFetchRequest alloc] init];
                [fetchRequestCC setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
                [fetchRequestCC setPredicate:[NSPredicate predicateWithFormat:@"code = %@",self.selectedCode]];
                
                NSArray* candidateC = [self.managedObjectContext executeFetchRequest:fetchRequestCC error:&error];
                
                if ([candidateC count] != 0) {
                    if ([self checkCandidateAvailability:(CandidateEntry*)[candidateC objectAtIndex:0] atTime:[(YRTimeCardView*)owner interviewStartTime]]) {
                        CandidateEntry* currentCandidate = (CandidateEntry*)[candidateC objectAtIndex:0];
                        [currentCandidate addAppointmentsObject:selectedAppointment];
                        [currentCandidate setStatus:@"scheduled"];
                        
                        [[(YRTimeCardView*)owner codeLabel] setText:self.selectedCode];
                        [[(YRTimeCardView*)owner candidateNameLabel] setText:self.selectedCandidate];
                    }
                    else
                    {
                        NSLog(@"There is a conflict with candidate");
                        
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:[NSString stringWithFormat:@"Candidate %@ has a conflict schedule",[NSString stringWithFormat:@"%@ %@",[(CandidateEntry*)[candidateC objectAtIndex:0] firstName],[(CandidateEntry*)[candidateC objectAtIndex:0] lastName]]] delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                        [alert show];
                        
                        [[(YRTimeCardView*)owner codeLabel] setText:@""];
                        
                        [[(YRTimeCardView*)owner candidateNameLabel] setText:@""];
                        
                        [[(YRTimeCardView*)owner interviewerNameLabel] setText:@""];
                    }
                }
                else
                {
                    NSLog(@"The candidate doesn't exist 3");
                }
                
                if (![[self managedObjectContext] save:&error]) {
                    NSLog(@"ERROR -- saving coredata");
                }
            }
                
            if (![self.selectedInterviewer isEqualToString:previousViewer]) {
                //update interviewer
                
                NSFetchRequest *fetchRequestIP = [[NSFetchRequest alloc] init];
                [fetchRequestIP setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
                [fetchRequestIP setPredicate:[NSPredicate predicateWithFormat:@"name = %@ && code = %@",previousViewer,[[NSUserDefaults standardUserDefaults] valueForKey:@"eventCode"]]];
                
                NSArray* interviewerP = [self.managedObjectContext executeFetchRequest:fetchRequestIP error:&error];
                
                if ([interviewerP count] != 0) {
                    Interviewer* previousInterviewer = (Interviewer*)[interviewerP objectAtIndex:0];
                    [previousInterviewer removeAppointmentsObject:selectedAppointment];
                }
                
                NSFetchRequest *fetchRequestIC = [[NSFetchRequest alloc] init];
                [fetchRequestIC setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
                [fetchRequestIC setPredicate:[NSPredicate predicateWithFormat:@"name = %@ && code = %@",self.selectedInterviewer,[[NSUserDefaults standardUserDefaults] valueForKey:@"eventCode"]]];
                
                NSArray* interviewerC = [self.managedObjectContext executeFetchRequest:fetchRequestIC error:&error];
                
                if ([interviewerC count] != 0) {
                    if ([self checkInterviewerAvailability:(Interviewer*)[interviewerC objectAtIndex:0] atTime:[(YRTimeCardView*)owner interviewStartTime]]) {
                        Interviewer* currentInterviewer = (Interviewer*)[interviewerC objectAtIndex:0];
                        [currentInterviewer addAppointmentsObject:selectedAppointment];
                        
                        [[(YRTimeCardView*)owner interviewerNameLabel] setText:[NSString stringWithFormat:@"%@",self.selectedInterviewer]];
                    }
                    else
                    {
                        NSLog(@"There is a conflict with interviewer");
                        [[(YRTimeCardView*)owner interviewerNameLabel] setText:@""];
                        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:[NSString stringWithFormat:@"Interviewer %@ has a conflict schedule",[(Interviewer*)[interviewerC objectAtIndex:0] name]] delegate:Nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }
                else
                {
                    [[(YRTimeCardView*)owner interviewerNameLabel] setText:@""];
                }
                
                if (![[self managedObjectContext] save:&error]) {
                    NSLog(@"ERROR -- saving coredata");
                }
            }
            else
            {
                //nothing need to be changed
            }
        }
    }
}

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    if (!self.isDataReady) {
        return 2;
    }
    else
    {
        return 1;
    }
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (!self.isDataReady) {
        if (component == 0) {
            return [self.yrdataEntry count] + 1;
        }
        else if (component == 1)
        {
            return [self.yrinterviewerEntry count] + 1;
        }
        else
        {
            return 0;
        }
    }
    else
    {
        return [self.yrinterviewerEntry count] + 1;
    }
}


#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (row == 0) {
        return @"None";
    }
    else
    {
        if (!self.isDataReady) {
            if (component == 0) {
                return [NSString stringWithFormat:@"%@ %@",[(CandidateEntry*)[self.yrdataEntry objectAtIndex:row-1] firstName],[(CandidateEntry*)[self.yrdataEntry objectAtIndex:row-1] lastName]];
            }
            else if (component == 1)
            {
                return [NSString stringWithFormat:@"%@",[(Interviewer*)[self.yrinterviewerEntry objectAtIndex:row-1] name]];
            }
            else
            {
                return @"?";
            }
        }
        else
        {
            return [NSString stringWithFormat:@"%@",[(Interviewer*)[self.yrinterviewerEntry objectAtIndex:row-1] name]];
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (!self.isDataReady) {
        if (component == 0) {
            if (row == 0) {
                self.selectedCandidate = @"";
                self.selectedCode = @"";
            }
            else
            {
                self.selectedCandidate = [NSString stringWithFormat:@"%@ %@",[(CandidateEntry*)[self.yrdataEntry objectAtIndex:row-1] firstName],[(CandidateEntry*)[self.yrdataEntry objectAtIndex:row-1] lastName]];
                self.selectedCode = [(CandidateEntry*)[self.yrdataEntry objectAtIndex:row-1] code];
            }
        }
        else if (component == 1)
        {
            if (row == 0) {
                self.selectedInterviewer = @"";
            }
            else
            {
                self.selectedInterviewer = [NSString stringWithFormat:@"%@",[(Interviewer*)[self.yrinterviewerEntry objectAtIndex:row-1] name]];
            }
        }
    }
    else
    {
        if (row == 0) {
            self.selectedInterviewer = @"";
        }
        else
        {
            self.selectedInterviewer = [NSString stringWithFormat:@"%@",[(Interviewer*)[self.yrinterviewerEntry objectAtIndex:row-1] name]];
        }
    }
}

-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* label = (UILabel*)view;
    if (!label) {
        label = [[UILabel alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            label.font = [UIFont fontWithName:@"Helvetica" size: 15];
        }
        else{
            label.font = [UIFont fontWithName:@"Helvetica" size: 25];
        }
        
        if (row == 0) {
            label.text = @"None";
        }
        else
        {
            if (!self.isDataReady) {
                if (component == 0) {
                    label.text = [NSString stringWithFormat:@"%@ %@",[(CandidateEntry*)[self.yrdataEntry objectAtIndex:row-1] firstName],[(CandidateEntry*)[self.yrdataEntry objectAtIndex:row-1] lastName]];
                }
                else if (component == 1)
                {
                    label.text = [NSString stringWithFormat:@"%@",[(Interviewer*)[self.yrinterviewerEntry objectAtIndex:row-1] name]];
                }
            }
            else
            {
                label.text = [NSString stringWithFormat:@"%@",[(Interviewer*)[self.yrinterviewerEntry objectAtIndex:row-1] name]];
            }
        }
    }
    return label;
}


@end
