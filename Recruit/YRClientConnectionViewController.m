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
#import "Interviewer.h"

@interface YRClientConnectionViewController ()

@property (nonatomic, strong) NSMutableArray *yrarrayConnectedDevices;

-(void)peerDidChangeStateWithNotification:(NSNotification *)notification;
-(void)needUpdateCodeNotification:(NSNotification *)notification;
-(void)popUpNameListNotification:(NSNotification*)notification;
-(void)removeNameListNotification:(NSNotification *)notification;
-(void)reconnectNotification:(NSNotification *)notification;
-(void)removeListView;

@end

@implementation YRClientConnectionViewController

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnectNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    self.yrarrayConnectedDevices = [[NSMutableArray alloc] init];
    self.yrIDCode = [NSMutableString new];
    
    
    [self.yrtableView setDelegate:self];
    [self.yrtableView setDataSource:self];
    [self.yrbrowseButton setHidden:YES];//this button is no longer needed
    
    
    //reset session and make the connect
    [self.appDelegate.mcManager.session disconnect];
    self.appDelegate.mcManager.session = nil;
    self.appDelegate.mcManager.autoBrowser = nil;
    self.appDelegate.mcManager.peerID = nil;
    [self.yrarrayConnectedDevices removeAllObjects];
    [self.appDelegate.dataManager stopListeningForData];
    [self.yrtableView reloadData];
    
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
}

- (void)viewWillAppear:(BOOL)animated
{
    self.clientUserName = [self.appDelegate.mcManager userName];
    [self.yrnameLabel setText:self.clientUserName];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)browseForDevices:(id)sender {
    
    [[self.appDelegate mcManager].session disconnect];
    [self.appDelegate mcManager].session = nil;
    [self.appDelegate mcManager].peerID = nil;
    [self.yrarrayConnectedDevices removeAllObjects];
    [self.appDelegate.dataManager stopListeningForData];
    [self.yrtableView reloadData];

    
    [[self.appDelegate mcManager] setHost:NO];//set host identity first, in order to initialize the session
    [[self.appDelegate mcManager] setupPeerAndSessionWithDisplayName:self.clientUserName];
    [[self.appDelegate mcManager] setupMCBrowser];
    
    [[[self.appDelegate mcManager] browser] setDelegate:self];
    [self presentViewController:[[self.appDelegate mcManager] browser] animated:YES completion:nil];
    
    if ([self.appDelegate dataManager] == nil) {
        [self.appDelegate setDataManager:[YRDataManager new]];
    }
    [[self.appDelegate dataManager] setHost:NO];
    [[self.appDelegate dataManager] startListeningForData];
    
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
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.yrtableView reloadData];
            
            BOOL peersNotExist = ([[[[self.appDelegate mcManager] session] connectedPeers] count] == 0);
            [self.yrdisconnectButton setEnabled:!peersNotExist];
        });
    }
}

-(void)needUpdateCodeNotification:(NSNotification *)notification
{
    NSMutableString *code = [[notification userInfo] objectForKey:@"recruitID"];
    self.yrIDCode = code;
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
    [self.yrnameLabel setText:self.appDelegate.mcManager.userName];
    [self.yrNameListView removeFromSuperview];
}

-(void)reconnectNotification:(NSNotification *)notification
{
    [self.appDelegate.mcManager.session disconnect];
    self.appDelegate.mcManager.session = nil;
    self.appDelegate.mcManager.autoBrowser = nil;
    self.appDelegate.mcManager.peerID = nil;
    [self.yrarrayConnectedDevices removeAllObjects];
    [self.appDelegate.dataManager stopListeningForData];
    [self.yrtableView reloadData];
    
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
}

-(void)removeListView
{
    [self.yrNameListView removeFromSuperview];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Note" message:@"If you can't find your name on the list, please contact the coordinator soon." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
    [self.tabBarController setSelectedViewController:[self.tabBarController.viewControllers objectAtIndex:1]];
}

#pragma mark - MCBrowserViewControllerDelegate

-(void)browserViewControllerDidFinish:(MCBrowserViewController *)browserViewController{
    [[self.appDelegate mcManager].browser dismissViewControllerAnimated:YES completion:nil];

    UILabel* titleLabel;
    UIButton* cancelButton;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.yrNameListView = [[UIView alloc] initWithFrame:CGRectMake(50, 100, 220, 300)];
        self.yrNameList = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, 220, 250) style:UITableViewStylePlain];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 180, 30)];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
        cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.yrNameListView.frame.size.width-30, 0, 30, 30)];
       
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.yrNameListView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-250, 250, 500, 600)];
        self.yrNameList = [[UITableView alloc] initWithFrame:CGRectMake(5, 40, 490, 555) style:UITableViewStylePlain];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 460, 70)];
        titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 30];
        cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.yrNameListView.frame.size.width-50, 0, 50, 50)];
    }
    [[self.yrNameListView layer] setCornerRadius:12];
    [[self.yrNameList layer] setCornerRadius:10];
    
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
    [[self.yrNameListView layer] setCornerRadius:20];
    [[self.yrNameListView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.yrNameListView layer] setBorderWidth:2];
    self.yrNameListView.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.yrNameListView];
}

-(void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController{
    [[self.appDelegate mcManager].browser dismissViewControllerAnimated:YES completion:nil];
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
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    //
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (tableView == self.yrtableView) {
        return [self.yrarrayConnectedDevices count];
    }
    else
    {
        return [self.appDelegate.dataManager.nameList count];
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (tableView == self.yrtableView)
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CellIdentifier"];
    
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"CellIdentifier"];
        }
    
        cell.textLabel.text = [self.yrarrayConnectedDevices objectAtIndex:indexPath.row][@"confirmedName"];
    
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nameListCell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"nameListCell"];
        }
        NSDictionary* current = [self.appDelegate.dataManager.nameList objectAtIndex:indexPath.row];
        
        cell.textLabel.text = current[@"name"];
        cell.detailTextLabel.text = current[@"email"];
        return cell;
    }
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
        
        [self.yrnameLabel setText:self.appDelegate.mcManager.userName];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"removeNameListNotification" object:nil];
        
        [self.tabBarController setSelectedViewController:[self.tabBarController.viewControllers objectAtIndex:1]];
    }
}

@end
