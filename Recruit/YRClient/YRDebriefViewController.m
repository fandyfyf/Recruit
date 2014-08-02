//
//  YRDebriefViewController.m
//  Recruit
//
//  Created by Yifan Fu on 7/11/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRDebriefViewController.h"
#import "YRAppDelegate.h"

@interface YRDebriefViewController ()

-(void)loadData;
-(void)refreshViewWithNewBroadCast:(NSNotification*)notification;
-(void)fetchTagList:(NSNotification*)notification;
-(void)showImageWithBroadCast:(NSNotification*)notification;
-(void)searchMode;
-(void)broadcastMode;
-(void)cancelScrollView;
-(void)tagCandidates;

-(void)showBusy;
-(void)dismissBusy;
-(void)signOut;

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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshViewWithNewBroadCast:) name:kYRDataManagerReceiveBroadcastNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchTagList:) name:kYRDataManagerReceiveTagListNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showImageWithBroadCast:) name:kYRDataManagerReceiveResumeNotification object:nil];
    
    self.view = [[UIView alloc] initWithFrame:self.view.frame];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.yrPromptMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-100, self.view.center.y-65, 200, 50)];
    
    self.yrPromptMessageLabel.text = @"Waiting...";
    self.yrPromptMessageLabel.textColor = [UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0];
    self.yrPromptMessageLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.view addSubview:self.yrPromptMessageLabel];
    
    self.gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(searchMode)];
    [(UISwipeGestureRecognizer*)self.gestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.view addGestureRecognizer:self.gestureRecognizer];
    
    self.gestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(broadcastMode)];
    [(UISwipeGestureRecognizer*)self.gestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.view addGestureRecognizer:self.gestureRecognizer];

    self.searchModeView = [YRDebriefSearchModeViewController new];
    self.searchModeView.source = self;
    
    
    //interface builder
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.tagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.tagButton.frame = CGRectMake(590, 760, 120, 120);
        self.tagButton.backgroundColor = [UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0];
        [[self.tagButton layer] setCornerRadius:60];
        [[self.tagButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.tagButton layer] setBorderWidth:5];
        [self.tagButton setTitle:@"Flag" forState:UIControlStateNormal];
        [self.tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.tagButton setTintColor:[UIColor whiteColor]];
        self.tagButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        
        [self.tagButton addTarget:self action:@selector(tagCandidates) forControlEvents:UIControlEventTouchUpInside];
        
        self.tagButton.hidden = YES;
        
        self.signOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.signOutButton.frame = CGRectMake(590, 890, 120, 120);
        self.signOutButton.backgroundColor = [UIColor lightGrayColor];
        [[self.signOutButton layer] setCornerRadius:60];
        [[self.signOutButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.signOutButton layer] setBorderWidth:5];
        [self.signOutButton setTitle:@"Sign Out" forState:UIControlStateNormal];
        [self.signOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.signOutButton setTintColor:[UIColor whiteColor]];
        self.signOutButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        
        [self.signOutButton addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside];
        
        self.codeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 110, 100, 30)];
        self.codeTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        self.codeTitleLabel.text = @"Rid: ";
        self.codeTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.codeTitleLabel.hidden = YES;
        
        self.flagView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 50, 50)];
        self.flagView.image = [UIImage imageNamed:@"flag.jpg"];
        self.flagView.hidden = YES;
        
        self.modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-100, 50, 200, 50)];
        self.modeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 40];
        self.modeLabel.textAlignment = NSTextAlignmentCenter;
        self.modeLabel.textColor = [UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0];
        self.modeLabel.text = @"Debriefing";
        
        self.searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.searchButton setFrame:CGRectMake(40, 950, 500, 50)];
        self.searchButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        self.searchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.searchButton setTitleColor:[UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.searchButton setTitle:@"Search" forState:UIControlStateNormal];
        [[self.searchButton layer] setCornerRadius:10];
        [[self.searchButton layer] setBorderColor:[[UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0] CGColor]];
        [[self.searchButton layer] setBorderWidth:1];
        [self.searchButton addTarget:self action:@selector(searchMode) forControlEvents:UIControlEventTouchUpInside];
        
        self.codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 110, 300, 30)];
        self.codeLabel.font = [UIFont fontWithName:@"Helvetica" size: 25];
        self.codeLabel.textAlignment = NSTextAlignmentLeft;
        self.codeLabel.hidden = YES;
        
        self.positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(500, 110, 200, 30)];
        self.positionLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        self.positionLabel.textAlignment = NSTextAlignmentCenter;
        self.positionLabel.hidden = YES;
        
        self.nameTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 160, 100, 30)];
        self.nameTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        self.nameTitleLabel.text = @"Name: ";
        self.nameTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.nameTitleLabel.hidden = YES;
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 160, 300, 30)];
        self.nameLabel.font = [UIFont fontWithName:@"Helvetica" size: 25];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.hidden = YES;
        
        self.emailTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 220, 100, 30)];
        self.emailTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        self.emailTitleLabel.text = @"Email: ";
        self.emailTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.emailTitleLabel.hidden = YES;
        
        self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 220, 300, 30)];
        self.emailLabel.font = [UIFont fontWithName:@"Helvetica" size: 25];
        self.emailLabel.textAlignment = NSTextAlignmentLeft;
        self.emailLabel.hidden = YES;
        
        self.GPATitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 280, 100, 30)];
        self.GPATitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        self.GPATitleLabel.text = @"GPA: ";
        self.GPATitleLabel.textAlignment = NSTextAlignmentLeft;
        self.GPATitleLabel.hidden = YES;
        
        self.GPALabel = [[UILabel alloc] initWithFrame:CGRectMake(150, 280, 300, 30)];
        self.GPALabel.font = [UIFont fontWithName:@"Helvetica" size: 25];
        self.GPALabel.textAlignment = NSTextAlignmentLeft;
        self.emailLabel.hidden = YES;
        
        self.preferenceTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 340, 200, 30)];
        self.preferenceTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        self.preferenceTitleLabel.text = @"Preference: ";
        self.preferenceTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.preferenceTitleLabel.hidden = YES;
        
        self.preferenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 340, 300, 30)];
        self.preferenceLabel.font = [UIFont fontWithName:@"Helvetica" size: 25];
        self.preferenceLabel.textAlignment = NSTextAlignmentLeft;
        self.preferenceLabel.hidden = YES;
        
        self.noteViewTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 400, 200, 30)];
        self.noteViewTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        self.noteViewTitleLabel.text = @"Notes: ";
        self.noteViewTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.noteViewTitleLabel.hidden = YES;
        
        self.noteView = [[UITextView alloc] initWithFrame:CGRectMake(40, 440, self.view.frame.size.width-80, 150)];
        self.noteView.hidden = YES;
        //self.noteView.userInteractionEnabled = NO;
        self.noteView.backgroundColor = [UIColor colorWithRed:1.0 green:247.0/255.0 blue:201.0/255.0 alpha:1.0];
        [[self.noteView layer] setCornerRadius:10];
        [self.noteView setEditable:NO];
        
        self.rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(550, 400, 100, 100)];
        self.rankLabel.textAlignment = NSTextAlignmentCenter;
        self.rankLabel.textColor = [UIColor redColor];
        self.rankLabel.font = [UIFont fontWithName:@"IowanOldStyle-Bold" size:100];
        self.rankLabel.backgroundColor = [UIColor clearColor];
        self.rankLabel.hidden = YES;
        
        self.rankPointFiveLabel = [[UILabel alloc] initWithFrame:CGRectMake(620, 380, 60, 60)];
        self.rankPointFiveLabel.textAlignment = NSTextAlignmentCenter;
        self.rankPointFiveLabel.textColor = [UIColor redColor];
        self.rankPointFiveLabel.font = [UIFont fontWithName:@"IowanOldStyle-Bold" size:50];
        self.rankPointFiveLabel.backgroundColor = [UIColor clearColor];
        self.rankPointFiveLabel.hidden = YES;
        self.rankPointFiveLabel.text = @".5";
        
        self.businessUnit1TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 600, 200, 30)];
        self.businessUnit1TitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        self.businessUnit1TitleLabel.text = @"Business Unit1: ";
        self.businessUnit1TitleLabel.textAlignment = NSTextAlignmentLeft;
        self.businessUnit1TitleLabel.hidden = YES;
        
        self.businessUnit1Label = [[UILabel alloc] initWithFrame:CGRectMake(250, 600, 250, 30)];
        self.businessUnit1Label.font = [UIFont fontWithName:@"Helvetica" size: 25];
        self.businessUnit1Label.textAlignment = NSTextAlignmentLeft;
        self.businessUnit1Label.hidden = YES;
        
        self.businessUnit2TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 660, 200, 30)];
        self.businessUnit2TitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        self.businessUnit2TitleLabel.text = @"Business Unit2: ";
        self.businessUnit2TitleLabel.textAlignment = NSTextAlignmentLeft;
        self.businessUnit2TitleLabel.hidden = YES;
        
        self.businessUnit2Label = [[UILabel alloc] initWithFrame:CGRectMake(250, 660, 250, 30)];
        self.businessUnit2Label.font = [UIFont fontWithName:@"Helvetica" size: 25];
        self.businessUnit2Label.textAlignment = NSTextAlignmentLeft;
        self.businessUnit2Label.hidden = YES;
        
        self.resumeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 720, 200, 30)];
        self.resumeTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        self.resumeTitleLabel.text = @"Resume: ";
        self.resumeTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.resumeTitleLabel.hidden = YES;
        
        self.resumeList = [[UITableView alloc] initWithFrame:CGRectMake(40, 760, 500, 150) style:UITableViewStylePlain];
        self.resumeList.delegate = self;
        self.resumeList.dataSource = self;
        self.resumeList.hidden = YES;
        [[self.resumeList layer] setCornerRadius:10];
        [[self.resumeList layer] setBorderColor:[[UIColor colorWithRed:202.0/255.0 green:202.0/255.0 blue:202.0/255.0 alpha:0.5] CGColor]];
        [[self.resumeList layer] setBorderWidth:2];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.tagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.tagButton.frame = CGRectMake(230, 425, 70, 70);
        self.tagButton.backgroundColor = [UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0];
        [[self.tagButton layer] setCornerRadius:35];
        [[self.tagButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.tagButton layer] setBorderWidth:4];
        [self.tagButton setTitle:@"Flag" forState:UIControlStateNormal];
        [self.tagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.tagButton setTintColor:[UIColor whiteColor]];
        self.tagButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        
        [self.tagButton addTarget:self action:@selector(tagCandidates) forControlEvents:UIControlEventTouchUpInside];
        
        self.tagButton.hidden = YES;
        
        self.signOutButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.signOutButton.frame = CGRectMake(230, 495, 70, 70);
        self.signOutButton.backgroundColor = [UIColor lightGrayColor];
        [[self.signOutButton layer] setCornerRadius:35];
        [[self.signOutButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.signOutButton layer] setBorderWidth:4];
        [self.signOutButton setTitle:@"Sign Out" forState:UIControlStateNormal];
        [self.signOutButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.signOutButton setTintColor:[UIColor whiteColor]];
        self.signOutButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 12];
        
        [self.signOutButton addTarget:self action:@selector(signOut) forControlEvents:UIControlEventTouchUpInside];
        
        
        self.codeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 50, 20)];
        self.codeTitleLabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
        self.codeTitleLabel.text = @"Rid: ";
        self.codeTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.codeTitleLabel.hidden = YES;
        
        self.flagView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 55, 30, 30)];
        self.flagView.image = [UIImage imageNamed:@"flag.jpg"];
        self.flagView.hidden = YES;
        
        self.modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 30, 120, 20)];
        self.modeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        self.modeLabel.textAlignment = NSTextAlignmentCenter;
        self.modeLabel.textColor = [UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0];
        self.modeLabel.text = @"Debriefing";
        
        self.searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.searchButton setFrame:CGRectMake(20, 530, 200, 30)];
        self.searchButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
        self.searchButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.searchButton setTitleColor:[UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0] forState:UIControlStateNormal];
        [self.searchButton setTitle:@"Search" forState:UIControlStateNormal];
        [[self.searchButton layer] setCornerRadius:5];
        [[self.searchButton layer] setBorderColor:[[UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0] CGColor]];
        [[self.searchButton layer] setBorderWidth:1];
        [self.searchButton addTarget:self action:@selector(searchMode) forControlEvents:UIControlEventTouchUpInside];
        
        self.codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 60, 200, 20)];
        self.codeLabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
        self.codeLabel.textAlignment = NSTextAlignmentLeft;
        self.codeLabel.hidden = YES;
        
        self.positionLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 60, 100, 20)];
        self.positionLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        self.positionLabel.textAlignment = NSTextAlignmentCenter;
        self.positionLabel.hidden = YES;
        
        self.nameTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 90, 50, 20)];
        self.nameTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        self.nameTitleLabel.text = @"Name: ";
        self.nameTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.nameTitleLabel.hidden = YES;
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 90, 200, 20)];
        self.nameLabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
        self.nameLabel.textAlignment = NSTextAlignmentLeft;
        self.nameLabel.hidden = YES;
        
        self.emailTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, 50, 20)];
        self.emailTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        self.emailTitleLabel.text = @"Email: ";
        self.emailTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.emailTitleLabel.hidden = YES;
        
        self.emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 120, 200, 20)];
        self.emailLabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
        self.emailLabel.textAlignment = NSTextAlignmentLeft;
        self.emailLabel.hidden = YES;
        
        self.GPATitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, 50, 20)];
        self.GPATitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        self.GPATitleLabel.text = @"GPA: ";
        self.GPATitleLabel.textAlignment = NSTextAlignmentLeft;
        self.GPATitleLabel.hidden = YES;
        
        self.GPALabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 150, 200, 20)];
        self.GPALabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
        self.GPALabel.textAlignment = NSTextAlignmentLeft;
        self.emailLabel.hidden = YES;
        
        self.preferenceTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 100, 20)];
        self.preferenceTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        self.preferenceTitleLabel.text = @"Preference: ";
        self.preferenceTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.preferenceTitleLabel.hidden = YES;
        
        self.preferenceLabel = [[UILabel alloc] initWithFrame:CGRectMake(110, 180, 200, 20)];
        self.preferenceLabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
        self.preferenceLabel.textAlignment = NSTextAlignmentLeft;
        self.preferenceLabel.hidden = YES;
        
        self.noteViewTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 210, 100, 20)];
        self.noteViewTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        self.noteViewTitleLabel.text = @"Notes: ";
        self.noteViewTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.noteViewTitleLabel.hidden = YES;
        
        self.noteView = [[UITextView alloc] initWithFrame:CGRectMake(20, 240, 280, 90)];
        self.noteView.hidden = YES;
        //self.noteView.userInteractionEnabled = NO;
        self.noteView.backgroundColor = [UIColor colorWithRed:1.0 green:247.0/255.0 blue:201.0/255.0 alpha:1.0];
        [[self.noteView layer] setCornerRadius:10];
        [self.noteView setEditable:NO];
        
        self.rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(210, 200, 80, 80)];
        self.rankLabel.textAlignment = NSTextAlignmentCenter;
        self.rankLabel.textColor = [UIColor redColor];
        self.rankLabel.font = [UIFont fontWithName:@"IowanOldStyle-Bold" size:60];
        self.rankLabel.backgroundColor = [UIColor clearColor];
        self.rankLabel.hidden = YES;
        
        self.rankPointFiveLabel = [[UILabel alloc] initWithFrame:CGRectMake(255, 200, 40, 40)];
        self.rankPointFiveLabel.textAlignment = NSTextAlignmentCenter;
        self.rankPointFiveLabel.textColor = [UIColor redColor];
        self.rankPointFiveLabel.font = [UIFont fontWithName:@"IowanOldStyle-Bold" size:30];
        self.rankPointFiveLabel.backgroundColor = [UIColor clearColor];
        self.rankPointFiveLabel.hidden = YES;
        self.rankPointFiveLabel.text = @".5";
        
        self.businessUnit1TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 340, 130, 20)];
        self.businessUnit1TitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        self.businessUnit1TitleLabel.text = @"Business Unit1: ";
        self.businessUnit1TitleLabel.textAlignment = NSTextAlignmentLeft;
        self.businessUnit1TitleLabel.hidden = YES;
        
        self.businessUnit1Label = [[UILabel alloc] initWithFrame:CGRectMake(150, 340, 150, 20)];
        self.businessUnit1Label.font = [UIFont fontWithName:@"Helvetica" size: 15];
        self.businessUnit1Label.textAlignment = NSTextAlignmentLeft;
        self.businessUnit1Label.hidden = YES;
        
        self.businessUnit2TitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 370, 130, 20)];
        self.businessUnit2TitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        self.businessUnit2TitleLabel.text = @"Business Unit2: ";
        self.businessUnit2TitleLabel.textAlignment = NSTextAlignmentLeft;
        self.businessUnit2TitleLabel.hidden = YES;
        
        self.businessUnit2Label = [[UILabel alloc] initWithFrame:CGRectMake(150, 370, 150, 20)];
        self.businessUnit2Label.font = [UIFont fontWithName:@"Helvetica" size: 15];
        self.businessUnit2Label.textAlignment = NSTextAlignmentLeft;
        self.businessUnit2Label.hidden = YES;
        
        self.resumeTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 400, 100, 20)];
        self.resumeTitleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        self.resumeTitleLabel.text = @"Resume: ";
        self.resumeTitleLabel.textAlignment = NSTextAlignmentLeft;
        self.resumeTitleLabel.hidden = YES;
        
        self.resumeList = [[UITableView alloc] initWithFrame:CGRectMake(20, 425, 200, 88) style:UITableViewStylePlain];
        self.resumeList.delegate = self;
        self.resumeList.dataSource = self;
        self.resumeList.hidden = YES;
        [[self.resumeList layer] setCornerRadius:10];
        [[self.resumeList layer] setBorderColor:[[UIColor colorWithRed:202.0/255.0 green:202.0/255.0 blue:202.0/255.0 alpha:0.5] CGColor]];
        [[self.resumeList layer] setBorderWidth:2];
    }
    
    [self.view addSubview:self.tagButton];
    [self.view addSubview:self.signOutButton];
    [self.view addSubview:self.flagView];
    [self.view addSubview:self.modeLabel];
    
    [self.view addSubview:self.codeTitleLabel];
    [self.view addSubview:self.nameTitleLabel];
    [self.view addSubview:self.emailTitleLabel];
    [self.view addSubview:self.GPATitleLabel];
    [self.view addSubview:self.preferenceTitleLabel];
    [self.view addSubview:self.noteViewTitleLabel];
    [self.view addSubview:self.businessUnit1TitleLabel];
    [self.view addSubview:self.businessUnit2TitleLabel];
    [self.view addSubview:self.resumeTitleLabel];
    
    [self.view addSubview:self.codeLabel];
    [self.view addSubview:self.positionLabel];
    [self.view addSubview:self.nameLabel];
    [self.view addSubview:self.emailLabel];
    [self.view addSubview:self.GPALabel];
    [self.view addSubview:self.preferenceLabel];
    [self.view addSubview:self.noteView];
    [self.view addSubview:self.rankLabel];
    [self.view addSubview:self.rankPointFiveLabel];
    [self.view addSubview:self.businessUnit1Label];
    [self.view addSubview:self.businessUnit2Label];
    [self.view addSubview:self.resumeList];
    [self.view addSubview:self.searchButton];
    
    self.Broadcast = YES;
    
    [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] dataManager] sendTagListRequest:[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].userName];
    
    //-----test-----//
//    self.currentDataEntry = @{@"firstName":@"Tom",@"lastName":@"Cruise",@"email":@"tomcruise@gmail.com",@"interviewer":@"Peter Edmonston",@"code":@"Test-1",@"status":@"pending",@"pdf":[NSNumber numberWithBool:NO],@"position":@"Full-Time",@"preference":@"Actor",@"date":[NSDate date],@"note":@"#note#\nHello World.\n\n\n\n\nHello World.\n",@"rank":@"3.5",@"gpa":@"3.5",@"BU1" :@"NY-MEP", @"BU2" :@"LA_MEP"};
//    [self loadData];
    [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] dataManager] pullData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData
{
    if (!self.yrPromptMessageLabel.isHidden) {
        self.yrPromptMessageLabel.hidden = YES;
    }
    self.codeTitleLabel.hidden = NO;
    self.codeLabel.hidden = NO;
    self.nameTitleLabel.hidden = NO;
    self.nameLabel.hidden = NO;
    self.emailTitleLabel.hidden = NO;
    self.emailLabel.hidden = NO;
    self.GPATitleLabel.hidden = NO;
    self.GPALabel.hidden = NO;
    self.preferenceTitleLabel.hidden = NO;
    self.preferenceLabel.hidden = NO;
    self.noteViewTitleLabel.hidden = NO;
    self.noteView.hidden = NO;
    self.rankLabel.hidden = NO;
    self.businessUnit1TitleLabel.hidden = NO;
    self.businessUnit2TitleLabel.hidden = NO;
    self.businessUnit1Label.hidden = NO;
    self.businessUnit2Label.hidden = NO;
    self.resumeTitleLabel.hidden = NO;
    self.resumeList.hidden = NO;
    self.positionLabel.hidden = NO;
    self.tagButton.hidden = NO;

    self.flagView.hidden = YES;
    [self.tagButton setTitle:@"Flag" forState:UIControlStateNormal];
    
    for (NSString* rid in self.tagList)
    {
        if ([rid isEqualToString:self.currentDataEntry[@"code"]]) {
            self.flagView.hidden = NO;
            //tagged already then untag
            [self.tagButton setTitle:@"unFlag" forState:UIControlStateNormal];
            break;
        }
    }
    
    if ([self.currentDataEntry[@"rank"] isEqualToString:@"3.5"]) {
        self.rankPointFiveLabel.hidden = NO;
        self.rankLabel.text = @"3";
    }
    else
    {
        self.rankLabel.text = self.currentDataEntry[@"rank"];
        self.rankPointFiveLabel.hidden = YES;
    }
    
    self.codeLabel.text = self.currentDataEntry[@"code"];
    self.nameLabel.text = [NSString stringWithFormat:@"%@ %@",self.currentDataEntry[@"firstName"],self.currentDataEntry[@"lastName"]];
    self.emailLabel.text = self.currentDataEntry[@"email"];
    self.GPALabel.text = self.currentDataEntry[@"gpa"];
    self.preferenceLabel.text = self.currentDataEntry[@"preference"];
    self.noteView.text = self.currentDataEntry[@"note"];
    self.businessUnit1Label.text = self.currentDataEntry[@"BU1"];
    self.businessUnit2Label.text = self.currentDataEntry[@"BU2"];
    self.positionLabel.text = self.currentDataEntry[@"position"];
    [self.resumeList reloadData];
}

-(void)refreshViewWithNewBroadCast:(NSNotification*)notification
{
    NSString* prevRid = self.currentDataEntry[@"code"];
    self.currentDataEntry = [notification userInfo];
    [self loadData];
    
    for(NSString* rid in self.tagList)
    {
        if ([rid isEqualToString:self.currentDataEntry[@"code"]] && !self.Broadcast && ![prevRid isEqualToString:self.currentDataEntry[@"code"]]) {
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Attention!" message:@"A tagged candidate is being broadcasted." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Show me", nil];
            [alertView show];
        }
    }
    
    NSLog(@"%@",self.currentDataEntry);
}

-(void)fetchTagList:(NSNotification*)notification
{
    self.tagList = [(NSArray*)[notification userInfo] mutableCopy];
    self.searchModeView.tagList = self.tagList;
}

-(void)showImageWithBroadCast:(NSNotification*)notification
{
    UIImage *image = [UIImage imageWithData:(NSData*)[notification userInfo]];
    
    self.showingImageView = [[UIImageView alloc] initWithImage:image];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.showingImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    }
    else{
        [self.showingImageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, 480)];
    }
    
    self.yrScrollViewCancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.yrScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        self.yrScrollViewCancelButton.frame = CGRectMake(self.view.frame.size.width-110, 10, 100, 100);
    }
    else{
        self.yrScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, self.view.frame.size.width, 480)];
        self.yrScrollViewCancelButton.frame = CGRectMake(self.view.frame.size.width-55, 50, 50, 50);
    }
    //self.yrScrollView.contentSize = image.size;
    self.yrScrollView.contentSize = self.showingImageView.frame.size;
    [self.yrScrollView addSubview:self.showingImageView];
    [self.yrScrollView setDelegate:self];
    [self.yrScrollView setMaximumZoomScale:4];
    [self.yrScrollView setMinimumZoomScale:1];
    
//    self.grayView = [[UIView alloc] initWithFrame:self.view.frame];
//    self.grayView.backgroundColor = [UIColor blackColor];
//    self.grayView.alpha = 0.9;
//    
//    [self.view addSubview:self.grayView];
    [self.view addSubview:self.yrScrollView];
    
    [self.yrScrollViewCancelButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.yrScrollViewCancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[self.yrScrollViewCancelButton layer] setCornerRadius:50];
        [[self.yrScrollViewCancelButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrScrollViewCancelButton layer] setBorderWidth:5];
        
        self.yrScrollViewCancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [[self.yrScrollViewCancelButton layer] setCornerRadius:25];
        [[self.yrScrollViewCancelButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrScrollViewCancelButton layer] setBorderWidth:3];
        
        self.yrScrollViewCancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
    }
    
    
    [self.yrScrollViewCancelButton addTarget:self action:@selector(cancelScrollView) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.yrScrollViewCancelButton];
}

-(void)searchMode
{
    NSLog(@"from right");
    
    self.Broadcast = NO;
    [UIView beginAnimations:@"flip" context:nil];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:NO];
    [UIView setAnimationDuration:0.3];
    
    [self.view addSubview:self.searchModeView.view];
    
    [UIView commitAnimations];
}

-(void)broadcastMode
{
    NSLog(@"from left");
    self.Broadcast = YES;
    [UIView beginAnimations:@"flip" context:nil];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:NO];
    [UIView setAnimationDuration:0.3];
    
    [self.searchModeView.view removeFromSuperview];
    
    [UIView commitAnimations];
}

-(void)cancelScrollView
{
    [self dismissBusy];
    [self.yrScrollView removeFromSuperview];
    [self.yrScrollViewCancelButton removeFromSuperview];
    [self.resumeList setUserInteractionEnabled:YES];
}

-(void)tagCandidates
{
    [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] dataManager] tagCandidate:self.currentDataEntry[@"code"] withOption:self.tagButton.titleLabel.text from:[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].userName];
    
    //update title make sure the same request won't happen continously
    if ([self.tagButton.titleLabel.text isEqualToString:@"Flag"]) {
        [self.tagButton setTitle:@"unFlag" forState:UIControlStateNormal];
        [self.tagList addObject:self.currentDataEntry[@"code"]];
    }
    else
    {
        [self.tagButton setTitle:@"Flag" forState:UIControlStateNormal];
        if ([self.tagList count] != 0) {
            int index = -1;
            for (int i = 0; i<[self.tagList count]; i++) {
                if ([[self.tagList objectAtIndex:i] isEqualToString:self.currentDataEntry[@"code"]]) {
                    index = i;
                    break;
                }
            }
            if (index >=0) {
                [self.tagList removeObjectAtIndex:index];
            }
        }
    }
}

-(void)showBusy
{
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.view.center;
    
    self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
    self.grayView.backgroundColor = [UIColor darkGrayColor];
    self.grayView.alpha = 0.4;
    
    [self.view addSubview:self.grayView];
    [self.view addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
}

-(void)dismissBusy
{
    [self.activityIndicator stopAnimating];
    [self.activityIndicator removeFromSuperview];
    [self.grayView removeFromSuperview];
    self.activityIndicator = nil;
    self.grayView = nil;
    [self.searchModeView.detailView dismissBusy];
}

-(void)signOut
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Sign Out?" message:@"Signing out the debrief session" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alertView show];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.currentDataEntry[@"fileNames"] count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"resumeListIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = self.currentDataEntry[@"fileNames"][indexPath.row];
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //send request to host
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] dataManager] sendDataRequestForFile:self.currentDataEntry[@"fileNames"][indexPath.row]];
    [tableView setUserInteractionEnabled:NO];
    [self showBusy];
}

#pragma mark - UIScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews objectAtIndex:0];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Show me"]) {
        [self broadcastMode];
    }
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Yes"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"debriefModeOffNotification" object:nil];
    }
}

@end
