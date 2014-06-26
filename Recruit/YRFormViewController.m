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

//-(void)checkReadySend;
//-(void)checkReadySave;
-(void)needUpdateCodeNotification:(NSNotification *)notification;
-(void)reconnectNotification:(NSNotification *)notification;
-(void)needEndSessionNotification:(NSNotification *)notification;
-(void)refresh;
-(void)showPlatformSeg;

@end

@implementation YRFormViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateCodeNotification:) name:@"NeedUpdateCodeNotification" object:nil];
    
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
    //[self.yrRankingSegmentControl addTarget:self action:@selector(checkReadySend) forControlEvents:UIControlEventValueChanged];
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NOTE" message:@"Ready to send?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",@"Recommand", nil];
    [alert show];
}

//-(void)checkReadySend
//{
//    if ([self.yrGPATextField.text length] != 0 && (self.yrRankingSegmentControl.selectedSegmentIndex == 3 || self.yrRankingSegmentControl.selectedSegmentIndex == 4)) {
//        [self.sendButton setEnabled:YES];
//    }
//    else
//    {
//        [self.sendButton setEnabled:NO];
//    }
//}
//
//-(void)checkReadySave
//{
//    if ([self.yrGPATextField.text length] != 0) {
//        [self.saveButton setEnabled:YES];
//    }
//    else
//    {
//        [self.saveButton setEnabled:NO];
//    }
//}

-(void)checkReady
{
    if ([self.yrGPATextField.text length] != 0) {
        [self.sendButton setEnabled:YES];
    }
    else
    {
        [self.sendButton setEnabled:NO];
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
    
//    [self checkReadySave];
//    [self checkReadySend];
    [self checkReady];
}

- (IBAction)cancelTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.yrGPATextField resignFirstResponder];
    
//    [self checkReadySave];
//    [self checkReadySend];
    [self checkReady];
    
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
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
        self.yrNoteTextView.frame = CGRectMake(20, 180, 280, 150);
    }
    
    [UIView commitAnimations];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self.yrNoteTextView resignFirstResponder];
}


@end
