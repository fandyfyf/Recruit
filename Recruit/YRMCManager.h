//
//  YRMCManager.h
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MultipeerConnectivity/MultipeerConnectivity.h"

FOUNDATION_EXPORT NSString* const kYRMCManagerDidChangeStateNotification;
FOUNDATION_EXPORT NSString* const kYRMCManagerDidReceiveDataNotification;

@interface YRMCManager : NSObject <MCSessionDelegate, MCAdvertiserAssistantDelegate, MCNearbyServiceAdvertiserDelegate>

@property (strong, nonatomic) MCPeerID *peerID;
@property (strong, nonatomic) MCPeerID *lastConnectionPeerID;
@property (strong, nonatomic) MCSession *session;
@property (strong, nonatomic) NSMutableArray *activeSessions;
@property (strong, nonatomic) MCNearbyServiceBrowser *autoBrowser;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *Nadvertiser;
@property (assign, getter = isHost) BOOL host;
@property (assign, getter = isBrowsing) BOOL browsing;
@property (assign, getter = isAdvertising) BOOL advertising;
@property (assign, getter = isDebriefing) BOOL debriefing;

@property (nonatomic, copy) NSString* userName;
@property (nonatomic, copy) NSString* userEmail;

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
-(void)setupMCBrowser;
-(void)advertiseSelf:(BOOL)shouldAdvertise;

@end
