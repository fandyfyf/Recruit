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

@interface YRHostMainViewController ()

@property (nonatomic, strong) NSMutableArray *yrarrayConnectedDevices;

-(void)debuggerFunction;
-(void)peerDidChangeStateWithNotification:(NSNotification *)notification;
-(void)needUpdateTableNotification:(NSNotification *)notification;
-(void)needUpdateConnectionListNotification:(NSNotification *)notification;
-(void)doneWithPad;

@end

@implementation YRHostMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //self.hostUserName = [self.source valueForKey:@"userName"];
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    
    self.hostUserName = self.appDelegate.mcManager.userName;
    NSLog(@"Hello: %@ as a Host",self.hostUserName);
    
    [self debuggerFunction];
    
    [self.yrnameLabel setText:self.hostUserName];
    //self.yrnameLabel.textAlignment = NSTextAlignmentCenter;
    
    
    self.yrPrefix = [NSString new];
    //set up session with host username
    [[self.appDelegate mcManager] setupPeerAndSessionWithDisplayName:self.hostUserName];
    [[self.appDelegate mcManager] setHost:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDidChangeStateWithNotification:) name:kYRMCManagerDidChangeStateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateTableNotification:) name:@"NeedUpdateTableNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateConnectionListNotification:) name:@"NeedUpdateConnectionListNotification" object:nil];
    
    
    
    self.yrarrayConnectedDevices = [[NSMutableArray alloc] init];
    [self.yrtableView setDelegate:self];
    [self.yrtableView setDataSource:self];
    [self.yrPrefixTextField setDelegate:self];
    
    //advertise
    //[[self.appDelegate mcManager] advertiseSelf:self.yrVisibilityControl.isOn];
    //disable brower button
    [self.yrbrowseButton setEnabled:NO];
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
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    doneToolbar.items = [NSArray arrayWithObjects:
                         //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithPad)],
                         nil];
    self.yrPrefixTextField.inputAccessoryView = doneToolbar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)browseForDevices:(id)sender {
    [[self.appDelegate mcManager] setupMCBrowser];
    [[[self.appDelegate mcManager] browser] setDelegate:self];
    [self presentViewController:[[self.appDelegate mcManager] browser] animated:YES completion:nil];
    
}

- (IBAction)disconnectConnection:(id)sender {
    for (NSDictionary *peerSession in [self.appDelegate mcManager].activeSessions) {
        [[peerSession valueForKey:@"session"] disconnect];
    }
    [[self.appDelegate mcManager].activeSessions removeAllObjects];
    [self.yrarrayConnectedDevices removeAllObjects];
    [self.yrtableView reloadData];
}

- (IBAction)signOut:(id)sender {
    NSLog(@"sign out");
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Sign Out?" message:@"Signing out will affect connected interviewers!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    
    [alert show];
}

//switch has a bug, and need to be fixed in a better way
- (IBAction)toggleVisibility:(id)sender {
    [self.yrPrefixTextField resignFirstResponder];
    self.yrPrefix = self.yrPrefixTextField.text;
    
    if (self.yrVisibilityControl.isOn) {
        if (self.yrPrefixTextField.isEnabled) {
            [self.yrPrefixTextField setEnabled:NO];
        }
        self.appDelegate.dataManager = nil;
        if ([self.appDelegate dataManager] == nil) {
            [self.appDelegate setDataManager:[[YRDataManager alloc] initWithPrefix:self.yrPrefix]];
            [[self.appDelegate dataManager] startListeningForData];
        }
        [[self.appDelegate dataManager] setHost:YES];
        
        //init active session && set up advertiser and advertise
        [[self.appDelegate mcManager] advertiseSelf:self.yrVisibilityControl.isOn];
    }
    else
    {
        if (!self.yrPrefixTextField.isEnabled) {
            [self.yrPrefixTextField setEnabled:YES];
        }
        if (self.appDelegate.dataManager != nil) {
            [self.appDelegate.dataManager stopListeningForData];
            [self.appDelegate setDataManager:nil];
        }
        
        
        for (NSDictionary *peerSession in [self.appDelegate mcManager].activeSessions) {
            [[peerSession valueForKey:@"session"] disconnect];
        }
        [[self.appDelegate mcManager].activeSessions removeAllObjects];
        [[[self.appDelegate mcManager] Nadvertiser] stopAdvertisingPeer];
        [[self.appDelegate mcManager] setNadvertiser:nil];
        
        [self.yrarrayConnectedDevices removeAllObjects];
        [self.yrtableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (IBAction)backgroundTapped:(id)sender {
    [self.yrPrefixTextField resignFirstResponder];
    self.yrPrefix = self.yrPrefixTextField.text;
}

-(void)debuggerFunction
{
    if ([self.hostUserName isEqualToString:@"kirito"]) {
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

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [self.yrarrayConnectedDevices addObject:@{@"displayName" : peerDisplayName, @"confirmedName" : @"connnecting..."}];

            //send ACK back
            [[self.appDelegate dataManager] sendACKBack:peerID];
            
            [[self.appDelegate dataManager] sendNameList:peerID];
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.yrtableView reloadData];
            
            BOOL peersNotExist = ([[self.appDelegate mcManager].activeSessions count] == 0);
            [self.yrdisconnectButton setEnabled:!peersNotExist];
        });
    }
}

-(void)needUpdateTableNotification:(NSNotification *)notification
{
    //
}

-(void)needUpdateConnectionListNotification:(NSNotification *)notification
{
    NSString* displayName = [[notification userInfo] objectForKey:@"displayName"];
    
    for (unsigned long i = 0; i < [self.yrarrayConnectedDevices count] ; i++) {
        if ([[self.yrarrayConnectedDevices objectAtIndex:i][@"displayName"] isEqualToString:displayName]) {
            [self.yrarrayConnectedDevices replaceObjectAtIndex:i withObject:[notification userInfo]];
            break;
        }
    }
    
    //update table here!!
    [self.yrtableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

-(void)doneWithPad
{
    [self.yrPrefixTextField resignFirstResponder];
    self.yrPrefix = self.yrPrefixTextField.text;
}

#pragma mark - MCBrowserViewControllerDelegate

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [[self.appDelegate mcManager].browser dismissViewControllerAnimated:YES completion:nil];
}


-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [[self.appDelegate mcManager].browser dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Connected Peers";
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.yrarrayConnectedDevices count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    cell.textLabel.text = [self.yrarrayConnectedDevices objectAtIndex:indexPath.row][@"confirmedName"];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0;
}

#pragma mark - UITextFieldDelegate

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
        for (NSDictionary *peerSession in [self.appDelegate mcManager].activeSessions) {
            [[peerSession valueForKey:@"session"] disconnect];
        }
        [[self.appDelegate mcManager].activeSessions removeAllObjects];
        
        [[[self.appDelegate mcManager] Nadvertiser] stopAdvertisingPeer];
        [self.appDelegate mcManager].Nadvertiser = nil;
        
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] removeObserver:[self.appDelegate dataManager]];
        [self.appDelegate setDataManager:nil];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
@end
