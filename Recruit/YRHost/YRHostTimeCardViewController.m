//
//  YRHostTimeCardViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/20/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRHostTimeCardViewController.h"
#import "CandidateEntry.h"
#import "Appointment.h"
#import "Interviewer.h"
#import "YRTimeCardView.h"

@interface YRHostTimeCardViewController ()

-(void)buildSchedule;

-(void)cardOnClick:(id)sender;

-(void)setUpInterviewNotification:(NSNotification *)notification;

-(void)reloadSchedule;

@end

@implementation YRHostTimeCardViewController
{
    BOOL dataIsReady;
}

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpInterviewNotification:) name:@"SetUpInterview" object:nil];
    dataIsReady = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.yrdataEntry = [NSMutableArray new];
    self.yrinterviewerEntry = [NSMutableArray new];
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    
    self.yrSchedulingController = [YRSchedulingViewController new];
    self.yrSchedulingController.managedObjectContext = self.managedObjectContext;
    
    self.columLabels = [NSMutableArray new];
    self.rowLabels = [NSMutableArray new];
    self.views = [NSMutableArray new];
    self.yrAppointmentInfo = [NSMutableArray new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.columLabels removeAllObjects];
    [self.rowLabels removeAllObjects];
    [self.views removeAllObjects];
    [self.yrAppointmentInfo removeAllObjects];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:self.managedObjectContext]];
    NSError* error = nil;
    NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [self setYrAppointmentInfo:[FetchResults mutableCopy]];
    
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
    dataIsReady = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)buildSchedule
{
    //======================UI parameters=========================//
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
    
    //======================Basic UI=========================//
    self.yrTimeLabelScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [self.toLeft intValue], self.view.frame.size.height)];
    self.yrPlaceOrNameScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self.toTop intValue])];
    self.yrTimeCardScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.yrTimeLabelScrollView.frame.size.width, self.yrPlaceOrNameScrollView.frame.size.height, self.view.frame.size.width-self.yrTimeLabelScrollView.frame.size.width, self.view.frame.size.height-self.yrPlaceOrNameScrollView.frame.size.height-49)];
    
    [self.yrTimeCardScrollView setContentSize:CGSizeMake(([self.cardWidth intValue]+5)*[self.yrColumNumber intValue]+[self.toLeft intValue], ([self.cardHeight intValue]+5)*[self.yrRowNumber intValue])];
    [self.yrTimeLabelScrollView setContentSize:CGSizeMake(self.yrTimeLabelScrollView.frame.size.width, ([self.cardHeight intValue]+5)*[self.yrRowNumber intValue])];
    [self.yrPlaceOrNameScrollView setContentSize:CGSizeMake(([self.cardWidth intValue]+5)*[self.yrColumNumber intValue]+[self.toLeft intValue], self.yrPlaceOrNameScrollView.frame.size.height)];
    
    
    //======================add button=========================//
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
        
        //=============set up time label for each row============//
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
            
            cellView.roomIndex = j;
            cellView.slotIndex = i;
            cellView.interviewStartTime = timeLabel.text;
            
            [self.views addObject:cellView];//add the view into array
            [self.yrTimeCardScrollView addSubview:cellView];
        }
    }
    
    //================load Data in==================//(iterate through all the data entry)
    
    if ([self.yrAppointmentInfo count] != 0) {
        for (Appointment* ap in self.yrAppointmentInfo) {
            int index = [ap.apIndex_y intValue] * [self.yrColumNumber intValue] + [ap.apIndex_x intValue];
            
            if (index < [self.views count]) {
                YRTimeCardView* targetCell = [self.views objectAtIndex:index];
                targetCell.candidateNameLabel.text = [NSString stringWithFormat:@"%@ %@",ap.candidate.firstName,ap.candidate.lastName];
                targetCell.interviewerNameLabel.text = ap.interviewers.name;
                targetCell.codeLabel.text = ap.candidate.code;
            }
            else
            {
                NSLog(@"index out of range");
            }
        }
    }
    
    [self.view addSubview:self.yrTimeCardScrollView];
    [self.view addSubview:self.yrTimeLabelScrollView];
    [self.view addSubview:self.yrPlaceOrNameScrollView];
}

-(void)cardOnClick:(id)sender
{
    if (!dataIsReady) {
        self.yrSchedulingController.yrTriggeringView = (UIControl*)sender;
        
        [UIView beginAnimations:@"pop" context:Nil];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:NO];
        [UIView setAnimationDuration:0.5];
        
        [self.view addSubview:self.yrSchedulingController.view];
        
        [UIView commitAnimations];
    }
    else
    {
        //after one click
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:self.managedObjectContext]];
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"apIndex_x = %d and apIndex_y = %d",[(YRTimeCardView*)sender roomIndex], [(YRTimeCardView*)sender slotIndex]]];
        
        NSError* error = nil;
        NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        //there is an appointment existing in that index
        if ([FetchResults count] != 0) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"The slot is taken." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
            [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"code = '%@'",self.passedInRid]]];
            NSError* error = nil;
            
            NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            
            if ([FetchResults count] != 0) {
                CandidateEntry* fetched = (CandidateEntry*)[FetchResults objectAtIndex:0];
                
                Appointment* item = (Appointment*)[NSEntityDescription insertNewObjectForEntityForName:@"Appointment" inManagedObjectContext:self.managedObjectContext];
                
                item.startTime = [(YRTimeCardView*)sender interviewStartTime];
                item.apIndex_x = [NSNumber numberWithInt:[(YRTimeCardView*)sender roomIndex]];
                item.apIndex_y = [NSNumber numberWithInt:[(YRTimeCardView*)sender slotIndex]];
                
                [fetched addAppointmentsObject:item];
                [fetched setStatus:@"scheduled"];
                
                if (![[self managedObjectContext] save:&error]) {
                    NSLog(@"ERROR -- saving coredata");
                }
                
                [[(YRTimeCardView*)sender codeLabel] setText:self.passedInRid];
                
                [[(YRTimeCardView*)sender candidateNameLabel] setText:[NSString stringWithFormat:@"%@ %@",item.candidate.firstName,item.candidate.lastName]];
                
                [[(YRTimeCardView*)sender interviewerNameLabel] setText:@""];
            }
            else
            {
                NSLog(@"the candidate doesn't exist in the list");
            }
            dataIsReady = NO;
        }
    }
}

-(void)setUpInterviewNotification:(NSNotification *)notification
{
    dataIsReady = YES;
    self.passedInRid = notification.object[@"code"];
}

-(void)reloadSchedule
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[self.yrColumNumber intValue]+1]  forKey:@"scheduleColums"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.yrSchedulingController.view removeFromSuperview];
    [self.yrTimeCardScrollView removeFromSuperview];
    [self.yrTimeLabelScrollView removeFromSuperview];
    [self.yrPlaceOrNameScrollView removeFromSuperview];
    self.yrTimeCardScrollView = nil;
    self.yrTimeLabelScrollView = nil;
    self.yrPlaceOrNameScrollView = nil;
    
    [self.views removeAllObjects];
    [self.yrAppointmentInfo removeAllObjects];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Appointment" inManagedObjectContext:self.managedObjectContext]];
    NSError* error = nil;
    NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    [self setYrAppointmentInfo:[FetchResults mutableCopy]];
    
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
