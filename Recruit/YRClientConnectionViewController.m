//
//  YRClientConnectionViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRClientConnectionViewController.h"
#import "YRFormViewController.h"
#import "YRDataManager.h"
#import "YRMCManager.h"

@interface YRClientConnectionViewController ()

@property (nonatomic, strong) NSMutableArray *yrarrayConnectedDevices;

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification;
-(void)needUpdateCodeNotification:(NSNotification *)notification;

@end

@implementation YRClientConnectionViewController

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
    
    self.clientUserName = [[NSUserDefaults standardUserDefaults] valueForKey:@"userName"];
    
    NSLog(@"Hello: %@ as a client",self.clientUserName);
    [self.yrnameLabel setText:self.clientUserName];
    
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    //set up session with host username
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDidChangeStateWithNotification:) name:kYRMCManagerDidChangeStateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateCodeNotification:) name:@"NeedUpdateCodeNotification" object:nil];
    
    
    
    self.yrarrayConnectedDevices = [[NSMutableArray alloc] init];
    [self.yrtableView setDelegate:self];
    [self.yrtableView setDataSource:self];
    self.yrIDCode = [NSMutableString new];
    
    //advertise
    //[[self.appDelegate mcManager] advertiseSelf:YES];  //client doesn't need to be posted
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)browseForDevices:(id)sender {

    if ([self.appDelegate dataManager] == nil) {
        [self.appDelegate setDataManager:[YRDataManager new]];
    }
    [[self.appDelegate dataManager] setHost:NO];
    [[self.appDelegate dataManager] startListeningForData];
    
    
    
    [[self.appDelegate mcManager] setupPeerAndSessionWithDisplayName:self.clientUserName];
    [[self.appDelegate mcManager] setHost:NO];
    [[self.appDelegate mcManager] setupMCBrowser];
    [[[self.appDelegate mcManager] browser] setDelegate:self];
    [self presentViewController:[[self.appDelegate mcManager] browser] animated:YES completion:nil];
    
}

- (IBAction)disconnectConnection:(id)sender {
    [[self.appDelegate mcManager].session disconnect];
    [self.appDelegate mcManager].session = nil;
    [self.yrarrayConnectedDevices removeAllObjects];
    
    [self.appDelegate.dataManager stopListeningForData];
    
    [self.yrtableView reloadData];
}


- (IBAction)signOut:(id)sender {
    [[self.appDelegate mcManager].session disconnect];
    [self.appDelegate mcManager].session = nil;
    [self.yrarrayConnectedDevices removeAllObjects];
    
    [self.appDelegate.dataManager stopListeningForData];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self.appDelegate setDataManager:nil];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
        NSString *peerDisplayName = peerID.displayName;
        MCSessionState state = [[[notification userInfo] objectForKey:@"state"] intValue];
        
        if (state != MCSessionStateConnecting) {
            if (state == MCSessionStateConnected) {
                [self.yrarrayConnectedDevices addObject:peerDisplayName];
            }
            else if (state == MCSessionStateNotConnected){
                if ([self.yrarrayConnectedDevices count] > 0) {
                    unsigned long indexOfPeer = [self.yrarrayConnectedDevices indexOfObject:peerDisplayName];
                    [self.yrarrayConnectedDevices removeObjectAtIndex:indexOfPeer];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.yrtableView reloadData];
                
                BOOL peersNotExist = ([[[[self.appDelegate mcManager] session] connectedPeers] count] == 0);
                [self.yrdisconnectButton setEnabled:!peersNotExist];
            });
        }
    });
}

-(void)needUpdateCodeNotification:(NSNotification *)notification
{
    NSMutableString *code = [[notification userInfo] objectForKey:@"recruitID"];
    self.yrIDCode = code;
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

@end
