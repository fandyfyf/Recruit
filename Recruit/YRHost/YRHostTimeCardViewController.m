//
//  YRHostTimeCardViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/20/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRHostTimeCardViewController.h"
#import "CandidateEntry.h"
#import "YRTimeCardView.h"
#import "YRInterviewAppointmentInfo.h"

@interface YRHostTimeCardViewController ()

-(void)buildSchedule;
//-(void)showList;
-(void)cardOnClick:(id)sender;

-(void)reloadSchedule;

@end

@implementation YRHostTimeCardViewController
{
    BOOL viewPoped;
    BOOL firstLoad;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    //[self buildSchedule];
    self.view.backgroundColor = [UIColor purpleColor];
    viewPoped = NO;
    self.yrdataEntry = [NSMutableArray new];
    self.yrinterviewerEntry = [NSMutableArray new];
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    
    self.yrSchedulingController = [YRSchedulingViewController new];
    self.yrSchedulingController.managedObjectContext = self.managedObjectContext;
    
    self.columLabels = [NSMutableArray new];
    self.rowLabels = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.columLabels removeAllObjects];
    [self.rowLabels removeAllObjects];
    
    self.yrAppointmentInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kYRAppointmentInfoKey];
    
    if (self.yrAppointmentInfo == nil) {
        self.yrAppointmentInfo = [NSMutableArray new];
        firstLoad = YES;
    }
    
    [self buildSchedule];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.yrSchedulingController.view removeFromSuperview];
    [self.yrTimeCardScrollView removeFromSuperview];
    [self.yrTimeLabelScrollView removeFromSuperview];
    [self.yrPlaceOrNameScrollView removeFromSuperview];
    self.yrTimeCardScrollView = nil;
    self.yrTimeLabelScrollView = nil;
    self.yrPlaceOrNameScrollView = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)buildSchedule
{
//    UIButton *scheduleButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    scheduleButton.frame = CGRectMake(0, 20, 50, 50);
//    [scheduleButton setTitle:@"Set" forState:UIControlStateNormal];
//    scheduleButton.tintColor = [UIColor whiteColor];
//    [scheduleButton addTarget:self action:@selector(showList) forControlEvents:UIControlEventTouchUpInside];
//    
//    [self.view addSubview:scheduleButton];
    
    self.cardWidth = [NSNumber numberWithInt:130];
    self.cardHeight = [NSNumber numberWithInt:100];
    self.toTop = [NSNumber numberWithInt:70];
    self.toLeft = [NSNumber numberWithInt:50];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.cardWidth = [NSNumber numberWithInt:195];
        self.cardHeight = [NSNumber numberWithInt:150];
        self.toTop = [NSNumber numberWithInt:100];
        self.toLeft = [NSNumber numberWithInt:100];
    }
    
    self.yrRowNumber = [NSNumber numberWithInt:20];
    self.yrColumNumber = [[NSUserDefaults standardUserDefaults] valueForKey:@"scheduleColums"];
    
    self.yrTimeLabelScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [self.toLeft intValue], self.view.frame.size.height)];
    //self.yrTimeLabelScrollView.backgroundColor = [UIColor purpleColor];
    self.yrPlaceOrNameScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self.toTop intValue])];
    self.yrTimeCardScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.yrTimeLabelScrollView.frame.size.width, self.yrPlaceOrNameScrollView.frame.size.height, self.view.frame.size.width-self.yrTimeLabelScrollView.frame.size.width, self.view.frame.size.height-self.yrPlaceOrNameScrollView.frame.size.height-49)];
    
    [self.yrTimeCardScrollView setContentSize:CGSizeMake(([self.cardWidth intValue]+5)*[self.yrColumNumber intValue]+[self.toLeft intValue], ([self.cardHeight intValue]+5)*[self.yrRowNumber intValue])];
    [self.yrTimeLabelScrollView setContentSize:CGSizeMake(self.yrTimeLabelScrollView.frame.size.width, ([self.cardHeight intValue]+5)*[self.yrRowNumber intValue])];
    [self.yrPlaceOrNameScrollView setContentSize:CGSizeMake(([self.cardWidth intValue]+5)*[self.yrColumNumber intValue]+[self.toLeft intValue], self.yrPlaceOrNameScrollView.frame.size.height)];
    
    
    //======================add button
    UIButton* addColumButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    addColumButton.frame = CGRectMake(([self.cardWidth intValue]+5)*[self.yrColumNumber intValue]+[self.toLeft intValue
                                                                                                   ]+10, [self.toTop intValue] - 40, 30, 30);
    [self.yrPlaceOrNameScrollView addSubview:addColumButton];
    [addColumButton addTarget:self action:@selector(reloadSchedule) forControlEvents:UIControlEventTouchUpInside];
    [addColumButton setTintColor:[UIColor whiteColor]];
    
    self.yrTimeCardScrollView.delegate = self;
    self.yrTimeCardScrollView.directionalLockEnabled = YES;

    
    for (int i=0; i<[self.yrColumNumber intValue]; i++) {
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake([self.toLeft intValue]+i*([self.cardWidth intValue]+5), [self.toTop intValue] - 40, [self.cardWidth intValue], 30)];
        
        [nameLabel setText:[NSString stringWithFormat:@"Room %d",i]];
        nameLabel.textColor = [UIColor whiteColor];
        nameLabel.font = [UIFont boldSystemFontOfSize:20];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            nameLabel.font = [UIFont boldSystemFontOfSize:25];
        }
        
        nameLabel.textAlignment = NSTextAlignmentCenter;
        [self.yrPlaceOrNameScrollView addSubview:nameLabel];
        [self.columLabels addObject:nameLabel];
    }
    
    int hour = [[[NSUserDefaults standardUserDefaults] valueForKey:@"scheduleStartTime"] intValue];
    int min = 0;
    int period = [[[NSUserDefaults standardUserDefaults] valueForKey:@"scheduleDuration"] intValue];
    
    for (int i=0; i<[self.yrRowNumber intValue] ; i++) {
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, i*([self.cardHeight intValue]+5)+[self.toTop intValue], [self.toLeft intValue], 20)];
        if (min < 10) {
            [timeLabel setText:[NSString stringWithFormat:@"%d : 0%d",hour,min]];
        }
        else
        {
            [timeLabel setText:[NSString stringWithFormat:@"%d : %d",hour,min]];
        }
        min = min + period;
        if (min >= 60) {
            hour ++;
            min = min%60;
        }
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.font = [UIFont boldSystemFontOfSize:15];
        timeLabel.textAlignment = NSTextAlignmentLeft;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            timeLabel.font = [UIFont boldSystemFontOfSize:25];
            timeLabel.textAlignment = NSTextAlignmentCenter;
        }
        
        [self.yrTimeLabelScrollView addSubview:timeLabel];
        
        [self.rowLabels addObject:timeLabel];
        
        
        for (int j=0; j<[self.yrColumNumber intValue] ; j++)
        {
            YRTimeCardView *cellView = [[YRTimeCardView alloc] initWithFrame:CGRectMake(j*([self.cardWidth intValue]+5), i*([self.cardHeight intValue]+5), [self.cardWidth intValue], [self.cardHeight intValue])];
            [[cellView layer] setBorderWidth:2];
            [[cellView layer] setBorderColor:[[UIColor blackColor] CGColor]];
            [[cellView layer] setCornerRadius:5];
            cellView.backgroundColor = [UIColor whiteColor];
            
            [cellView addTarget:self action:@selector(cardOnClick:) forControlEvents:UIControlEventTouchUpInside];
            cellView.index = i*[self.yrColumNumber intValue] + j;
            
            cellView.interviewStartTime = timeLabel.text;
            
            if (firstLoad) {
                YRInterviewAppointmentInfo* newInfo = [YRInterviewAppointmentInfo new];
                newInfo.index = i*[self.yrColumNumber intValue] + j;
                
                NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject:newInfo];
                
                [self.yrAppointmentInfo addObject:encodedData];
            }
            else
            {
                //load data
                NSData* curr = [self.yrAppointmentInfo objectAtIndex:i*[self.yrColumNumber intValue]+j];
                YRInterviewAppointmentInfo* decodedData = [NSKeyedUnarchiver unarchiveObjectWithData:curr];
                
                if ([decodedData isTaken]) {
                    cellView.candidateNameLabel.text = decodedData.candidateName;
                    if ([decodedData.interviewerName isEqualToString:@""]) {
                        NSLog(@"%@",decodedData.interviewerName);
                        cellView.interviewerNameLabel.text = @"";
                    }
                    else
                    {
                        cellView.interviewerNameLabel.text = [NSString stringWithFormat:@"%@",decodedData.interviewerName];
                    }
                    cellView.codeLabel.text = decodedData.candidateRid;
                }
            }
            
            //cellView.backgroundColor = [UIColor lightGrayColor];
            [self.yrTimeCardScrollView addSubview:cellView];
        }
    }
    firstLoad = NO;
    
    [[NSUserDefaults standardUserDefaults] setObject:self.yrAppointmentInfo forKey:kYRAppointmentInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [self.view addSubview:self.yrTimeCardScrollView];
    [self.view addSubview:self.yrTimeLabelScrollView];
    [self.view addSubview:self.yrPlaceOrNameScrollView];
}

//-(void)showList
//{
//    self.cardDetailView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/4,self.view.frame.size.height/4,self.view.frame.size.width/2, self.view.frame.size.height/2)];
//    
//    self.cardDetailView.backgroundColor = [UIColor whiteColor];
//    
//    self.recommandListTable = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.cardDetailView.frame.size.width, self.cardDetailView.frame.size.height) style:UITableViewStylePlain];
//    
//    [self.cardDetailView addSubview:self.recommandListTable];
//    self.recommandListTable.delegate = self;
//    self.recommandListTable.dataSource = self;
//    
//    
//    [[self.cardDetailView layer] setBorderColor:[[UIColor purpleColor] CGColor]];
//    [[self.cardDetailView layer] setBorderWidth:2];
//    [self.view addSubview:self.cardDetailView];
//}

-(void)cardOnClick:(id)sender
{
//    if (!viewPoped) {
//        NSLog(@"hello world");
//        
//        self.yrTriggeringView = (UIControl*)sender;
//        
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            self.cardDetailView = [[UIView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/4,self.view.frame.size.height/4,self.view.frame.size.width/2, self.view.frame.size.height/2)];
//            
//            self.cardDetailView.backgroundColor = [UIColor whiteColor];
//            self.cardDetailView.hidden = YES;
//            
//            UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
//            
//            
//            
//            [[self.cardDetailView layer] setBorderColor:[[UIColor purpleColor] CGColor]];
//            [[self.cardDetailView layer] setBorderWidth:2];
//            [self.view addSubview:self.cardDetailView];
//            
//            [UIView beginAnimations:@"pop" context:Nil];
//            
//            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.cardDetailView cache:NO];
//            [UIView setAnimationDuration:1];
//            
//            [self.cardDetailView setHidden:NO];
//            
//            
//            [UIView commitAnimations];
//        }
//        else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
//        {
//            self.cardDetailView = [[UIView alloc] initWithFrame:self.view.frame];
//            self.cardDetailView.backgroundColor = [UIColor whiteColor];
//            
//            UILabel* candidateTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 40, 150, 20)];
//            [candidateTitleLabel setText:@"Candidates: "];
//            candidateTitleLabel.font = [UIFont boldSystemFontOfSize:15];
//            [self.cardDetailView addSubview:candidateTitleLabel];
//            
//            UILabel* interviewerTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 250, 150, 20)];
//            [interviewerTitleLabel setText:@"Interviewers: "];
//            interviewerTitleLabel.font = [UIFont boldSystemFontOfSize:15];
//            [self.cardDetailView addSubview:interviewerTitleLabel];
//            
//            self.candidatesPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width, 300)];
//            self.interviewerPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 250, self.view.frame.size.width, 300)];
//            self.candidatesPickerView.delegate = self;
//            self.candidatesPickerView.dataSource = self;
//            self.interviewerPickerView.delegate = self;
//            self.interviewerPickerView.dataSource = self;
//            
//            [self fetch];
//            
//            [self.cardDetailView addSubview:self.candidatesPickerView];
//            [self.cardDetailView addSubview:self.interviewerPickerView];
//            
//            UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
//            [cancelButton setFrame:CGRectMake(20, 480, 50, 30)];
//            [cancelButton setTintColor:[UIColor purpleColor]];
//            [cancelButton addTarget:self action:@selector(cancelDetail) forControlEvents:UIControlEventTouchUpInside];
//            
//            [self.cardDetailView addSubview:cancelButton];
//            
//            UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            [doneButton setTitle:@"Done" forState:UIControlStateNormal];
//            [doneButton setFrame:CGRectMake(250, 480, 50, 30)];
//            [doneButton setTintColor:[UIColor purpleColor]];
//            [doneButton addTarget:self action:@selector(cancelDetail) forControlEvents:UIControlEventTouchUpInside];
//            
//            [self.cardDetailView addSubview:doneButton];
//            
//            [UIView beginAnimations:@"pop" context:Nil];
//            
//            [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:NO];
//            [UIView setAnimationDuration:1];
//            
//            [self.view addSubview:self.cardDetailView];
//        
//            [UIView commitAnimations];
//        }
//        
//        viewPoped = YES;
//    }
    self.yrSchedulingController.yrTriggeringView = (UIControl*)sender;
    
    [UIView beginAnimations:@"pop" context:Nil];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:NO];
    [UIView setAnimationDuration:0.5];
    
    [self.view addSubview:self.yrSchedulingController.view];
    
    [UIView commitAnimations];
}

-(void)reloadSchedule
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[self.yrColumNumber intValue]+1]  forKey:@"scheduleColums"];
    //[[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMutableArray* infoArray = [[[NSUserDefaults standardUserDefaults] objectForKey:kYRAppointmentInfoKey] mutableCopy];
    
    for (int i = 0; i < [self.yrRowNumber intValue]; i++) {
        YRInterviewAppointmentInfo* newInfo = [YRInterviewAppointmentInfo new];
        
        NSData* encodedData = [NSKeyedArchiver archivedDataWithRootObject:newInfo];
        
        [infoArray insertObject:encodedData atIndex:[self.yrColumNumber intValue]*(i+1) + i];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:infoArray forKey:kYRAppointmentInfoKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.yrSchedulingController.view removeFromSuperview];
    [self.yrTimeCardScrollView removeFromSuperview];
    [self.yrTimeLabelScrollView removeFromSuperview];
    [self.yrPlaceOrNameScrollView removeFromSuperview];
    self.yrTimeCardScrollView = nil;
    self.yrTimeLabelScrollView = nil;
    self.yrPlaceOrNameScrollView = nil;
    
    self.yrAppointmentInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kYRAppointmentInfoKey];
    [self buildSchedule];
}

#pragma mark - UIScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.yrTimeLabelScrollView.contentOffset = CGPointMake(0, self.yrTimeCardScrollView.contentOffset.y);
    self.yrPlaceOrNameScrollView.contentOffset = CGPointMake(self.yrTimeCardScrollView.contentOffset.x, 0);
    
    for (UILabel* curr in self.rowLabels) {
        if (curr.frame.origin.y - self.yrTimeCardScrollView.contentOffset.y < [self.toTop intValue]) {
            curr.alpha = (curr.frame.origin.y - self.yrTimeCardScrollView.contentOffset.y)/[self.toTop intValue];
        }
        else
        {
            curr.alpha = 1;
        }
    }
    
    for (UILabel* curr in self.columLabels) {
        if (curr.frame.origin.x - self.yrTimeCardScrollView.contentOffset.x < [self.toLeft intValue]) {
            curr.alpha = (curr.frame.origin.x - self.yrTimeCardScrollView.contentOffset.x+30)/[self.toLeft intValue];
        }
        else
        {
            curr.alpha = 1;
        }
    }
    
}


@end