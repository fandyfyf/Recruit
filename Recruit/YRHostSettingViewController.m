//
//  YRHostSettingViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/13/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRHostSettingViewController.h"
#import "YRViewerDataCell.h"
#import "YRFormDataCell.h"
#import <Guile/UITextField+AutoSuggestAdditions.h>
#import <Guile/Guile.h>
#import "YRAppDelegate.h"
#import "Interviewer.h"
#import "Event.h"
#import <objc/message.h>

@interface YRHostSettingViewController ()

@property (strong, nonatomic) UIView* yrCardView;
@property (copy, nonatomic) NSString* selectedEvent;
@property (copy, nonatomic) NSString* selectedEventName;

-(void)fetchInterviewerInfoWithCode:(NSString*)code;
-(void)yrCardViewCancel;
-(void)yrCardViewSave;
-(void)yrCardViewEventSave;

-(void)removeAllInterviewerInfo;
-(void)saveScheduleInfo;
-(void)doneWithPad;
-(void)doneWithInfo;
-(void)removeTextView;
-(void)insertString:(NSString*)insertingString;
-(void)nextInterviewerField;
-(void)doneWithInterviewFields;

-(void)showDatePicker;
-(void)showAddressInfo;

-(void)showYdatePicker;

@end

@implementation YRHostSettingViewController
{
    float add_origin_y;
    float remove_origin_y;
    float add_form_origin_y;
    float remove_form_origin_y;
    float add_event_origin_y;
    int currentSelected;
    BOOL modifyModeON;
}

-(void)awakeFromNib
{
    self.eventArray = [[NSMutableArray alloc] init];
    self.interviewerArray = [[NSMutableArray alloc] init];
}

- (UIImage *)colorImage:(UIImage *)origImage withColor:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(origImage.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, (CGRect){ {0,0}, origImage.size} );
    
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, origImage.size.height);
    CGContextConcatCTM(context, flipVertical);
    CGContextDrawImage(context, (CGRect){ CGPointMake(0, 0), origImage.size }, [origImage CGImage]);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
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
    self.interviewStartDate.delegate = self;
    self.interviewEndDate.delegate = self;
    
    self.interviewStartTime.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleStartTimeKey]];
    self.interviewDuration.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleDurationKey]];
    self.interviewLocations.text = [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleColumsKey]];
    
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyy"];
    
    self.interviewStartDate.text = [format stringFromDate:(NSDate*)[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleStartDateKey]];
    
    self.interviewEndDate.text = [NSString stringWithFormat:@"%d",[[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleNumberOfDayKey] intValue]];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDatePicker)];
    
    self.tapGestureRecognizer.delegate = self;
    
    [self.interviewStartDate addGestureRecognizer:self.tapGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showDatePicker)];
    
    self.tapGestureRecognizer.delegate = self;
    
    [self.interviewEndDate addGestureRecognizer:self.tapGestureRecognizer];
    
    //set up date view
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.datePickerView = [[YRDatePickerView alloc] initWithFrame:CGRectMake(0, 50, self.view.frame.size.width/2+50, 300)];
        [[self.datePickerView layer] setCornerRadius:10];
        
        //ydaypicker
        self.yDayPickerView = [[YRYDayPickerView alloc] initWithFrame:CGRectMake(0, 600, self.view.frame.size.width, 300)];
        [[self.yDayPickerView layer] setCornerRadius:10];
        
        self.yDayPickerView.delegate = self;

    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.datePickerView = [[YRDatePickerView alloc] initWithFrame:CGRectMake(0, 30, self.view.frame.size.width, 450)];
        [[self.datePickerView layer] setCornerRadius:5];
        
        //ydaypicker
    }
    
    [self fetchEventInfo];
    
    if ([self.eventArray count] != 0) {
        //there is event, return interviewer info for the first event
        
        self.selectedEvent = [(Event*)[self.eventArray firstObject] eventCode];
        self.selectedEventName = [(Event*)[self.eventArray firstObject] eventName];
        [self fetchInterviewerInfoWithCode:self.selectedEvent];
        //select
        [self.interviewerList selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    self.formList = [[[NSUserDefaults standardUserDefaults] objectForKey:kYREmailFormsKey] mutableCopy];
    //int formListCount = [self.formList count];
    int interviewCount = [self.interviewerArray count];
    int eventCount = [self.eventArray count];
    
    
    //set background image fail
    //[self.uploadButton setBackgroundImage:[self colorImage:[UIImage imageNamed:@"upload2.png"] withColor:[UIColor redColor]] forState:UIControlStateNormal];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[self.yrRemoveButton layer] setCornerRadius:20];
        [[self.yrRemoveButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrRemoveButton layer] setBorderWidth:5];
        [[self.yrAddButton layer] setCornerRadius:20];
        [[self.yrAddButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrAddButton layer] setBorderWidth:5];
        
        //set the button to a correct place
        [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, self.yrAddFormButton.frame.origin.y + interviewCount*60 + eventCount*60 + 100, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
        [self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, self.yrAddButton.frame.origin.y + eventCount*60 + 52, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
        
        self.yrRemoveButton.hidden = YES;
        
        [[self.yrRemoveFormButton layer] setCornerRadius:20];
        [[self.yrRemoveFormButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrRemoveFormButton layer] setBorderWidth:5];
        [[self.yrAddFormButton layer] setCornerRadius:20];
        [[self.yrAddFormButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrAddFormButton layer] setBorderWidth:5];
        
        [[self.yrAddEventButton layer] setCornerRadius:20];
        [[self.yrAddEventButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrAddEventButton layer] setBorderWidth:5];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [[self.yrRemoveButton layer] setCornerRadius:12.5];
        [[self.yrRemoveButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrRemoveButton layer] setBorderWidth:2];
        [[self.yrAddButton layer] setCornerRadius:12.5];
        [[self.yrAddButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrAddButton layer] setBorderWidth:2];
        
        //set the button to a correct place
        [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, self.yrAddFormButton.frame.origin.y + interviewCount*50 + eventCount*50 + 90, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
        
        [self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, self.yrAddButton.frame.origin.y + eventCount*50 + 45, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
        
        self.yrRemoveButton.hidden = YES;
        
        [[self.yrRemoveFormButton layer] setCornerRadius:12.5];
        [[self.yrRemoveFormButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrRemoveFormButton layer] setBorderWidth:2];
        [[self.yrAddFormButton layer] setCornerRadius:12.5];
        [[self.yrAddFormButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrAddFormButton layer] setBorderWidth:2];
        
        [[self.yrAddEventButton layer] setCornerRadius:12.5];
        [[self.yrAddEventButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [[self.yrAddEventButton layer] setBorderWidth:2];
    }
    
    add_origin_y = self.yrAddButton.frame.origin.y;
    remove_origin_y = self.yrRemoveButton.frame.origin.y;
    add_form_origin_y = self.yrAddFormButton.frame.origin.y;
    remove_form_origin_y = self.yrRemoveFormButton.frame.origin.y;
    add_event_origin_y = self.yrAddEventButton.frame.origin.y;
    
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
    
    modifyModeON = NO;
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
    self.grayView.backgroundColor = [UIColor blackColor];
    self.grayView.alpha = 0.0;
    
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
        [nameLabel setFont:[UIFont fontWithName:@"Helvetica" size: 12]];
        
        emailLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 95, 60, 30)];
        [emailLabel setText:@"email:"];
        [emailLabel setTextAlignment:NSTextAlignmentRight];
        [emailLabel setFont:[UIFont fontWithName:@"Helvetica" size: 12]];
        
        codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 60, 30)];
        [codeLabel setText:@"code:"];
        [codeLabel setTextAlignment:NSTextAlignmentRight];
        [codeLabel setFont:[UIFont fontWithName:@"Helvetica" size: 12]];
        
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
    self.yrCardView.alpha = 0.0;
    
    [self.view addSubview:self.yrCardView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.yrCardView.alpha = 1.0;
        self.grayView.alpha = 0.4;
    }];
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

-(void)addEventFunction
{
    self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
    self.grayView.backgroundColor = [UIColor blackColor];
    self.grayView.alpha = 0.0;
    
    [self.view addSubview:self.grayView];
    
    UILabel* titleLabel;
    UILabel* eventCodeLabel;
    UILabel* eventNameLabel;
    UILabel* eventAddressLabel;
    UIButton* cancelButton;
    UIButton* saveButton;
    
    UIButton* addressInfoButton;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //rotation needs update setting
        self.yrCardView = [[UIView alloc] initWithFrame:CGRectMake(self.view.center.x-214, self.view.center.y-250, 428, 300)];
        
        [[self.yrCardView layer] setCornerRadius:10];
        
        self.yrCardView.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 288, 40)];
        if (modifyModeON) {
            [titleLabel setText:@"Campus Event"];
        }
        else
        {
            [titleLabel setText:@"New Campus Event"];
        }
        [titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:25]];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        
        self.eventName = [[UITextField alloc] initWithFrame:CGRectMake(140, 80, 240, 30)];
        self.eventName.borderStyle = UITextBorderStyleRoundedRect;
        [self.eventName setFont:[UIFont systemFontOfSize: 14]];
        self.eventName.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.eventName.autocorrectionType = UITextAutocorrectionTypeNo;
        
        self.eventCode = [[UITextField alloc] initWithFrame:CGRectMake(140, 125, 240, 30)];
        self.eventCode.borderStyle = UITextBorderStyleRoundedRect;
        [self.eventCode setFont:[UIFont systemFontOfSize: 14]];
        self.eventCode.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.eventCode.autocorrectionType = UITextAutocorrectionTypeNo;
        
        self.eventAddress = [[UITextField alloc] initWithFrame:CGRectMake(140, 170, 240, 30)];
        self.eventAddress.borderStyle = UITextBorderStyleRoundedRect;
        [self.eventAddress setFont:[UIFont systemFontOfSize: 14]];
        self.eventAddress.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.eventAddress.autocorrectionType = UITextAutocorrectionTypeYes;
        
        self.eventAddress.delegate = self;
        self.eventCode.delegate = self;
        self.eventName.delegate = self;
        
        eventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 80, 30)];
        [eventNameLabel setText:@"School:"];
        [eventNameLabel setTextAlignment:NSTextAlignmentRight];
        
        eventCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 125, 80, 30)];
        [eventCodeLabel setText:@"Code:"];
        [eventCodeLabel setTextAlignment:NSTextAlignmentRight];
        
        eventAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 170, 80, 30)];
        [eventAddressLabel setText:@"Address:"];
        [eventAddressLabel setTextAlignment:NSTextAlignmentRight];
        
        addressInfoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [addressInfoButton setFrame:CGRectMake(390, 175, 20, 20)];
        [addressInfoButton addTarget:self action:@selector(showAddressInfo) forControlEvents:UIControlEventTouchUpInside];
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(40, 250, 100, 40);
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 22];
        [cancelButton addTarget:self action:@selector(yrCardViewCancel) forControlEvents:UIControlEventTouchUpInside];
        
        saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        saveButton.frame = CGRectMake(308, 250, 100, 40);
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        saveButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 22];
        [saveButton addTarget:self action:@selector(yrCardViewEventSave) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        self.yrCardView = [[UIView alloc] initWithFrame:CGRectMake(20, 120, 280, 230)];
        [[self.yrCardView layer] setCornerRadius:10];
        
        self.yrCardView.backgroundColor = [UIColor whiteColor];
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 200, 20)];
        
        if (modifyModeON) {
            [titleLabel setText:@"Campus Event"];
        }
        else
        {
            [titleLabel setText:@"New Campus Event"];
        }
        
        [titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:16]];
        [titleLabel setTextAlignment:NSTextAlignmentLeft];
        
        
        self.eventName = [[UITextField alloc] initWithFrame:CGRectMake(80, 50, 180, 30)];
        self.eventName.borderStyle = UITextBorderStyleRoundedRect;
        [self.eventName setFont:[UIFont systemFontOfSize: 14]];
        self.eventName.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.eventName.autocorrectionType = UITextAutocorrectionTypeNo;
        
        self.eventCode = [[UITextField alloc] initWithFrame:CGRectMake(80, 95, 180, 30)];
        self.eventCode.borderStyle = UITextBorderStyleRoundedRect;
        [self.eventCode setFont:[UIFont systemFontOfSize: 14]];
        self.eventCode.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
        self.eventCode.autocorrectionType = UITextAutocorrectionTypeNo;
        
        self.eventAddress = [[UITextField alloc] initWithFrame:CGRectMake(80, 140, 180, 30)];
        self.eventAddress.borderStyle = UITextBorderStyleRoundedRect;
        [self.eventAddress setFont:[UIFont systemFontOfSize: 14]];
        self.eventAddress.autocapitalizationType = UITextAutocapitalizationTypeWords;
        self.eventAddress.autocorrectionType = UITextAutocorrectionTypeYes;
        
        self.eventAddress.delegate = self;
        self.eventCode.delegate = self;
        self.eventName.delegate = self;
        
        eventNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 60, 30)];
        [eventNameLabel setText:@"School:"];
        [eventNameLabel setTextAlignment:NSTextAlignmentRight];
        [eventNameLabel setFont:[UIFont fontWithName:@"Helvetica" size: 12]];
        
        eventCodeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 95, 60, 30)];
        [eventCodeLabel setText:@"Code:"];
        [eventCodeLabel setTextAlignment:NSTextAlignmentRight];
        [eventCodeLabel setFont:[UIFont fontWithName:@"Helvetica" size: 12]];
        
        eventAddressLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 60, 30)];
        [eventAddressLabel setText:@"Address:"];
        [eventAddressLabel setTextAlignment:NSTextAlignmentRight];
        [eventAddressLabel setFont:[UIFont fontWithName:@"Helvetica" size: 12]];
        
        cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        cancelButton.frame = CGRectMake(40, 190, 60, 30);
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(yrCardViewCancel) forControlEvents:UIControlEventTouchUpInside];
        
        saveButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        saveButton.frame = CGRectMake(180, 190, 60, 30);
        [saveButton setTitle:@"Save" forState:UIControlStateNormal];
        [saveButton addTarget:self action:@selector(yrCardViewEventSave) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    doneToolbar.items = [NSArray arrayWithObjects:
                         //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(nextEventField)],
                         nil];
    self.eventCode.inputAccessoryView = doneToolbar;
    self.eventName.inputAccessoryView = doneToolbar;
    
    doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    doneToolbar.items = [NSArray arrayWithObjects:
                         //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithEventFields)],
                         nil];
    
    self.eventAddress.inputAccessoryView = doneToolbar;
    
    
    [self.yrCardView addSubview:cancelButton];
    [self.yrCardView addSubview:saveButton];
    [self.yrCardView addSubview:self.eventCode];
    [self.yrCardView addSubview:self.eventName];
    [self.yrCardView addSubview:self.eventAddress];
    [self.yrCardView addSubview:eventCodeLabel];
    [self.yrCardView addSubview:eventNameLabel];
    [self.yrCardView addSubview:eventAddressLabel];
    [self.yrCardView addSubview:titleLabel];
    [self.yrCardView addSubview:addressInfoButton];
    self.yrCardView.alpha = 0.0;
    
    [self.view addSubview:self.yrCardView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.yrCardView.alpha = 1.0;
        self.grayView.alpha = 0.4;
    }];
}

- (IBAction)addEvent:(id)sender {
    [self addEventFunction];
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

- (IBAction)uploadData:(id)sender {
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Upload All the data" message:@"upload all the data to email address: " delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Confirm", nil];
    [alertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [alertView show];
}

-(void)yrCardViewCancel
{
    modifyModeON = NO;
    //remove keyboard first
    [self.eventCode resignFirstResponder];
    [self.eventName resignFirstResponder];
    [self.eventAddress resignFirstResponder];
    
    [self.interviewerCode resignFirstResponder];
    [self.interviewerName resignFirstResponder];
    [self.interviewerEmail resignFirstResponder];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.yrCardView.alpha = 0.0;
        self.grayView.alpha = 0.0;
    } completion:^(BOOL finish){
        [self.yrCardView removeFromSuperview];
        [self.grayView removeFromSuperview];
        self.interviewerEmail = nil;
        self.interviewerName = nil;
        self.interviewerCode = nil;
        self.eventCode = nil;
        self.eventName = nil;
        self.eventAddress = nil;
    }];
}

-(void)yrCardViewSave
{
    if (self.interviewerName.text.length == 0 || self.interviewerEmail.text.length == 0 || self.interviewerCode.text.length == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"name/email/code shouldn't be empty" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        BOOL exist = NO;
        for (Event* event in self.eventArray)
        {
            if ([event.eventCode isEqualToString:self.interviewerCode.text]) {
                exist = YES;
                break;
            }
        }
        
        if (exist) {
            //Do a fetch first to rule out duplicate ones
            NSFetchRequest* request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"code = %@ and name = %@",self.interviewerCode.text,self.interviewerName.text]];
            NSError* error = nil;
            NSArray* result = [self.managedObjectContext executeFetchRequest:request error:&error];
            
            if ([result count] != 0) {
                //already exist
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Interviewer existed" message:@"The Interviewer is already attending the event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else
            {
                Interviewer* item = (Interviewer*)[NSEntityDescription insertNewObjectForEntityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext];
                item.name = self.interviewerName.text;
                item.email = self.interviewerEmail.text;
                item.code = self.interviewerCode.text;
                item.tagList = [NSArray new];
                
                request = [[NSFetchRequest alloc] init];
                [request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext]];
                [request setPredicate:[NSPredicate predicateWithFormat:@"eventCode = %@",item.code]];
                
                NSArray* fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
                
                //update interviewer count for the selected event
                Event* selectedEvent = (Event*)[fetchResults firstObject];
                [selectedEvent setEventInterviewerCount:[NSNumber numberWithInt:[selectedEvent.eventInterviewerCount intValue] + 1]];
                
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"ERROR -- saving coredata");
                }
                
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"New Interviewer Created" message:[NSString stringWithFormat:@"\"%@\" has been added to Event: \"%@\"",item.name,selectedEvent.eventName] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
                
                
                if ([self.selectedEvent isEqualToString:self.interviewerCode.text]) {
                    //the selected event is the same event
                    [self.interviewerArray addObject:item];
                    
                    [self.interviewerList beginUpdates];
                    
                    [self.interviewerList insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.interviewerArray count]-1 inSection:1]]withRowAnimation:UITableViewRowAnimationTop];
                    
                    [self.interviewerList endUpdates];
                    
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        //adjust button;
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                            [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, self.yrAddFormButton.frame.origin.y+60, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
                            add_form_origin_y += 60;
                        }
                        else
                        {
                            [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, self.yrAddFormButton.frame.origin.y+50, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
                            add_form_origin_y += 50;
                        }
                    }];
                }
                
                [UIView animateWithDuration:0.4 animations:^{
                    self.yrCardView.alpha = 0.0;
                    self.grayView.alpha = 0.0;
                } completion:^(BOOL finish){
                    [self.yrCardView removeFromSuperview];
                    [self.grayView removeFromSuperview];
                    self.grayView = nil;
                    self.yrCardView = nil;
                }];
            }
        }
        else
        {
            //event is not existing in the list
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Event doesn't exist." message:[NSString stringWithFormat:@"Event \"%@\" doesn't exist, please double check the spelling or create it first.",self.interviewerCode.text] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertView show];
        }
    }
}

-(void)yrCardViewEventSave
{
    if (modifyModeON) {
        //modify
        modifyModeON = NO;
        if (self.eventName.text.length == 0) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"name shouldn't be empty" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            NSFetchRequest* request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext]];
            [request setPredicate:[NSPredicate predicateWithFormat:@"eventCode = %@",self.eventCode.text]];
            
            NSError* error = nil;
            NSArray* result = [self.managedObjectContext executeFetchRequest:request error:&error];
            
            Event* targetToModify = [result firstObject];
            
            [targetToModify setEventName:self.eventName.text];
            [targetToModify setEventAddress:self.eventAddress.text];
            
            if (![self.managedObjectContext save:&error]) {
                NSLog(@"ERROR -- saving coredata");
            }
            
            [UIView animateWithDuration:0.3 animations:^{
                self.yrCardView.alpha = 0.0;
                self.grayView.alpha = 0.0;
            } completion:^(BOOL finish){
                [self.yrCardView removeFromSuperview];
                [self.grayView removeFromSuperview];
                self.grayView = nil;
                self.yrCardView = nil;
            }];
            
            [self fetchEventInfo];
            [self.interviewerList reloadData];
        }
    }
    else
    {
        if (self.eventCode.text.length == 0 || self.eventName.text.length == 0) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"code/name shouldn't be empty" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
        else
        {
            NSFetchRequest* request = [[NSFetchRequest alloc] init];
            [request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext]];
            
            NSError* error = nil;
            NSArray* result = [self.managedObjectContext executeFetchRequest:request error:&error];
            
            BOOL existInData = NO;
            
            for (Event* event in result)
            {
                if ([event.eventCode isEqualToString:self.eventCode.text]) {
                    existInData = YES;
                    break;
                }
            }
            
            if (existInData) {
                //alert
                UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Code existed" message:@"The event code existed." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                [alertView show];
            }
            else
            {
                Event* item = (Event*)[NSEntityDescription insertNewObjectForEntityForName:@"Event" inManagedObjectContext:self.managedObjectContext];
                item.eventCode = self.eventCode.text;
                item.eventName = self.eventName.text;
                item.eventAddress = self.eventAddress.text;
                item.eventInterviewerCount = [NSNumber numberWithInt:0];
                
                NSError *error = nil;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"ERROR -- saving coredata");
                }
                
                [self.eventArray addObject:item];
                
                [self.interviewerList beginUpdates];
                
                [self.interviewerList insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:[self.eventArray count]-1 inSection:0]]withRowAnimation:UITableViewRowAnimationTop];
                
                [self.interviewerList endUpdates];
                
                [UIView animateWithDuration:0.3 animations:^{
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, self.yrAddFormButton.frame.origin.y+60, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
                        add_form_origin_y += 60;
                        [self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, self.yrAddButton.frame.origin.y+60, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
                        add_origin_y += 60;
                    }
                    else
                    {
                        [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, self.yrAddFormButton.frame.origin.y+50, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
                        add_form_origin_y += 50;
                        [self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, self.yrAddButton.frame.origin.y+50, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
                        add_origin_y += 50;
                    }
                }];
                
                //change the header
                if ([self.eventArray count] == 1) {
                    //just insert the first one
                    self.selectedEvent = [(Event*)[self.eventArray firstObject] eventCode];
                    self.selectedEventName = [(Event*)[self.eventArray firstObject] eventName];
                    [self.interviewerList reloadData];
                    
                    [self.interviewerList selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                }
                
                [UIView animateWithDuration:0.3 animations:^{
                    self.yrCardView.alpha = 0.0;
                    self.grayView.alpha = 0.0;
                } completion:^(BOOL finish){
                    [self.yrCardView removeFromSuperview];
                    [self.grayView removeFromSuperview];
                    self.grayView = nil;
                    self.yrCardView = nil;
                }];
            }
        }
    }
}

-(void)fetchInterviewerInfoWithCode:(NSString*)code
{
    if (self.interviewerArray == nil) {
        self.interviewerArray = [NSMutableArray new];
    }
    
    [self.interviewerArray removeAllObjects];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@",code]];
    
    NSError* error = nil;
    
    NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    self.interviewerArray = [FetchResults mutableCopy];
    
    //in case interviewArray is nil
    if (self.interviewerArray == nil) {
        self.interviewerArray = [NSMutableArray new];
    }
}

-(void)fetchEventInfo
{
    if (self.eventArray == nil) {
        self.eventArray = [NSMutableArray new];
    }
    
    [self.eventArray removeAllObjects];
    
    NSFetchRequest* fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext]];
    
    NSError* error = nil;
    
    NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    self.eventArray = [FetchResults mutableCopy];
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
    [self checkKeyWordValidation];
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
    
    [self.interviewerList reloadData];
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

-(void)nextEventField
{
    if ([self.eventName isFirstResponder]) {
        //[self.interviewerName resignFirstResponder];
        [self.eventCode becomeFirstResponder];
    }
    else if ([self.eventCode isFirstResponder]) {
        //[self.interviewerEmail resignFirstResponder];
        [self.eventAddress becomeFirstResponder];
    }
}

-(void)doneWithEventFields
{
    [self.eventAddress resignFirstResponder];
}

//not yet finished
-(void)checkKeyWordValidation
{
    NSString* testString = self.yrEditingView.text;
    
    NSRange left = [testString rangeOfString:@"{"];
    NSRange right = [testString rangeOfString:@"}"];
    
    while(left.location != NSNotFound && right.location != NSNotFound) {
        NSRange key = NSMakeRange(left.location + left.length, right.location - left.location - left.length);
        
        NSString* potentialKey = [testString substringWithRange:key];
        
        if ([potentialKey rangeOfString:@" "].location == NSNotFound) {
            //no space between
            NSLog(@"target is %@",potentialKey);
            
            //check if it exist in the keylist
            
            testString = [testString substringFromIndex:right.location + 1];
            
            left = [testString rangeOfString:@"{"];
            right = [testString rangeOfString:@"}"];
        }
        else
        {
            //there is space in between, it's not a key
        }
    }
}

#pragma mark - OnCampusInterviewDatePicker

-(void)showDatePicker
{
    //need implement
    NSLog(@"tapped!");
    self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
    self.grayView.backgroundColor = [UIColor blackColor];
    self.grayView.alpha = 0.0;
    self.datePickerView.alpha = 0.0;
    
    self.datePickerView.grayView = self.grayView;
    self.datePickerView.startDate = self.interviewStartDate;
    self.datePickerView.numberOfDay = self.interviewEndDate;
    
    self.datePickerView.datePicker.date = [[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleStartDateKey];
    [self.datePickerView.numberPicker selectRow:[[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleNumberOfDayKey] intValue]-1 inComponent:0 animated:YES];
    self.datePickerView.selectedDays = [NSString stringWithFormat:@"%d",[[[NSUserDefaults standardUserDefaults] valueForKey:kYRScheduleNumberOfDayKey] intValue]];
    
    
    [self.view addSubview:self.grayView];
    [self.view addSubview:self.datePickerView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.grayView.alpha = 0.4;
        self.datePickerView.alpha = 1.0;
    }];
}

-(void)showAddressInfo
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Address" message:@"Please put down the address of where the interview will take place" delegate:nil cancelButtonTitle:@"Gotcha" otherButtonTitles:nil, nil];
    [alertView show];
}

#pragma mark - OnSiteInterviewDatePicker

-(void)showYdatePicker
{
    self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
    self.grayView.backgroundColor = [UIColor blackColor];
    self.grayView.alpha = 0.0;
    self.yDayPickerView.alpha = 0.0;
    
    self.yDayPickerView.grayView = self.grayView;
    
    self.yDayPickerView.datePicker.date = [NSDate date];
    
    [self.view addSubview:self.grayView];
    [self.view addSubview:self.yDayPickerView];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.grayView.alpha = 0.4;
        self.yDayPickerView.alpha = 1.0;
    }];
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

-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.interviewStartDate || textField == self.interviewEndDate) {
        return NO;
    }
    else
    {
        return YES;
    }
}

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
        //setting table has three sections
        return 4;
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
            return @"Campus Events";
        }
        else if (section == 1)
        {
            if (self.selectedEventName == nil) {
                return @"Onsite Interviewers -- None";
            }
            else
            {
                return [NSString stringWithFormat:@"Onsite Interviewers -- %@",self.selectedEventName];
            }
        }
        else if (section == 2)
        {
            return @"Email Forms";
        }
        else
        {
            return @"Ydays";
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
            return [self.eventArray count];
        }
        else if (section == 1) {
            return [self.interviewerArray count];
        }
        else if (section == 2)
        {
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
            //load Ydays
            self.YdayList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"YdayList"] mutableCopy];
            if (self.YdayList == nil) {
                return 1;//add one
            }
            else
            {
                return [self.YdayList count]+1;
            }
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
            //select row in section 0
            static NSString* identifier = @"eventIdentifier";
            
            YREventDataCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [[YREventDataCell alloc] init];
            }
            Event* current = [self.eventArray objectAtIndex:indexPath.row];
            cell.eventNameLabel.text = current.eventName;
            cell.eventAddressLabel.text = current.eventAddress;
            cell.eventCodeLabel.text = current.eventCode;
            cell.indexPath = indexPath;
            cell.delegate = self;
            
            return cell;
        }
        else if (indexPath.section == 1) {
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
        else if (indexPath.section == 2)
        {
            static NSString* identifier = @"formIdentifier";
            YRFormDataCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [YRFormDataCell new];
            }
            cell.formNameLabel.textColor = [UIColor darkGrayColor];
            cell.formNameLabel.text = [[self.formList[indexPath.row] allKeys] firstObject];
            cell.formDetailLabel.text = [[[self.formList[indexPath.row] allValues] firstObject] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            
            return cell;
        }
        else
        {
            static NSString* identifier = @"formIdentifier";
            YRFormDataCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (cell == nil) {
                cell = [YRFormDataCell new];
            }
            
            if (indexPath.row == [self.YdayList count]) {
                cell.formNameLabel.textColor = [UIColor lightGrayColor];
                cell.formNameLabel.text = @"Click to add a date...";
            }
            else
            {
                cell.formNameLabel.textColor = [UIColor darkGrayColor];
                cell.formNameLabel.text = [self.YdayList objectAtIndex:indexPath.row];
                //cell.formDetailLabel.text = [[[self.formList[indexPath.row] allValues] firstObject] stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            }
            
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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            return 50.0;
        }
        else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            return 60.0;
        }
        else{
            return 44.0;
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.yrEditingTable) {
        //test
        //self.emailKeywordArray = nil;
        //objc_msgSend(nil, @selector(objectAtIndex:),0);
        
        [self insertString:[(NSDictionary*)[self.emailKeywordArray objectAtIndex:indexPath.row] allValues][0]];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else if(tableView == self.interviewerList)
    {
        UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
        
        doneToolbar.items = [NSArray arrayWithObjects:
                             //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                             [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                             [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithPad)],
                             nil];
        
        if (indexPath.section == 2) {
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
        else if (indexPath.section == 0)
        {
            //refetch interview array
            
            if (![self.selectedEvent isEqualToString:[(Event*)[self.eventArray objectAtIndex:indexPath.row] eventCode]]) {
                self.selectedEvent = [(Event*)[self.eventArray objectAtIndex:indexPath.row] eventCode];
                self.selectedEventName = [(Event*)[self.eventArray objectAtIndex:indexPath.row] eventName];
                [self fetchInterviewerInfoWithCode:self.selectedEvent];
                
                [tableView beginUpdates];
                
                [tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
                
                [tableView endUpdates];
                
                int interviewCount = [self.interviewerArray count];
                int eventCount = [self.eventArray count];
                
                [UIView animateWithDuration:0.3 animations:^{
                    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                        
                        //set the button to a correct place
                        [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, add_event_origin_y + interviewCount*60 + eventCount*60 + 100, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
                        [self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, add_event_origin_y + eventCount*60 + 52, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
                    }
                    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                    {
                        [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, add_event_origin_y + interviewCount*50 + eventCount*50 + 90, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
                        
                        [self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, add_event_origin_y + eventCount*50 + 45, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
                    }
                }];
                add_origin_y = self.yrAddButton.frame.origin.y;
                remove_origin_y = self.yrRemoveButton.frame.origin.y;
                add_form_origin_y = self.yrAddFormButton.frame.origin.y;
                remove_form_origin_y = self.yrRemoveFormButton.frame.origin.y;
                add_event_origin_y = self.yrAddEventButton.frame.origin.y;
            }
        }
        else if (indexPath.section == 3)
        {
            if (indexPath.row == [self.YdayList count]) {
                [self showYdatePicker];
            }
        }
        if (indexPath.section != 0) {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

//-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return YES;
//}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        if (tableView == self.interviewerList) {
            if (indexPath.section == 0) {
                //when event is about to be deleted
                NSFetchRequest* request = [[NSFetchRequest alloc] init];
                [request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext]];
                [request setPredicate:[NSPredicate predicateWithFormat:@"eventCode = %@",[(Event*)[self.eventArray objectAtIndex:indexPath.row] eventCode]]];
                NSError* error = nil;
                NSArray* fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
                Event* targetEvent = [fetchResults firstObject];
                
                if ([targetEvent.eventInterviewerCount intValue] > 0) {
                    //prompt can't delete
                    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"WARNNING" message:@"Please delete all the interviewers first to remove the event." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alertView show];
                }
                else
                {
                    [self.eventArray removeObjectAtIndex:indexPath.row];
                    //adjust button positions
                    
                    [tableView beginUpdates];
                    

                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            
                    
                    [tableView endUpdates];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                            [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, self.yrAddFormButton.frame.origin.y-60, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
                            add_form_origin_y -= 60;
                            [self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, self.yrAddButton.frame.origin.y-60, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
                            add_origin_y -= 60;
                        }
                        else
                        {
                            [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, self.yrAddFormButton.frame.origin.y-50, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
                            add_form_origin_y -= 50;
                            [self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, self.yrAddButton.frame.origin.y-50, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
                            add_origin_y -= 50;
                        }
                    }];
                    
                    [self.managedObjectContext deleteObject:[fetchResults firstObject]];
                    
                    if (![self.managedObjectContext save:&error]) {
                        NSLog(@"ERROR -- saving coredata");
                    }
                    
                    if ([self.eventArray count] == 0) {
                        self.selectedEvent = nil;
                        self.selectedEventName = nil;
                        
                        [tableView reloadData];
                    }
                }
            }
            else if (indexPath.section == 1) {
                NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                [fetchRequest setEntity:[NSEntityDescription entityForName:@"Interviewer" inManagedObjectContext:self.managedObjectContext]];
                [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"name = %@ && code = %@",[(Interviewer*)self.interviewerArray[indexPath.row] name],[(Interviewer*)self.interviewerArray[indexPath.row] code]]];
                
                NSError* error = nil;
                
                NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
                
                if ([[(Interviewer*)FetchResults[0] appointments] count] != 0) {
                    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:[NSString stringWithFormat: @"Selected Interviewer has %d interviews set up",[[(Interviewer*)FetchResults[0] appointments] count]] delegate:Nil cancelButtonTitle:@"Oops" otherButtonTitles:nil, nil];
                    [alert show];
                }
                else
                {
                    [self.interviewerArray removeObjectAtIndex:indexPath.row];
                
//                    [UIView animateWithDuration:0.3 animations:^{
//                        [tableView beginUpdates];
//                        
//                        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
//                        
//                        [tableView endUpdates];
//                    } completion:^(BOOL finished) {
//                        [UIView animateWithDuration:0.3 animations:^{
//                            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//                                [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, self.yrAddFormButton.frame.origin.y-60, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
//                                add_form_origin_y -= 60;
//                            }
//                            else
//                            {
//                                [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, self.yrAddFormButton.frame.origin.y-50, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
//                                add_form_origin_y -= 50;
//                            }
//                        }];
//                    }];
                    
                    [tableView beginUpdates];
                    
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                    
                    [tableView endUpdates];
                    
                    [UIView animateWithDuration:0.3 animations:^{
                        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                            [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, self.yrAddFormButton.frame.origin.y-60, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
                            add_form_origin_y -= 60;
                        }
                        else
                        {
                            [self.yrAddFormButton setFrame:CGRectMake(self.yrAddFormButton.frame.origin.x, self.yrAddFormButton.frame.origin.y-50, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height)];
                            add_form_origin_y -= 50;
                        }
                    }];
                    
                    [self.managedObjectContext deleteObject:[FetchResults firstObject]];
                    
                    //reset interviewer count
                    NSFetchRequest* request = [[NSFetchRequest alloc] init];
                    [request setEntity:[NSEntityDescription entityForName:@"Event" inManagedObjectContext:self.managedObjectContext]];
                    [request setPredicate:[NSPredicate predicateWithFormat:@"eventCode = %@",[(Interviewer*)FetchResults[0] code]]];
                    NSError* error = nil;
                    NSArray* fetchResults = [self.managedObjectContext executeFetchRequest:request error:&error];
                    
                    //update interviewer count for the selected event
                    Event* selectedEvent = (Event*)[fetchResults firstObject];
                    [selectedEvent setEventInterviewerCount:[NSNumber numberWithInt:[selectedEvent.eventInterviewerCount intValue] - 1]];
                    
                    if (![self.managedObjectContext save:&error]) {
                        NSLog(@"ERROR -- saving coredata");
                    }
                }
            }
            else if(indexPath.section == 2)
            {
                [self.formList removeObjectAtIndex:indexPath.row];
                [[NSUserDefaults standardUserDefaults] setObject:self.formList forKey:kYREmailFormsKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                [tableView beginUpdates];
                
                
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                
                
                [tableView endUpdates];
            }
            else
            {
                //remove from Yday list
                if (indexPath.row != [self.YdayList count]) {
                    [self.YdayList removeObjectAtIndex:indexPath.row];
                    
                    [[NSUserDefaults standardUserDefaults] setObject:self.YdayList forKey:@"YdayList"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    [tableView beginUpdates];
                    
                    
                    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                    
                    
                    [tableView endUpdates];
                }
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
    if ([buttonTitle isEqualToString:@"Accept"]) {
        if (self.formList == nil) {
            self.formList = [NSMutableArray new];
        }
        [self.formList addObject:@{[alertView textFieldAtIndex:0].text : @""}];
        
        [[NSUserDefaults standardUserDefaults] setObject:self.formList forKey:kYREmailFormsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //[self.yrAddButton setFrame:CGRectMake(self.yrAddButton.frame.origin.x, self.yrAddButton.frame.origin.y+44, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height)];
        
        [self.interviewerList reloadData];
        
        self.formList = [[[NSUserDefaults standardUserDefaults] objectForKey:kYREmailFormsKey] mutableCopy];
    }
    if ([buttonTitle isEqualToString:@"Confirm"]) {
        NSString* targetAddress = [alertView textFieldAtIndex:0].text;
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
        NSError *error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        
        NSString* fileName = [NSString stringWithFormat:@"%@-Data",[[NSUserDefaults standardUserDefaults] valueForKey:@"eventCode"]];
        
        fileName = [fileName stringByAppendingPathExtension:@"csv"];
        
        NSString *fullPath = [dataPath stringByAppendingPathComponent:fileName];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:self.managedObjectContext]];
        
        NSArray* FetchResults = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        NSString* dataEntry = [NSString new];
        
        dataEntry = [dataEntry stringByAppendingString:@"School,First Name,Last Name,E-mail,GPA,Rank,Candidate Type,Profile,BU 1, BU 2,Notes,\n"];
        
        for (CandidateEntry* candidate in FetchResults) {
            NSString* scannedNote = [candidate.notes stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
            dataEntry = [dataEntry stringByAppendingString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,%@,\n",candidate.code,candidate.firstName,candidate.lastName,candidate.emailAddress,[candidate.gpa stringValue],[candidate.rank stringValue],candidate.position,candidate.preference,candidate.businessUnit1,candidate.businessUnit2,scannedNote]];
        }
        
        [dataEntry writeToFile:fullPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        
        if ([MFMailComposeViewController canSendMail]) {
            NSString *emailTitle = @"Data Upload";        //NSString *messageBody = @"Message goes here!";
            
            
            self.yrMailViewController = [[MFMailComposeViewController alloc] init];
            self.yrMailViewController.mailComposeDelegate = self;
            [self.yrMailViewController setSubject:emailTitle];
            [self.yrMailViewController setToRecipients:@[targetAddress]];
            
            [self.yrMailViewController addAttachmentData:[NSData dataWithContentsOfFile:fullPath] mimeType:@"csv" fileName:fileName];
            // Present mail view controller on screen
            [self presentViewController:self.yrMailViewController animated:YES completion:NULL];
        }
        else
        {
            NSLog(@"Fail");
        }

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
    self.yrAddEventButton.frame = CGRectMake(self.yrAddEventButton.frame.origin.x, add_event_origin_y-scrollView.contentOffset.y, self.yrAddEventButton.frame.size.width, self.yrAddEventButton.frame.size.height);
    
    self.yrAddButton.frame = CGRectMake(self.yrAddButton.frame.origin.x, add_origin_y-scrollView.contentOffset.y, self.yrAddButton.frame.size.width, self.yrAddButton.frame.size.height);
    
    self.yrAddFormButton.frame = CGRectMake(self.yrAddFormButton.frame.origin.x, add_form_origin_y-scrollView.contentOffset.y, self.yrAddFormButton.frame.size.width, self.yrAddFormButton.frame.size.height);
    
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
    
    if (add_event_origin_y-scrollView.contentOffset.y < self.interviewerList.frame.origin.y) {
        self.yrAddEventButton.hidden = YES;
    }
    else
    {
        self.yrAddEventButton.hidden = NO;
    }
}

#pragma mark - MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    
    // Remove the mail view
    [self.yrMailViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - YREventDataCellDelegate

-(void)showInfoData:(NSIndexPath*)indexPath
{
    //show the form
    modifyModeON = YES;
    [self addEventFunction];
    self.eventCode.text = [(Event*)[self.eventArray objectAtIndex:indexPath.row] eventCode];
    self.eventName.text = [(Event*)[self.eventArray objectAtIndex:indexPath.row] eventName];
    self.eventAddress.text = [(Event*)[self.eventArray objectAtIndex:indexPath.row] eventAddress];
    
    [self.eventCode setUserInteractionEnabled:NO];
}

#pragma mark - YRYDayPickerViewDelegate

-(void)reloadYDayList
{
    [self.interviewerList performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

@end
