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


@implementation YRDataManager

-(id) init{
    self = [super init];
    
    if (self) {
        _managedObjectContext = [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
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
        
        NSLog(@"message is %@; I AM %@",dic[@"msg"], self);
        
        if ([dic[@"msg"] isEqualToString:@"backup"] && self.isHost)
        {
            if ([self isNotDuplicateData:dic[@"data"]]) {
                CandidateEntry* curr = [self saveCandidate:dic[@"data"]];
                NSDictionary *dict = @{@"entry" : curr};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedUpdateTableNotification"
                                                                    object:nil
                                                                  userInfo:dict];
            }
            else
            {
                NSLog(@"duplicate code and firstName found");
            }
        }
        else if([dic[@"msg"] isEqualToString:@"data"] && self.isHost)
        {
            if ([self isNotDuplicateData:dic[@"data"]]){
                [self sendACKBack:peerID];
                
                CandidateEntry* curr = [self saveCandidate:dic[@"data"]];
                NSDictionary *dict = @{@"entry" : curr};
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedUpdateTableNotification"
                                                                    object:nil
                                                                  userInfo:dict];
            }
            else
            {
                [self sendACKBack:peerID];
                NSLog(@"duplicate code and firstName found");
            }
        }
        else if([dic[@"msg"] isEqualToString:@"broadcast"] && !self.isHost)
        {
            //receive debrief invitation
            NSLog(@"receiving one broadcast entry");
            //post notification to observers
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"receiveBroadcastNotification" object:nil userInfo:dic[@"data"]];
        }
        else if([dic[@"msg"] isEqualToString:@"debriefInvitation"] && !self.isHost)
        {
            //receive debrief invitation
            NSLog(@"receiving debrief invitation");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Debrief Invitation" message:@"The host is starting a debrief session and your are invited!" delegate:self cancelButtonTitle:@"Decline" otherButtonTitles:@"Accept", nil];
            [alert show];
            //or post notification to observers
        }
        else if([dic[@"msg"] isEqualToString:@"debriefTermination"] && !self.isHost)
        {
            //receive debrief invitation
            NSLog(@"receiving debrief termination");
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Debrief Termination" message:@"The host is closing the session" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alert show];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"debriefModeOffNotification" object:nil];
            //or post notification to observers
        }
        else if([dic[@"msg"] isEqualToString:@"identityConfirm"] && self.isHost)
        {
            NSLog(@"Receiving update username: %@ from %@",peerID.displayName,dic[@"data"]);
            
            NSDictionary* dict = @{@"displayName": peerID.displayName, @"confirmedName" : dic[@"data"]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedUpdateConnectionListNotification" object:nil userInfo:dict];
            
            //===================send to new connected user====================//
            if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DebriefModeOn"] boolValue]) {
                [self sendDebriefInvitationToPeer:peerID];
            }
            
        }
        else if([dic[@"msg"] isEqualToString:@"ack"])
        {
            [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].lastConnectionPeerID = dic[@"source"];
            NSDictionary *dict = @{@"recruitID": dic[@"code"]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedUpdateCodeNotification"
                                                                object:nil
                                                              userInfo:dict];
            
            //        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            //        [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
            //        NSError* error = nil;
            //        NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            //
            //        //reset the core data
            //        for (CandidateEntry* backedUpCandidate in FetchResults)
            //        {
            //            [self.managedObjectContext deleteObject:backedUpCandidate];
            //        }
            //
            //        for (CandidateEntry* backedUpCandidate in FetchResults)
            //        {
            //            NSDictionary* dic = @{@"firstName":backedUpCandidate.firstName,@"lastName":backedUpCandidate.lastName,@"email":backedUpCandidate.emailAddress,@"interviewer":backedUpCandidate.interviewer,@"code":backedUpCandidate.code,@"recommand":backedUpCandidate.recommand,@"status":backedUpCandidate.status,@"pdf":backedUpCandidate.pdf,@"position":backedUpCandidate.position,@"preference":backedUpCandidate.preference,@"date":backedUpCandidate.date,@"note":backedUpCandidate.notes,@"rank":[backedUpCandidate.rank stringValue],@"gpa":[backedUpCandidate.gpa stringValue]};
            //            NSDictionary* packet = @{@"msg" : @"backup", @"data":dic};
            //            [self sendBackUp:packet];
            //        }
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
                    NSDictionary* dic = @{@"firstName":backedUpCandidate.firstName,@"lastName":backedUpCandidate.lastName,@"email":backedUpCandidate.emailAddress,@"interviewer":[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].userName,@"code":backedUpCandidate.code,@"recommand":backedUpCandidate.recommand,@"status":backedUpCandidate.status,@"pdf":backedUpCandidate.pdf,@"position":backedUpCandidate.position,@"preference":backedUpCandidate.preference,@"date":backedUpCandidate.date,@"note":backedUpCandidate.notes,@"rank":[backedUpCandidate.rank stringValue],@"gpa":[backedUpCandidate.gpa stringValue]};
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
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"SignedInAlready"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"NameListReadyNotification"
                                                                object:nil
                                                              userInfo:nil];
            }
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

    
    [item setRecommand:infoData[@"recommand"]];
    [item setStatus:infoData[@"status"]];
    [item setPdf:infoData[@"pdf"]];
    [item setPosition:infoData[@"position"]];
    [item setPreference:infoData[@"preference"]];
    [item setDate:infoData[@"date"]];
    [item setNotes:[(NSString*)infoData[@"note"] stringByAppendingString:[NSString stringWithFormat:@"\n\n#%@#\n\n",[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].userName]]];
    [item setRank:[NSNumber numberWithFloat:[(NSString*)infoData[@"rank"] floatValue]]];
    [item setGpa:[NSNumber numberWithFloat:[(NSString*)infoData[@"gpa"] floatValue]]];
    [item setBusinessUnit1:@""];
    [item setBusinessUnit2:@""];
    
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
    [item setRecommand:infoData[@"recommand"]];
    [item setStatus:infoData[@"status"]];
    [item setPdf:infoData[@"pdf"]];
    [item setPosition:infoData[@"position"]];
    [item setPreference:infoData[@"preference"]];
    [item setDate:infoData[@"date"]];
    [item setNotes:infoData[@"note"]];
    [item setRank:[NSNumber numberWithFloat:[(NSString*)infoData[@"rank"] floatValue]]];
    [item setGpa:[NSNumber numberWithFloat:[(NSString*)infoData[@"gpa"] floatValue]]];
    
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"ERROR -- saving coredata");
    }
    return item;
}

-(void)sendData:(NSDictionary*)data
{
    NSMutableData* yrdataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:yrdataToSend];
    
    [yrarchiver encodeObject:data forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];
    
    NSArray * allPeers = [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].session.connectedPeers;
    
    //NSLog(@"%@",allPeers);
    
    NSError *error;
    
    [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].session sendData:yrdataToSend toPeers:allPeers withMode:MCSessionSendDataReliable error:&error];
    
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

-(void)sendNameList:(MCPeerID*)peerID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@",self.yrPrefix]];
    
    NSError* error = nil;
    
    NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    //NSMutableArray* currentList = [FetchResults mutableCopy];
    NSMutableArray* currentList = [NSMutableArray new];
    
    for (Interviewer* curr in FetchResults) {
        NSDictionary * dic = @{@"name" : curr.name, @"email" : curr.email};
        [currentList addObject:dic];
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
        NSLog(@"%@", [error localizedDescription]);
    }
}

-(void)sendIdentityConfirmation:(NSString*)updateUserName
{
    NSDictionary* dic = @{@"msg" : @"identityConfirm", @"data" : updateUserName};
    
    NSMutableData* yrdataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:yrdataToSend];
    
    [yrarchiver encodeObject:dic forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];
    
    NSArray * allPeers = [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].session.connectedPeers;
    
    NSLog(@"peer count  %lu",(unsigned long)[allPeers count]);
    
    NSError *error;
    
    [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].session sendData:yrdataToSend toPeers:allPeers withMode:MCSessionSendDataReliable error:&error];
    
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
    
    NSMutableData* yrdataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:yrdataToSend];
    
    [yrarchiver encodeObject:dic forKey:@"infoDataKey"];
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
    
    NSMutableData* yrdataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:yrdataToSend];
    
    [yrarchiver encodeObject:dic forKey:@"infoDataKey"];
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

-(void)sendBackUp:(NSDictionary *)localBackUp
{
    NSMutableData* yrdataToSend = [NSMutableData new];
    NSKeyedArchiver* yrarchiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:yrdataToSend];
    
    [yrarchiver encodeObject:localBackUp forKey:@"infoDataKey"];
    [yrarchiver finishEncoding];
    
    NSArray * allPeers = [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].session.connectedPeers;
    
    NSLog(@"peer count  %lu",(unsigned long)[allPeers count]);
    
    NSError *error;
    
    [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].session sendData:yrdataToSend toPeers:allPeers withMode:MCSessionSendDataReliable error:&error];
    
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
        NSLog(@"%@", [error localizedDescription]);
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

#pragma mark- UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Accept"]) {
        //accept the debrief mode
        //send acknowledge back?
        
        //bring up new view controller to show broadcast
        [[NSNotificationCenter defaultCenter] postNotificationName:@"debriefModeOnNotification" object:nil];
    }
}

@end
