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
        _counter = 0;
    }
    
    return self;
}

-(void)didReceiveDataWithNotification:(NSNotification *)notification
{
    MCPeerID *peerID = [[notification userInfo] objectForKey:@"peerID"];
    
    NSData* yrinfoData = [[notification userInfo] objectForKey:@"data"];
    
    NSKeyedUnarchiver* yrunarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:yrinfoData];
    
    NSMutableDictionary *dic = [[yrunarchiver decodeObjectForKey:@"infoDataKey"] mutableCopy];
    
    [yrunarchiver finishDecoding];
    
    NSLog(@"message is %@",dic[@"msg"]);
    
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
            NSLog(@"duplicate code and firstName found");
        }
    }
    else if([dic[@"msg"] isEqualToString:@"ack"])
    {
        [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].lastConnectionPeerID = dic[@"source"];
        NSDictionary *dict = @{@"recruitID": dic[@"code"]};
        
        if (self.localBackUp != nil) {
            [self sendBackUp:self.localBackUp];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NeedUpdateCodeNotification"
                                                            object:nil
                                                          userInfo:dict];
    }
    else if([dic[@"msg"] isEqualToString:@"nameList"])
    {
        NSLog(@"The receiving list is %@",dic[@"data"]);
        self.nameList = dic[@"data"];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NameListReadyNotification"
                                                            object:nil
                                                          userInfo:nil];
    }
    else
    {
        NSLog(@"trash");
    }

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
    [item setCode:infoData[@"code"]];
    [item setRecommand:infoData[@"recommand"]];
    [item setStatus:infoData[@"status"]];
    [item setPdf:infoData[@"pdf"]];
    [item setPosition:infoData[@"position"]];
    [item setPreference:infoData[@"preference"]];
    [item setDate:infoData[@"date"]];
    [item setNotes:[(NSString*)infoData[@"note"] stringByAppendingString:[NSString stringWithFormat:@"\n\n#%@#\n\n",[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].userName]]];
    [item setRank:[NSNumber numberWithFloat:[(NSString*)infoData[@"rank"] floatValue]]];
    [item setGpa:[NSNumber numberWithFloat:[(NSString*)infoData[@"gpa"] floatValue]]];
    
    [item setInterviews:[NSMutableArray new]];
    
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
        
        self.localBackUp = @{@"msg" : @"backup" , @"data" : data[@"data"]};
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
        self.localBackUp = nil;
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
    return self.counter;
}

- (void)dealloc{
    [self stopListeningForData];
}

@end
