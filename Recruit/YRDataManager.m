//
//  YRDataManager.m
//  Recruit
//
//  Created by Yifan Fu on 6/11/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRDataManager.h"
#import "YRAppDelegate.h"
#import "YRMCManager.h"
#import "Interviewer.h"



//=========verified notification========

//=========observer: YRDataViewController
NSString* const kYRDataManagerNeedUpdateTableNotification = @"NeedUpdateTableNotification";

//=========observer: YRMCManager
NSString* const kYRDataManagerNeedUpdateConnectionListNotification = @"NeedUpdateConnectionListNotification";

//=========observer: YRClientSignIn & YRFormView
NSString* const kYRDataManagerNeedPromptNameListNotification = @"NameListReadyNotification";

//=========observer: YRClientSignIn & YRFormView
NSString* const kYRDataManagerNeedUpdateCodeNotification = @"NeedUpdateCodeNotification";



NSString* const kYRDataManagerReceiveBroadcastNotification = @"receiveBroadcastNotification";
NSString* const kYRDataManagerReceiveResumeNotification = @"receiveResumeNotification";
NSString* const kYRDataManagerReceiveTagListNotification = @"receiveTagListNotification";
NSString* const kYRDataManagerReceiveSearchResultNotification = @"receiveSearchResultNotification";
NSString* const kYRDataManagerReceiveDebriefTerminationNotification = @"debriefModeOffNotification";
NSString* const kYRDataManagerReceiveDebriefInitiationNotification = @"debriefModeOnNotification";
NSString* const kYRDataManagerNeedStartBroadcastNotification = @"broadcastNotification";
NSString* const kYRDataManagerNeedUpdateTagInfoNotification = @"needUpdateTagInformationNotification";




@implementation YRDataManager

-(id) init{
    self = [super init];
    
    if (self) {
        _managedObjectContext = [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
        _debug_counter = 100;
    }
    return self;
}

- (void)startListeningForData{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveDataWithNotification:) name:kYRMCManagerDidReceiveDataNotification object:nil];
}

- (void)stopListeningForData{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(id) initWithPrefix:(NSString*)prefix
{
    self = [self init];
    
    if (self) {
        _yrPrefix = prefix;
        if ([[NSUserDefaults standardUserDefaults] valueForKey:@"codeIndex"] == nil) {
            _counter = 0;
            //initialize code Index in userdefault
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:_counter] forKey:@"codeIndex"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        else
        {
            _counter = [[[NSUserDefaults standardUserDefaults] valueForKey:@"codeIndex"] intValue];
        }
    }
    
    return self;
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
        
        NSData* yrinfoData = [[notification userInfo] objectForKey:@"data"];
        
        NSKeyedUnarchiver* yrunarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:yrinfoData];
        
        NSMutableDictionary *dic = [[yrunarchiver decodeObjectForKey:@"infoDataKey"] mutableCopy];
        
        [yrunarchiver finishDecoding];
        
        //NSLog(@"message is %@; I AM %@",dic[@"msg"], self);
        
        
        if([dic[@"msg"] isEqualToString:@"data"] && self.isHost)
        {
            if ([self isNotDuplicateData:dic[@"data"]]){
                [self sendACKBack:peerID];
                
                CandidateEntry* curr = [self saveCandidate:dic[@"data"]];
                NSDictionary *dict = @{@"entry" : curr};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerNeedUpdateTableNotification object:nil userInfo:dict];
            }
            else
            {
                [self sendACKBack:peerID];
                NSLog(@"duplicate code and firstName found");
            }
        }
        else if ([dic[@"msg"] isEqualToString:@"backup"] && self.isHost)
        {
            if ([self isNotDuplicateData:dic[@"data"]]) {
                CandidateEntry* curr = [self saveCandidate:dic[@"data"]];
                NSDictionary *dict = @{@"entry" : curr};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerNeedUpdateTableNotification
                                                                    object:nil
                                                                  userInfo:dict];
            }
            else
            {
                NSLog(@"duplicate code and firstName found");
            }
        }
        else if([dic[@"msg"] isEqualToString:@"ack"])
        {
            [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].lastConnectionPeerID = dic[@"source"];
            NSDictionary *dict = @{@"recruitID": dic[@"code"]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerNeedUpdateCodeNotification object:nil userInfo:dict];
//#if Debug
            //==================================debug========================================//
//            [self debugSenderActiveWithCode:dic[@"code"]];
            //===============================================================================//
//#endif
        }
        else if([dic[@"msg"] isEqualToString:@"nameList"])
        {
            NSLog(@"The receiving list is %@",dic[@"data"]);
            self.nameList = dic[@"data"];
            
            BOOL signIn = [[[NSUserDefaults standardUserDefaults] valueForKey:@"SignedInAlready"] boolValue];
            
            if (signIn) {
                [self sendIdentityConfirmation:[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].userName];
                
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
                NSError* error = nil;
                NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                
                for (CandidateEntry* backedUpCandidate in FetchResults)
                {
                    NSDictionary* dic = @{@"firstName":backedUpCandidate.firstName,@"lastName":backedUpCandidate.lastName,@"email":backedUpCandidate.emailAddress,@"interviewer":[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].userName,@"code":backedUpCandidate.code,@"status":backedUpCandidate.status,@"pdf":backedUpCandidate.pdf,@"position":backedUpCandidate.position,@"preference":backedUpCandidate.preference,@"date":backedUpCandidate.date,@"note":backedUpCandidate.notes,@"rank":[backedUpCandidate.rank stringValue],@"gpa":[backedUpCandidate.gpa stringValue],@"tagList":[backedUpCandidate tagList]};
                    NSDictionary* packet = @{@"msg" : @"backup", @"data":dic};
                    [self sendBackUp:packet];
                    NSLog(@"sending one entry");
                }
                
                //reset the core data
                for (CandidateEntry* backedUpCandidate in FetchResults)
                {
                    [self.managedObjectContext deleteObject:backedUpCandidate];
                    NSLog(@"deleting one coredata entry");
                }
                
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"ERROR -- saving coredata");
                }
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"renewQueuingNotification" object:nil];
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"SignedInAlready"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerNeedPromptNameListNotification object:nil userInfo:nil];
            }
        }
        else if([dic[@"msg"] isEqualToString:@"identityConfirm"] && self.isHost)
        {
            NSLog(@"Receiving confirmed name : %@",dic[@"data"]);
            
            NSDictionary* dict = @{@"displayName": peerID.displayName, @"confirmedName" : dic[@"data"]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerNeedUpdateConnectionListNotification object:nil userInfo:dict];
            
            //===================send to new connected user====================//
            if ([(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].isDebriefing) {
                [self sendDebriefInvitationToPeer:peerID];
            }
            //=================================================================//
        }
        //========================Debrif message ==========================//
        else if([dic[@"msg"] isEqualToString:@"broadcast"] && !self.isHost)
        {
            //receive debrief invitation
            NSLog(@"receiving one broadcast entry");
            //post notification to observers
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerReceiveBroadcastNotification object:nil userInfo:dic[@"data"]];
        }
        else if([dic[@"msg"] isEqualToString:@"resumeRequest"] && self.isHost)
        {
            NSLog(@"receiving one resume request");
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
            
            NSError *error;
            if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
            
            NSString* fileName = dic[@"data"];
            
            NSString *fullPath = [dataPath stringByAppendingPathComponent:fileName];
            
            NSDictionary* dic = @{@"msg" : @"resume" , @"data" : [NSData dataWithContentsOfFile:fullPath]};
            
            [self sendResume:dic toPeer:peerID];
            
        }
        else if([dic[@"msg"] isEqualToString:@"resume"])
        {
            NSLog(@"receiving one resume");
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerReceiveResumeNotification object:nil userInfo:dic[@"data"]];
        }
        else if([dic[@"msg"] isEqualToString:@"debriefInvitation"] && !self.isHost)
        {
            //receive debrief invitation
            NSLog(@"receiving debrief invitation");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Debrief Invitation" message:@"The host is starting a debrief session and your are invited!" delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
            [alert show];
            //send tagList request
            
            //[self sendTagListRequest:[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].userName];
        }
        else if([dic[@"msg"] isEqualToString:@"tagListRequest"] && self.isHost)
        {
            NSLog(@"receive tag list request from %@",dic[@"data"]);
            
            NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name = %@ && code = %@",dic[@"data"],[[NSUserDefaults standardUserDefaults] valueForKey:@"eventCode"]]];
            
            NSError* error = nil;
            NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            NSArray* tagList;
            if ([FetchResults count] != 0) {
                tagList = [(Interviewer*)FetchResults[0] tagList];
                NSDictionary* dic = @{@"msg" : @"tagList" , @"data" : tagList};
                
                [self sendTagList:dic toPeer:peerID];
            }
            else
            {
                NSLog(@"interviewer not found");
            }
        }
        else if([dic[@"msg"] isEqualToString:@"tagList"] && !self.isHost)
        {
            NSLog(@"receiving tag list %@",dic[@"data"]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerReceiveTagListNotification object:nil userInfo:dic[@"data"]];
        }
        else if([dic[@"msg"] isEqualToString:@"pullData"] && self.isHost)
        {
            //send notification broadcast
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerNeedStartBroadcastNotification object:nil];
        }
        else if([dic[@"msg"] isEqualToString:@"Flag"] && self.isHost)
        {
            NSLog(@"receiving tag request for Candidate %@ from %@",dic[@"data"],dic[@"viewer"]);
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@",dic[@"data"]]];
            NSError* error = nil;
            NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            NSFetchRequest *fetchRequest_I = [[NSFetchRequest alloc] init];
            [fetchRequest_I setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest_I setPredicate:[NSPredicate predicateWithFormat:@"name = %@ && code = %@",dic[@"viewer"],[[NSUserDefaults standardUserDefaults] valueForKey:@"eventCode"]]];
            NSArray* FetchResults_I = [self.managedObjectContext executeFetchRequest:fetchRequest_I error:&error];
            
            if ([FetchResults count] != 0 && [FetchResults_I count] != 0) {
                CandidateEntry* selected = FetchResults[0];
                
                //add to tag list
                NSMutableArray* tagList = [selected.tagList mutableCopy];
                [tagList addObject:dic[@"viewer"]];
                [selected setTagList:[NSArray arrayWithArray:tagList]];
                
                Interviewer* selected_I = FetchResults_I[0];
                NSMutableArray* tagList_I = [selected_I.tagList mutableCopy];
                [tagList_I addObject:dic[@"data"]];
                [selected_I setTagList:[NSArray arrayWithArray:tagList_I]];
                //manage taglist for interviewer too
                //if connection failed then all the tag list will lost on client end.
                
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"ERROR -- saving coredata");
                }
                
                //update UI in detail View
                [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerNeedUpdateTagInfoNotification object:selected];
            }
            else
            {
                NSLog(@"target candidate not found");
            }
        }
        else if([dic[@"msg"] isEqualToString:@"unFlag"] && self.isHost)
        {
            NSLog(@"receiving untag request for Candidate %@ from %@",dic[@"data"],dic[@"viewer"]);
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@",dic[@"data"]]];
            NSError* error = nil;
            NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            NSFetchRequest *fetchRequest_I = [[NSFetchRequest alloc] init];
            [fetchRequest_I setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest_I setPredicate:[NSPredicate predicateWithFormat:@"name = %@ && code = %@",dic[@"viewer"],[[NSUserDefaults standardUserDefaults] valueForKey:@"eventCode"]]];
            
            NSArray* FetchResults_I = [self.managedObjectContext executeFetchRequest:fetchRequest_I error:&error];
            
            if ([FetchResults count] != 0  && [FetchResults_I count] != 0) {
                CandidateEntry* selected = FetchResults[0];
                
                //remove from tag list
                NSMutableArray* tagList = [selected.tagList mutableCopy];
                if ([tagList count] != 0) {
                    int index = -1;
                    for (int i=0; i<[tagList count]; i++) {
                        if ([[tagList objectAtIndex:i] isEqualToString:dic[@"viewer"]]) {
                            index = i;
                            break;
                        }
                    }
                    if (index >=0) {
                        [tagList removeObjectAtIndex:index];
                    }
                    [selected setTagList:[NSArray arrayWithArray:tagList]];
                }
                //manage taglist for interviewer too
                Interviewer* selected_I = FetchResults_I[0];
                
                NSMutableArray* tagList_I = [selected_I.tagList mutableCopy];
                if ([tagList_I count] != 0) {
                    int index = -1;
                    for (int i=0; i<[tagList_I count]; i++) {
                        if ([[tagList_I objectAtIndex:i] isEqualToString:dic[@"data"]]) {
                            index = i;
                            break;
                        }
                    }
                    if (index >=0) {
                        [tagList_I removeObjectAtIndex:index];
                    }
                    [selected_I setTagList:[NSArray arrayWithArray:tagList_I]];
                }
                
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"ERROR -- saving coredata");
                }
                
                //update UI in detail View
                [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerNeedUpdateTagInfoNotification object:selected];
            }
            else
            {
                NSLog(@"target candidate not found");
            }
        }
        else if ([dic[@"msg"] isEqualToString:@"searchQuery"] && self.isHost)
        {
            NSLog(@"receiving seach query %@",dic[@"data"]);
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"preference = %@ && rank >= %@ && position = %@",dic[@"data"][@"option"],dic[@"data"][@"ranking"],dic[@"data"][@"position"]]];
            NSError* error = nil;
            NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            NSMutableArray* dataToSend = [NSMutableArray new];
            
            for (CandidateEntry* result in FetchResults)
            {
                NSDictionary* dic = @{@"firstName":result.firstName,@"lastName":result.lastName,@"email":result.emailAddress,@"interviewer":result.interviewer,@"code":result.code,@"status":result.status,@"pdf":result.pdf,@"position":result.position,@"preference":result.preference,@"date":result.date,@"note":result.notes,@"rank":[result.rank stringValue],@"gpa":[result.gpa stringValue],@"tagList":[result tagList],@"fileNames":result.fileNames};
                [dataToSend addObject:dic];
            }
            
            [self sendSearchResult:[NSArray arrayWithArray:dataToSend] toPeer:peerID];
        }
        else if([dic[@"msg"] isEqualToString:@"searchResult"] && !self.isHost)
        {
            NSLog(@"receiving search result: %@",dic[@"data"]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerReceiveSearchResultNotification object:dic[@"data"]];
        }
        else if([dic[@"msg"] isEqualToString:@"debriefTermination"] && !self.isHost)
        {
            //receive debrief termination
            NSLog(@"receiving debrief termination");
            [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].debriefing = NO;
            
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Debrief Termination" message:@"The host is closing the session" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerReceiveDebriefTerminationNotification object:nil];
            //or post notification to observers
        }
        else
        {
            NSLog(@"trash");
        }
    });
}

- (BOOL)isNotDuplicateData:(NSDictionary*)infoData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@ and firstName = %@",infoData[@"code"],infoData[@"firstName"]]];
    
    NSError* error = nil;
    NSMutableArray* mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    if ([mutableFetchResults count] == 0) {
        return YES;
    }
    else
    {
        return NO;
    }
}

-(CandidateEntry*)saveCandidate:(NSDictionary *)infoData
{
    CandidateEntry* item = (CandidateEntry*)[NSEntityDescription insertNewObjectForEntityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext];
    [item setFirstName:infoData[@"firstName"]];
    [item setLastName:infoData[@"lastName"]];
    [item setEmailAddress:infoData[@"email"]];
    [item setInterviewer:infoData[@"interviewer"]];
    if ([infoData[@"code"] isEqualToString:@"Offline"]) {
        [item setCode:[NSString stringWithFormat:@"%@-%d",self.yrPrefix,[self nextCode]]];
    }
    else
    {
        [item setCode:infoData[@"code"]];
    }

    
    [item setStatus:infoData[@"status"]];
    [item setPdf:infoData[@"pdf"]];
    [item setFileNames:[NSArray new]];
    [item setPosition:infoData[@"position"]];
    [item setPreference:infoData[@"preference"]];
    [item setDate:infoData[@"date"]];
    [item setNotes:[(NSString*)infoData[@"note"] stringByAppendingString:[NSString stringWithFormat:@"\n\n#%@#\n\n",[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].userName]]];
    [item setRank:[NSNumber numberWithFloat:[(NSString*)infoData[@"rank"] floatValue]]];
    [item setGpa:[NSNumber numberWithFloat:[(NSString*)infoData[@"gpa"] floatValue]]];
    [item setBusinessUnit1:@""];
    [item setBusinessUnit2:@""];
    [item setResumeCounter:[NSNumber numberWithInt:0]];
    [item setYday1:@""];
    [item setYday2:@""];
    [item setApproved:[NSNumber numberWithBool:NO]];
    
    
    if ([infoData[@"tagList"] count] != 0) {
        
        [item setTagList:infoData[@"tagList"]];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name = %@ && code = %@",infoData[@"interviewer"],[[NSUserDefaults standardUserDefaults] valueForKey:@"eventCode"]]];
        
        NSError* error = nil;
        NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        if ([FetchResults count] != 0) {
            NSMutableArray* interviewerTagList = [[(Interviewer*)FetchResults[0] tagList] mutableCopy];
            [interviewerTagList addObject:item.code];
            //save new tagList
            [(Interviewer*)FetchResults[0] setTagList:[NSArray arrayWithArray:interviewerTagList]];
        }
        else
        {
            NSLog(@"Interviewer not found");
        }
    }
    else
    {
        [item setTagList:[NSArray new]];
    }
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"ERROR -- saving coredata");
    }
    
    return item;
}

-(CandidateEntry*)queuingLocalCandidate:(NSDictionary *)infoData
{
    CandidateEntry* item = (CandidateEntry*)[NSEntityDescription insertNewObjectForEntityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext];
    
    [item setFirstName:infoData[@"firstName"]];
    [item setLastName:infoData[@"lastName"]];
    [item setEmailAddress:infoData[@"email"]];
    [item setInterviewer:infoData[@"interviewer"]];
    [item setCode:infoData[@"code"]];
    [item setStatus:infoData[@"status"]];
    [item setPdf:infoData[@"pdf"]];
    [item setPosition:infoData[@"position"]];
    [item setPreference:infoData[@"preference"]];
    [item setDate:infoData[@"date"]];
    [item setNotes:infoData[@"note"]];
    [item setRank:[NSNumber numberWithFloat:[(NSString*)infoData[@"rank"] floatValue]]];
    [item setGpa:[NSNumber numberWithFloat:[(NSString*)infoData[@"gpa"] floatValue]]];
    [item setTagList:infoData[@"tagList"]];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"ERROR -- saving coredata");
    }
    return item;
}

-(NSError*)sendToHostWithData:(NSDictionary*)data
{
    NSMutableData* yrdataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:yrdataToSend];
    
    [yrarchiver encodeObject:data forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];
    
    NSArray * allPeers = [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].session.connectedPeers;
    
    //TODO: might also send the request to self, need to check
    
    NSError *error;
    
    [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].session sendData:yrdataToSend toPeers:allPeers withMode:MCSessionSendDataReliable error:&error];
    return error;
}

-(void)sendToPeer:(MCPeerID*)peer withData:(NSDictionary*)data
{
    //encode data
    NSMutableData* yrdataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:yrdataToSend];
    [yrarchiver encodeObject:data forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];
    
    for (NSDictionary* dic in [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].activeSessions) {
        
        if ([[(MCPeerID*)dic[@"peer"] displayName] isEqualToString:peer.displayName]) {
            NSArray * allPeers = [(MCSession*)dic[@"session"] connectedPeers];
            
            NSLog(@"peer count  %lu",(unsigned long)[allPeers count]);
            
            NSError *error;
            
            [(MCSession*)dic[@"session"] sendData:yrdataToSend toPeers:allPeers withMode:MCSessionSendDataReliable error:&error];
            
            if(error){
                NSLog(@"%@", [error localizedDescription]);
            }
            else
            {
                //
            }
        }
    }
}

-(void)sendToALLClientsWithData:(NSDictionary*)data
{
    NSMutableData* yrdataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:yrdataToSend];
    
    [yrarchiver encodeObject:data forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];
    
    for (NSDictionary* dic in [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].activeSessions) {
        NSArray * allPeers = [(MCSession*)dic[@"session"] connectedPeers];
        
        NSLog(@"peer count  %lu",(unsigned long)[allPeers count]);
        
        NSError *error;
        
        [(MCSession*)dic[@"session"] sendData:yrdataToSend toPeers:allPeers withMode:MCSessionSendDataReliable error:&error];
        
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        else
        {
            //
        }
    }
}

-(void)sendData:(NSDictionary*)data
{
    NSError* error = [self sendToHostWithData:data];
    
    if(error){
        NSLog(@"%@", [error localizedDescription]);
        
        //save the data in local core data
        [self queuingLocalCandidate:data[@"data"]];
        
        //send fail, no connection, restart browsing
        if (![(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].isBrowsing) {
            [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].autoBrowser startBrowsingForPeers];
            [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager] setBrowsing:YES];
        }
    }
}

-(void)broadCastData:(NSDictionary*)data
{
    [self sendToALLClientsWithData:data];
}

-(NSError*)sendDataRequestForFile:(NSString*)fileName
{
    NSDictionary* dic = @{@"msg" : @"resumeRequest", @"data" : fileName};
    
    NSError* error = [self sendToHostWithData:dic];
    
    return error;
    
//    if(error){
//        NSLog(@"%@", [error localizedDescription]);
//        
//        [[NSNotificationCenter defaultCenter] postNotificationName:@"connectionDropNotification" object:nil];
//    }
}

-(void)pullData
{
    NSDictionary* data = @{@"msg" : @"pullData"};
    
    NSError* error = [self sendToHostWithData:data];
    
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)sendResume:(NSDictionary*)data toPeer:(MCPeerID*)peer
{
    NSMutableData* yrdataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:yrdataToSend];
    
    [yrarchiver encodeObject:data forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];
    
    for (NSDictionary* dic in [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].activeSessions) {
        
        if ([[(MCPeerID*)dic[@"peer"] displayName] isEqualToString:peer.displayName]) {
            NSArray * allPeers = [(MCSession*)dic[@"session"] connectedPeers];
            
            NSLog(@"peer count  %lu",(unsigned long)[allPeers count]);
            
            NSError *error;
            
            [(MCSession*)dic[@"session"] sendData:yrdataToSend toPeers:allPeers withMode:MCSessionSendDataReliable error:&error];
            
            if(error){
                NSLog(@"%@", [error localizedDescription]);
            }
            else
            {
                //
            }
        }
    }
}

-(void)sendNameList:(MCPeerID*)peerID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@",self.yrPrefix]];
    
    NSError* error = nil;
    
    NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    NSMutableArray* currentList = [NSMutableArray new];
    
    NSArray* connectedList = [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].connectedDevices;
    
    for (Interviewer* curr in FetchResults) {
        BOOL check = NO;
        for (NSDictionary* connected in connectedList){
            if ([connected[@"confirmedName"] isEqualToString:curr.name]) {
                check = YES;
                break;
            }
        }
        if (check) {
            continue;
        }
        else
        {
            NSDictionary * dic = @{@"name" : curr.name, @"email" : curr.email};
            [currentList addObject:dic];
        }
    }
    
    NSDictionary* dic = @{@"msg" : @"nameList", @"data" : currentList};
    
    NSLog(@"sending name list");
    
    NSMutableData* dataToSend = [NSMutableData new];
    
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    
    [yrarchiver encodeObject:dic forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];
    
    MCSession * selectedSession;
    
    for (NSDictionary* dic in [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].activeSessions) {
        if ([[dic[@"peer"] displayName] isEqualToString:peerID.displayName]) {
            selectedSession = dic[@"session"];
        }
    }
    
    [selectedSession sendData:dataToSend toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
    if(error){
        NSLog(@"Error %@", [error localizedDescription]);
    }
}

-(void)sendIdentityConfirmation:(NSString*)updateUserName
{
    NSDictionary* dic = @{@"msg" : @"identityConfirm", @"data" : updateUserName};
    NSError* error = [self sendToHostWithData:dic];
    
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
    else
    {
            //
    }
}

-(void)sendDebriefTermination
{
    NSDictionary* dic = @{@"msg" : @"debriefTermination"};
    
    [self sendToALLClientsWithData:dic];
}

-(void)sendDebriefInvitationToPeer:(MCPeerID*)peer
{
    NSDictionary* dic = @{@"msg" : @"debriefInvitation"};
    
    NSMutableData* yrdataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:yrdataToSend];
    
    [yrarchiver encodeObject:dic forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];

    for (NSDictionary* dic in [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].activeSessions) {
        
        if ([[(MCPeerID*)dic[@"peer"] displayName] isEqualToString:peer.displayName]) {
            NSArray * allPeers = [(MCSession*)dic[@"session"] connectedPeers];
            
            NSLog(@"peer count  %lu",(unsigned long)[allPeers count]);
            
            NSError *error;
            
            [(MCSession*)dic[@"session"] sendData:yrdataToSend toPeers:allPeers withMode:MCSessionSendDataReliable error:&error];
            
            if(error){
                NSLog(@"%@", [error localizedDescription]);
            }
            else
            {
                //
            }
        }
    }
}

-(void)sendDebriefInvitation
{
    NSDictionary* dic = @{@"msg" : @"debriefInvitation"};
    
    [self sendToALLClientsWithData:dic];
}

-(NSError*)sendSearchQuery:(NSDictionary*)dic
{
    NSDictionary* data = @{@"msg" : @"searchQuery", @"data" : dic};
    NSError* error = [self sendToHostWithData:data];
    
    
    return error;
}

-(void)sendSearchResult:(NSArray*)array toPeer:(MCPeerID*)peer
{
    NSDictionary* data = @{@"msg" : @"searchResult", @"data" : array};
    NSMutableData* yrdataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:yrdataToSend];
    
    [yrarchiver encodeObject:data forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];
    
    for (NSDictionary* dic in [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].activeSessions) {
        
        if ([[(MCPeerID*)dic[@"peer"] displayName] isEqualToString:peer.displayName]) {
            NSArray * allPeers = [(MCSession*)dic[@"session"] connectedPeers];
            
            NSLog(@"peer count  %lu",(unsigned long)[allPeers count]);
            
            NSError *error;
            
            [(MCSession*)dic[@"session"] sendData:yrdataToSend toPeers:allPeers withMode:MCSessionSendDataReliable error:&error];
            
            if(error){
                NSLog(@"%@", [error localizedDescription]);
            }
            else
            {
                //after the search result are securely sent
                break;
            }
        }
    }
}

-(void)sendTagListRequest:(NSString*)interviewerName
{
    NSDictionary* dic = @{@"msg" : @"tagListRequest", @"data" : interviewerName};
    
    NSError* error = [self sendToHostWithData:dic];
    
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)sendTagList:(NSDictionary*)data toPeer:(MCPeerID*)peer
{
    NSMutableData* yrdataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:yrdataToSend];
    
    [yrarchiver encodeObject:data forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];
    
    for (NSDictionary* dic in [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].activeSessions) {
        
        if ([[(MCPeerID*)dic[@"peer"] displayName] isEqualToString:peer.displayName]) {
            NSArray * allPeers = [(MCSession*)dic[@"session"] connectedPeers];
            
            NSLog(@"peer count  %lu",(unsigned long)[allPeers count]);
            
            NSError *error;
            
            [(MCSession*)dic[@"session"] sendData:yrdataToSend toPeers:allPeers withMode:MCSessionSendDataReliable error:&error];
            
            if(error){
                NSLog(@"%@", [error localizedDescription]);
            }
            else
            {
                //
            }
        }
    }
}

-(NSError*)tagCandidate:(NSString*)ID withOption:(NSString*)option from:(NSString*)viewer
{
    NSDictionary* dic = @{@"msg" : option, @"data" : ID, @"viewer" : viewer};
    
    NSError* error = [self sendToHostWithData:dic];
    
    return error;
}

-(void)sendBackUp:(NSDictionary *)localBackUp
{
    NSLog(@"sending backups");
    NSError* error = [self sendToHostWithData:localBackUp];
    
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
    else
    {
        //
    }
}

-(void)sendACKBack:(MCPeerID*)peerID
{
    NSDictionary* dic = @{@"msg" : @"ack", @"code" : [NSString stringWithFormat:@"%@-%d",self.yrPrefix,[self nextCode]], @"source" : [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].peerID};
    NSMutableData* dataToSend = [NSMutableData new];
    
    NSLog(@"sending %@ with session number %lu",dic[@"code"],(unsigned long)[[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].activeSessions count]);
    
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    
    [yrarchiver encodeObject:dic forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];
    
    NSError *error;
    
    MCSession * selectedSession;
    
    for (NSDictionary* dic in [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].activeSessions) {
        if ([[dic[@"peer"] displayName] isEqualToString:peerID.displayName]) {
            selectedSession = dic[@"session"];
        }
    }
    
    [selectedSession sendData:dataToSend toPeers:@[peerID] withMode:MCSessionSendDataReliable error:&error];
    if(error){
        NSLog(@"Error %@", [error localizedDescription]);
    }
}

-(int) nextCode
{
    self.counter = self.counter + 1;
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:self.counter] forKey:@"codeIndex"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return self.counter;
}

- (void)dealloc{
    [self stopListeningForData];
}

-(void)debugSenderActiveWithCode:(NSString*)rid
{
    if (self.debug_counter > 0) {
        self.debug_counter = self.debug_counter - 1;
        //send entry here;
        NSDictionary *dataDic = @{@"firstName" :[NSString stringWithFormat:@"%@first",rid], @"lastName" : [NSString stringWithFormat:@"%@last",rid], @"email" : [NSString stringWithFormat:@"%@email",rid], @"code" : rid,  @"status" : @"pending", @"pdf" : [NSNumber numberWithBool:NO], @"preference" : @"Mobile - iOS", @"position" : @"Full-Time", @"date" : [NSDate date], @"note" : @"#empty#", @"gpa" : @"3.5", @"rank" : @"3", @"interviewer" : [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].userName, @"tagList" : [NSArray new]};
        
        NSMutableDictionary *newDic = [NSMutableDictionary new];
        [newDic addEntriesFromDictionary:dataDic];
        
        //change NSDictionary to NSMutableDictionary
        NSDictionary *dic = @{@"msg" : @"data", @"data" : newDic};
        
        [self sendData:dic];
    }
}

#pragma mark- UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Accept"]) {
        //accept the debrief mode
        [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].debriefing = YES;
        //bring up new view controller to show broadcast
        [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerReceiveDebriefInitiationNotification object:nil];
    }
}

@end
