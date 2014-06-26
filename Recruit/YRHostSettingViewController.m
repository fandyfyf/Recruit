//
//  YRHostSettingViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/13/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRHostSettingViewController.h"
#import "YRViewerDataCell.h"
#import <Guile/UITextField+AutoSuggestAdditions.h>
#import <Guile/Guile.h>


@interface YRHostSettingViewController ()

@property (strong, nonatomic) UIView* yrCardView;

-(void)fetchInterviewerInfo;
-(void)yrCardViewCancel;
-(void)yrCardViewSave;
-(void)removeAllInterviewerInfo;
-(void)saveScheduleInfo;

@end

@implementation YRHostSettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)awakeFromNib
{
    self.interviewerArray = [[NSMutableArray alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [self.userNameTextField setText:[[NSUserDefaults standardUserDefaults] valueForKey: @"userName"]];
    [self.emailTextField setText:[[NSUserDefaults standardUserDefaults] valueForKey: @"userEmail"]];
    
    self.emailTextField.suggestionDelegate = self;
    self.emailTextField.delegate = self;
    self.userNameTextField.delegate = self;
    
    self.interviewerList.delegate = self;
    self.interviewerList.dataSource = self;
    
    self.interviewStartTime.delegate = self;
    self.interviewDuration.delegate = self;
    self.interviewLocations.delegate = self;
    
    self.interviewStartTime.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"scheduleStartTime"]];
    self.interviewDuration.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"scheduleDuration"]];
    self.interviewLocations.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:@"scheduleColums"]];
    
    [self fetchInterviewerInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addInterviewer:(id)sender {
    
    UILabel* titleLabel;
    UILabel* nameLabel;
    UILabel* emailLabel;
    UILabel* codeLabel;
    UIButton* cancelButton;
    UIButton* saveButton;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.yrCardView = [[UIView alloc] initWithFrame:CGRectMake(170, 300, 428, 300)];
        
        [[self.yrCardView layer] setBorderColor:[[UIColor grayColor] CGColor]];
        [[self.yrCardView layer] setCornerRadius:30];
        [[self.yrCardView layer] setBorderWidth:5];
        
        self.yrCardView.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, 40, 288, 40)];
        [titleLabel setText:@"New Interviewer"];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:26]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        self.interviewerName = [[UITextField alloc] initWithFrame:CGRectMake(180, 100, 200, 30)];
        self.interviewerName.borderStyle = UITextBorderStyleRoundedRect;
        [self.interviewerName setFont:[UIFont systemFontOfSize: 14]];
        self.interviewerName.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.interviewerName.autocorrectionType = UITextAutocorrectionTypeNo;
        
        self.interviewerEmail = [[AutoSuggestTextField alloc] initWithFrame:CGRectMake(180, 145, 200, 30)];
        self.interviewerEmail.borderStyle = UITextBorderStyleRoundedRect;
        [self.interviewerEmail setFont:[UIFont systemFontOfSize: 14]];
        self.interviewerEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.interviewerEmail.autocorrectionType = UITextAutocorrectionTypeNo;
        self.interviewerEmail.keyboardType = UIKeyboardTypeEmailAddress;
        
        self.interviewerCode = [[UITextField alloc] initWithFrame:CGRectMake(180, 190, 200, 30)];
        self.interviewerCode.borderStyle = UITextBorderStyleRoundedRect;
        [self.interviewerCode setFont:[UIFont systemFontOfSize: 14]];
        self.interviewerCode.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.interviewerCode.autocorrectionType = UITextAutocorrectionTypeNo;
        
        
        self.interviewerEmail.suggestionDelegate = self;
        self.interviewerEmail.delegate = self;
        self.interviewerName.delegate = self;
        self.interviewerCode.delegate = self;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 100, 60, 30)];
        [nameLabel setText:@"name:"];
        [nameLabel setTextAlignment:NSTextAlignmentRight];
        
        emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 145, 60, 30)];
        [emailLabel setText:@"email:"];
        [emailLabel setTextAlignment:NSTextAlignmentRight];
        
        codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 190, 60, 30)];
        [codeLabel setText:@"code:"];
        [codeLabel setTextAlignment:NSTextAlignmentRight];
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(60, 230, 100, 40);
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:22];
        [cancelButton addTarget:self action:@selector(yrCardViewCancel) forControlEvents:UIControlEventTouchUpInside];
        
        saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        saveButton.frame = CGRectMake(288, 230, 100, 40);
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        saveButton.titleLabel.font = [UIFont boldSystemFontOfSize:22];
        [saveButton addTarget:self action:@selector(yrCardViewSave) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        self.yrCardView = [[UIView alloc] initWithFrame:CGRectMake(20, 120, 280, 230)];
        
        [[self.yrCardView layer] setBorderColor:[[UIColor grayColor] CGColor]];
        [[self.yrCardView layer] setCornerRadius:10];
        [[self.yrCardView layer] setBorderWidth:5];
        
        self.yrCardView.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, 200, 30)];
        [titleLabel setText:@"New Interviewer"];
        [titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        self.interviewerName = [[UITextField alloc] initWithFrame:CGRectMake(80, 60, 160, 30)];
        self.interviewerName.borderStyle = UITextBorderStyleRoundedRect;
        [self.interviewerName setFont:[UIFont systemFontOfSize: 14]];
        self.interviewerName.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.interviewerName.autocorrectionType = UITextAutocorrectionTypeNo;
        
        self.interviewerEmail = [[AutoSuggestTextField alloc] initWithFrame:CGRectMake(80, 105, 160, 30)];
        self.interviewerEmail.borderStyle = UITextBorderStyleRoundedRect;
        [self.interviewerEmail setFont:[UIFont systemFontOfSize: 14]];
        self.interviewerEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.interviewerEmail.autocorrectionType = UITextAutocorrectionTypeNo;
        self.interviewerEmail.keyboardType = UIKeyboardTypeEmailAddress;
        
        self.interviewerCode = [[UITextField alloc] initWithFrame:CGRectMake(80, 150, 160, 30)];
        self.interviewerCode.borderStyle = UITextBorderStyleRoundedRect;
        [self.interviewerCode setFont:[UIFont systemFontOfSize: 14]];
        self.interviewerCode.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.interviewerCode.autocorrectionType = UITextAutocorrectionTypeNo;
        
        self.interviewerEmail.suggestionDelegate = self;
        self.interviewerEmail.delegate = self;
        self.interviewerName.delegate = self;
        self.interviewerCode.delegate = self;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 60, 30)];
        [nameLabel setText:@"name:"];
        [nameLabel setTextAlignment:NSTextAlignmentRight];
        
        emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 105, 60, 30)];
        [emailLabel setText:@"email:"];
        [emailLabel setTextAlignment:NSTextAlignmentRight];
        
        codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 60, 30)];
        [codeLabel setText:@"code:"];
        [codeLabel setTextAlignment:NSTextAlignmentRight];
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(40, 190, 60, 30);
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(yrCardViewCancel) forControlEvents:UIControlEventTouchUpInside];
        
        saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        saveButton.frame = CGRectMake(180, 190, 60, 30);
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(yrCardViewSave) forControlEvents:UIControlEventTouchUpInside];
    }
    [self.yrCardView addSubview:cancelButton];
    [self.yrCardView addSubview:saveButton];
    [self.yrCardView addSubview:self.interviewerName];
    [self.yrCardView addSubview:self.interviewerEmail];
    [self.yrCardView addSubview:self.interviewerCode];
    [self.yrCardView addSubview:nameLabel];
    [self.yrCardView addSubview:emailLabel];
    [self.yrCardView addSubview:codeLabel];
    [self.yrCardView addSubview:titleLabel];
    
    [self.view addSubview:self.yrCardView];
}

- (IBAction)removeAll:(id)sender {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Do you want to remove all interviewers?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    [alert show];
}

- (IBAction)backgroundTapped:(id)sender {
    [self.emailTextField resignFirstResponder];
    [self.userNameTextField resignFirstResponder];
    [self.interviewLocations resignFirstResponder];
    [self.interviewDuration resignFirstResponder];
    [self.interviewStartTime resignFirstResponder];
    
    [self.emailTextField acceptSuggestion];
    [self saveScheduleInfo];
}

-(void)yrCardViewCancel
{
    [self.yrCardView removeFromSuperview];
    self.interviewerEmail = nil;
    self.interviewerName = nil;
    self.interviewerCode = nil;
}

-(void)yrCardViewSave
{
    if (self.interviewerName.text.length == 0 || self.interviewerEmail.text.length == 0 || self.interviewerCode.text.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"name/email/code shouldn't be empty" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        NSDictionary* curr = @{@"name" : self.interviewerName.text, @"email" : self.interviewerEmail.text, @"code" : self.interviewerCode.text};
        
        [self.interviewerArray addObject:curr];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.interviewerArray forKey:@"interviewerList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.interviewerList reloadData];
        [self.yrCardView removeFromSuperview];
    }
}

-(void)fetchInterviewerInfo
{
    self.interviewerArray = [[[NSUserDefaults standardUserDefaults] objectForKey:@"interviewerList"] mutableCopy];
    if (self.interviewerArray == nil) {
        self.interviewerArray = [NSMutableArray new];
    }
}

-(void)removeAllInterviewerInfo
{
    [self.interviewerArray removeAllObjects];
    [self.interviewerList reloadData];
    [[NSUserDefaults standardUserDefaults] setObject:self.interviewerArray forKey:@"interviewerList"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)saveScheduleInfo
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[self.interviewStartTime.text intValue]] forKey:@"scheduleStartTime"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[self.interviewDuration.text intValue]] forKey:@"scheduleDuration"];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[self.interviewLocations.text intValue]] forKey:@"scheduleColums"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - AutoSuggestDelegate

- (NSString *)suggestedStringForInputString:(NSString *)input
{
    static NSArray *domains;
    if (!domains) {
        domains = @[@"gmail.com",
                    @"gmail.co.uk",
                    @"yahoo-inc.com",
                    @"yahoo.com",
                    @"yahoo.cn",
                    @"hotmail.com"];
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

#pragma mark- UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.emailTextField resignFirstResponder];
    [self.userNameTextField resignFirstResponder];
    [self.interviewerEmail resignFirstResponder];
    [self.interviewerName resignFirstResponder];
    [self.interviewerCode resignFirstResponder];
    [self.interviewStartTime resignFirstResponder];
    [self.interviewDuration resignFirstResponder];
    [self.interviewLocations resignFirstResponder];
    
    [self.emailTextField acceptSuggestion];
    [self.interviewerEmail acceptSuggestion];
    
    [self saveScheduleInfo];
    return YES;
}

#pragma mark- UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //NSLog(@"%lu",(unsigned long)self.interviewerArray.count);
    return [self.interviewerArray count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"interviewerIdentifier";
    
    YRViewerDataCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [YRViewerDataCell new];
    }
    cell.yrNameLabel.text = [self.interviewerArray objectAtIndex:indexPath.row][@"name"];
    cell.yrEmailLabel.text = [self.interviewerArray objectAtIndex:indexPath.row][@"email"];
    cell.yrCodeLabel.text = [self.interviewerArray objectAtIndex:indexPath.row][@"code"];
    return cell;
}

#pragma mark- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 60.0;
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return 100.0;
    }
    else{
        return 44.0;
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Yes"]) {
        [self removeAllInterviewerInfo];
    }
}

@end
