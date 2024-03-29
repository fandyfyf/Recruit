//
//  YRFormViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRFormViewController.h"
#import "YRMCManager.h"
#import "YRDataManager.h"
#import "YRClientSignInViewController.h"

typedef NS_ENUM(NSInteger, yRFormAlertType)
{
    formAlertTypeProceed,
    formAlertTypeSend
};

@interface YRFormViewController ()

-(BOOL)checkReady;
-(void)needUpdateCodeNotification:(NSNotification *)notification;
-(void)popUpNameListNotification:(NSNotification*)notification;
-(void)removeNameListNotification:(NSNotification *)notification;
-(void)debriefingModeOnNotification:(NSNotification *)notification;
-(void)debriefingModeOffNotification:(NSNotification *)notification;
-(void)refresh;
-(void)showPlatformSeg;
-(void)doneWithPad;
-(void)removeListView;


@property (nonatomic) UIView *overlayView;

@end

@implementation YRFormViewController
{
    CGRect noteRect;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateCodeNotification:) name:kYRDataManagerNeedUpdateCodeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpNameListNotification:) name:kYRDataManagerNeedPromptNameListNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeNameListNotification:) name:@"removeNameListNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debriefingModeOnNotification:) name:kYRDataManagerReceiveDebriefInitiationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debriefingModeOffNotification:) name:kYRDataManagerReceiveDebriefTerminationNotification object:nil];
    
    self.yrcodeLabel.text = [(YRClientSignInViewController*)self.source yrcodeLabel].text;
    
    self.yrGPATextField.delegate = self;
    self.yrNoteTextView.delegate = self;
    [[self.yrNoteTextView layer] setCornerRadius:10];
    
    [self.yrNoteTextView setText:[NSString stringWithFormat:@"#%@#\n\n",self.appDelegate.mcManager.userName]];
    
    
    NSDate * now = [NSDate date];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyy"];
    int year = [[format stringFromDate:now] intValue];
    
    for (int i=0; i<4; i++) {
        [self.yrGraduationSegCtrl setTitle:[NSString stringWithFormat:@"%d",year+i] forSegmentAtIndex:i];
    }
    
    [self.yrPreferenceSegmentControl addTarget:self action:@selector(showPlatformSeg) forControlEvents:UIControlEventValueChanged];
    
    NSDictionary* tempBack = [[NSUserDefaults standardUserDefaults] objectForKey:@"tempBackUp"];
    if (tempBack != nil) {
        self.yrGPATextField.text = tempBack[@"gpa"];
        self.yrPositionSegmentControl.selectedSegmentIndex = [tempBack[@"position"] integerValue];
        self.yrGraduationSegCtrl.selectedSegmentIndex = [tempBack[@"graduation"] integerValue];
        self.yrPreferenceSegmentControl.selectedSegmentIndex = [tempBack[@"preference"] integerValue];
        self.yrPlatformSegCtrl.selectedSegmentIndex = [tempBack[@"platform"] integerValue];
        self.yrRankingSegmentControl.selectedSegmentIndex = [tempBack[@"rank"] integerValue];
        self.yrNoteTextView.text = tempBack[@"note"];
    }
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    doneToolbar.items = [NSArray arrayWithObjects:
//                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                           [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                           [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithPad)],
                           nil];
    self.yrGPATextField.inputAccessoryView = doneToolbar;
    self.yrNoteTextView.inputAccessoryView = doneToolbar;
    
    self.overlayView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.overlayView setBackgroundColor:[UIColor purpleColor]];
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.overlayView];
    [self.overlayView setFrame:self.view.bounds];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.overlayView.alpha = 1.0;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.overlayView setFrame:self.view.bounds];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Registration" message: @"Please tap OK to proceed if you are a Yahoo engineer" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
    alert.delegate = self;
    alert.tag = formAlertTypeProceed;
    [alert show];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshInformation:(id)sender {
    [self refresh];
}

- (IBAction)sendInformation:(id)sender {
    if ([self checkReady]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send Now?" message:@"Please write down the resume ID on the back of resume!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",@"Send and Flag!", nil];
        alert.tag = formAlertTypeSend;
        [alert show];
    }
    else
    {
        if (self.yrRankingSegmentControl.selectedSegmentIndex != UISegmentedControlNoSegment) {
            //wait until GPA is filled out
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Please enter GPA!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag = formAlertTypeSend;
            [alert show];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Please rank candidate!" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            alert.tag = formAlertTypeSend;
            [alert show];
        }
    }
}

-(BOOL)checkReady
{
    if ([self.yrGPATextField.text length] != 0 && self.yrRankingSegmentControl.selectedSegmentIndex != UISegmentedControlNoSegment) {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(void)needUpdateCodeNotification:(NSNotification *)notification
{
    NSMutableString *code = [[notification userInfo] objectForKey:@"recruitID"];
    [self.yrcodeLabel performSelectorOnMainThread:@selector(setText:) withObject:code waitUntilDone:NO];
}

-(void)popUpNameListNotification:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UILabel* titleLabel;
        UIButton* cancelButton;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.yrNameListView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x - 110, 100, 220, 300)];
            self.yrNameList = [[UITableView alloc] initWithFrame:CGRectMake(5, 40, 210, 255) style:UITableViewStylePlain];
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 180, 30)];
            titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
            cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.yrNameListView.frame.size.width-30, 0, 30, 30)];
            
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.yrNameListView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-250, 250, 500, 600)];
            self.yrNameList = [[UITableView alloc] initWithFrame:CGRectMake(5, 80, 490, 515) style:UITableViewStylePlain];
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.yrNameListView.frame.size.width-40, 70)];
            titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 30];
            cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.yrNameListView.frame.size.width-50, 0, 50, 50)];
        }
        [[self.yrNameListView layer] setCornerRadius:12];
        [[self.yrNameList layer] setCornerRadius:10];
        [titleLabel setTextColor:[UIColor whiteColor]];
        
        [cancelButton addTarget:self action:@selector(removeListView) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setTitle:@"X" forState:UIControlStateNormal];
        cancelButton.tintColor = [UIColor whiteColor];
        
        [self.yrNameList setContentInset:UIEdgeInsetsMake(1.0, 0, 0, 0)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.text = @"Register";
        self.yrNameList.delegate = self;
        self.yrNameList.dataSource = self;
        
        [self.yrNameList setSeparatorInset:UIEdgeInsetsZero];
        [self.yrNameListView addSubview:self.yrNameList];
        [self.yrNameListView addSubview:titleLabel];
        [self.yrNameListView addSubview:cancelButton];
        //        [[self.yrNameListView layer] setBorderColor:[[UIColor grayColor] CGColor]];
        //        [[self.yrNameListView layer] setBorderWidth:2];
        self.yrNameListView.backgroundColor = [UIColor purpleColor];
        
        [self.view addSubview:self.yrNameListView];
        
    });
}

-(void)removeNameListNotification:(NSNotification *)notification
{
    [self.yrNameListView removeFromSuperview];
}

-(void)debriefingModeOnNotification:(NSNotification *)notification
{
    if (self.debriefingViewController == nil) {
        self.debriefingViewController = [YRDebriefViewController new];
        [self.view addSubview:self.debriefingViewController.view];
    }
    else
    {
        [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] dataManager] pullData];
    }
}

-(void)debriefingModeOffNotification:(NSNotification *)notification
{
    [self.debriefingViewController.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self.debriefingViewController];
    self.debriefingViewController = nil;
}

-(void)refresh
{
    [self.yrGPATextField setText:@""];
    [self.sendButton setEnabled:NO];
}

-(void)showPlatformSeg
{
    if (self.yrPreferenceSegmentControl.selectedSegmentIndex == 3) {
        self.yrPlatformSegCtrl.hidden = NO;
    }
    else
    {
        self.yrPlatformSegCtrl.hidden = YES;
    }
}

-(void)doneWithPad
{
    [self.yrGPATextField resignFirstResponder];
    [self.yrNoteTextView resignFirstResponder];
    
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.3];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.yrNoteTextView.frame = CGRectMake(70, 531, 627, 280);
    }
    else{
        // This is a hack to support various iPhone sizes.
        // We should use layoutSubviews!! Or use Auto Layout.
        
        CGFloat height = (CGRectGetMinY(self.sendButton.frame) - 298) - 8; // 8 is the margin between UI elements
        self.yrNoteTextView.frame = CGRectMake(20, 298, 280, height);
    }
    //self.yrNoteTextView.frame = noteRect;
    
    [UIView commitAnimations];
    [self.yrNoteTextView resignFirstResponder];
}

- (IBAction)backgroundTapped:(id)sender {
    
    [self.yrGPATextField resignFirstResponder];
    
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.3];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.yrNoteTextView.frame = CGRectMake(70, 531, 627, 280);
    }
    else{
        CGFloat height = (CGRectGetMinY(self.sendButton.frame) - 298) - 8; // 8 is the margin between UI elements
        self.yrNoteTextView.frame = CGRectMake(20, 298, 280, height);
    }
    //self.yrNoteTextView.frame = noteRect;
    
    [UIView commitAnimations];
    [self.yrNoteTextView resignFirstResponder];
}

- (IBAction)cancelTapped:(id)sender {
    NSDictionary* temporarybackUp = @{@"gpa" : self.yrGPATextField.text, @"position" : [NSNumber numberWithInt:self.yrPositionSegmentControl.selectedSegmentIndex], @"graduation" : [NSNumber numberWithInt:self.yrGraduationSegCtrl.selectedSegmentIndex], @"preference" : [NSNumber numberWithInt:self.yrPreferenceSegmentControl.selectedSegmentIndex], @"platform" : [NSNumber numberWithInt:self.yrPlatformSegCtrl.selectedSegmentIndex], @"rank" : [NSNumber numberWithInt:self.yrRankingSegmentControl.selectedSegmentIndex], @"note" : self.yrNoteTextView.text};
    [[NSUserDefaults standardUserDefaults] setObject:temporarybackUp forKey:@"tempBackUp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)removeListView
{
    [self.yrNameListView removeFromSuperview];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Note" message:@"If you can't find your name on the list, please contact the coordinator soon." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    //[self.tabBarController setSelectedViewController:[self.tabBarController.viewControllers objectAtIndex:1]];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.yrGPATextField resignFirstResponder];
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == formAlertTypeSend) {
        if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
            [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"tempBackUp"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            NSString* preference;
            if (self.yrPreferenceSegmentControl.selectedSegmentIndex == 3) {
                preference = [NSString stringWithFormat:@"%@ - %@",[self.yrPreferenceSegmentControl titleForSegmentAtIndex:self.yrPreferenceSegmentControl.selectedSegmentIndex],[self.yrPlatformSegCtrl titleForSegmentAtIndex:self.yrPlatformSegCtrl.selectedSegmentIndex]];
            }
            else if (self.yrPreferenceSegmentControl.selectedSegmentIndex == 0)
            {
                preference = @"Front End";
            }
            else if (self.yrPreferenceSegmentControl.selectedSegmentIndex == 1)
            {
                preference = @"Back End";
            }
            else if (self.yrPreferenceSegmentControl.selectedSegmentIndex == 2)
            {
                preference = @"Service Engineering";
            }
            else
            {
                preference = [self.yrPreferenceSegmentControl titleForSegmentAtIndex:self.yrPreferenceSegmentControl.selectedSegmentIndex];
            }
            NSDictionary *dataDic = @{@"firstName" : [[(YRClientSignInViewController*)self.source yrFirstNameTextField] text], @"lastName" : [[(YRClientSignInViewController*)self.source yrLastNameTextField] text], @"email" : [[(YRClientSignInViewController*)self.source yrEmailTextField] text], @"code" : self.yrcodeLabel.text,  @"status" : @"pending", @"pdf" : [NSNumber numberWithBool:NO], @"preference" : preference, @"position" : [self.yrPositionSegmentControl titleForSegmentAtIndex:self.yrPositionSegmentControl.selectedSegmentIndex], @"date" : [NSDate date], @"note" : [self.yrNoteTextView text], @"gpa" : self.yrGPATextField.text, @"rank" : [self.yrRankingSegmentControl titleForSegmentAtIndex:self.yrRankingSegmentControl.selectedSegmentIndex], @"interviewer" : self.appDelegate.mcManager.userName, @"tagList" : [NSArray new]};
            
            NSMutableDictionary *newDic = [NSMutableDictionary new];
            [newDic addEntriesFromDictionary:dataDic];
            
            if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Send and Flag!"]) {
                newDic[@"tagList"] = @[self.appDelegate.mcManager.userName];
            }
            //change NSDictionary to NSMutableDictionary
            NSDictionary *packet = @{kYRMessageMessageSection : kYRDataEntryMessage, kYRMessageDataSection : newDic};
            
            [(YRClientSignInViewController*)self.source setCodeLabel:@"Offline"];
            [self.appDelegate.dataManager sendData:packet];
            
            [self refresh];
            
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    } else if (alertView.tag == formAlertTypeProceed) {
        [UIView animateWithDuration:1.0 animations:^{
            self.overlayView.alpha = 0.0f;
        }];
    }
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.3];
    //remember the current shape of the noteview, with the differece of 3.5 screen and 4.0 screen
    noteRect = self.yrNoteTextView.frame;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.yrNoteTextView.frame = CGRectMake(30, 350, 708, 385);
    }
    else{
        self.yrNoteTextView.frame = CGRectMake(10, 20, 300, 300);
    }
    
    [UIView commitAnimations];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self.yrNoteTextView resignFirstResponder];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.appDelegate.dataManager.nameList count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nameListCell"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"nameListCell"];
    }
    
    NSDictionary* current = [self.appDelegate.dataManager.nameList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = current[@"name"];
    cell.detailTextLabel.text = current[@"email"];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.yrNameList) {
        
        //Interviewer* current = self.appDelegate.dataManager.nameList[indexPath.row];
        NSDictionary* current = self.appDelegate.dataManager.nameList[indexPath.row];
        
        NSString* prevUserName = [self.appDelegate.mcManager.userName copy];
        
        //[self.appDelegate.mcManager setUserName:current.name];
        [self.appDelegate.mcManager setUserName:current[@"name"]];
        
        [self.yrNameListView removeFromSuperview];
        
        
        //send back up with the updated username
        
        [self.appDelegate.dataManager sendIdentityConfirmation:prevUserName];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.appDelegate.managedObjectContext]];
        NSError* error = nil;
        NSArray* FetchResults = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (CandidateEntry* backedUpCandidate in FetchResults)
        {
            NSDictionary* dic = @{@"firstName":backedUpCandidate.firstName,@"lastName":backedUpCandidate.lastName,@"email":backedUpCandidate.emailAddress,@"interviewer":self.appDelegate.mcManager.userName,@"code":backedUpCandidate.code,@"status":backedUpCandidate.status,@"pdf":backedUpCandidate.pdf,@"position":backedUpCandidate.position,@"preference":backedUpCandidate.preference,@"date":backedUpCandidate.date,@"note":backedUpCandidate.notes,@"rank":[backedUpCandidate.rank stringValue],@"gpa":[backedUpCandidate.gpa stringValue],@"tagList":backedUpCandidate.tagList};
            
            
            NSDictionary* packet = @{kYRMessageMessageSection : kYRBackupDataEntryMessage, kYRMessageDataSection : dic};
            [self.appDelegate.dataManager sendBackUp:packet];
            NSLog(@"sending one entry");
        }
        
        //reset the core data
        for (CandidateEntry* backedUpCandidate in FetchResults)
        {
            [self.appDelegate.managedObjectContext deleteObject:backedUpCandidate];
            NSLog(@"deleting one coredata entry");
        }
        
        if (![self.appDelegate.managedObjectContext save:&error]) {
            NSLog(@"ERROR -- saving coredata");
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeNameListNotification" object:nil];
    }
}


@end
