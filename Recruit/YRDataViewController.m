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

-(void)needUpdateTableNotification:(NSNotification *)notification;

-(void)fetchCandidates;

-(void)sortMethodSelected:(UISegmentedControl *)mySegmentedControl;


@end

@implementation YRDataViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ListToDetail"]) {
        [segue.destinationViewController setValue:self.currentEntry forKey:@"dataSource"];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.yrdataEntry = [NSMutableArray new];
    [self.infoDataList setDelegate:self];
    [self.infoDataList setDataSource:self];
    
    self.appDelegate = (YRAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateTableNotification:) name:@"NeedUpdateTableNotification" object:nil];
    self.yrPrefix = [(YRHostMainViewController*)self.tabBarController.viewControllers[0] yrPrefix];
    
    self.managedObjectContext = [self.appDelegate managedObjectContext];
    
    //[self fetchCandidates];
    
    [self.yrSortingSegmentControl addTarget:self action:@selector(sortMethodSelected:) forControlEvents:UIControlEventValueChanged];
    [self.yrPositionFilter addTarget:self action:@selector(sortMethodSelected:) forControlEvents:UIControlEventValueChanged];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self fetchCandidates]; //updatedata before each time the view appear
    
    [self.infoDataList reloadData];
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
    //[self fetchCandidates];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.yrdataEntry addObject:[[notification userInfo] objectForKey:@"entry"]];
        
        [self.infoDataList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    });
}

-(void)fetchCandidates
{
    [self.yrdataEntry removeAllObjects];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
    
    if(self.yrSortingSegmentControl.selectedSegmentIndex == 1)
    {
        //[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"recommand = %@",[NSNumber numberWithBool:YES]]];
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
            //[fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"recommand = %@",[NSNumber numberWithBool:YES]]];
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

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
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
    
    if ([current.recommand boolValue]) {
        cell.yrcodeLabel.textColor = [UIColor redColor];
    }
    else
    {
        cell.yrcodeLabel.textColor = [UIColor blackColor];
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
        cell.yrstatusLabel.textColor = [UIColor greenColor];
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
        cell.yrPDFIconView.image = [UIImage imageNamed:@"document.png"];
    }
    else
    {
        cell.yrPDFIconView.image = nil;
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.currentEntry = (CandidateEntry*)[self.yrdataEntry objectAtIndex:indexPath.row];
    [self performSegueWithIdentifier:@"ListToDetail" sender:self];
}

@end
