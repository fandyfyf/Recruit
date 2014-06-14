//
//  YRDataManager.h
//  Recruit
//
//  Created by Yifan Fu on 6/11/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "CandidateEntry.h"

@interface YRDataManager : NSObject


//@property (strong, nonatomic) YRAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString  *yrPrefix;
@property (assign) int counter;
@property (assign, getter = isHost) BOOL host;

-(id) init;

-(id) initWithPrefix:(NSString*)prefix;

-(void)didReceiveDataWithNotification:(NSNotification *)notification;

-(CandidateEntry*)saveCandidate:(NSDictionary *)infoData;

-(void)sendACKBack:(MCPeerID*)peerID;

-(void)sendData:(NSDictionary*)data;

-(int) nextCode;

- (void)startListeningForData;

- (void)stopListeningForData;

@end
