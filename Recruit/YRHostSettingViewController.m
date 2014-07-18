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
#import "YRAppDelegate.h"
#import "Interviewer.h"


@interface YRHostSettingViewController ()

@property (strong, nonatomic) UIView* yrCardView;

-(void)fetchInterviewerInfo;
-(void)yrCardViewCancel;
-(void)yrCardViewSave;
-(void)removeAllInterviewerInfo;
-(void)saveScheduleInfo;
-(void)doneWithPad;
-(void)doneWithInfo;
-(void)removeTextView;
-(void)insertString:(NSString*)insertingString;
-(void)nextInterviewerField;
-(void)doneWithInterviewFields;

@end

@implementation YRHostSettingViewController
{
    float add_origin_y;
    float remove_origin_y;
    float add_form_origin_y;
    float remove_form_origin_y;
    int currentSelected;
}

-(void)awakeFromNib
{
    self.interviewerArray = [[NSMutableArray alloc] init];
    self.emailKeywordArray = [[NSArray alloc] init];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.managedObjectContext = [(YRAppDelegate*)[[UIApplication sharedApplication] delegate] managedObjectContext];
    
    [self.userNameTextField setText:[[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager] userName]];
    [self.emailTextField setText:[[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager] userEmail]];
    
    self.emailTextField.suggestionDelegate = self;
    self.emailTextField.delegate = self;
    self.userNameTextField.delegate = self;
    
    self.interviewerList.delegate = self;
    self.interviewerList.dataSource = self;
    
    self.interviewStartTime.delegate = self;
    self.interviewDuration.delegate = self;
    self.interviewLocations.delegate = self;
    
    self.interviewStartTime.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleStartTimeKey]];
    self.interviewDuration.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleDurationKey]];
    self.interviewLocations.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleColumsKey]];
    
    [self fetchInterviewerInfo];
    
    self.formList = [[[NSUserDefaults standardUserDefaults] objectForKey:kYREmailFormsKey] mutableCopy];
    int formListCount = [self.formList count];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[self.yrRemoveButton layer] setCornerRadius:20];
        [[self.yrRemoveButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrRemoveButton layer] setBorderWidth:5];
        [[self.yrAddButton layer] setCornerRadius:20];
        [[self.yrAddButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrAddButton layer] setBorderWidth:5];
        
        //[self.yrRemoveButton setFrame:CGRectMake(self.yrRemoveButton.frame.origin.x, self.yrRemoveButton.frame.origin.y + formListCount*44 + 50, self.yrRemoveButton.frame.size.width, self.yrRemoveButton.frame.size.height)];
        [self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, self.yrAddButton.frame.origin.y + formListCount*44 + 50, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
        self.yrRemoveButton.hidden = YES;
        
        [[self.yrRemoveFormButton layer] setCornerRadius:20];
        [[self.yrRemoveFormButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrRemoveFormButton layer] setBorderWidth:5];
        [[self.yrAddFormButton layer] setCornerRadius:20];
        [[self.yrAddFormButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrAddFormButton layer] setBorderWidth:5];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [[self.yrRemoveButton layer] setCornerRadius:12.5];
        [[self.yrRemoveButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrRemoveButton layer] setBorderWidth:2];
        [[self.yrAddButton layer] setCornerRadius:12.5];
        [[self.yrAddButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrAddButton layer] setBorderWidth:2];
        //[self.yrRemoveButton setFrame:CGRectMake(self.yrRemoveButton.frame.origin.x, self.yrRemoveButton.frame.origin.y + formListCount*44 + 45, self.yrRemoveButton.frame.size.width, self.yrRemoveButton.frame.size.height)];
        [self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, self.yrAddButton.frame.origin.y + formListCount*44 + 45, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
        self.yrRemoveButton.hidden = YES;
        
        [[self.yrRemoveFormButton layer] setCornerRadius:12.5];
        [[self.yrRemoveFormButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrRemoveFormButton layer] setBorderWidth:2];
        [[self.yrAddFormButton layer] setCornerRadius:12.5];
        [[self.yrAddFormButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrAddFormButton layer] setBorderWidth:2];
    }
    
    add_origin_y = self.yrAddButton.frame.origin.y;
    remove_origin_y = self.yrRemoveButton.frame.origin.y;
    add_form_origin_y = self.yrAddFormButton.frame.origin.y;
    remove_form_origin_y = self.yrRemoveFormButton.frame.origin.y;
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    doneToolbar.items = [NSArray arrayWithObjects:
                         //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithInfo)],
                         nil];
    self.emailTextField.inputAccessoryView = doneToolbar;
    self.userNameTextField.inputAccessoryView = doneToolbar;
    self.interviewStartTime.inputAccessoryView = doneToolbar;
    self.interviewDuration.inputAccessoryView = doneToolbar;
    self.interviewLocations.inputAccessoryView = doneToolbar;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    //reload every time the view is showing
    self.interviewStartTime.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleStartTimeKey]];
    self.interviewDuration.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleDurationKey]];
    self.interviewLocations.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleColumsKey]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)addInterviewer:(id)sender {
    
    self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
    self.grayView.backgroundColor = [UIColor darkGrayColor];
    self.grayView.alpha = 0.5;
    
    [self.view addSubview:self.grayView];
    
    UILabel* titleLabel;
    UILabel* nameLabel;
    UILabel* emailLabel;
    UILabel* codeLabel;
    UIButton* cancelButton;
    UIButton* saveButton;
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //rotation needs update setting 
        self.yrCardView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-214, self.view.center.y-250, 428, 300)];
        
        [[self.yrCardView layer] setCornerRadius:10];
        
        self.yrCardView.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 288, 40)];
        [titleLabel setText:@"New Interviewer"];
        [titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:25]];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        
        self.interviewerName = [[UITextField alloc] initWithFrame:CGRectMake(140, 80, 240, 30)];
        self.interviewerName.borderStyle = UITextBorderStyleRoundedRect;
        [self.interviewerName setFont:[UIFont systemFontOfSize: 14]];
        self.interviewerName.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.interviewerName.autocorrectionType = UITextAutocorrectionTypeNo;
        
        self.interviewerEmail = [[AutoSuggestTextField alloc] initWithFrame:CGRectMake(140, 125, 240, 30)];
        self.interviewerEmail.borderStyle = UITextBorderStyleRoundedRect;
        [self.interviewerEmail setFont:[UIFont systemFontOfSize: 14]];
        self.interviewerEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.interviewerEmail.autocorrectionType = UITextAutocorrectionTypeNo;
        self.interviewerEmail.keyboardType = UIKeyboardTypeEmailAddress;
        
        self.interviewerCode = [[UITextField alloc] initWithFrame:CGRectMake(140, 170, 240, 30)];
        self.interviewerCode.borderStyle = UITextBorderStyleRoundedRect;
        [self.interviewerCode setFont:[UIFont systemFontOfSize: 14]];
        self.interviewerCode.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.interviewerCode.autocorrectionType = UITextAutocorrectionTypeNo;
        
        
        self.interviewerEmail.suggestionDelegate = self;
        self.interviewerEmail.delegate = self;
        self.interviewerName.delegate = self;
        self.interviewerCode.delegate = self;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 80, 60, 30)];
        [nameLabel setText:@"name:"];
        [nameLabel setTextAlignment:NSTextAlignmentRight];
        
        emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 125, 60, 30)];
        [emailLabel setText:@"email:"];
        [emailLabel setTextAlignment:NSTextAlignmentRight];
        
        codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 170, 60, 30)];
        [codeLabel setText:@"code:"];
        [codeLabel setTextAlignment:NSTextAlignmentRight];
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(40, 250, 100, 40);
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 22];
        [cancelButton addTarget:self action:@selector(yrCardViewCancel) forControlEvents:UIControlEventTouchUpInside];
        
        saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        saveButton.frame = CGRectMake(308, 250, 100, 40);
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        saveButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 22];
        [saveButton addTarget:self action:@selector(yrCardViewSave) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        self.yrCardView = [[UIView alloc] initWithFrame:CGRectMake(20, 120, 280, 230)];
        [[self.yrCardView layer] setCornerRadius:10];
        
        self.yrCardView.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
        [titleLabel setText:@"New Interviewer"];
        [titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:16]];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        
        self.interviewerName = [[UITextField alloc] initWithFrame:CGRectMake(80, 50, 160, 30)];
        self.interviewerName.borderStyle = UITextBorderStyleRoundedRect;
        [self.interviewerName setFont:[UIFont systemFontOfSize: 14]];
        self.interviewerName.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.interviewerName.autocorrectionType = UITextAutocorrectionTypeNo;
        
        self.interviewerEmail = [[AutoSuggestTextField alloc] initWithFrame:CGRectMake(80, 95, 160, 30)];
        self.interviewerEmail.borderStyle = UITextBorderStyleRoundedRect;
        [self.interviewerEmail setFont:[UIFont systemFontOfSize: 14]];
        self.interviewerEmail.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.interviewerEmail.autocorrectionType = UITextAutocorrectionTypeNo;
        self.interviewerEmail.keyboardType = UIKeyboardTypeEmailAddress;
        
        self.interviewerCode = [[UITextField alloc] initWithFrame:CGRectMake(80, 140, 160, 30)];
        self.interviewerCode.borderStyle = UITextBorderStyleRoundedRect;
        [self.interviewerCode setFont:[UIFont systemFontOfSize: 14]];
        self.interviewerCode.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.interviewerCode.autocorrectionType = UITextAutocorrectionTypeNo;
        
        self.interviewerEmail.suggestionDelegate = self;
        self.interviewerEmail.delegate = self;
        self.interviewerName.delegate = self;
        self.interviewerCode.delegate = self;
        
        nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 60, 30)];
        [nameLabel setText:@"name:"];
        [nameLabel setTextAlignment:NSTextAlignmentRight];
        
        emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 95, 60, 30)];
        [emailLabel setText:@"email:"];
        [emailLabel setTextAlignment:NSTextAlignmentRight];
        
        codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 60, 30)];
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
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    doneToolbar.items = [NSArray arrayWithObjects:
                         //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(nextInterviewerField)],
                         nil];
    self.interviewerName.inputAccessoryView = doneToolbar;
    self.interviewerEmail.inputAccessoryView = doneToolbar;
    
    doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    doneToolbar.items = [NSArray arrayWithObjects:
                         //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithInterviewFields)],
                         nil];
    
    self.interviewerCode.inputAccessoryView = doneToolbar;
    
    
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

- (IBAction)addEmailForm:(id)sender {
    UIAlertView* addFormAlert = [[UIAlertView alloc] initWithTitle:@"Adding an Email Form" message:@"Give it a name please." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Accept", nil];
    [addFormAlert setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [addFormAlert show];
}

- (IBAction)removeEmailForms:(id)sender {
}

- (IBAction)changeDebriefStatus:(id)sender {
    if (self.yrDebriefSegCtrl.selectedSegmentIndex ==1) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Debrief Mode On?" message:@"Turn on debrief will potentially interrupt ongoing interviews." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Debrief!", nil];
        [alert show];
    }
    else
    {
        //turn off debrief stuff
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"DebriefModeOn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] dataManager] sendDebriefTermination];
    }
}

-(void)yrCardViewCancel
{
    [self.yrCardView removeFromSuperview];
    [self.grayView removeFromSuperview];
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
        Interviewer* item = (Interviewer*)[NSEntityDescription insertNewObjectForEntityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext];
        item.name = self.interviewerName.text;
        item.email = self.interviewerEmail.text;
        item.code = self.interviewerCode.text;
        item.tagList = [NSArray new];
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"ERROR -- saving coredata");
        }
        
        //save the event code list in the user default
        NSMutableArray* eventCodeList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"eventCodeList"] mutableCopy];
        if (eventCodeList == nil) {
            //if the list is empty then add the code now
            eventCodeList = [NSMutableArray new];
            [eventCodeList addObject:item.code];
        }
        else
        {
            BOOL exist = NO;
            for (NSString* code in eventCodeList) {
                if ([code isEqualToString:item.code]) {
                    exist = YES;
                    break;
                }
            }
            if (!exit) {
                //insert
                [eventCodeList addObject:item.code];
            }
        }
        //update the event code list
        [[NSUserDefaults standardUserDefaults] setObject:eventCodeList forKey:@"eventCodeList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        
        [self.interviewerArray addObject:item];
        
        [self.interviewerList reloadData];
        [self.yrCardView removeFromSuperview];
        [self.grayView removeFromSuperview];
    }
}

-(void)fetchInterviewerInfo
{
    if (self.interviewerArray == nil) {
        self.interviewerArray = [NSMutableArray new];
    }
    
    
    [self.interviewerArray removeAllObjects];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
    
    NSError* error = nil;
    
    NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    self.interviewerArray = [FetchResults mutableCopy];
}

-(void)removeAllInterviewerInfo
{
    [self.interviewerArray removeAllObjects];
    [self.interviewerList reloadData];
    
    
    //delete core data
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
    
    NSError* error = nil;
    
    NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject* obj in FetchResults) {
        [self.managedObjectContext deleteObject:obj];
    }
    
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"ERROR -- saving coredata");
    }
}

-(void)saveScheduleInfo
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[self.interviewStartTime.text intValue]] forKey:kYRScheduleStartTimeKey];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[self.interviewDuration.text intValue]] forKey:kYRScheduleDurationKey];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[self.interviewLocations.text intValue]] forKey:kYRScheduleColumsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)doneWithPad
{
    [self saveForm];
    [self.yrEditingView resignFirstResponder];
    [self.yrEditingView removeFromSuperview];
    [self.removeFromViewButton removeFromSuperview];
    [self.yrEditingTable removeFromSuperview];
}

-(void)doneWithInfo
{
    [self.emailTextField resignFirstResponder];
    [self.userNameTextField resignFirstResponder];
    [self.interviewLocations resignFirstResponder];
    [self.interviewDuration resignFirstResponder];
    [self.interviewStartTime resignFirstResponder];
    
    [self.emailTextField acceptSuggestion];
    [self saveScheduleInfo];
}

-(void)removeTextView
{
    [self saveForm];
    [self.removeFromViewButton removeFromSuperview];
    [self.yrEditingTable removeFromSuperview];
    [self.yrEditingView removeFromSuperview];
}

-(void)saveForm
{
    NSMutableDictionary* temp = [[self.formList objectAtIndex:currentSelected] mutableCopy];
    [temp setObject:self.yrEditingView.text forKey:[self.formList[currentSelected] allKeys][0]];
    
    [self.formList replaceObjectAtIndex:currentSelected withObject:temp];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.formList forKey:kYREmailFormsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)insertString:(NSString*)insertingString
{
    NSRange range = self.yrEditingView.selectedRange;
    NSString * firstHalfString = [self.yrEditingView.text substringToIndex:range.location];
    NSString * secondHalfString = [self.yrEditingView.text substringFromIndex: range.location];
    self.yrEditingView.scrollEnabled = NO;  // turn off scrolling
    
    self.yrEditingView.text = [NSString stringWithFormat: @"%@%@%@",
                       firstHalfString,
                       insertingString,
                       secondHalfString];
    range.location += [insertingString length];
    self.yrEditingView.selectedRange = range;
    self.yrEditingView.scrollEnabled = YES;  // turn scrolling back on.
}

-(void)nextInterviewerField
{
    if ([self.interviewerName isFirstResponder]) {
        //[self.interviewerName resignFirstResponder];
        [self.interviewerEmail becomeFirstResponder];
    }
    else if ([self.interviewerEmail isFirstResponder]) {
        //[self.interviewerEmail resignFirstResponder];
        [self.interviewerCode becomeFirstResponder];
    }
}

-(void)doneWithInterviewFields
{
    [self.interviewerCode resignFirstResponder];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (tableView == self.yrEditingTable) {
        return 1;
    }
    else
    {
        return 2;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (tableView == self.yrEditingTable) {
        return @"Keys";
    }
    else
    {
        if (section == 0) {
            return @"Email Forms";
        }
        else
        {
            return @"Onsite Interviewers";
        }
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.yrEditingTable) {
        return [self.emailKeywordArray count];
    }
    else
    {
        if (section == 0) {
            self.formList = [[[NSUserDefaults standardUserDefaults] objectForKey:kYREmailFormsKey] mutableCopy];
            if (self.formList == nil) {
                return 0;
            }
            else
            {
                return [self.formList count];
            }
        }
        else
        {
            return [self.interviewerArray count];
        }
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.yrEditingTable) {
        static NSString* identifier = @"keyIdentifier";
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.textLabel.text = [(NSDictionary*)[self.emailKeywordArray objectAtIndex:indexPath.row] allKeys][0];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size: 10];
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size: 15];
        }
        return cell;
    }
    else
    {
        if (indexPath.section == 0) {
            static NSString* identifier = @"formIdentifier";
            UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            cell.textLabel.text = [self.formList[indexPath.row] allKeys][0];
            return cell;
        }
        else
        {
            static NSString* identifier = @"interviewerIdentifier";
            
            YRViewerDataCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [YRViewerDataCell new];
            }
            Interviewer* current = [self.interviewerArray objectAtIndex:indexPath.row];
            cell.yrNameLabel.text = current.name;
            cell.yrEmailLabel.text = current.email;
            cell.yrCodeLabel.text = current.code;
            return cell;
        }
    }
}

#pragma mark- UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.yrEditingTable) {
        return 44.0;
    }
    else
    {
        if (indexPath.section == 1) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                return 50.0;
            }
            else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                return 90.0;
            }
            else{
                return 44.0;
            }
        }
        else
        {
            return 44.0;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.yrEditingTable) {
        [self insertString:[(NSDictionary*)[self.emailKeywordArray objectAtIndex:indexPath.row] allValues][0]];
    }
    else if(tableView == self.interviewerList)
    {
        UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        
        doneToolbar.items = [NSArray arrayWithObjects:
                             //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithPad)],
                             nil];
        
        if (indexPath.section == 0) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                //bring up text view
                self.yrEditingView = [[UITextView alloc] initWithFrame:CGRectMake(self.view.center.x-384, self.view.center.y-450, 584, 650)];
                self.yrEditingView.delegate = self;
                self.yrEditingView.keyboardType = UIKeyboardTypeDefault;
                self.yrEditingView.inputAccessoryView = doneToolbar;
                [self.yrEditingView setBackgroundColor:[UIColor colorWithRed:1.0 green:247.0/255.0 blue:201.0/255.0 alpha:1]];
                [[self.yrEditingView layer] setCornerRadius:10];
                
                self.yrEditingTable = [[UITableView alloc] initWithFrame:CGRectMake(self.view.center.x+200, self.view.center.y-450, 184, 650) style:UITableViewStyleGrouped];
                self.emailKeywordArray = [[NSUserDefaults standardUserDefaults] arrayForKey:kYREmailKeyWordsKey];
                self.yrEditingTable.delegate = self;
                self.yrEditingTable.dataSource = self;
                [[self.yrEditingTable layer] setCornerRadius:10];
                //[self.yrEditingTable setSeparatorInset:UIEdgeInsetsZero];
                
                self.removeFromViewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [self.removeFromViewButton setFrame:CGRectMake(584-20, self.view.center.y-450-20, 40, 40)];
                self.removeFromViewButton.backgroundColor = [UIColor redColor];
                [self.removeFromViewButton setTitle:@"X" forState:UIControlStateNormal];
                [self.removeFromViewButton.titleLabel setFont:[UIFont boldSystemFontOfSize:30]];
                self.removeFromViewButton.titleLabel.textColor = [UIColor whiteColor];
                [self.removeFromViewButton setTintColor:[UIColor whiteColor]];
                [[self.removeFromViewButton layer] setCornerRadius:20];
                [[self.removeFromViewButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
                [[self.removeFromViewButton layer] setBorderWidth:4];
            }
            else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                //bring up text view
                self.yrEditingView = [[UITextView alloc] initWithFrame:CGRectMake(self.view.center.x-160, self.view.center.y-256, 220, 274)];
                self.yrEditingView.delegate = self;
                self.yrEditingView.keyboardType = UIKeyboardTypeDefault;
                self.yrEditingView.inputAccessoryView = doneToolbar;
                [self.yrEditingView setBackgroundColor:[UIColor colorWithRed:1.0 green:247.0/255.0 blue:201.0/255.0 alpha:1]];
                [[self.yrEditingView layer] setCornerRadius:10];
                
                self.yrEditingTable = [[UITableView alloc] initWithFrame:CGRectMake(self.view.center.x+60, self.view.center.y-256, 100, 274) style:UITableViewStyleGrouped];
                self.emailKeywordArray = [[NSUserDefaults standardUserDefaults] arrayForKey:kYREmailKeyWordsKey];
                self.yrEditingTable.delegate = self;
                self.yrEditingTable.dataSource = self;
                [[self.yrEditingTable layer] setCornerRadius:10];
                //[self.yrEditingTable setSeparatorInset:UIEdgeInsetsZero];
                
                self.removeFromViewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                [self.removeFromViewButton setFrame:CGRectMake(220-20, self.view.center.y-256-20, 40, 40)];
                self.removeFromViewButton.backgroundColor = [UIColor redColor];
                [self.removeFromViewButton setTitle:@"X" forState:UIControlStateNormal];
                [self.removeFromViewButton.titleLabel setFont:[UIFont boldSystemFontOfSize:30]];
                self.removeFromViewButton.titleLabel.textColor = [UIColor whiteColor];
                [self.removeFromViewButton setTintColor:[UIColor whiteColor]];
                [[self.removeFromViewButton layer] setCornerRadius:20];
                [[self.removeFromViewButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
                [[self.removeFromViewButton layer] setBorderWidth:4];

            }
            
            [self.removeFromViewButton addTarget:self action:@selector(removeTextView) forControlEvents:UIControlEventTouchUpInside];
            
            self.yrEditingView.text = [self.formList[indexPath.row] allValues][0];
            currentSelected = indexPath.row;
            [self.view addSubview:self.yrEditingView];
            [self.view addSubview:self.yrEditingTable];
            [self.view addSubview:self.removeFromViewButton];
            [self.yrEditingView becomeFirstResponder];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (tableView == self.interviewerList) {
            if (indexPath.section == 1) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                [fetchRequest setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name = %@ && code = %@",[(Interviewer*)self.interviewerArray[indexPath.row] name],[[NSUserDefaults standardUserDefaults] valueForKey:@"eventCode"]]];
                
                NSError* error = nil;
                
                NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                
                if ([[(Interviewer*)FetchResults[0] appointments] count] != 0) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:[NSString stringWithFormat: @"Selected Interviewer has %d interviews set up",[[(Interviewer*)FetchResults[0] appointments] count]] delegate:Nil cancelButtonTitle:@"Oops" otherButtonTitles:nil, nil];
                    [alert show];
                }
                else
                {
                    [self.interviewerArray removeObjectAtIndex:indexPath.row];
                    [tableView reloadData];
                    [self.managedObjectContext deleteObject:FetchResults[0]];
                    
                    if (![self.managedObjectContext save:&error]) {
                        NSLog(@"ERROR -- saving coredata");
                    }
                }
            }
            else
            {
//                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Please confirm if you want to delete this entry." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
//                [alert show];
                [self.formList removeObjectAtIndex:indexPath.row];
                [[NSUserDefaults standardUserDefaults] setObject:self.formList forKey:kYREmailFormsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, self.yrAddButton.frame.origin.y-44, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
                //[self.yrRemoveButton setFrame:CGRectMake(self.yrRemoveButton.frame.origin.x, self.yrRemoveButton.frame.origin.y-44, self.yrRemoveButton.frame.size.width, self.yrRemoveButton.frame.size.height)];
                
                [self.interviewerList reloadData];
            }
        }
    }
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* buttonTitle = [alertView buttonTitleAtIndex:buttonIndex];
    if ([buttonTitle isEqualToString:@"Yes"]) {
        [self removeAllInterviewerInfo];
    }
//    if ([buttonTitle isEqualToString:@"Confirm"]) {
//        [[NSUserDefaults standardUserDefaults] setObject:self.formList forKey:kYREmailFormsKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    if ([buttonTitle isEqualToString:@"Accept"]) {
        if (self.formList == nil) {
            self.formList = [NSMutableArray new];
        }
        [self.formList addObject:@{[alertView textFieldAtIndex:0].text : @""}];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.formList forKey:kYREmailFormsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, self.yrAddButton.frame.origin.y+44, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
        //[self.yrRemoveButton setFrame:CGRectMake(self.yrRemoveButton.frame.origin.x, self.yrRemoveButton.frame.origin.y+44, self.yrRemoveButton.frame.size.width, self.yrRemoveButton.frame.size.height)];
        
        [self.interviewerList reloadData];
        
        self.formList = [[[NSUserDefaults standardUserDefaults] objectForKey:kYREmailFormsKey] mutableCopy];
    }
    
    if ([buttonTitle isEqualToString:@"Debrief!"]) {
        [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:YES] forKey:@"DebriefModeOn"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //do debrief stuff
        [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] dataManager] sendDebriefInvitation];
    }
    if ([buttonTitle isEqualToString:@"Cancel"]) {
        self.yrDebriefSegCtrl.selectedSegmentIndex = 0;
    }
}

#pragma mark - UISrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    self.yrAddButton.frame = CGRectMake(self.yrAddButton.frame.origin.x, add_origin_y-scrollView.contentOffset.y, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height);
    //self.yrRemoveButton.frame = CGRectMake(self.yrRemoveButton.frame.origin.x, remove_origin_y-scrollView.contentOffset.y, self.yrRemoveButton.frame.size.width, self.yrRemoveButton.frame.size.height);
    
    self.yrAddFormButton.frame = CGRectMake(self.yrAddFormButton.frame.origin.x, add_form_origin_y-scrollView.contentOffset.y, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height);
    
    //self.yrRemoveFormButton.frame = CGRectMake(self.yrRemoveFormButton.frame.origin.x, remove_form_origin_y-scrollView.contentOffset.y, self.yrRemoveFormButton.frame.size.width, self.yrRemoveFormButton.frame.size.height);
    
    if (add_form_origin_y-scrollView.contentOffset.y < self.interviewerList.frame.origin.y) {
        self.yrAddFormButton.hidden = YES;
        //self.yrRemoveFormButton.hidden = YES;
    }
    else
    {
        self.yrAddFormButton.hidden = NO;
        //self.yrRemoveFormButton.hidden = NO;
    }
    
    if (add_origin_y-scrollView.contentOffset.y < self.interviewerList.frame.origin.y) {
        self.yrAddButton.hidden = YES;
        //self.yrRemoveButton.hidden = YES;
    }
    else
    {
        self.yrAddButton.hidden = NO;
        //self.yrRemoveButton.hidden = NO;
    }
}

@end
