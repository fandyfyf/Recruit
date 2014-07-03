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

@interface YRSchedulingViewController ()

-(void)cancelDetail;
-(void)saveDetail;
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
    self.view = [[UIView alloc] initWithFrame:self.view.frame];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel* candidateTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 40, 150, 20)];
    [candidateTitleLabel setText:@"Candidates: "];
    candidateTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.view addSubview:candidateTitleLabel];
    
    UILabel* interviewerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 250, 150, 20)];
    [interviewerTitleLabel setText:@"Interviewers: "];
    interviewerTitleLabel.font = [UIFont boldSystemFontOfSize:15];
    [self.view addSubview:interviewerTitleLabel];
    
    self.candidatesPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 300)];
    self.interviewerPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 250, self.view.frame.size.width, 300)];
    self.candidatesPickerView.delegate = self;
    self.candidatesPickerView.dataSource = self;
    self.interviewerPickerView.delegate = self;
    self.interviewerPickerView.dataSource = self;
    
    //diable user interaction on picker view doesn't work
    if (self.yrTriggeringView.candidateLock) {
        [self.candidatesPickerView setUserInteractionEnabled:NO];
    }
    
    [self.view addSubview:self.candidatesPickerView];
    [self.view addSubview:self.interviewerPickerView];
    
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [cancelButton setFrame:CGRectMake(50, 480, 150, 50)];
        cancelButton.titleLabel.font = [UIFont systemFontOfSize:35];
        doneButton.titleLabel.font = [UIFont systemFontOfSize:35];
        [doneButton setFrame:CGRectMake(self.view.frame.size.width-200, 480, 150, 50)];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [cancelButton setFrame:CGRectMake(20, 480, 50, 30)];
        [doneButton setFrame:CGRectMake(self.view.frame.size.width-70, 480, 50, 30)];
    }
    [cancelButton setTintColor:[UIColor purpleColor]];
    [cancelButton addTarget:self action:@selector(cancelDetail) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.view addSubview:cancelButton];
    
    [doneButton setTintColor:[UIColor purpleColor]];
    [doneButton addTarget:self action:@selector(saveDetail) forControlEvents:UIControlEventTouchUpInside];
    [doneButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    
    [self.view addSubview:doneButton];
    
    [UIView beginAnimations:@"pop" context:Nil];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:NO];
    [UIView setAnimationDuration:0.5];

    
    [UIView commitAnimations];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self fetch];
    [self.candidatesPickerView reloadAllComponents];
    [self.interviewerPickerView reloadAllComponents];
    
    //setting default appearance of picker view
    
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
            [self.interviewerPickerView selectRow:index+1 inComponent:0 animated:YES];
        }
        else
        {
            [self.interviewerPickerView selectRow:0 inComponent:0 animated:YES];
        }
    }
    else
    {
        [self.interviewerPickerView selectRow:0 inComponent:0 animated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)cancelDetail
{
    [UIView beginAnimations:@"disappear" context:Nil];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view.superview cache:NO];
    [UIView setAnimationDuration:0.5];
    
    [self.view removeFromSuperview];
    
    [UIView commitAnimations];
}

-(void)saveDetail
{
    [self addContent:self.yrTriggeringView];
    [UIView beginAnimations:@"disappear" context:Nil];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view.superview cache:NO];
    [UIView setAnimationDuration:0.5];
    
    [self.view removeFromSuperview];
    
    [UIView commitAnimations];
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
            [fetchRequestI setPredicate:[NSPredicate predicateWithFormat:@"name = %@",self.selectedInterviewer]];
            
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
                NSLog(@"The candidate doesn't exist");
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
                NSLog(@"The candidate doesn't exist");
            }
            
            NSFetchRequest *fetchRequestI = [[NSFetchRequest alloc] init];
            [fetchRequestI setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequestI setPredicate:[NSPredicate predicateWithFormat:@"name = %@",previousViewer]];
            
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
                    NSLog(@"The candidate doesn't exist");
                }
                
                if (![[self managedObjectContext] save:&error]) {
                    NSLog(@"ERROR -- saving coredata");
                }
            }
                
            if (![self.selectedInterviewer isEqualToString:previousViewer]) {
                //update interviewer
                
                NSFetchRequest *fetchRequestIP = [[NSFetchRequest alloc] init];
                [fetchRequestIP setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
                [fetchRequestIP setPredicate:[NSPredicate predicateWithFormat:@"name = %@",previousViewer]];
                
                NSArray* interviewerP = [self.managedObjectContext executeFetchRequest:fetchRequestIP error:&error];
                
                if ([interviewerP count] != 0) {
                    Interviewer* previousInterviewer = (Interviewer*)[interviewerP objectAtIndex:0];
                    [previousInterviewer removeAppointmentsObject:selectedAppointment];
                }
                
                NSFetchRequest *fetchRequestIC = [[NSFetchRequest alloc] init];
                [fetchRequestIC setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
                [fetchRequestIC setPredicate:[NSPredicate predicateWithFormat:@"name = %@",self.selectedInterviewer]];
                
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
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    //NSLog(@"%u",[self.yrdataEntry count]);
    if (pickerView == self.candidatesPickerView) {
        return [self.yrdataEntry count] + 1;
    }
    else if(pickerView == self.interviewerPickerView)
    {
        return [self.yrinterviewerEntry count] + 1;
    }
    else
    {
        return 0;
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
        if (pickerView == self.candidatesPickerView) {
            return [NSString stringWithFormat:@"%@ %@",[(CandidateEntry*)[self.yrdataEntry objectAtIndex:row-1] firstName],[(CandidateEntry*)[self.yrdataEntry objectAtIndex:row-1] lastName]];
        }
        else if (pickerView == self.interviewerPickerView)
        {
            return [NSString stringWithFormat:@"%@",[(Interviewer*)[self.yrinterviewerEntry objectAtIndex:row-1] name]];
        }
        else
        {
            return @"?";
        }
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (pickerView == self.candidatesPickerView) {
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
    else if (pickerView == self.interviewerPickerView)
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


@end
