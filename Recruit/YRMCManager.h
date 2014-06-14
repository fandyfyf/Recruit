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
@property (strong, nonatomic) MCBrowserViewController *browser;
//@property (strong, nonatomic) MCAdvertiserAssistant *advertiser;
@property (strong, nonatomic) MCNearbyServiceAdvertiser *Nadvertiser;
@property (assign, getter = isHost) BOOL host;

-(void)setupPeerAndSessionWithDisplayName:(NSString *)displayName;
-(void)setupMCBrowser;
-(void)advertiseSelf:(BOOL)shouldAdvertise;

@end
