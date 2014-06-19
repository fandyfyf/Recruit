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
-(void)removeListView;

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

- (void)viewWillAppear:(BOOL)animated
{
    self.clientUserName = [[NSUserDefaults standardUserDefaults] valueForKey:@"userName"];
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
    [self.yrarrayConnectedDevices removeAllObjects];
    
    [self.appDelegate.dataManager stopListeningForData];
    
    [self.yrtableView reloadData];

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
}

-(void)needUpdateCodeNotification:(NSNotification *)notification
{
    NSMutableString *code = [[notification userInfo] objectForKey:@"recruitID"];
    self.yrIDCode = code;
}

-(void)removeListView
{
    [self.yrNameListView removeFromSuperview];
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Note" message:@"If you can't find your name on the list, please contact the coordinator soon." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    [alert show];
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
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.yrNameListView.frame.size.width-30, 0, 30, 30)];
       
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.yrNameListView = [[UIView alloc] initWithFrame:CGRectMake(150, 250, 468, 600)];
        self.yrNameList = [[UITableView alloc] initWithFrame:CGRectMake(0, 100, 468, 500) style:UITableViewStylePlain];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 428, 70)];
        titleLabel.font = [UIFont boldSystemFontOfSize:30];
        cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(self.yrNameListView.frame.size.width-50, 0, 50, 50)];
    }
    
    [cancelButton addTarget:self action:@selector(removeListView) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setTitle:@"X" forState:UIControlStateNormal];
    cancelButton.titleLabel.textColor = [UIColor redColor];
    
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
    
        cell.textLabel.text = [self.yrarrayConnectedDevices objectAtIndex:indexPath.row];
    
        return cell;
    }
    else
    {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"nameListCell"];
        
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"nameListCell"];
        }
        
        cell.textLabel.text = [self.appDelegate.dataManager.nameList objectAtIndex:indexPath.row][@"name"];
        cell.detailTextLabel.text = [self.appDelegate.dataManager.nameList objectAtIndex:indexPath.row][@"email"];
        
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
        [[NSUserDefaults standardUserDefaults] setValue:self.appDelegate.dataManager.nameList[indexPath.row][@"name"] forKey:@"userName"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.yrNameListView removeFromSuperview];
        
        [self.yrnameLabel setText:self.appDelegate.dataManager.nameList[indexPath.row][@"name"]];
    }
}

@end
