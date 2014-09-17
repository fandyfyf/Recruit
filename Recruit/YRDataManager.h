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

FOUNDATION_EXPORT NSString* const kYRDataManagerReceiveBroadcastNotification;
FOUNDATION_EXPORT NSString* const kYRDataManagerReceiveResumeNotification;
FOUNDATION_EXPORT NSString* const kYRDataManagerReceiveTagListNotification;
FOUNDATION_EXPORT NSString* const kYRDataManagerReceiveSearchResultNotification;
FOUNDATION_EXPORT NSString* const kYRDataManagerReceiveDebriefTerminationNotification;
FOUNDATION_EXPORT NSString* const kYRDataManagerReceiveDebriefInitiationNotification;

FOUNDATION_EXPORT NSString* const kYRDataManagerNeedUpdateTableNotification;
FOUNDATION_EXPORT NSString* const kYRDataManagerNeedStartBroadcastNotification;
FOUNDATION_EXPORT NSString* const kYRDataManagerNeedUpdateTagInfoNotification;
FOUNDATION_EXPORT NSString* const kYRDataManagerNeedUpdateCodeNotification;
FOUNDATION_EXPORT NSString* const kYRDataManagerNeedUpdateConnectionListNotification;
FOUNDATION_EXPORT NSString* const kYRDataManagerNeedPromptNameListNotification;

@interface YRDataManager : NSObject <UIAlertViewDelegate>


//@property (strong, nonatomic) YRAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSString  *yrPrefix;
@property (assign) int counter;
@property (assign, getter = isHost) BOOL host;
@property (strong,nonatomic) NSMutableArray* nameList;

@property (assign) int debug_counter;

-(id) init;

-(id) initWithPrefix:(NSString*)prefix;

-(void)didReceiveDataWithNotification:(NSNotification *)notification;

- (BOOL)isNotDuplicateData:(NSDictionary*)infoData;

-(CandidateEntry*)saveCandidate:(NSDictionary *)infoData;

-(CandidateEntry*)queuingLocalCandidate:(NSDictionary *)infoData;

-(NSError*)sendToHostWithData:(NSDictionary*)data;

-(void)sendToALLClientsWithData:(NSDictionary*)data;

-(void)sendACKBack:(MCPeerID*)peerID;

-(void)sendData:(NSDictionary*)data;

-(void)broadCastData:(NSDictionary*)data;

-(NSError*)sendDataRequestForFile:(NSString*)fileName;

-(void)pullData;

-(void)sendResume:(NSDictionary*)data toPeer:(MCPeerID*)peer;

-(void)sendNameList:(MCPeerID*)peerID;

-(void)sendIdentityConfirmation:(NSString*)updateUserName;

-(void)sendDebriefTermination;

-(void)sendDebriefInvitationToPeer:(MCPeerID*)peer;

-(void)sendDebriefInvitation;

-(NSError*)sendSearchQuery:(NSDictionary*)dic;

-(void)sendSearchResult:(NSArray*)array toPeer:(MCPeerID*)peer;

-(void)sendTagListRequest:(NSString*)interviewerName;

-(void)sendTagList:(NSDictionary*)data toPeer:(MCPeerID*)peer;

-(NSError*)tagCandidate:(NSString*)ID withOption:(NSString*)option from:(NSString*)interviewer;

-(void)sendBackUp:(NSDictionary* )localBackUp;

-(int) nextCode;

- (void)startListeningForData;

- (void)stopListeningForData;

//debug mode function//
-(void)debugSenderActiveWithCode:(NSString*)rid;

@end
