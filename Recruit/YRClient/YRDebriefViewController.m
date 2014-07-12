//
//  YRDebriefViewController.m
//  Recruit
//
//  Created by Yifan Fu on 7/11/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRDebriefViewController.h"

@interface YRDebriefViewController ()

-(void)refreshViewWithNewBroadCast:(NSNotification*)notification;
-(void)showControlPanel:(UIGestureRecognizer*)gestureRecognizer;
-(void)dismissControlPanel:(UIGestureRecognizer*)gestureRecognizer;
-(void)switchMode;

@end

@implementation YRDebriefViewController

- (void)awakeFromNib
{
    self.currentDataEntry = [NSDictionary new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewWithNewBroadCast:) name:@"receiveBroadcastNotification" object:nil];
    
    self.view = [[UIView alloc] initWithFrame:self.view.frame];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.yrPromptMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-100, self.view.center.y-65, 200, 50)];
    
    self.yrPromptMessageLabel.text = @"Loading...";
    self.yrPromptMessageLabel.textColor = [UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0];
    self.yrPromptMessageLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:self.yrPromptMessageLabel];
    
    self.gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showControlPanel:)];
    [(UISwipeGestureRecognizer*)self.gestureRecognizer setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.view addGestureRecognizer:self.gestureRecognizer];
    
    self.gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissControlPanel:)];
    [(UISwipeGestureRecognizer*)self.gestureRecognizer setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.view addGestureRecognizer:self.gestureRecognizer];

    
    //interface builder
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.controlPanel = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-50, self.view.frame.size.width, 80)];
        self.controlPanel.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.5];
        
        self.tagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.tagButton.frame = CGRectMake(10, 10, 60, 60);
        self.tagButton.backgroundColor = [UIColor clearColor];
        [[self.tagButton layer] setCornerRadius:30];
        [[self.tagButton layer] setBorderColor:[[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] CGColor]];
        [[self.tagButton layer] setBorderWidth:2];
        [self.tagButton setTitle:@"Tag" forState:UIControlStateNormal];
        [self.tagButton setTitleColor:[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.tagButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        
        [self.controlPanel addSubview:self.tagButton];
        
        self.broadCastButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.broadCastButton.frame = CGRectMake(130, 10, 60, 60);
        self.broadCastButton.backgroundColor = [UIColor clearColor];
        [[self.broadCastButton layer] setCornerRadius:30];
        [[self.broadCastButton layer] setBorderColor:[[UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0] CGColor]];
        [[self.broadCastButton layer] setBorderWidth:2];
        [self.broadCastButton setTitle:@"Broadcast" forState:UIControlStateNormal];
        [self.broadCastButton setTitleColor:[UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.broadCastButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [self.broadCastButton setHidden:YES];
        [self.broadCastButton addTarget:self action:@selector(switchMode) forControlEvents:UIControlEventTouchUpInside];
        
        [self.controlPanel addSubview:self.broadCastButton];
        
        self.selfServeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.selfServeButton.frame = CGRectMake(130, 10, 60, 60);
        self.selfServeButton.backgroundColor = [UIColor clearColor];
        [[self.selfServeButton layer] setCornerRadius:30];
        [[self.selfServeButton layer] setBorderColor:[[UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0] CGColor]];
        [[self.selfServeButton layer] setBorderWidth:2];
        [self.selfServeButton setTitle:@"Seach" forState:UIControlStateNormal];
        [self.selfServeButton setTitleColor:[UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        self.selfServeButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        [self.selfServeButton addTarget:self action:@selector(switchMode) forControlEvents:UIControlEventTouchUpInside];
        
        [self.controlPanel addSubview:self.selfServeButton];
        
        self.signOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.signOutButton.frame = CGRectMake(250, 10, 60, 60);
        self.signOutButton.backgroundColor = [UIColor clearColor];
        [[self.signOutButton layer] setCornerRadius:30];
        [[self.signOutButton layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
        [[self.signOutButton layer] setBorderWidth:2];
        [self.signOutButton setTitle:@"Exit" forState:UIControlStateNormal];
        [self.signOutButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        self.signOutButton.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        
        [self.controlPanel addSubview:self.signOutButton];
        
        self.codeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 30, 50, 20)];
        self.codeTitleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.codeTitleLabel.text = @"Rid: ";
        self.codeTitleLabel.textAlignment = NSTextAlignmentLeft;
        //self.codeTitleLabel.hidden = YES;
        
        self.codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 30, 200, 20)];
        self.codeLabel.font = [UIFont systemFontOfSize:15];
        self.codeLabel.textAlignment = NSTextAlignmentLeft;
        //self.codeLabel.hidden = YES;
        
        self.nameTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 70, 50, 20)];
        self.nameTitleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.nameTitleLabel.text = @"Name: ";
        self.nameTitleLabel.textAlignment = NSTextAlignmentLeft;
        //self.nameTitleLabel.hidden = YES;
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 70, 200, 20)];
        self.nameLabel.font = [UIFont systemFontOfSize:15];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        //self.nameLabel.hidden = YES;
        
        self.emailTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 110, 50, 20)];
        self.emailTitleLabel.font = [UIFont boldSystemFontOfSize:15];
        self.emailTitleLabel.text = @"Email: ";
        self.emailTitleLabel.textAlignment = NSTextAlignmentLeft;
        //self.emailTitleLabel.hidden = YES;
        
        self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 110, 200, 20)];
        self.emailLabel.font = [UIFont systemFontOfSize:15];
        self.emailLabel.textAlignment = NSTextAlignmentLeft;
        //self.emailLabel.hidden = YES;
        
        [self.view addSubview:self.controlPanel];
        
        [self.view addSubview:self.codeTitleLabel];
        [self.view addSubview:self.nameTitleLabel];
        [self.view addSubview:self.emailTitleLabel];
        
        
        
        
        [self.view addSubview:self.codeLabel];
        [self.view addSubview:self.nameLabel];
        [self.view addSubview:self.emailLabel];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)refreshViewWithNewBroadCast:(NSNotification*)notification
{
    self.currentDataEntry = [notification userInfo];
    if (!self.yrPromptMessageLabel.isHidden) {
        self.yrPromptMessageLabel.hidden = YES;
    }
    self.codeTitleLabel.hidden = NO;
    self.codeLabel.hidden = NO;
    self.codeLabel.text = self.currentDataEntry[@"code"];
    self.nameTitleLabel.hidden = NO;
    self.nameLabel.hidden = NO;
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",self.currentDataEntry[@"firstName"],self.currentDataEntry[@"lastName"]];
    self.emailTitleLabel.hidden = NO;
    self.emailLabel.hidden = NO;
    self.emailLabel.text = self.currentDataEntry[@"email"];
    
    NSLog(@"%@",self.currentDataEntry);
}

-(void)showControlPanel:(UIGestureRecognizer*)gestureRecognizer
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.controlPanel setFrame:CGRectMake(self.controlPanel.frame.origin.x, 439, self.controlPanel.frame.size.width, self.controlPanel.frame.size.height)];
    }];
}

-(void)dismissControlPanel:(UIGestureRecognizer*)gestureRecognizer
{
    [UIView animateWithDuration:0.3 animations:^{
        [self.controlPanel setFrame:CGRectMake(self.controlPanel.frame.origin.x, 519, self.controlPanel.frame.size.width, self.controlPanel.frame.size.height)];
    }];
}

-(void)switchMode
{
    if (self.broadCastButton.isHidden) {
        self.selfServeButton.hidden = YES;
        self.broadCastButton.hidden = NO;
    }
    else
    {
        self.broadCastButton.hidden = YES;
        self.selfServeButton.hidden = NO;
    }
}

@end
