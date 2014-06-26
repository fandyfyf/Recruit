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

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification;
-(void)needUpdateTableNotification:(NSNotification *)notification;

@end

@implementation YRHostMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //self.hostUserName = [self.source valueForKey:@"userName"];
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    
    self.hostUserName = self.appDelegate.mcManager.userName;
    NSLog(@"Hello: %@ as a Host",self.hostUserName);
    
    [self.yrnameLabel setText:self.hostUserName];
    //self.yrnameLabel.textAlignment = NSTextAlignmentCenter;
    
    
    self.yrPrefix = [NSString new];
    //set up session with host username
    [[self.appDelegate mcManager] setupPeerAndSessionWithDisplayName:self.hostUserName];
    [[self.appDelegate mcManager] setHost:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDidChangeStateWithNotification:) name:kYRMCManagerDidChangeStateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateTableNotification:) name:@"NeedUpdateTableNotification" object:nil];
    self.yrarrayConnectedDevices = [[NSMutableArray alloc] init];
    [self.yrtableView setDelegate:self];
    [self.yrtableView setDataSource:self];
    [self.yrPrefixTextField setDelegate:self];
    
    //advertise
    //[[self.appDelegate mcManager] advertiseSelf:self.yrVisibilityControl.isOn];
    //disable brower button
    [self.yrbrowseButton setEnabled:NO];
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

- (IBAction)toggleVisibility:(id)sender {
    [self.yrPrefixTextField resignFirstResponder];
    self.yrPrefix = self.yrPrefixTextField.text;
    
    if (self.yrVisibilityControl.isOn) {
        [self.yrPrefixTextField setEnabled:NO];
        if ([self.appDelegate dataManager] == nil) {
            [self.appDelegate setDataManager:[[YRDataManager alloc] initWithPrefix:self.yrPrefix]];
        }
        [[self.appDelegate dataManager] setHost:YES];
        [[self.appDelegate dataManager] startListeningForData];
    }
    else
    {
        [self.yrPrefixTextField setEnabled:YES];
        [self.appDelegate.dataManager stopListeningForData];
        [self.appDelegate setDataManager:nil];
    }
    
    [[self.appDelegate mcManager] advertiseSelf:self.yrVisibilityControl.isOn];
}

- (IBAction)backgroundTapped:(id)sender {
    [self.yrPrefixTextField resignFirstResponder];
    self.yrPrefix = self.yrPrefixTextField.text;
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    NSString *peerDisplayName = peerID.displayName;
    MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
    
    if (state != MCSessionStateConnecting) {
        if (state == MCSessionStateConnected) {
            [self.yrarrayConnectedDevices addObject:peerDisplayName];
            //send ACK back
            [[self.appDelegate dataManager] sendACKBack:peerID];
            
            [[self.appDelegate dataManager] sendNameList:peerID];
        }
        else if (state == MCSessionStateNotConnected){
            if ([self.yrarrayConnectedDevices count] > 0) {
                unsigned long indexOfPeer = [self.yrarrayConnectedDevices indexOfObject:peerDisplayName];
                [self.yrarrayConnectedDevices removeObjectAtIndex:indexOfPeer];
                
                [[self.appDelegate mcManager].activeSessions removeObjectAtIndex:indexOfPeer];
                
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


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.yrarrayConnectedDevices count];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
    }
    
    cell.textLabel.text = [self.yrarrayConnectedDevices objectAtIndex:indexPath.row];
    
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
@end
