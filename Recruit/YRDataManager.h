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

@property (strong,nonatomic) NSDictionary* localBackUp;
@property (strong,nonatomic) NSMutableArray* nameList;

-(id) init;

-(id) initWithPrefix:(NSString*)prefix;

-(void)didReceiveDataWithNotification:(NSNotification *)notification;

- (BOOL)isNotDuplicateData:(NSDictionary*)infoData;

-(CandidateEntry*)saveCandidate:(NSDictionary *)infoData;

-(void)sendACKBack:(MCPeerID*)peerID;

-(void)sendData:(NSDictionary*)data;

-(void)sendNameList:(MCPeerID*)peerID;

-(void)sendBackUp:(NSDictionary* )localBackUp;

-(int) nextCode;

- (void)startListeningForData;

- (void)stopListeningForData;



@end
