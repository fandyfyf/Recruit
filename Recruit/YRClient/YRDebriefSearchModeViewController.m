//
//  YRDebriefSearchModeViewController.m
//  Recruit
//
//  Created by Yifan Fu on 7/15/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRDebriefSearchModeViewController.h"
#import "YRDebriefViewController.h"
#import "YRAppDelegate.h"
#import "YRSearchResultCell.h"

@interface YRDebriefSearchModeViewController ()

-(void)remoteSearch;
-(void)receiveResultAndUpdate:(NSNotification*)notification;
-(void)broadcastMode;

-(void)showBusy;
-(void)dismissBusy;

@end

@implementation YRDebriefSearchModeViewController

-(void)awakeFromNib
{
    self.searchResult = [NSMutableArray new];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveResultAndUpdate:) name:kYRDataManagerReceiveSearchResultNotification object:nil];
    
    self.view = [[UIView alloc] initWithFrame:self.view.frame];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.SearchOptions = @[@"Front End",@"Back End",@"Service Engineering",@"Mobile - iOS",@"Mobile - Android",@"Lab",@"Design",@"IT",@"Non-Tech"];
    self.rankingOptions = @[@"4",@"3.5",@"3",@"2",@"1"];
    
    self.positionOptions = @[@"Full-Time",@"Intern"];
    
    self.detailView = [YRDebriefSearchModeDetailViewController new];
    self.detailView.tagList = self.tagList;
    
    //UIView * seperator1;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-100, 50, 200, 50)];
        self.modeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 40];
        self.modeLabel.textAlignment = NSTextAlignmentCenter;
        self.modeLabel.textColor = [UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0];
        self.modeLabel.text = @"Search";
        
        self.queryLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.center.x-200, 110, 400, 30)];
        self.queryLabel.font = [UIFont fontWithName:@"Helvetica" size: 25];
        
        self.searchOptionPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(50, 140, self.view.frame.size.width-100, 300)];
        self.searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.searchButton setFrame:CGRectMake(self.view.center.x-75, 355, 150, 30)];
        self.searchButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 25];
        
        self.resultCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(600, 380, 100, 100)];
        self.resultCountLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 70];
        self.resultCountLabel.textColor = [UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0];
        
        self.broadcastButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.broadcastButton.frame = CGRectMake(40, 60, 150, 30);
        self.broadcastButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size: 25];
        [[self.broadcastButton layer] setCornerRadius:10];
        
        self.searchResultListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 400, self.view.frame.size.width, 624) style:UITableViewStyleGrouped];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 30, 120, 20)];
        self.modeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
        self.modeLabel.textAlignment = NSTextAlignmentCenter;
        self.modeLabel.textColor = [UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0];
        self.modeLabel.text = @"Search";
    
        self.queryLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 60, 200, 20)];
        self.queryLabel.font = [UIFont fontWithName:@"Helvetica" size: 13];
        
        self.searchOptionPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(20, 70, 280, 100)];
        
        //seperator1 = [[UIView alloc] initWithFrame:CGRectMake(175, 95, 1, 120)];
        //[seperator1 setBackgroundColor:[UIColor lightGrayColor]];
        
        self.searchButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.searchButton setFrame:CGRectMake(self.view.center.x-50, 225, 100, 30)];
        self.searchButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
        [[self.searchButton layer] setCornerRadius:5];
        
        self.resultCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(200, 250, 100, 50)];
        self.resultCountLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 40];
        self.resultCountLabel.textColor = [UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0];
        
        self.broadcastButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        self.broadcastButton.frame = CGRectMake(20, 30, 50, 20);
        [[self.broadcastButton layer] setCornerRadius:5];
        
        
        self.searchResultListTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 260, 320, 308) style:UITableViewStyleGrouped];
    }
    
    self.queryLabel.textColor = [UIColor lightGrayColor];
    self.queryLabel.text = @"Search Query";
    self.queryLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.searchButton setTitle:@"Search" forState:UIControlStateNormal];
    [self.searchButton setTitleColor:[UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.searchButton addTarget:self action:@selector(remoteSearch) forControlEvents:UIControlEventTouchUpInside];
    [[self.searchButton layer] setBorderColor:[[UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0] CGColor]];
    [[self.searchButton layer] setBorderWidth:1];
    
    [self.broadcastButton setTitle:@"Back" forState:UIControlStateNormal];
    self.broadcastButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.broadcastButton setTitleColor:[UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self.broadcastButton addTarget:self action:@selector(broadcastMode) forControlEvents:UIControlEventTouchUpInside];
    [[self.broadcastButton layer] setBorderColor:[[UIColor colorWithRed:1.0 green:163.0/255.0 blue:43.0/255.0 alpha:1.0] CGColor]];
    [[self.broadcastButton layer] setBorderWidth:1];

    
    self.resultCountLabel.text = @"0";
    self.resultCountLabel.textAlignment = NSTextAlignmentRight;
    
    
    self.searchOptionPicker.delegate = self;
    self.searchOptionPicker.dataSource = self;
    self.searchResultListTableView.delegate = self;
    self.searchResultListTableView.dataSource = self;
    
    [self.view addSubview:self.modeLabel];
    [self.view addSubview:self.queryLabel];
    [self.view addSubview:self.searchOptionPicker];
    //[self.view addSubview:seperator1];
    [self.view addSubview:self.searchButton];
    [self.view addSubview:self.searchResultListTableView];
    [self.view addSubview:self.resultCountLabel];
    [self.view addSubview:self.broadcastButton];
    
    self.option = @"Front End";
    self.ranking = @"4";
    self.position = @"Full-Time";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)remoteSearch
{
    self.queryLabel.text = [NSString stringWithFormat:@"%@ + %@ + %@",self.option, self.ranking, self.position];
    NSDictionary* dic = @{@"option" : self.option, @"ranking" : self.ranking, @"position" : self.position};
    
    //send search Query
    [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] dataManager] sendSearchQuery:dic];
    [self showBusy];
}

-(void)receiveResultAndUpdate:(NSNotification*)notification
{
    [self dismissBusy];
    self.searchResult = [notification object];
    
    self.resultCountLabel.text = [NSString stringWithFormat:@"%d",[self.searchResult count]];
    //reload search result table
    [self.searchResultListTableView reloadData];
}

-(void)broadcastMode
{
    [(YRDebriefViewController*)self.source setBroadcast:YES];
    [UIView beginAnimations:@"flip" context:nil];
    
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.source.view cache:NO];
    [UIView setAnimationDuration:0.3];
    
    [self.view removeFromSuperview];
    
    [UIView commitAnimations];
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
    self.
    self.activityIndicator = nil;
    self.grayView = nil;
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.searchResult count];
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [NSString stringWithFormat:@"Search Results - %d",[self.searchResult count]];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"seachResultIdentifier";
    
    NSDictionary* currentData = [self.searchResult objectAtIndex:indexPath.row];
    
    YRSearchResultCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[YRSearchResultCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            cell.flagView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 30, 30)];
            cell.flagView.image = [UIImage imageNamed:@"flag.jpg"];
            cell.codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 10, 150, 30)];
            cell.codeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
            
            cell.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(230, 10, 300, 30)];
            cell.nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
            
            cell.rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(600, 10, 70, 70)];
            cell.rankLabel.font = [UIFont fontWithName:@"IowanOldStyle-Bold" size:60];
            cell.halfRankLabel = [[UILabel alloc] initWithFrame:CGRectMake(635, 10, 40, 40)];
            cell.halfRankLabel.font = [UIFont fontWithName:@"IowanOldStyle-Bold" size:35];
        }
        else
        {
            cell.flagView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 20, 20)];
            cell.flagView.image = [UIImage imageNamed:@"flag.jpg"];
            cell.codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, 10, 60, 20)];
            cell.codeLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
            
            cell.nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 150, 20)];
            cell.nameLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 15];
            
            cell.rankLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 5, 50, 50)];
            cell.rankLabel.font = [UIFont fontWithName:@"IowanOldStyle-Bold" size:40];
            cell.halfRankLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, 10, 20, 20)];
            cell.halfRankLabel.font = [UIFont fontWithName:@"IowanOldStyle-Bold" size:18];
        }
        [cell.contentView addSubview:cell.flagView];
        [cell.contentView addSubview:cell.codeLabel];
        [cell.contentView addSubview:cell.nameLabel];
        [cell.contentView addSubview:cell.rankLabel];
        [cell.contentView addSubview:cell.halfRankLabel];
    }
    
    cell.flagView.hidden = YES;
    cell.codeLabel.textColor = [UIColor blackColor];
    
    if ([currentData[@"tagList"] count] != 0) {
        for (NSString* name in currentData[@"tagList"]) {
            if ([name isEqualToString:[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager].userName]) {
                cell.flagView.hidden = NO;
                cell.codeLabel.textColor = [UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0];
                break;
            }
        }
    }
    
    cell.codeLabel.text = currentData[@"code"];
    cell.nameLabel.text = [NSString stringWithFormat:@"%@ %@",currentData[@"firstName"],currentData[@"lastName"]];
    cell.nameLabel.textAlignment = NSTextAlignmentLeft;
    cell.rankLabel.textColor = [UIColor redColor];
    cell.halfRankLabel.textColor = [UIColor redColor];
    
    if ([currentData[@"rank"] isEqualToString:@"3.5"]) {
        cell.rankLabel.text = @"3";
        cell.halfRankLabel.text = @".5";
        cell.halfRankLabel.hidden = NO;
    }
    else
    {
        cell.rankLabel.text = currentData[@"rank"];
        cell.halfRankLabel.hidden = YES;
    }
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 89;
    }
    else
    {
        return 60;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.detailView.currentDataEntry = [self.searchResult objectAtIndex:indexPath.row];
    
    [self.view addSubview:self.detailView.view];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 3;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (component == 0) {
        return [self.SearchOptions count];
    }
    else if (component == 1)
    {
        return [self.rankingOptions count];
    }
    else
    {
        return [self.positionOptions count];
    }
}

#pragma mark - UIPickerViewDelegate

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        if (component == 0) {
            return 160.0;
        }
        else if (component == 1)
        {
            return 40.0;
        }
        else
        {
            return 80.0;
        }
    }
    else
    {
        if (component == 0) {
            return 250.0;
        }
        else if (component == 1)
        {
            return 250.0;
        }
        else
        {
            return 250.0;
        }
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0) {
        return [self.SearchOptions objectAtIndex:row];
    }
    else if (component == 1)
    {
        return [self.rankingOptions objectAtIndex:row];
    }
    else
    {
        return [self.positionOptions objectAtIndex:row];
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (component == 0) {
        self.option = [self.SearchOptions objectAtIndex:row];
    }
    else if (component == 1)
    {
        self.ranking = [self.rankingOptions objectAtIndex:row];
    }
    else if (component == 2)
    {
        self.position = [self.positionOptions objectAtIndex:row];
    }
}

-(UIView*)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel* label = (UILabel*)view;
    if (!label) {
        label = [[UILabel alloc] init];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            label.font = [UIFont fontWithName:@"Helvetica" size: 15];
        }
        else{
            label.font = [UIFont fontWithName:@"Helvetica-Bold" size: 25];
        }
        
        if (component == 0) {
            label.text = [self.SearchOptions objectAtIndex:row];
        }
        else if (component == 1)
        {
            label.text = [self.rankingOptions objectAtIndex:row];
            label.textAlignment = NSTextAlignmentCenter;
        }
        else
        {
            label.text = [self.positionOptions objectAtIndex:row];
        }
    }
    return label;
}

@end
