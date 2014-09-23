//
//  YRMCManager.m
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRAppDelegate.h"

//NSString* const kYRMCManagerDidChangeStateNotification = @"DidChangeStateNotification";

NSString* const kYRMCManagerNeedUpdateConnectionListNotification = @"MCManagerNeedUpdateConnectionListNotification";
NSString* const kYRMCManagerDidReceiveDataNotification = @"DidReceiveDataNotification";

@implementation YRMCManager

-(id)init{
    self = [super init];
    
    if (self) {
        _peerID = nil;
        _session = nil;
        _activeSessions = nil;
        _connectedDevices = nil;
        _autoBrowser = nil;
        _Nadvertiser = nil;
//property
        _userEmail = nil;
        _userName = nil;
//status
        _browsing = NO;
        _advertising = NO;
        _debriefing = NO;
    }
    return self;
}


-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName
{
    self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    //set up array of connected devices
    self.connectedDevices = [[NSMutableArray alloc] init];
    
    //clients only have one session
    if (!self.isHost) {
        self.session = [[MCSession alloc] initWithPeer:self.peerID];
        self.session.delegate = self;
    }
    //host have array of session
    else
    {
        if (self.activeSessions == nil) {
            self.activeSessions = [NSMutableArray new];
        }
        [self.activeSessions removeAllObjects];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateConnectionListNotification:) name:kYRDataManagerNeedUpdateConnectionListNotification object:nil];
    }
}

-(void)setupMCBrowser
{
    //the service type should be limited to 1 to 15 characters long
    self.autoBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer:self.peerID serviceType:@"files"];
}

-(void)advertiseSelf:(BOOL)shouldAdvertise
{
    if (shouldAdvertise) {
        NSLog(@"advertising...");
        self.Nadvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer:self.peerID discoveryInfo:nil serviceType:@"files"];
        [self.Nadvertiser setDelegate:self];
        [self.Nadvertiser startAdvertisingPeer];
    }
    else{
        NSLog(@"stop advertising...");
        [self.Nadvertiser stopAdvertisingPeer];
        self.Nadvertiser = nil;
    }
}

-(void)setupSessionManagerForHost:(BOOL)isHost
{
    //set up session with host username
    [self setHost:isHost];
    [self setupPeerAndSessionWithDisplayName:self.userName];
    
    if (!self.isHost)
    {
        [self setupMCBrowser];
        self.autoBrowser.delegate = self;
        [self.autoBrowser startBrowsingForPeers];
        [self setBrowsing:YES];
    }
    else
    {
        //browser is not needed for host
    }
}

-(void)needUpdateConnectionListNotification:(NSNotification*)notification
{
    NSString* displayName = [[notification userInfo] objectForKey:@"displayName"];
    
    for (unsigned long i = 0; i < [self.connectedDevices count] ; i++) {
        if ([[self.connectedDevices objectAtIndex:i][@"displayName"] isEqualToString:displayName]) {
            [self.connectedDevices replaceObjectAtIndex:i withObject:[notification userInfo]];
            
            NSLog(@"%@ connected",[self.connectedDevices objectAtIndex:i][@"confirmedName"]);
            break;
        }
    }
    
    //update table here!!
    [[NSNotificationCenter defaultCenter] postNotificationName:kYRMCManagerNeedUpdateConnectionListNotification object:nil];
}

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    //NSLog(@"Invitation received");
    NSMutableArray* deletedSession = [NSMutableArray new];
    
    for (int i=0; i< [self.activeSessions count] ;i++)
    {
        if ([[(MCPeerID*)[self.activeSessions objectAtIndex:i][@"peer"] displayName] isEqualToString:peerID.displayName]) {
            [deletedSession addObject:[NSNumber numberWithInt:i]];
            //disconnect the session first before deleting them
            [(MCSession*)[self.activeSessions objectAtIndex:i][@"session"] disconnect];
        }
    }
    
    for (NSNumber* index in deletedSession) {
        [self.activeSessions removeObjectAtIndex:[index intValue]];
    }
    
    NSMutableArray* deletedDevice = [NSMutableArray new];
    
    for (int i = 0; i< [self.connectedDevices count]; i++) {
        if ([[self.connectedDevices objectAtIndex:i][@"displayName"] isEqualToString:peerID.displayName]) {
            [deletedDevice addObject:[NSNumber numberWithInt:i]];
        }
    }
    
    for (NSNumber* index in deletedDevice) {
        [self.connectedDevices removeObjectAtIndex:[index intValue]];
    }
    
    MCSession *newSession = [[MCSession alloc] initWithPeer: self.peerID];
    newSession.delegate = self;
    
    NSDictionary *peerSession = @{@"peer" : peerID, @"session" : newSession};
    
    //accept the invitation using the new session
    invitationHandler(YES, newSession);
    
    [self.activeSessions addObject:peerSession];
    NSLog(@"new session created for peer : %@",peerID.displayName);
}

#pragma mark - MCNearByServiceBrowserDelegate

-(void)browser:(MCNearbyServiceBrowser *)browser foundPeer:(MCPeerID *)peerID withDiscoveryInfo:(NSDictionary *)info
{
    NSString *remotePeerName = peerID.displayName;
    
    NSLog(@"Browser found %@", remotePeerName);
    NSLog(@"Inviting %@", remotePeerName);
    
    //create new session
    self.session = [[MCSession alloc] initWithPeer:self.peerID];
    self.session.delegate = self;
    
    
    //since the host will be the only one we advertise, so there are only one
    [browser invitePeer:peerID toSession:self.session withContext:nil timeout:30.0];
    
    [browser stopBrowsingForPeers];
    [self setBrowsing:NO];
}

- (void)browser:(MCNearbyServiceBrowser *)browser lostPeer:(MCPeerID *)peerID
{
    //
}

#pragma mark - MCSessionDelegate

//MCSessionStateConnected
//MCSessionStateNotConnected
//MCSessionStateConnecting

-(void)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL))certificateHandler
{
    certificateHandler(YES);
}

-(void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state{
    //new connection happen
    if (self.isHost) {
        if (state != MCSessionStateConnecting) {
            if (state == MCSessionStateConnected) {
                
                [self.connectedDevices addObject:@{@"displayName" : peerID.displayName, @"confirmedName" : @"connnecting..."}];
                
                NSLog(@"%@ connecting...",peerID.displayName);
                
                //send ACK back
                [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] dataManager] sendACKBack:peerID];
                [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] dataManager] sendNameList:peerID];
            }
            else if (state == MCSessionStateNotConnected){
                if ([self.connectedDevices count] > 0) {
                    unsigned long indexOfPeer = 0;
                    for (unsigned long i = 0; i < [self.connectedDevices count] ; i++) {
                        if ([[self.connectedDevices objectAtIndex:i][@"displayName"] isEqualToString:peerID.displayName]) {
                            indexOfPeer = i;
                            break;
                        }
                    }
                    NSLog(@"%@ disconnected",[self.connectedDevices objectAtIndex:indexOfPeer][@"confirmedName"]);
                    
                    [self.connectedDevices removeObjectAtIndex:indexOfPeer];
                }
            }
            else
            {
                NSLog(@"missing state");
            }
            
            //reload table notification
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRMCManagerNeedUpdateConnectionListNotification object:nil];
        }
        else
        {
            NSLog(@"is connecting");
        }
    }
    else
    {
        if (state != MCSessionStateConnecting) {
            if (state == MCSessionStateConnected) {
                [self.connectedDevices addObject:@{@"displayName" : peerID.displayName, @"confirmedName" : @"connnecting..."}];
            }
            else if (state == MCSessionStateNotConnected){
                if ([self.connectedDevices count] > 0) {
                    unsigned long indexOfPeer = 0;
                    for (unsigned long i = 0; i < [self.connectedDevices count] ; i++) {
                        if ([[self.connectedDevices objectAtIndex:i][@"displayName"] isEqualToString:peerID.displayName]) {
                            indexOfPeer = i;
                            break;
                        }
                    }
                    [self.connectedDevices removeObjectAtIndex:indexOfPeer];
                    //if the connection drops during the debrief mode then browse for Host
                    
                    if (self.isDebriefing) {
                        [self.autoBrowser startBrowsingForPeers];
                        [self setBrowsing:YES];
                    }
                }
            }
        }
    }
}

//message data arrives from one of the peer
-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID
                           };
    
    //notify dataManager
    
    //TODO: if the data is identityConfirm, then there is no need to send to dataManager
    [[NSNotificationCenter defaultCenter] postNotificationName:kYRMCManagerDidReceiveDataNotification
                                                        object:nil
                                                      userInfo:dict];
}


-(void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress{
    
}


-(void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error{
    
}


-(void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID{
    
}

@end
