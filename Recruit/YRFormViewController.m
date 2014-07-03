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

@interface YRFormViewController ()


-(BOOL)checkReady;
-(void)needUpdateCodeNotification:(NSNotification *)notification;
-(void)reconnectNotification:(NSNotification *)notification;
-(void)needEndSessionNotification:(NSNotification *)notification;
-(void)popUpNameListNotification:(NSNotification*)notification;
-(void)removeNameListNotification:(NSNotification *)notification;
-(void)refresh;
-(void)showPlatformSeg;
-(void)doneWithPad;
-(void)removeListView;

@end

@implementation YRFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateCodeNotification:) name:@"NeedUpdateCodeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpNameListNotification:) name:@"NameListReadyNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeNameListNotification:) name:@"removeNameListNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnectNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needEndSessionNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NOTE" message:@"Ready to send?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",@"Recommand", nil];
        [alert show];
    }
    else
    {
        //wait until GPA is filled out
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"GPA can't be empty!" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(BOOL)checkReady
{
    if ([self.yrGPATextField.text length] != 0) {
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

-(void)reconnectNotification:(NSNotification *)notification
{
    //NSLog(@"Name is %@",[[[[self tabBarController] viewControllers] objectAtIndex: 0] valueForKey:@"clientUserName"]);
    [[self.appDelegate mcManager] setupPeerAndSessionWithDisplayName:[[[self.tabBarController viewControllers] objectAtIndex: 0] valueForKey:@"clientUserName"]];
    MCNearbyServiceBrowser *browser = [[MCNearbyServiceBrowser alloc] initWithPeer:[self.appDelegate mcManager].peerID serviceType:@"files"];
    [browser invitePeer:[self.appDelegate mcManager].lastConnectionPeerID toSession:[self.appDelegate mcManager].session withContext:nil timeout:10];
}

-(void)needEndSessionNotification:(NSNotification *)notification
{
    [[self.appDelegate mcManager].session disconnect];
    [self.appDelegate mcManager].session = nil;
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
            titleLabel.font = [UIFont boldSystemFontOfSize:20];
            cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.yrNameListView.frame.size.width-30, 0, 30, 30)];
            
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            self.yrNameListView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-250, 250, 500, 600)];
            self.yrNameList = [[UITableView alloc] initWithFrame:CGRectMake(5, 80, 490, 515) style:UITableViewStylePlain];
            titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.yrNameListView.frame.size.width-40, 70)];
            titleLabel.font = [UIFont boldSystemFontOfSize:30];
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

-(void)refresh
{
    [self.yrGPATextField setText:@""];
    [self.sendButton setEnabled:NO];
}

-(void)showPlatformSeg
{
    if (self.yrPreferenceSegmentControl.selectedSegmentIndex == 3) {
        self.yrPlatformSegCtrl.enabled = YES;
    }
    else
    {
        self.yrPlatformSegCtrl.enabled = NO;
    }
}

-(void)doneWithPad
{
    [self.yrGPATextField resignFirstResponder];
    [self.yrNoteTextView resignFirstResponder];
    
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.5];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.yrNoteTextView.frame = CGRectMake(70, 531, 627, 280);
    }
    else{
        self.yrNoteTextView.frame = CGRectMake(20, 298, 280, 150);
    }
    
    [UIView commitAnimations];
    [self.yrNoteTextView resignFirstResponder];
}

- (IBAction)backgroundTapped:(id)sender {
    
    [self.yrGPATextField resignFirstResponder];
    
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.5];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.yrNoteTextView.frame = CGRectMake(70, 531, 627, 280);
    }
    else{
        self.yrNoteTextView.frame = CGRectMake(20, 298, 280, 150);
    }
    
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
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Note" message:@"If you can't find your name on the list, please contact the coordinator soon." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
    [self.tabBarController setSelectedViewController:[self.tabBarController.viewControllers objectAtIndex:1]];
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
    if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"tempBackUp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSString* preference;
        if (self.yrPreferenceSegmentControl.selectedSegmentIndex == 3) {
            preference = [NSString stringWithFormat:@"%@ - %@",[self.yrPreferenceSegmentControl titleForSegmentAtIndex:self.yrPreferenceSegmentControl.selectedSegmentIndex],[self.yrPlatformSegCtrl titleForSegmentAtIndex:self.yrPlatformSegCtrl.selectedSegmentIndex]];
        }
        else
        {
            preference = [self.yrPreferenceSegmentControl titleForSegmentAtIndex:self.yrPreferenceSegmentControl.selectedSegmentIndex];
        }
        NSDictionary *dataDic = @{@"firstName" : [[(YRClientSignInViewController*)self.source yrFirstNameTextField] text], @"lastName" : [[(YRClientSignInViewController*)self.source yrLastNameTextField] text], @"email" : [[(YRClientSignInViewController*)self.source yrEmailTextField] text], @"code" : self.yrcodeLabel.text, @"recommand" : [NSNumber numberWithBool:NO], @"status" : @"pending", @"pdf" : [NSNumber numberWithBool:NO], @"preference" : preference, @"position" : [self.yrPositionSegmentControl titleForSegmentAtIndex:self.yrPositionSegmentControl.selectedSegmentIndex], @"date" : [NSDate date], @"note" : [self.yrNoteTextView text], @"gpa" : self.yrGPATextField.text, @"rank" : [self.yrRankingSegmentControl titleForSegmentAtIndex:self.yrRankingSegmentControl.selectedSegmentIndex], @"interviewer" : self.appDelegate.mcManager.userName};
        
        NSMutableDictionary *newDic = [NSMutableDictionary new];
        [newDic addEntriesFromDictionary:dataDic];
        
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Recommand"]) {
            newDic[@"recommand"] = [NSNumber numberWithBool:YES];
        }
        //change NSDictionary to NSMutableDictionary
        NSDictionary *dic = @{@"msg" : @"data", @"data" : newDic};
        
        [(YRClientSignInViewController*)self.source setCodeLabel:@"No Connection!"];
        [self.appDelegate.dataManager sendData:dic];
        
        [self refresh];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.5];
    
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
    
    //        Interviewer* current = [self.appDelegate.dataManager.nameList objectAtIndex:indexPath.row];
    //
    //        cell.textLabel.text = current.name;
    //        cell.detailTextLabel.text = current.email;
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
        
        //[self.appDelegate.mcManager setUserName:current.name];
        [self.appDelegate.mcManager setUserName:current[@"name"]];
        
        [self.yrNameListView removeFromSuperview];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeNameListNotification" object:nil];
    }
}


@end
