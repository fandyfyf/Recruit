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
#import "YRTimeCardView.h"
#import "YRInterviewAppointmentInfo.h"

@interface YRSchedulingViewController ()

-(void)cancelDetail;
-(void)saveDetail;
-(void)fetch;
-(void)addContent:(UIControl*)owner;

@end

NSString* const kYRAppointmentInfoKey = @"appointmentInfo";

@implementation YRSchedulingViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
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
    
    if ([(YRTimeCardView*)self.yrTriggeringView candidateNameLabel].text != nil) {
        if (![[(YRTimeCardView*)self.yrTriggeringView candidateNameLabel].text isEqualToString:@""]) {
            //setting default at the beginning
            self.selectedCandidate = [(YRTimeCardView*)self.yrTriggeringView candidateNameLabel].text;
            self.selectedCode = [(YRTimeCardView*)self.yrTriggeringView codeLabel].text;
            int index = 0;
            for (int i = 0; i<[self.yrdataEntry count];i++) {
                if ([[NSString stringWithFormat:@"%@ %@",[(CandidateEntry*)[self.yrdataEntry objectAtIndex:i] firstName],[(CandidateEntry*)[self.yrdataEntry objectAtIndex:i] lastName]] isEqualToString:[(YRTimeCardView*)self.yrTriggeringView candidateNameLabel].text]  ) {
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
    
    
    if ([(YRTimeCardView*)self.yrTriggeringView interviewerNameLabel].text != nil) {
        if (![[(YRTimeCardView*)self.yrTriggeringView interviewerNameLabel].text isEqualToString:@""]) {
            //setting default at the beginning
            self.selectedInterviewer = [(YRTimeCardView*)self.yrTriggeringView interviewerNameLabel].text;
            int index = 0;
            for (int i = 0; i<[self.yrinterviewerEntry count];i++) {
                if ([[(Interviewer*)[self.yrinterviewerEntry objectAtIndex:i] name] isEqualToString:[(YRTimeCardView*)self.yrTriggeringView interviewerNameLabel].text]) {
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

-(void)addContent:(UIControl*)owner
{
    NSString* previous = [(YRTimeCardView*)owner codeLabel].text;
    
    NSMutableArray* infoArray = [[[NSUserDefaults standardUserDefaults] objectForKey:kYRAppointmentInfoKey] mutableCopy];
    YRInterviewAppointmentInfo* selected = [NSKeyedUnarchiver unarchiveObjectWithData:[infoArray objectAtIndex:[(YRTimeCardView*)owner index]]];
    
    if ([self.selectedCode isEqualToString:@""]) {
        [selected setTaken:NO];
        [selected setCandidateRid:[@"" mutableCopy]];
        [selected setCandidateName:[@"" mutableCopy]];
        [selected setInterviewerName:[@"" mutableCopy]];
    }
    else
    {
        [selected setTaken:YES];
        [selected setCandidateRid:[self.selectedCode mutableCopy]];
        [selected setCandidateName:[self.selectedCandidate mutableCopy]];
        [selected setInterviewerName:[self.selectedInterviewer mutableCopy]];
    }
    
    [infoArray setObject:[NSKeyedArchiver archivedDataWithRootObject:selected] atIndexedSubscript:[(YRTimeCardView*)owner index]];
    
    [[NSUserDefaults standardUserDefaults] setObject:infoArray forKey:kYRAppointmentInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    

    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
    
    if ([self.selectedCode isEqualToString:@""]) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = '%@'",previous]]];
    }
    else
    {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = '%@'",self.selectedCode]]];
    }
    
    NSError* error = nil;
    NSMutableArray* mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if ([mutableFetchResults count] != 0) {
        
        NSMutableArray* interviews = [(CandidateEntry*)[mutableFetchResults objectAtIndex:0] interviews];
        
        if (![self.selectedCode isEqualToString:@""]) {
            
            //same code, remove duplicate first
            if ([self.selectedCode isEqualToString:[(YRTimeCardView*)owner codeLabel].text]) {
                int index = -1;
                for (int i=0;i<[interviews count];i++)
                {
                    NSDictionary* dic = [interviews objectAtIndex:i];
                    if ([dic isEqualToDictionary:@{@"time" : [(YRTimeCardView*)owner interviewStartTime], @"interviewer" : [(YRTimeCardView*)owner interviewerNameLabel].text}]) {
                        index = i;
                    }
                }
                //renew the entry
                [interviews setObject:@{@"time" : [(YRTimeCardView*)owner interviewStartTime], @"interviewer" : self.selectedInterviewer} atIndexedSubscript:index];
            }
            else
            {
                //add new entry to new guy
                [interviews addObject:@{@"time" : [(YRTimeCardView*)owner interviewStartTime], @"interviewer" : self.selectedInterviewer}];
                
                //delete old entry from previous guy
            }
            
            [(CandidateEntry*)[mutableFetchResults objectAtIndex:0] setStatus:@"scheduled"];
        }
        else
        {
            int index = -1;
            for (int i=0;i<[interviews count];i++)
            {
                NSDictionary* dic = [interviews objectAtIndex:i];
                if ([dic isEqualToDictionary:@{@"time" : [(YRTimeCardView*)owner interviewStartTime], @"interviewer" : [(YRTimeCardView*)owner interviewerNameLabel].text}]) {
                    index = i;
                }
            }
            if (index >=0) {
                [interviews removeObjectAtIndex:index];
            }
            if ([interviews count] == 0) {
                [(CandidateEntry*)[mutableFetchResults objectAtIndex:0] setStatus:@"pending"];
            }
        }

    }
    if (![[self managedObjectContext] save:&error]) {
        NSLog(@"ERROR -- saving coredata");
    }
    
    if (![self.selectedCode isEqualToString:@""]) {
        if (![self.selectedCode isEqualToString:[(YRTimeCardView*)owner codeLabel].text]) {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = '%@'",previous]]];
            NSError* error = nil;
            NSMutableArray* mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
            if ([mutableFetchResults count] != 0) {
                NSMutableArray* interviews = [(CandidateEntry*)[mutableFetchResults objectAtIndex:0] interviews];
                
                int index = -1;
                for (int i=0;i<[interviews count];i++)
                {
                    NSDictionary* dic = [interviews objectAtIndex:i];
                    if ([dic isEqualToDictionary:@{@"time" : [(YRTimeCardView*)owner interviewStartTime], @"interviewer" : [(YRTimeCardView*)owner interviewerNameLabel].text}]) {
                        index = i;
                    }
                }
                if (index >=0) {
                    [interviews removeObjectAtIndex:index];
                }
                if ([interviews count] == 0) {
                    [(CandidateEntry*)[mutableFetchResults objectAtIndex:0] setStatus:@"pending"];
                }
            }
            if (![[self managedObjectContext] save:&error]) {
                NSLog(@"ERROR -- saving coredata");
            }
        }
    }
    
    [[(YRTimeCardView*)owner codeLabel] setText:self.selectedCode];
    
    [[(YRTimeCardView*)owner candidateNameLabel] setText:self.selectedCandidate];
    
    if ([self.selectedInterviewer isEqualToString:@""]) {
        [[(YRTimeCardView*)owner interviewerNameLabel] setText:@""];
    }
    else
    {
        [[(YRTimeCardView*)owner interviewerNameLabel] setText:[NSString stringWithFormat:@"%@",self.selectedInterviewer]];
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
