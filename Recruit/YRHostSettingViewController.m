//
//  YRHostSettingViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/13/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRHostSettingViewController.h"
#import <Guile/UITextField+AutoSuggestAdditions.h>
#import <Guile/Guile.h>


@interface YRHostSettingViewController ()

@property (strong, nonatomic) UIView* yrCardView;

-(void)fetchInterviewerInfo;
-(void)yrCardViewCancel;
-(void)yrCardViewSave;
-(void)removeAllInterviewerInfo;

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
    
    [self fetchInterviewerInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addInterviewer:(id)sender {
    
    self.yrCardView = [[UIView alloc] initWithFrame:CGRectMake(20, 120, 280, 200)];
    
    [[self.yrCardView layer] setBorderColor:[[UIColor grayColor] CGColor]];
    [[self.yrCardView layer] setCornerRadius:50];
    [[self.yrCardView layer] setBorderWidth:5];
    
    self.yrCardView.backgroundColor = [UIColor whiteColor];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, 200, 30)];
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
    
    self.interviewerEmail.suggestionDelegate = self;
    self.interviewerEmail.delegate = self;
    self.interviewerName.delegate = self;
    
    UILabel* nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 60, 60, 30)];
    [nameLabel setText:@"name:"];
    [nameLabel setTextAlignment:NSTextAlignmentRight];
    
    UILabel* emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 105, 60, 30)];
    [emailLabel setText:@"email:"];
    [emailLabel setTextAlignment:NSTextAlignmentRight];
    
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake(40, 150, 60, 30);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(yrCardViewCancel) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton* saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    saveButton.frame = CGRectMake(180, 150, 60, 30);
    [saveButton setTitle:@"Save" forState:UIControlStateNormal];
    [saveButton addTarget:self action:@selector(yrCardViewSave) forControlEvents:UIControlEventTouchUpInside];
    
    [self.yrCardView addSubview:cancelButton];
    [self.yrCardView addSubview:saveButton];
    [self.yrCardView addSubview:self.interviewerName];
    [self.yrCardView addSubview:self.interviewerEmail];
    [self.yrCardView addSubview:nameLabel];
    [self.yrCardView addSubview:emailLabel];
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
    
    [self.emailTextField acceptSuggestion];
}

-(void)yrCardViewCancel
{
    [self.yrCardView removeFromSuperview];
    self.interviewerEmail = nil;
    self.interviewerName = nil;
}

-(void)yrCardViewSave
{
    if (self.interviewerName.text.length == 0 || self.interviewerEmail.text.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"name/email shouldn't be empty" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        NSDictionary* curr = @{@"name" : self.interviewerName.text, @"email" : self.interviewerEmail.text};
        
        NSLog(@"%@ %@",self.interviewerName.text,self.interviewerEmail.text);
        
        
        //while become nil when want to add
        if (self.interviewerArray == nil) {
            self.interviewerArray = [NSMutableArray new];
        }
        
        [self.interviewerArray addObject:curr];
        
        NSLog(@"%lu",(unsigned long)self.interviewerArray.count);
        
        [[NSUserDefaults standardUserDefaults] setObject:self.interviewerArray forKey:@"interviewerList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.interviewerList reloadData];
        [self.yrCardView removeFromSuperview];
    }
}

-(void)fetchInterviewerInfo
{
    self.interviewerArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"interviewerList"];
}

-(void)removeAllInterviewerInfo
{
    [self.interviewerArray removeAllObjects];
    [self.interviewerList reloadData];
    [[NSUserDefaults standardUserDefaults] setObject:self.interviewerArray forKey:@"interviewerList"];
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
    
    [self.emailTextField acceptSuggestion];
    [self.interviewerEmail acceptSuggestion];
    
    return YES;
}

#pragma mark- UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"%lu",(unsigned long)self.interviewerArray.count);
    return [self.interviewerArray count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier = @"interviewerIdentifier";
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    cell.textLabel.text = [self.interviewerArray objectAtIndex:indexPath.row][@"name"];
    cell.detailTextLabel.text = [self.interviewerArray objectAtIndex:indexPath.row][@"email"];
    
    return cell;
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
