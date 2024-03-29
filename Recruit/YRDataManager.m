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


//message Type
NSString* const kYRMessageMessageSection = @"msg";
NSString* const kYRMessageDataSection = @"messageData";


NSString* const kYRDataEntryMessage = @"data";
NSString* const kYRBackupDataEntryMessage = @"backup";
NSString* const kYRAcknowledgeMessage = @"ack";
NSString* const kYRNameListMessage = @"nameList";
NSString* const kYRIdentityConfirmMessage = @"identityConfirm";

//Debriefing Mode

NSString* const kYRDebriefBroadcastMessage = @"broadcast";
NSString* const kYRDebriefResumeRequestMessage = @"resumeRequest";
NSString* const kYRDebriefTagListRequestMessage = @"tagListRequest";
NSString* const kYRDebriefLastDiscussedDataRequestMessage = @"pullData";
NSString* const kYRDebriefSearchRequestMessage = @"searchQuery";

NSString* const kYRDebriefFlagRequestMessage = @"Flag";
NSString* const kYRDebriefUnflagRequestMessage = @"unFlag";

NSString* const kYRDebriefDataResumeMessage = @"resume";
NSString* const kYRDebriefDataTagListMessage = @"tagList";
NSString* const kYRDebriefDataSearchResultMessage = @"searchResult";


NSString* const kYRDebriefInvitationMessage = @"debriefInvitation";
NSString* const kYRDebriefTerminationMessage = @"debriefTermination";



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
        
        NSString* message = dic[kYRMessageMessageSection];
        
        
        if([message isEqualToString:kYRDataEntryMessage] && self.isHost)
        {
            //send acknowledge upone receive data entry
            [self sendACKBack:peerID];
            
            if ([self isNotDuplicateData:dic[kYRMessageDataSection]]){
                //save data in coredata
                CandidateEntry* curr = [self saveCandidate:dic[kYRMessageDataSection]];
                
                //update in table via posting notification
                NSDictionary *dict = @{@"entry" : curr};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerNeedUpdateTableNotification object:nil userInfo:dict];
            }
            else
            {
                NSLog(@"duplicate code and firstName found");
            }
        }
        else if ([message isEqualToString:kYRBackupDataEntryMessage] && self.isHost)
        {
            if ([self isNotDuplicateData:dic[kYRMessageDataSection]]) {
                CandidateEntry* curr = [self saveCandidate:dic[kYRMessageDataSection]];
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
        else if([message isEqualToString:kYRAcknowledgeMessage])
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
        else if([message isEqualToString:kYRNameListMessage])
        {
            NSLog(@"The receiving list is %@",dic[kYRMessageDataSection]);
            self.nameList = dic[kYRMessageDataSection];
            
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
                    
                    NSDictionary* packet = @{kYRMessageMessageSection : kYRBackupDataEntryMessage, kYRMessageDataSection:dic};
                    
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
        else if([message isEqualToString:kYRIdentityConfirmMessage] && self.isHost)
        {
            NSLog(@"Receiving confirmed name : %@",dic[kYRMessageDataSection]);
            
            NSDictionary* dict = @{@"displayName": peerID.displayName, @"confirmedName" : dic[kYRMessageDataSection]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerNeedUpdateConnectionListNotification object:nil userInfo:dict];
            
            //===================send to new connected user====================//
            if ([(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].isDebriefing) {
                [self sendDebriefInvitationToPeer:peerID];
            }
            //=================================================================//
        }
        //========================Debrif message ==========================//
        else if([message isEqualToString:kYRDebriefBroadcastMessage] && !self.isHost)
        {
            //receive debrief invitation
            NSLog(@"receiving one broadcast entry");
            //post notification to observers
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerReceiveBroadcastNotification object:nil userInfo:dic[kYRMessageDataSection]];
        }
        else if([message isEqualToString:kYRDebriefResumeRequestMessage] && self.isHost)
        {
            NSLog(@"receiving one resume request");
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
            NSError *error;
            if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
            NSString* fileName = dic[kYRMessageDataSection];
            NSString *fullPath = [dataPath stringByAppendingPathComponent:fileName];
            
            NSDictionary* dic = @{kYRMessageMessageSection : kYRDebriefDataResumeMessage , kYRMessageDataSection : [NSData dataWithContentsOfFile:fullPath]};
            
            [self sendResume:dic toPeer:peerID];
            
        }
        else if([message isEqualToString:kYRDebriefDataResumeMessage])
        {
            NSLog(@"receiving one resume");
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerReceiveResumeNotification object:nil userInfo:dic[kYRMessageDataSection]];
        }
        else if([message isEqualToString:kYRDebriefInvitationMessage] && !self.isHost)
        {
            //receive debrief invitation
            NSLog(@"receiving debrief invitation");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Debrief Invitation" message:@"The host is starting a debrief session and your are invited!" delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
            [alert show];
            //send tagList request
            
            //[self sendTagListRequest:[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].userName];
        }
        else if([message isEqualToString:kYRDebriefTagListRequestMessage] && self.isHost)
        {
            NSLog(@"receive tag list request from %@",dic[kYRMessageDataSection]);
            
            NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name = %@ && code = %@",dic[kYRMessageDataSection],[[NSUserDefaults standardUserDefaults] valueForKey:@"eventCode"]]];
            
            NSError* error = nil;
            NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            NSArray* tagList;
            if ([FetchResults count] != 0) {
                tagList = [(Interviewer*)FetchResults[0] tagList];
                NSDictionary* dic = @{kYRMessageMessageSection : kYRDebriefDataTagListMessage , kYRMessageDataSection : tagList};
                
                [self sendTagList:dic toPeer:peerID];
            }
            else
            {
                NSLog(@"interviewer not found");
            }
        }
        else if([message isEqualToString:kYRDebriefDataTagListMessage] && !self.isHost)
        {
            NSLog(@"receiving tag list %@",dic[kYRMessageDataSection]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerReceiveTagListNotification object:nil userInfo:dic[kYRMessageDataSection]];
        }
        else if([message isEqualToString:kYRDebriefLastDiscussedDataRequestMessage] && self.isHost)
        {
            NSLog(@"Host received pull from %@",peerID.displayName);
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerNeedStartBroadcastNotification object:peerID];
        }
        else if([message isEqualToString:kYRDebriefFlagRequestMessage] && self.isHost)
        {
            NSLog(@"receiving tag request for Candidate %@ from %@",dic[kYRMessageDataSection],dic[@"viewer"]);
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@",dic[kYRMessageDataSection]]];
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
                [tagList_I addObject:dic[kYRMessageDataSection]];
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
        else if([message isEqualToString:kYRDebriefUnflagRequestMessage] && self.isHost)
        {
            NSLog(@"receiving untag request for Candidate %@ from %@",dic[kYRMessageDataSection],dic[@"viewer"]);
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@",dic[kYRMessageDataSection]]];
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
                        if ([[tagList_I objectAtIndex:i] isEqualToString:dic[kYRMessageDataSection]]) {
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
        else if ([message isEqualToString:kYRDebriefSearchRequestMessage] && self.isHost)
        {
            NSLog(@"receiving seach query %@",dic[kYRMessageDataSection]);
            
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"preference = %@ && rank >= %@ && position = %@",dic[kYRMessageDataSection][@"option"],dic[kYRMessageDataSection][@"ranking"],dic[kYRMessageDataSection][@"position"]]];
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
        else if([message isEqualToString:kYRDebriefDataSearchResultMessage] && !self.isHost)
        {
            NSLog(@"receiving search result: %@",dic[kYRMessageDataSection]);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:kYRDataManagerReceiveSearchResultNotification object:dic[kYRMessageDataSection]];
        }
        else if([message isEqualToString:kYRDebriefTerminationMessage] && !self.isHost)
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
    NSMutableData* dataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:dataToSend];
    [yrarchiver encodeObject:data forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];

    MCSession * selectedSession;
    
    for (NSDictionary* dic in [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].activeSessions) {
        if ([[dic[@"peer"] displayName] isEqualToString:peer.displayName]) {
            selectedSession = dic[@"session"];
            break;
        }
    }
    
    NSError* error = nil;
    [selectedSession sendData:dataToSend toPeers:@[peer] withMode:MCSessionSendDataReliable error:&error];
    if(error){
        NSLog(@"Error %@", [error localizedDescription]);
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
        [self queuingLocalCandidate:data[kYRMessageDataSection]];
        
        //TODO: after the connection has dropped and the browsing is timed out, the bowsing flag never got switched off. So the client will only initiate the reconnection for only one time and 30 secs. after that, it won't try to reconnect again. It's a problem is need to be fixed.
        
        
        //send fail, no connection, restart browsing
        if (![(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].isBrowsing) {
            [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].autoBrowser startBrowsingForPeers];
            [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager] setBrowsing:YES];
        }
    }
}

-(void)broadCastData:(NSDictionary*)data
{
    NSLog(@"Host broadcasting %@",data);
    [self sendToALLClientsWithData:data];
}

-(void)broadCastData:(NSDictionary *)data toPeer:(MCPeerID*)peer
{
    NSLog(@"Host broadcasting to peer %@ %@",peer.displayName,data);
    [self sendToPeer:peer withData:data];
}

-(NSError*)sendDataRequestForFile:(NSString*)fileName
{
    NSDictionary* packet = @{kYRMessageMessageSection : kYRDebriefResumeRequestMessage, kYRMessageDataSection : fileName};
    
    NSError* error = [self sendToHostWithData:packet];
    
    return error;
}

-(void)pullData
{
    NSDictionary* packet = @{kYRMessageMessageSection : kYRDebriefLastDiscussedDataRequestMessage};
    
    NSError* error = [self sendToHostWithData:packet];
    
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)sendResume:(NSDictionary*)data toPeer:(MCPeerID*)peer
{
    [self sendToPeer:peer withData:data];
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
    
    NSDictionary* packet = @{kYRMessageMessageSection : kYRNameListMessage , kYRMessageDataSection : currentList};
    
    NSLog(@"sending name list");
    
    [self sendToPeer:peerID withData:packet];
}

-(void)sendIdentityConfirmation:(NSString*)updateUserName
{
    NSDictionary* packet = @{kYRMessageMessageSection : kYRIdentityConfirmMessage, kYRMessageDataSection : updateUserName};
    NSError* error = [self sendToHostWithData:packet];
    
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)sendDebriefTermination
{
    NSDictionary* packet = @{kYRMessageMessageSection : kYRDebriefTerminationMessage};
    
    [self sendToALLClientsWithData:packet];
}

//send debrief invitation to newly connected user
-(void)sendDebriefInvitationToPeer:(MCPeerID*)peer
{
    NSDictionary* packet = @{kYRMessageMessageSection : kYRDebriefInvitationMessage};
    
    [self sendToPeer:peer withData:packet];
}

//broadcast debrief invitation to all connected users
-(void)sendDebriefInvitation
{
    NSDictionary* packet = @{kYRMessageMessageSection : kYRDebriefInvitationMessage};
    
    [self sendToALLClientsWithData:packet];
}

-(NSError*)sendSearchQuery:(NSDictionary*)dic
{
    NSDictionary* packet = @{kYRMessageMessageSection : kYRDebriefSearchRequestMessage, kYRMessageDataSection : dic};
    
    return [self sendToHostWithData:packet];
}

-(void)sendSearchResult:(NSArray*)array toPeer:(MCPeerID*)peer
{
    NSDictionary* packet = @{kYRMessageMessageSection : kYRDebriefDataSearchResultMessage, kYRMessageDataSection : array};
    
    [self sendToPeer:peer withData:packet];
}

-(void)sendTagListRequest:(NSString*)interviewerName
{
    NSDictionary* packet = @{kYRMessageMessageSection : kYRDebriefTagListRequestMessage, kYRMessageDataSection : interviewerName};
    
    NSError* error = [self sendToHostWithData:packet];
    
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)sendTagList:(NSDictionary*)data toPeer:(MCPeerID*)peer
{
    [self sendToPeer:peer withData:data];
}

-(NSError*)tagCandidate:(NSString*)ID withOption:(NSString*)option from:(NSString*)viewer
{
    //TODO: combine target candidate and viewer
    NSDictionary* dic = @{kYRMessageMessageSection : option, kYRMessageDataSection : ID, @"viewer" : viewer};
    
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
}

-(void)sendACKBack:(MCPeerID*)peerID
{
    //TODO: combine code and source to be data
    NSDictionary* packet = @{kYRMessageMessageSection : kYRAcknowledgeMessage, @"code" : [NSString stringWithFormat:@"%@-%d",self.yrPrefix,[self nextCode]], @"source" : [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].peerID};
    
    [self sendToPeer:peerID withData:packet];
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
        NSDictionary *dic = @{kYRMessageMessageSection : kYRDataEntryMessage, kYRMessageDataSection : newDic};
        
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
