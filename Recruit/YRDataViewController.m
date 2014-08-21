//
//  YRDataViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/10/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRDataViewController.h"
#import "YRinfoDataCell.h"
#import "YRHostMainViewController.h"
#import "CandidateEntry.h"

@interface YRDataViewController ()

@property (strong, nonatomic) CandidateEntry* currentEntry;
@property (strong, nonatomic) NSArray* fileNames;

-(void)needUpdateTableNotification:(NSNotification *)notification;

-(void)setUpInterviewNotification:(NSNotification *)notification;

-(void)updateTagInformation:(NSNotification*)notification;

-(void)fetchCandidates;

-(void)sortMethodSelected:(UISegmentedControl *)mySegmentedControl;

-(void)checkSchedule:(UIGestureRecognizer*)tapRecognizer;

-(void)showImage:(UIGestureRecognizer*)tapRecognizer;

-(void)cancelScrollView;

-(void)scrollLeft;

-(void)scrollRight;

@end

@implementation YRDataViewController
{
    BOOL checkScheduleMode;
    int showingImageIndex;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ListToDetail"]) {
        [segue.destinationViewController setValue:self.currentEntry forKey:@"dataSource"];
        if (checkScheduleMode) {
            [segue.destinationViewController setValue:[NSNumber numberWithBool:YES] forKey:@"checkScheduleFlag"];
        }
        else
        {
            [segue.destinationViewController setValue:[NSNumber numberWithBool:NO] forKey:@"checkScheduleFlag"];
        }
        checkScheduleMode = NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.yrdataEntry = [NSMutableArray new];
    [self.infoDataList setDelegate:self];
    [self.infoDataList setDataSource:self];
    self.fileNames = [NSArray new];
    
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateTableNotification:) name:kYRDataManagerNeedUpdateTableNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUpInterviewNotification:) name:@"SetUpInterview" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTagInformation:) name:kYRDataManagerNeedUpdateTagInfoNotification object:nil];
    
    self.yrPrefix = [(YRHostMainViewController*)self.tabBarController.viewControllers[0] yrPrefix];
    
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    
    //[self fetchCandidates];
    
    [self.yrSortingSegmentControl addTarget:self action:@selector(sortMethodSelected:) forControlEvents:UIControlEventValueChanged];
    [self.yrPositionFilter addTarget:self action:@selector(sortMethodSelected:) forControlEvents:UIControlEventValueChanged];
    
    checkScheduleMode = NO;
    
    if ([self.appDelegate.mcManager.userName isEqualToString:@"kirito"]) {
        self.yrAdministorDeleteButton.hidden = NO;
    }
    else
    {
        self.yrAdministorDeleteButton.hidden = YES;
    }
    
    self.yrSearchBar.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchCandidates]; //updatedata before each time the view appear
    
    [self.infoDataList reloadData];
    self.yrSearchBar.text = @"";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showFiles
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSArray *files = [manager contentsOfDirectoryAtPath:documentsDirectory error:nil];
    
    for (NSString *file in files) {
        NSLog(@"File at: %@",file);
    }
}

-(void)needUpdateTableNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        CandidateEntry* curr = [[notification userInfo] objectForKey:@"entry"];
        
        NSLog(@"%@",curr);
        
        if ([self.yrPositionFilter selectedSegmentIndex] == 0) {
            [self.yrdataEntry addObject:curr];
            
            [self.infoDataList beginUpdates];
            
            
            if ([self.yrdataEntry count] % 2 == 0) {
                [self.infoDataList insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.yrdataEntry count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            }
            else
            {
                [self.infoDataList insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.yrdataEntry count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
            }
            
            [self.infoDataList endUpdates];
        }
        else if ([self.yrPositionFilter selectedSegmentIndex] == 1 && [curr.position isEqualToString:@"Intern"])
        {
            [self.yrdataEntry addObject:curr];
            [self.infoDataList beginUpdates];
            
            
            if ([self.yrdataEntry count] % 2 == 0) {
                [self.infoDataList insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.yrdataEntry count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            }
            else
            {
                [self.infoDataList insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.yrdataEntry count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
            }
            
            [self.infoDataList endUpdates];
        }
        else if ([self.yrPositionFilter selectedSegmentIndex] == 2 && [curr.position isEqualToString:@"Full-Time"])
        {
            [self.yrdataEntry addObject:curr];
            
            [self.infoDataList beginUpdates];
            
            
            if ([self.yrdataEntry count] % 2 == 0) {
                [self.infoDataList insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.yrdataEntry count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
            }
            else
            {
                [self.infoDataList insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.yrdataEntry count]-1 inSection:0]] withRowAnimation:UITableViewRowAnimationRight];
            }
            
            [self.infoDataList endUpdates];
        }
    });
}

-(void)setUpInterviewNotification:(NSNotification *)notification
{
    [self.tabBarController setSelectedViewController:[self.tabBarController.viewControllers objectAtIndex:2]];
}

-(void)updateTagInformation:(NSNotification*)notification
{
    //update flag...
    [self fetchCandidates];
    [self.infoDataList reloadData];
}

-(void)fetchCandidates
{
    [self.yrdataEntry removeAllObjects];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
    
    if(self.yrSortingSegmentControl.selectedSegmentIndex == 1)
    {
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]]];
    }
    
    if (self.yrPositionFilter.selectedSegmentIndex != 0) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"position = %@",[self.yrPositionFilter titleForSegmentAtIndex:self.yrPositionFilter.selectedSegmentIndex]]];
    }
    
    NSError* error = nil;
    NSMutableArray* mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    [self setYrdataEntry:mutableFetchResults];
}

-(void)sortMethodSelected:(UISegmentedControl *)mySegmentedControl
{
    //guarantee the insert only happen in main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.yrdataEntry removeAllObjects];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
        
        if(self.yrSortingSegmentControl.selectedSegmentIndex == 1)
        {
            [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]]];
        }
        
        if (self.yrPositionFilter.selectedSegmentIndex != 0) {
            [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"position = %@",[self.yrPositionFilter titleForSegmentAtIndex:self.yrPositionFilter.selectedSegmentIndex]]];
        }
        
        NSError* error = nil;
        NSMutableArray* mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
        [self setYrdataEntry:mutableFetchResults];
        [self.infoDataList reloadData];
    });
}

-(void)checkSchedule:(UIGestureRecognizer*)tapRecognizer
{
    NSLog(@"Tap");
    CGPoint tapLocation = [tapRecognizer locationInView:self.infoDataList];
    NSIndexPath* indexPath = [self.infoDataList indexPathForRowAtPoint:tapLocation];
    YRinfoDataCell* tappedCell = (YRinfoDataCell*)[self.infoDataList cellForRowAtIndexPath:indexPath];
    if ([tappedCell.yrstatusLabel.text isEqualToString:@"scheduled"]) {
        self.currentEntry = (CandidateEntry*)[self.yrdataEntry objectAtIndex:indexPath.row];
        checkScheduleMode = YES;
        [self performSegueWithIdentifier:@"ListToDetail" sender:self];
    }
    else if ([tappedCell.yrstatusLabel.text isEqualToString:@"pending"])
    {
        NSDictionary* dic = @{@"code" : tappedCell.yrcodeLabel.text,@"name" :[NSString stringWithFormat:@"%@",tappedCell.yrnameLabel.text]};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SetUpInterview" object:dic];
    }
}

-(void)showImage:(UIGestureRecognizer*)tapRecognizer
{
    CGPoint tapLocation = [tapRecognizer locationInView:self.infoDataList];
    NSIndexPath* indexPath = [self.infoDataList indexPathForRowAtPoint:tapLocation];
//    YRinfoDataCell* tappedCell = (YRinfoDataCell*)[self.infoDataList cellForRowAtIndexPath:indexPath];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
    
    NSError *error;
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
    showingImageIndex = 0;
    self.fileNames = [(CandidateEntry*)[self.yrdataEntry objectAtIndex:indexPath.row] fileNames];
    
    NSString* fileName = self.fileNames[showingImageIndex];
    
    NSString *fullPath = [dataPath stringByAppendingPathComponent:fileName];
    
    UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfFile:fullPath]];
    
    
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
    
    self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
    self.grayView.backgroundColor = [UIColor blackColor];
    self.grayView.alpha = 0.9;
    
    [self.view addSubview:self.grayView];
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
    
    UIGestureRecognizer* swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(scrollLeft)];
    [(UISwipeGestureRecognizer*)swipe setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.yrScrollView addGestureRecognizer:swipe];
    
    swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(scrollRight)];
    [(UISwipeGestureRecognizer*)swipe setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.yrScrollView addGestureRecognizer:swipe];
    
    swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(scrollLeft)];
    [(UISwipeGestureRecognizer*)swipe setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.yrScrollView addGestureRecognizer:swipe];
    
    swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(scrollRight)];
    [(UISwipeGestureRecognizer*)swipe setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.yrScrollView addGestureRecognizer:swipe];
}

-(void)cancelScrollView
{
    [self.yrScrollView removeFromSuperview];
    [self.yrScrollViewCancelButton removeFromSuperview];
    [self.grayView removeFromSuperview];
}

- (IBAction)deleteCoreData:(id)sender {
    
    [self.yrdataEntry removeAllObjects];
    
    [self.infoDataList reloadData];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
    
    NSError* error = nil;
    NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (CandidateEntry* candidate in FetchResults) {
        [self.managedObjectContext deleteObject:candidate];
    }
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"ERROR -- saving coredata");
    }
}

- (IBAction)cancelSearch:(id)sender {
    [self.yrSearchBar resignFirstResponder];
    self.yrSearchBar.text = @"";
    
    //reload data without search input
    [self.yrdataEntry removeAllObjects];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
    
    if(self.yrSortingSegmentControl.selectedSegmentIndex == 1)
    {
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]]];
    }
    
    if (self.yrPositionFilter.selectedSegmentIndex != 0) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"position = %@",[self.yrPositionFilter titleForSegmentAtIndex:self.yrPositionFilter.selectedSegmentIndex]]];
    }
    
    NSError* error = nil;
    NSMutableArray* mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    [self setYrdataEntry:mutableFetchResults];
    
    [self.infoDataList reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

-(void)scrollLeft
{
    NSLog(@"Left");
    if (showingImageIndex+1<[self.fileNames count]) {
        showingImageIndex = showingImageIndex + 1;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
        
        NSError *error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        
        NSString* fileName = self.fileNames[showingImageIndex];
        
        NSString *fullPath = [dataPath stringByAppendingPathComponent:fileName];
        
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfFile:fullPath]];
        
        [UIView beginAnimations:@"swipe" context:nil];
        
        [UIView setAnimationDuration:0.7];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:self.showingImageView cache:NO];
        
        self.showingImageView.image = image;
        
        [UIView commitAnimations];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Last Page" message:@"This is the last Page" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

-(void)scrollRight
{
    NSLog(@"Right");
    
    if (showingImageIndex-1>=0) {
        showingImageIndex = showingImageIndex -1;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
        
        NSError *error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        
        NSString* fileName = self.fileNames[showingImageIndex];
        
        NSString *fullPath = [dataPath stringByAppendingPathComponent:fileName];
        
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfFile:fullPath]];
        
        [UIView beginAnimations:@"swipe" context:nil];
        
        [UIView setAnimationDuration:0.7];
        
        [UIView setAnimationTransition:UIViewAnimationTransitionCurlDown forView:self.showingImageView cache:NO];
        
        self.showingImageView.image = image;
        
        [UIView commitAnimations];
    }
    else
    {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"First Page" message:@"This is the first Page" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Data Entries";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.yrdataEntry.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"dataIdentifier";
    
    YRinfoDataCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell == nil) {
        cell = [YRinfoDataCell new];
    }
    
    CandidateEntry* current = (CandidateEntry*)[self.yrdataEntry objectAtIndex:indexPath.row];
    
 
    cell.yrnameLabel.text = [NSString stringWithFormat:@"%@ %@",current.firstName,current.lastName];
    cell.yremailLabel.text = current.emailAddress;
    cell.yrinterviewerLabel.text = current.interviewer;
    cell.yrcodeLabel.text = current.code;
    
    if ([current.tagList count] != 0) {
        cell.yrcodeLabel.textColor = [UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0];
        cell.yrStarView.hidden = NO;
    }
    else
    {
        cell.yrcodeLabel.textColor = [UIColor blackColor];
        cell.yrStarView.hidden = YES;
    }
    
    cell.yrstatusLabel.text = current.status;
    if ([current.status isEqualToString:@"pending"]) {
        cell.yrstatusLabel.textColor = [UIColor grayColor];
    }
    else if([current.status isEqualToString:@"rejected"])
    {
        cell.yrstatusLabel.textColor = [UIColor redColor];
    }
    else if([current.status isEqualToString:@"scheduled"])
    {
        cell.yrstatusLabel.textColor = [UIColor colorWithRed:110.0/255.0 green:163.0/255.0 blue:41.0/255.0 alpha:1.0];
    }
    else
    {
        //
    }
    cell.yrGPALabel.text = [NSString stringWithFormat:@"%@",current.gpa];
    
    if ([current.rank floatValue] == 3.5) {
        cell.yrRankLabel.text = @"3";
        cell.yrHalfRankLabel.hidden = NO;
    }
    else
    {
        cell.yrRankLabel.text = [current.rank stringValue];
        cell.yrHalfRankLabel.hidden = YES;
    }
    
    if ([current.pdf boolValue]) {
        [cell.yrPDFIconView setHidden:NO];
        cell.yrPDFIconView.image = [UIImage imageNamed:@"document.png"];
    }
    else
    {
        [cell.yrPDFIconView setHidden:YES];
        cell.yrPDFIconView.image = nil;
    }
    
    [cell.yrstatusLabel setUserInteractionEnabled:YES];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(checkSchedule:)];
    [cell.yrstatusLabel addGestureRecognizer:tapGesture];
    
    [cell.yrPDFIconView setUserInteractionEnabled:YES];
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showImage:)];
    [cell.yrPDFIconView addGestureRecognizer:tapGesture];
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentEntry = (CandidateEntry*)[self.yrdataEntry objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ListToDetail" sender:self];
    
    //broadcast the current entry: could just move the folloing code to detail view after the info got loaded
    
//    if ([[[NSUserDefaults standardUserDefaults] valueForKey:@"DebriefModeOn"] boolValue]) {
//        //send out broadCast with self.currentEntry
//        NSDictionary* dic = @{@"firstName":self.currentEntry.firstName,@"lastName":self.currentEntry.lastName,@"email":self.currentEntry.emailAddress,@"interviewer":self.currentEntry.interviewer,@"code":self.currentEntry.code,@"status":self.currentEntry.status,@"pdf":self.currentEntry.pdf,@"position":self.currentEntry.position,@"preference":self.currentEntry.preference,@"date":self.currentEntry.date,@"note":self.currentEntry.notes,@"rank":[self.currentEntry.rank stringValue],@"gpa":[self.currentEntry.gpa stringValue],@"BU1" : self.currentEntry.businessUnit1, @"BU2" : self.currentEntry.businessUnit2, @"fileNames" : self.currentEntry.fileNames, @"tagList" : self.currentEntry.tagList};
//        NSDictionary* packet = @{@"msg" : @"broadcast", @"data":dic};
//        
//        [self.appDelegate.dataManager broadCastData:packet];
//    }
}

#pragma mark - UIScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews objectAtIndex:0];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    NSLog(@"%f",scrollView.zoomScale);
    if (scrollView.zoomScale == 1) {
        //enable swipe
    }
    else
    {
        //disable swipe
    }
}

#pragma mark - UISearchBarDelegate

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self.yrdataEntry removeAllObjects];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
    
    if(self.yrSortingSegmentControl.selectedSegmentIndex == 1)
    {
        [fetchRequest setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"rank" ascending:NO]]];
    }
    
    if (self.yrPositionFilter.selectedSegmentIndex != 0 && ![searchText isEqualToString:@""]) {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(code CONTAINS[cd] %@ || firstName CONTAINS[cd] %@ || lastName CONTAINS[cd] %@) && position = %@",searchText,searchText,searchText,[self.yrPositionFilter titleForSegmentAtIndex:self.yrPositionFilter.selectedSegmentIndex]]];
    }
    else if (![searchText isEqualToString:@""])
    {
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code CONTAINS[cd] %@ || firstName CONTAINS[cd] %@ || lastName CONTAINS[cd] %@",searchText,searchText,searchText]];
    }

    NSError* error = nil;
    NSMutableArray* mutableFetchResults = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    [self setYrdataEntry:mutableFetchResults];
    [self.infoDataList reloadData];
}

@end
