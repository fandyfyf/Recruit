//
//  YRClientSignInViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/19/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRClientSignInViewController.h"
#import "YRFormViewController.h"
#import <Guile/UITextField+AutoSuggestAdditions.h>
#import <Guile/Guile.h>
#import "YRDataManager.h"
#import "YRMCManager.h"
#import "Interviewer.h"

@interface YRClientSignInViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *yrarrayConnectedDevices;

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification;
-(void)needUpdateCodeNotification:(NSNotification *)notification;
-(void)popUpNameListNotification:(NSNotification*)notification;
-(void)removeNameListNotification:(NSNotification *)notification;
-(void)debriefingModeOnNotification:(NSNotification *)notification;
-(void)debriefingModeOffNotification:(NSNotification *)notification;
-(void)reconnectNotification:(NSNotification *)notification;
-(void)removeListView;
-(BOOL)checkReady;
-(void)nextCandidateField;
-(void)doneWithCandidateFields;
@end

@implementation YRClientSignInViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SignInToForm"]) {
        [(YRFormViewController*)segue.destinationViewController setSource:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.clientUserName = [self.appDelegate.mcManager userName];
    
    NSLog(@"Hello: %@ as a client",self.clientUserName);
    [self.yrnameLabel setText:self.clientUserName];
    
    //Listen to notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDidChangeStateWithNotification:) name:kYRMCManagerDidChangeStateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateCodeNotification:) name:kYRDataManagerNeedUpdateCodeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popUpNameListNotification:) name:kYRDataManagerNeedPromptNameListNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeNameListNotification:) name:@"removeNameListNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debriefingModeOnNotification:) name:kYRDataManagerReceiveDebriefInitiationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(debriefingModeOffNotification:) name:kYRDataManagerReceiveDebriefTerminationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnectNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    self.yrarrayConnectedDevices = [[NSMutableArray alloc] init];
    self.yrIDCode = [NSMutableString new];
    
    //reset session and make the connect
    [self.appDelegate.mcManager.session disconnect];
    self.appDelegate.mcManager.session = nil;
    self.appDelegate.mcManager.autoBrowser = nil;
    self.appDelegate.mcManager.peerID = nil;
    [self.yrarrayConnectedDevices removeAllObjects];
    [self.appDelegate.dataManager stopListeningForData];
    
    if ([self.appDelegate dataManager] == nil) {
        [self.appDelegate setDataManager:[YRDataManager new]];
    }
    [[self.appDelegate dataManager] setHost:NO];
    [[self.appDelegate dataManager] startListeningForData];
    
    [self.appDelegate.mcManager setHost:NO];//set host identity first, in order to initialize the session
    [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:self.clientUserName];
    [self.appDelegate.mcManager setupMCBrowser];
    
    self.appDelegate.mcManager.autoBrowser.delegate = self;
    [self.appDelegate.mcManager.autoBrowser startBrowsingForPeers];
    [self.appDelegate.mcManager setBrowsing:YES];

    self.yrFirstNameTextField.delegate = self;
    self.yrLastNameTextField.delegate = self;
    self.yrEmailTextField.delegate = self;
    self.yrEmailTextField.suggestionDelegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[self.yrSignOutButton layer] setCornerRadius:35];
        [[self.yrSignOutButton layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [[self.yrSignOutButton layer] setBorderWidth:2];
    }
    else
    {
        [[self.yrSignOutButton layer] setCornerRadius:30];
        [[self.yrSignOutButton layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [[self.yrSignOutButton layer] setBorderWidth:2];
        
//        [[self.yrContinueButton layer] setCornerRadius:30];
//        [[self.yrContinueButton layer] setBorderColor:[[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] CGColor]];
//        [[self.yrContinueButton layer] setBorderWidth:2];
    }
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    doneToolbar.items = [NSArray arrayWithObjects:
                         //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(nextCandidateField)],
                         nil];
    self.yrFirstNameTextField.inputAccessoryView = doneToolbar;
    self.yrLastNameTextField.inputAccessoryView = doneToolbar;
    
    doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    doneToolbar.items = [NSArray arrayWithObjects:
                         //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithCandidateFields)],
                         nil];
    
    self.yrEmailTextField.inputAccessoryView = doneToolbar;
    
//    //=====test=====/
//    if (self.debriefingViewController == nil) {
//        self.debriefingViewController = [YRDebriefViewController new];
//    }
//    self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
//    self.grayView.backgroundColor = [UIColor blackColor];
//    self.grayView.alpha = 0.9;
//    
//    [self.view addSubview:self.grayView];
//    [self.view addSubview:self.debriefingViewController.view];
//===========test===========//
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.clientUserName = [self.appDelegate.mcManager userName];
    [self.yrnameLabel setText:self.clientUserName];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    self.scrollView.contentSize = self.view.bounds.size;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)continueGo:(id)sender {
    if ([self checkReady]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Hi Student" message:@"Please hand back the device to our engineer." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Continue", nil];
        [alert show];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"fields need to be completed" delegate:Nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (IBAction)backgroundTapped:(id)sender {
    [self.yrFirstNameTextField resignFirstResponder];
    [self.yrLastNameTextField resignFirstResponder];
    [self.yrEmailTextField resignFirstResponder];
    [self.yrEmailTextField acceptSuggestion];
}

- (IBAction)signOut:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Signing out?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

-(void)setCodeLabel:(NSString*)label
{
    self.yrcodeLabel.text = label;
    self.yrFirstNameTextField.text = @"";
    self.yrLastNameTextField.text = @"";
    self.yrEmailTextField.text = @"";
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [self.yrarrayConnectedDevices addObject:@{@"displayName" : peerDisplayName, @"confirmedName" : @"connnecting..."}];
        }
        else if (state == MCSessionStateNotConnected){
            if ([self.yrarrayConnectedDevices count] > 0) {
                unsigned long indexOfPeer = 0;
                for (unsigned long i = 0; i < [self.yrarrayConnectedDevices count] ; i++) {
                    if ([[self.yrarrayConnectedDevices objectAtIndex:i][@"displayName"] isEqualToString:peerDisplayName]) {
                        indexOfPeer = i;
                        break;
                    }
                }
                [self.yrarrayConnectedDevices removeObjectAtIndex:indexOfPeer];
            }
        }
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
        self.yrNameListView.backgroundColor = [UIColor purpleColor];
        
        [self.view addSubview:self.yrNameListView];
        
    });
}

-(void)removeNameListNotification:(NSNotification *)notification
{
    [self.yrnameLabel setText:self.appDelegate.mcManager.userName];
    [self.yrNameListView removeFromSuperview];
}

-(void)removeListView
{
    [self.yrNameListView removeFromSuperview];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Note" message:@"If you can't find your name on the list, please contact the coordinator soon." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    [alert show];
    //[self.tabBarController setSelectedViewController:[self.tabBarController.viewControllers objectAtIndex:1]];
}

-(void)debriefingModeOnNotification:(NSNotification *)notification
{
    if (self.debriefingViewController == nil) {
        self.debriefingViewController = [YRDebriefViewController new];
    }
    self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
    self.grayView.backgroundColor = [UIColor blackColor];
    self.grayView.alpha = 0.9;
    
    [self.view addSubview:self.grayView];
    [self.view addSubview:self.debriefingViewController.view];
}

-(void)debriefingModeOffNotification:(NSNotification *)notification
{
    //[self.debriefingViewController dismissViewControllerAnimated:YES completion:nil];
    [self.grayView removeFromSuperview];
    [self.debriefingViewController.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self.debriefingViewController];
    self.debriefingViewController = nil;
    
    [[self.appDelegate mcManager].session disconnect];
    [self.appDelegate mcManager].session = nil;
    [self.yrarrayConnectedDevices removeAllObjects];
    
    [self.appDelegate.dataManager stopListeningForData];
    
    [self.appDelegate setDataManager:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)dealloc
{
    NSLog(@"deallocating...");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)reconnectNotification:(NSNotification *)notification
{
    [self.appDelegate.mcManager.session disconnect];
    self.appDelegate.mcManager.session = nil;
    self.appDelegate.mcManager.autoBrowser = nil;
    self.appDelegate.mcManager.peerID = nil;
    [self.yrarrayConnectedDevices removeAllObjects];
    [self.appDelegate.dataManager stopListeningForData];
    
    if ([self.appDelegate dataManager] == nil) {
        [self.appDelegate setDataManager:[YRDataManager new]];
    }
    [[self.appDelegate dataManager] setHost:NO];
    [[self.appDelegate dataManager] startListeningForData];
    
    [self.appDelegate.mcManager setHost:NO];//set host identity first, in order to initialize the session
    [self.appDelegate.mcManager setupPeerAndSessionWithDisplayName:self.clientUserName];
    [self.appDelegate.mcManager setupMCBrowser];
    
    self.appDelegate.mcManager.autoBrowser.delegate = self;
    [self.appDelegate.mcManager.autoBrowser startBrowsingForPeers];
    [self.appDelegate.mcManager setBrowsing:YES];
}

-(BOOL)checkReady
{
    if ([self.yrFirstNameTextField.text length] == 0 || [self.yrLastNameTextField.text length] == 0 || [self.yrEmailTextField.text length] == 0) {
        return NO;
    }
    else
    {
        return YES;
    }
}

-(void)nextCandidateField
{
    if ([self.yrFirstNameTextField isFirstResponder]) {
        //[self.interviewerName resignFirstResponder];
        [self.yrLastNameTextField becomeFirstResponder];
    }
    else if ([self.yrLastNameTextField isFirstResponder]) {
        //[self.interviewerEmail resignFirstResponder];
        [self.yrEmailTextField becomeFirstResponder];
    }
}

-(void)doneWithCandidateFields
{
    [self.yrEmailTextField resignFirstResponder];
}


#pragma mark - MCNearByServiceBrowserDelegate

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSString *remotePeerName = peerID.displayName;
    
    NSLog(@"Browser found %@", remotePeerName);
    
    NSLog(@"Inviting %@", remotePeerName);
    
    //since the host will be the only one we advertise, so there are only one
    [browser invitePeer:peerID toSession:self.appDelegate.mcManager.session withContext:nil timeout:30.0];
    
    [browser stopBrowsingForPeers];
    [self.appDelegate.mcManager setBrowsing:NO];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    //
}



#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField{
    [self.scrollView scrollRectToVisible:textField.frame animated:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.yrFirstNameTextField resignFirstResponder];
    [self.yrLastNameTextField resignFirstResponder];
    [self.yrEmailTextField resignFirstResponder];
    [self.yrEmailTextField acceptSuggestion];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.yrFirstNameTextField resignFirstResponder];
    [self.yrLastNameTextField resignFirstResponder];
    [self.yrEmailTextField resignFirstResponder];
    [self.yrEmailTextField acceptSuggestion];
    return YES;
}

#pragma mark - AutoSuggestDelegate

- (NSString *)suggestedStringForInputString:(NSString *)input
{
    static NSArray *domains;
    if (!domains) {
        domains = @[@"columbia.edu",
                    @"colgate.edu",
                    @"gmail.com",
                    @"gmail.co.uk",
                    @"yahoo.com",
                    @"yahoo.cn",
                    @"hotmail.com",
                    @"yahoo-inc.com"];
    }
    
    NSArray *parts = [input componentsSeparatedByString:@"@"];
    NSString *suggestion = nil;
    if (parts.count == 2) {
        NSString *domain = [parts lastObject];
        
        if (domain.length == 0) {
            suggestion = nil;
        }
        else {
            for (NSString *current in domains) {
                if ([current isEqualToString:domain]) {
                    suggestion = nil;
                    break;
                }
                else if ([current hasPrefix:domain]) {
                    suggestion = [current substringFromIndex:domain.length];
                    break;
                }
            }
        }
    }
    return suggestion;
}

-(UIColor *)suggestedTextColor
{
    return [UIColor grayColor];
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
        
        NSString* prevUserName = [self.appDelegate.mcManager.userName copy];
        
        [self.appDelegate.mcManager setUserName:current[@"name"]];
        
        [self.yrNameListView removeFromSuperview];
        
        NSLog(@"update %@ to %@",prevUserName,self.appDelegate.mcManager.userName);
        
        //send out backUp here with the updated name
        
        [self.appDelegate.dataManager sendIdentityConfirmation:self.appDelegate.mcManager.userName];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.appDelegate.managedObjectContext]];
        NSError* error = nil;
        NSArray* FetchResults = [self.appDelegate.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (CandidateEntry* backedUpCandidate in FetchResults)
        {
            //update the taglist with the updated interview username
            NSMutableArray* newTagList = [NSMutableArray new];
            [newTagList addObject:self.appDelegate.mcManager.userName];
            [backedUpCandidate setTagList:[NSArray arrayWithArray:newTagList]];
            
            NSDictionary* dic = @{@"firstName":backedUpCandidate.firstName,@"lastName":backedUpCandidate.lastName,@"email":backedUpCandidate.emailAddress,@"interviewer":self.appDelegate.mcManager.userName,@"code":backedUpCandidate.code,@"status":backedUpCandidate.status,@"pdf":backedUpCandidate.pdf,@"position":backedUpCandidate.position,@"preference":backedUpCandidate.preference,@"date":backedUpCandidate.date,@"note":backedUpCandidate.notes,@"rank":[backedUpCandidate.rank stringValue],@"gpa":[backedUpCandidate.gpa stringValue],@"tagList":[backedUpCandidate tagList]};
            NSDictionary* packet = @{@"msg" : @"backup", @"data":dic};
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

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [[self.appDelegate mcManager].session disconnect];
        [self.appDelegate mcManager].session = nil;
        [[self.appDelegate mcManager].autoBrowser stopBrowsingForPeers];
        [self.appDelegate mcManager].autoBrowser = nil;
        
        self.yrIDCode = nil;
        [self.yrarrayConnectedDevices removeAllObjects];
        self.yrarrayConnectedDevices = nil;
        
        //stop listening to notifications
        // TODO: We shouldn't stop listening for all notification, right? We lose the keyboard notifications....
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        
        [self.appDelegate.dataManager stopListeningForData];
        [self.appDelegate setDataManager:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Continue"]) {
        [self.view endEditing:YES];
        [self performSegueWithIdentifier:@"SignInToForm" sender:self];
    }
}

#pragma mark - Keyboard

- (void)keyboardDidShow:(NSNotification *)notif{
    NSValue *endFrame = [[notif userInfo] objectForKey: UIKeyboardFrameEndUserInfoKey];
    if (endFrame) {
        CGRect convertedFrame = [self.view convertRect:[endFrame CGRectValue] fromView:nil];
        UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, convertedFrame.size.height, 0.0);
        self.scrollView.contentInset = contentInsets;
    }
}

- (void)keyboardWillHide:(NSNotification *)notif{
    self.scrollView.contentInset = UIEdgeInsetsZero;
}

@end
