//
//  YRHostMainViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRHostMainViewController.h"
#import "CandidateEntry.h"
#import "YRMCManager.h"
#import "YRDataManager.h"
#import "Event.h"

@interface YRHostMainViewController ()

-(void)debuggerFunction;
-(void)updateConnectionListNotification:(NSNotification *)notification;
-(void)willEnterBackgroundNotification:(NSNotification *)notification;
-(void)doneWithPad;
-(void)showEventCode;

@end

@implementation YRHostMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //============verified notification============//
    //update connection list
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateConnectionListNotification:) name:kYRMCManagerNeedUpdateConnectionListNotification object:nil];
    
    
    
    //enter background
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    //=================================

    
    //initialization
    self.yrPrefix = [[NSString alloc] init];
    
    //property set up
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    NSLog(@"Hello: %@ as a Host",self.appDelegate.mcManager.userName);
    
    [self debuggerFunction];
    [self.yrnameLabel setText:self.appDelegate.mcManager.userName];
    
    //initial setup for Host Manager
    [[self.appDelegate mcManager] setupSessionManagerForHost:YES];
    
    [self.yrtableView setDelegate:self];
    [self.yrtableView setDataSource:self];
    [self.yrPrefixTextField setDelegate:self];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[self.yrSignOutButton layer] setCornerRadius:35];
        [[self.yrSignOutButton layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [[self.yrSignOutButton layer] setBorderWidth:2];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [[self.yrSignOutButton layer] setCornerRadius:30];
        [[self.yrSignOutButton layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [[self.yrSignOutButton layer] setBorderWidth:2];
    }
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    
    doneToolbar.items = [NSArray arrayWithObjects:
                         //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithPad)],nil];
    self.yrPrefixTextField.inputAccessoryView = doneToolbar;
    
    //tap gesture recognizer
    UITapGestureRecognizer* gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEventCode)];
    gestureRecognizer.delegate = self;
    [self.yrPrefixTextField addGestureRecognizer:gestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signOut:(id)sender {
    NSLog(@"sign out");
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Sign Out?" message:@"Signing out will affect connected interviewers!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (IBAction)backgroundTapped:(id)sender {
    [self.yrPrefixTextField resignFirstResponder];
    self.yrPrefix = self.yrPrefixTextField.text;
}

- (IBAction)onOffSwitch:(id)sender {
    [self.yrPrefixTextField resignFirstResponder];
    
    if (![self.yrPrefixTextField.text isEqualToString:@""]) {
        self.yrPrefix = self.yrPrefixTextField.text;
        
        
        if (self.yrOnOffControl.selectedSegmentIndex == 1) {
            NSLog(@"On");
            if (self.yrPrefixTextField.isEnabled) {
                [self.yrPrefixTextField setEnabled:NO];
            }
            //renew the dataManager
            self.appDelegate.dataManager = nil;
            [self.appDelegate setDataManager:[[YRDataManager alloc] initWithPrefix:self.yrPrefix]];
            [[self.appDelegate dataManager] startListeningForData];
            [[self.appDelegate dataManager] setHost:YES];
            
            //init active session && set up advertiser and advertise
            [[self.appDelegate mcManager] advertiseSelf:YES];
            self.appDelegate.mcManager.advertising = YES;
        }
        else
        {
            NSLog(@"Off");
            if (!self.yrPrefixTextField.isEnabled) {
                [self.yrPrefixTextField setEnabled:YES];
            }
            
            //clean the data manager
            if (self.appDelegate.dataManager != nil) {
                [self.appDelegate.dataManager stopListeningForData];
                [self.appDelegate setDataManager:nil];
            }
            
            for (NSDictionary *peerSession in [self.appDelegate mcManager].activeSessions) {
                [[peerSession valueForKey:@"session"] disconnect];
            }
            [[self.appDelegate mcManager].activeSessions removeAllObjects];
            
            [[self.appDelegate mcManager] advertiseSelf:NO];
            self.appDelegate.mcManager.advertising = NO;
            
            [self.appDelegate.mcManager.connectedDevices removeAllObjects];
            
            [self.yrtableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }
    }
    else
    {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Event code is empty" message:@"Please select an event code from the pull down menu. Or go to setting page to add new event" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
        //reset the control
        [self.yrOnOffControl setSelectedSegmentIndex:0];
    }
}

-(void)debuggerFunction
{
    if ([self.appDelegate.mcManager.userName isEqualToString:@"kirito"]) {
        CandidateEntry* item = (CandidateEntry*)[NSEntityDescription insertNewObjectForEntityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext];
        [item setFirstName:@"Tom"];
        [item setLastName:@"Cruise"];
        [item setEmailAddress:@"tom@gmail.com"];
        [item setInterviewer:@"edgeOfTomorrow"];
        [item setCode:@"Test-1"];
        
        [item setStatus:@"pending"];
        [item setPdf:[NSNumber numberWithBool:NO]];
        [item setPosition:@"Intern"];
        [item setPreference:@"Actor"];
        [item setDate:[NSDate date]];
        [item setNotes:@"Note"];
        [item setRank:[NSNumber numberWithFloat:3.5]];
        [item setGpa:[NSNumber numberWithFloat:3.5]];
        [item setFileNames:[NSArray new]];
        [item setTagList:[NSArray new]];
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"ERROR -- saving coredata");
        }
    }
}

-(void)updateConnectionListNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.yrtableView reloadData];
    });
    //[self.yrtableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)willEnterBackgroundNotification:(NSNotification *)notification
{
    [self.appDelegate.mcManager.connectedDevices removeAllObjects];
    [self.yrtableView reloadData];
    NSLog(@"Host entered background");
}

-(void)doneWithPad
{
    [self.yrPrefixTextField resignFirstResponder];
    self.yrPrefix = self.yrPrefixTextField.text;
}

-(NSArray*)fetchEventList
{
    NSFetchRequest* request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext]];
    
    NSError* error = nil;
    NSArray* fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
    return fetchResults;
}

-(void)showEventCode
{
    self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
    self.grayView.backgroundColor = [UIColor blackColor];
    self.grayView.alpha = 0.0;

    [self.grayView addTarget:self action:@selector(dismissEventList) forControlEvents:UIControlEventTouchUpInside];
    
    self.eventArray = [self fetchEventList];
    
    if (self.eventArray == nil || [self.eventArray count] == 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"No Existing Event" message:@"Please go to setting to create a new event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alertView show];
    }
    else
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.eventList = [[UITableView alloc] initWithFrame:CGRectMake(30, 134, 165, 20+44*[self.eventArray count]) style:UITableViewStylePlain];
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            self.eventList = [[UITableView alloc] initWithFrame:CGRectMake(20, 84, 165, 20+44*[self.eventArray count]) style:UITableViewStylePlain];
        }
        self.eventList.alpha = 0.0;
        
        [self.eventList setDelegate:self];
        [self.eventList setDataSource:self];
        
        [[self.eventList layer] setCornerRadius:10];
        [[self.eventList layer] setBorderColor:[[UIColor blackColor] CGColor]];
        [[self.eventList layer] setBorderWidth:0.5];
        
        [self.view addSubview:self.grayView];
        [UIView animateWithDuration:0.3 animations:^{
            self.grayView.alpha = 0.4;
            self.eventList.alpha = 1.0;
        }];
        
        [self.view addSubview:self.eventList];
    }
}

-(void)dismissEventList
{
    [UIView animateWithDuration:0.3 animations:^{
        self.grayView.alpha = 0.0;
        self.eventList.alpha = 0.0;
    } completion:^(BOOL finish){
        [self.grayView removeFromSuperview];
        [self.eventList removeFromSuperview];
        self.grayView = nil;
        self.eventList = nil;
    }];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.yrtableView) {
        return @"Connected Peers";
    }
    else if (tableView == self.eventList)
    {
        return @"Event Codes";
    }
    else
    {
        return @"???";
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView == self.yrtableView) {
        return [self.appDelegate.mcManager.connectedDevices count];
    }
    else if (tableView == self.eventList)
    {
        return [self.eventArray count];
    }
    else
    {
        return 0;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    if (tableView == self.yrtableView) {
        cell.textLabel.text = [self.appDelegate.mcManager.connectedDevices objectAtIndex:indexPath.row][@"confirmedName"];
    }
    else if (tableView == self.eventList)
    {
        cell.textLabel.text = [(Event*)[self.eventArray objectAtIndex:indexPath.row] eventCode];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView == self.yrtableView) {
        return 60.0;
    }
    else if (tableView == self.eventList)
    {
        return 44.0;
    }
    else
    {
        return 0;
    }
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.eventList) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if ([[(Event*)[self.eventArray objectAtIndex:indexPath.row] eventInterviewerCount] intValue] == 0) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Selected Event has no Interviewer" message:@"Please go to setting page to add interviewers to the current event" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
        else
        {
            self.yrPrefix = [(Event*)[self.eventArray objectAtIndex:indexPath.row] eventCode];
        
            self.yrPrefixTextField.text = self.yrPrefix;
            
            
            //set the event code in the user default
            
            [[NSUserDefaults standardUserDefaults] setValue:self.yrPrefix forKey:@"eventCode"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        [self dismissEventList];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.yrPrefixTextField) {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.yrPrefixTextField resignFirstResponder];
    self.yrPrefix = self.yrPrefixTextField.text;
    return YES;
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        //disconnect all the sessions before signing out
        for (NSDictionary *peerSession in [self.appDelegate mcManager].activeSessions) {
            [[peerSession valueForKey:@"session"] disconnect];
        }
        [[self.appDelegate mcManager].activeSessions removeAllObjects];
        [[self.appDelegate mcManager] setActiveSessions:nil];
        //stop advertising and release the advertiser
        [[self.appDelegate mcManager] advertiseSelf:NO];
        self.appDelegate.mcManager.advertising = NO;
        
        //release dataManager
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] removeObserver:[self.appDelegate dataManager]];
        [self.appDelegate setDataManager:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
