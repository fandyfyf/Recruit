//
//  YRMCManager.m
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRMCManager.h"

NSString* const kYRMCManagerDidChangeStateNotification = @"DidChangeStateNotification";
NSString* const kYRMCManagerDidReceiveDataNotification = @"DidReceiveDataNotification";

@implementation YRMCManager

-(id)init{
    self = [super init];
    
    if (self) {
        _peerID = nil;
        _session = nil;
        _autoBrowser = nil;
        _activeSessions = nil;
        _Nadvertiser = nil;
        _userEmail = nil;
        _userName = nil;
        _browsing = NO;
        _advertising = NO;
        _debriefing = NO;
    }
    return self;
}


-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName
{
    //set peer with provided string
    self.peerID = [[MCPeerID alloc] initWithDisplayName:displayName];
    
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

#pragma mark - MCNearbyServiceAdvertiserDelegate

- (void)advertiser:(MCNearbyServiceAdvertiser *)advertiser didReceiveInvitationFromPeer:(MCPeerID *)peerID withContext:(NSData *)context invitationHandler:(void(^)(BOOL accept, MCSession *session))invitationHandler
{
    //NSLog(@"Invitation received");
    
    MCSession *newSession = [[MCSession alloc] initWithPeer: self.peerID];
    newSession.delegate = self;
    
    NSDictionary *peerSession = @{@"peer" : peerID, @"session" : newSession};
    
    //accept the invitation using the new session
    invitationHandler(YES, newSession);
    
    [self.activeSessions addObject:peerSession];
    
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
    //new connection take place
    NSDictionary *dict = @{@"peerID": peerID,
                           @"state" : [NSNumber numberWithInt:state]
                           };
    NSLog(@"State: %ld",state);
    [[NSNotificationCenter defaultCenter] postNotificationName:kYRMCManagerDidChangeStateNotification
                                                        object:nil
                                                      userInfo:dict];
}

//message data arrives from one of the peer
-(void)session:(MCSession *)session didReceiveData:(NSData *)data fromPeer:(MCPeerID *)peerID{
    NSDictionary *dict = @{@"data": data,
                           @"peerID": peerID
                           };
    //NSLog(@"receive data once!! with %@; I AM %@",dict, self);
    NSLog(@"I AM %@",self);
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
