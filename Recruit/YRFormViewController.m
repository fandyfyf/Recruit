//
//  YRFormViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRFormViewController.h"
#import "YRMCManager.h"
#import "YRDataManager.h"
#import <Guile/UITextField+AutoSuggestAdditions.h>
#import <Guile/Guile.h>

@interface YRFormViewController ()

-(void)checkReady;
-(void)needUpdateCodeNotification:(NSNotification *)notification;
-(void)reconnectNotification:(NSNotification *)notification;
-(void)needEndSessionNotification:(NSNotification *)notification;
-(void)refresh;

@end

@implementation YRFormViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateCodeNotification:) name:@"NeedUpdateCodeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reconnectNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needEndSessionNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    if ([[self.tabBarController.viewControllers[0] valueForKey:@"yrIDCode"] length] != 0) {
        [self.yrcodeLabel setText:[self.tabBarController.viewControllers[0] valueForKey:@"yrIDCode"]];
    }
    
    self.yremailLabel.delegate = self;
    self.yrfirstnameLabel.delegate = self;
    self.yrlastnameLabel.delegate = self;
    self.yremailLabel.suggestionDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)refreshInformation:(id)sender {
    [self refresh];
}

- (IBAction)sendInformation:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"NOTE" message:@"Ready to send?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Send",@"Recommand", nil];
    [alert show];
}

-(void)checkReady
{
    if ([self.yrfirstnameLabel.text length] != 0 && [self.yrlastnameLabel.text length] != 0 && [self.yremailLabel.text length] != 0) {
        [self.sendButton setEnabled:YES];
    }
    else
    {
        [self.sendButton setEnabled:NO];
    }
}

-(void)needUpdateCodeNotification:(NSNotification *)notification
{
    NSMutableString *code = [[notification userInfo] objectForKey:@"recruitID"];
    [self.yrcodeLabel performSelectorOnMainThread:@selector(setText:) withObject:code waitUntilDone:NO];
}

-(void)reconnectNotification:(NSNotification *)notification
{
    //NSLog(@"Name is %@",[[[[self tabBarController] viewControllers] objectAtIndex: 0] valueForKey:@"clientUserName"]);
    [[self.appDelegate mcManager] setupPeerAndSessionWithDisplayName:[[[self.tabBarController viewControllers] objectAtIndex: 0] valueForKey:@"clientUserName"]];
    MCNearbyServiceBrowser *browser = [[MCNearbyServiceBrowser alloc] initWithPeer:[self.appDelegate mcManager].peerID serviceType:@"files"];
    [browser invitePeer:[self.appDelegate mcManager].lastConnectionPeerID toSession:[self.appDelegate mcManager].session withContext:nil timeout:10];
}

-(void)needEndSessionNotification:(NSNotification *)notification
{
    [[self.appDelegate mcManager].session disconnect];
    [self.appDelegate mcManager].session = nil;
}

-(void)refresh
{
    self.yrfirstnameLabel.text = @"";
    self.yrlastnameLabel.text = @"";
    self.yremailLabel.text = @"";
    [self.sendButton setEnabled:NO];
}

- (IBAction)backgroundTapped:(id)sender {
    [self.yrfirstnameLabel resignFirstResponder];
    [self.yrlastnameLabel resignFirstResponder];
    [self.yremailLabel resignFirstResponder];
    [self checkReady];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.yrfirstnameLabel resignFirstResponder];
    [self.yrlastnameLabel resignFirstResponder];
    [self.yremailLabel resignFirstResponder];
    [self checkReady];
    
    return YES;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (![[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Cancel"]) {
        NSDictionary *dataDic = @{@"firstName" : self.yrfirstnameLabel.text, @"lastName" : self.yrlastnameLabel.text, @"email" : self.yremailLabel.text, @"gender" : [self.yrgenderSegmentControl titleForSegmentAtIndex:self.yrgenderSegmentControl.selectedSegmentIndex], @"code" : self.yrcodeLabel.text, @"recommand" : [NSNumber numberWithBool:NO], @"status" : @"pending"};
        
        NSMutableDictionary *newDic = [NSMutableDictionary new];
        [newDic addEntriesFromDictionary:dataDic];
        
        if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Recommand"]) {
            newDic[@"recommand"] = [NSNumber numberWithBool:YES];
        }
        //change NSDictionary to NSMutableDictionary
        NSDictionary *dic = @{@"msg" : @"data", @"data" : newDic};
        
        [self.appDelegate.dataManager sendData:dic];
        
        [self refresh];
        [self.yrcodeLabel setText:@"- - -"];
    }
}

#pragma mark - AutoSuggestDelegate

- (NSString *)suggestedStringForInputString:(NSString *)input
{
    static NSArray *domains;
    if (!domains) {
        domains = @[@"gmail.com",
                    @"gmail.co.uk",
                    @"yahoo.com",
                    @"yahoo.cn",
                    @"hotmail.com",
                    @"yahoo-inc.com"];
    }
    
    NSArray *parts = [input componentsSeparatedByString:@"@"];
    NSString *suggestion = nil;
    if (parts.count == 2) {
        NSString *domain = [parts lastObject];
        
        if (domain.length == 0) {
            suggestion = nil;
        }
        else {
            for (NSString *current in domains) {
                if ([current isEqualToString:domain]) {
                    suggestion = nil;
                    break;
                }
                else if ([current hasPrefix:domain]) {
                    suggestion = [current substringFromIndex:domain.length];
                    break;
                }
            }
        }
    }
    return suggestion;
}

-(UIColor *)suggestedTextColor
{
    return [UIColor grayColor];
}


@end
