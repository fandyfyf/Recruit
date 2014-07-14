//
//  YRHostDetailViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/14/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRHostDetailViewController.h"
#import <Guile/UITextField+AutoSuggestAdditions.h>
#import <Guile/Guile.h>
#import "Appointment.h"
#import "Interviewer.h"

@interface YRHostDetailViewController ()

-(void)cancelScrollView;
-(void)updateCoreData;
- (void) spinWithOptions: (UIViewAnimationOptions) options onView:(UIView*)view withDuration:(NSTimeInterval)duration withAngle:(CGFloat)angle;
-(void)email;
-(void)tapOnLabel:(UITapGestureRecognizer*)gestureRecognizer;
-(void)doneWithPad;
-(void)changeRank:(id)sender;
-(void)cancelRankChange;
-(void)removeViews;
-(void)checkScheduleFunction;
-(void)scrollLeft;
-(void)scrollRight;

@end

@implementation YRHostDetailViewController
{
    BOOL spin;
    int currentSelectedEmailForm;
    BOOL replacingMode;
    int showingImageIndex;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.appDelegate = (YRAppDelegate* )[[UIApplication sharedApplication] delegate];
    
    self.yrCodeLabel.text = self.dataSource.code;
    
    if ([self.dataSource.preference isEqualToString:@"FE"]) {
        self.yrPreferenceTextField.text = @"Back End";
    }
    else if ([self.dataSource.preference isEqualToString:@"BE"])
    {
        self.yrPreferenceTextField.text = @"Front End";
    }
    else
    {
        self.yrPreferenceTextField.text = self.dataSource.preference;
    }
    self.yrBusinessUnit1.text = self.dataSource.businessUnit1;
    self.yrBusinessUnit2.text = self.dataSource.businessUnit2;
    
    self.yrFirstNameTextField.delegate = self;
    self.yrLastNameTextField.delegate = self;
    self.yrEmailTextField.delegate = self;
    self.yrEmailTextField.suggestionDelegate = self;
    self.yrBusinessUnit1.delegate = self;
    self.yrBusinessUnit2.delegate = self;
    
    self.yrFirstNameTextField.text = self.dataSource.firstName;
    self.yrLastNameTextField.text = self.dataSource.lastName;
    self.yrEmailTextField.text = self.dataSource.emailAddress;
    self.yrRecommendLabel.text = self.dataSource.interviewer;
    
    if ([self.dataSource.recommand boolValue]) {
        
        [self.yrRecommendSwitch setOn:YES animated:YES];
        self.yrRecommendLabel.hidden = NO;
        self.yrRecommandMark.textColor = [UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0];
    }
    else
    {
        self.yrRecommendLabel.hidden = YES;
        [self.yrRecommendSwitch setOn:NO animated:NO];
    }
    
    if ([self.dataSource.pdf boolValue]) {
        [self.yrFileNameButton setHidden:NO];
        
//        NSDateFormatter* format = [[NSDateFormatter alloc] init];
//        [format setDateFormat:@"MMddyyyHHmm"];
//        NSString* date = [format stringFromDate:self.dataSource.date];
//        
//        NSString* fileName = [self.yrCodeLabel.text stringByAppendingString:[NSString stringWithFormat:@"_%@",date]];
//        
//        NSString *fullPath = [fileName stringByAppendingPathExtension:@"jpg"];
        
        [self.yrFileNameButton setTitle:@"Resume" forState:UIControlStateNormal];
    }
    else
    {
        [self.yrFileNameButton setHidden:YES];
    }
    
    [self.yrCommentTextView setDelegate:self];
    
    [[self.yrCommentTextView layer] setCornerRadius:10];
    
    [self.yrCommentTextView setText:self.dataSource.notes];
    
    if ([self.dataSource.position isEqualToString:@"Intern"]) {
        self.yrPositionSegmentControl.selectedSegmentIndex = 0;
    }
    else
    {
        self.yrPositionSegmentControl.selectedSegmentIndex = 1;
    }
    
    
    UITapGestureRecognizer* tapAction = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnLabel:)];
    tapAction.delegate = self;
    [self.yrRankLabel setUserInteractionEnabled:YES];
    [self.yrRankLabel addGestureRecognizer:tapAction];
    
    if ([self.dataSource.rank floatValue] == 3.5) {
        self.yrHalfRankLabel.hidden = NO;
        self.yrRankLabel.text = @"3";
    }
    else
    {
        self.yrRankLabel.text = [self.dataSource.rank stringValue];
        self.yrHalfRankLabel.hidden = YES;
    }
    
    self.yrGPATextField.text = [NSString stringWithFormat:@"%@",self.dataSource.gpa];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:[self.appDelegate managedObjectContext]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@",self.dataSource.code]];
    NSError* error = nil;
    NSArray* FetchResults = [[self.appDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if ([FetchResults count] != 0) {
        CandidateEntry* item = FetchResults[0];
        if ([item.appointments count] == 0) {
            self.checkInterviewButton.hidden = YES;
        }
        else
        {
            self.checkInterviewButton.hidden = NO;
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[self.yrScheduleButton layer] setCornerRadius:35];
        [[self.yrScheduleButton layer] setBorderColor:[[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] CGColor]];
        [[self.yrScheduleButton layer] setBorderWidth:2];
        
        [[self.yrGoBackButton layer] setCornerRadius:35];
        [[self.yrGoBackButton layer] setBorderColor:[[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] CGColor]];
        [[self.yrGoBackButton layer] setBorderWidth:2];
        
        [[self.yrEmailButton layer] setCornerRadius:35];
        [[self.yrEmailButton layer] setBorderColor:[[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] CGColor]];
        [[self.yrEmailButton layer] setBorderWidth:2];
        
        [[self.checkInterviewButton layer] setCornerRadius:35];
        [[self.checkInterviewButton layer] setBorderColor:[[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] CGColor]];
        [[self.checkInterviewButton layer] setBorderWidth:2];
        
        [self.yrGPATextField setFrame:CGRectMake(540, 221, 144, 40)];
    }
    else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [[self.yrGoBackButton layer] setCornerRadius:25];
        [[self.yrGoBackButton layer] setBorderColor:[[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] CGColor]];
        [[self.yrGoBackButton layer] setBorderWidth:2];
        [[self.yrEmailButton layer] setCornerRadius:25];
        [[self.yrEmailButton layer] setBorderColor:[[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] CGColor]];
        [[self.yrEmailButton layer] setBorderWidth:2];
        [[self.yrScheduleButton layer] setCornerRadius:25];
        [[self.yrScheduleButton layer] setBorderColor:[[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] CGColor]];
        [[self.yrScheduleButton layer] setBorderWidth:2];
        [[self.checkInterviewButton layer] setCornerRadius:25];
        [[self.checkInterviewButton layer] setBorderColor:[[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] CGColor]];
        [[self.checkInterviewButton layer] setBorderWidth:2];
    }
    spin = YES;
    replacingMode = NO;
    
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, 320, 50)];
    
    doneToolbar.items = [NSArray arrayWithObjects:
                         //                           [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelNumberPad)],
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithPad)],
                         nil];
    self.yrFirstNameTextField.inputAccessoryView = doneToolbar;
    self.yrLastNameTextField.inputAccessoryView = doneToolbar;
    self.yrEmailTextField.inputAccessoryView = doneToolbar;
    self.yrGPATextField.inputAccessoryView = doneToolbar;
    self.yrPreferenceTextField.inputAccessoryView = doneToolbar;
    self.yrBusinessUnit1.inputAccessoryView = doneToolbar;
    self.yrBusinessUnit2.inputAccessoryView = doneToolbar;
    self.yrCommentTextView.inputAccessoryView = doneToolbar;
 }

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if ([self.checkScheduleFlag boolValue]) {
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.yrEmailButton.frame = CGRectMake(621, 20, 70, 70);
            
            self.yrScheduleButton.frame = CGRectMake(548, 20, 70, 70);
            
            self.checkInterviewButton.frame = CGRectMake(475, 20, 70, 70);
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            self.yrEmailButton.frame = CGRectMake(260, 20, 50, 50);
            
            self.yrScheduleButton.frame = CGRectMake(208, 20, 50, 50);
            
            self.checkInterviewButton.frame = CGRectMake(156, 20, 50, 50);
        }
        [self checkScheduleFunction];
    }
    else
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [UIView animateWithDuration:0.5 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{self.yrEmailButton.frame = CGRectMake(621, 20, 70, 70);} completion:^(BOOL finish){ spin = NO;}];
            [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.yrEmailButton withDuration:0.15f withAngle:M_PI/2];
            
            [UIView animateWithDuration:0.5 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{self.yrScheduleButton.frame = CGRectMake(548, 20, 70, 70);} completion:^(BOOL finish){ spin = NO;}];
            [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.yrScheduleButton withDuration:0.15f withAngle:M_PI/2];
            
            [UIView animateWithDuration:0.5 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{self.checkInterviewButton.frame = CGRectMake(475, 20, 70, 70);} completion:^(BOOL finish){ spin = NO;}];
            [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.checkInterviewButton withDuration:0.15f withAngle:M_PI/2];
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            [UIView animateWithDuration:0.5 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{self.yrEmailButton.frame = CGRectMake(260, 20, 50, 50);} completion:^(BOOL finish){ spin = NO;}];
            [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.yrEmailButton withDuration:0.15f withAngle:M_PI/2];
            
            [UIView animateWithDuration:0.5 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{self.yrScheduleButton.frame = CGRectMake(208, 20, 50, 50);} completion:^(BOOL finish){ spin = NO;}];
            [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.yrScheduleButton withDuration:0.15f withAngle:M_PI/2];
            
            [UIView animateWithDuration:0.5 delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{self.checkInterviewButton.frame = CGRectMake(156, 20, 50, 50);} completion:^(BOOL finish){ spin = NO;}];
            [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.checkInterviewButton withDuration:0.15f withAngle:M_PI/2];
        }
    }
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self.yrCommentTextView setFrame:CGRectMake(550, 100, 250, 600)];
        [self.YRCommentLabel setFrame:CGRectMake(770, 50, 160, 30)];
    }
    else
    {
        [self.yrCommentTextView setFrame:CGRectMake(84, 610, 600, 325)];
        [self.YRCommentLabel setFrame:CGRectMake(304, 572, 160, 30)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takeAnImage:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)goBack:(id)sender {
    [self updateCoreData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)checkImage:(id)sender {
    int half = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        half = 150;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        half = 120;
    }
    
    self.resumeOptionView = [[UIView alloc] initWithFrame:CGRectMake(self.yrFileNameButton.center.x-half, self.yrFileNameButton.center.y+20, 2*half, 160)];
    [[self.resumeOptionView layer] setCornerRadius:12];
    
    self.resumeOptionTable = [[UITableView alloc] initWithFrame:CGRectMake(5, 5, 2*half - 10, 150) style:UITableViewStylePlain];
    [[self.resumeOptionTable layer] setCornerRadius:10];
    //        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 2*half - 100, 20)];
    //        titleLabel.text = @"Files";
    //        titleLabel.textColor = [UIColor purpleColor];
    //        titleLabel.textAlignment = NSTextAlignmentLeft;
    //        titleLabel.font = [UIFont boldSystemFontOfSize:15];
    
    //        [self.resumeOptionView addSubview:titleLabel];
    [self.resumeOptionView addSubview:self.resumeOptionTable];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIViewController* newController = [UIViewController new];
        self.popOver = [[UIPopoverController alloc] initWithContentViewController:newController];
        newController.view = self.resumeOptionView;
        
        [self.popOver setPopoverContentSize:CGSizeMake(2*half, 160)];
        
        [self.popOver presentPopoverFromRect:CGRectMake(self.yrFileNameButton.center.x-half, self.yrFileNameButton.center.y+20, 2*half, -2) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        self.resumeOptionView.backgroundColor = [UIColor purpleColor];
        //            titleLabel.textColor = [UIColor whiteColor];
        self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
        self.grayView.backgroundColor = [UIColor darkGrayColor];
        self.grayView.alpha = 0.5;
        [self.grayView addTarget:self action:@selector(removeViews) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.grayView];
        
        [self.view addSubview:self.resumeOptionView];
    }
    self.resumeOptionTable.delegate = self;
    self.resumeOptionTable.dataSource = self;
    
    //done
}

- (IBAction)backgroundTapped:(id)sender {
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.2];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.yrCommentTextView.frame = CGRectMake(84, 610, 600, 325);
    }
    else{
        self.yrCommentTextView.frame = CGRectMake(10, 417, 300, 120);
    }
    [UIView commitAnimations];
    [self.yrCommentTextView resignFirstResponder];
    [self.yrFirstNameTextField resignFirstResponder];
    [self.yrLastNameTextField resignFirstResponder];
    [self.yrEmailTextField resignFirstResponder];
    [self.yrEmailTextField acceptSuggestion];
    [self.yrBusinessUnit1 resignFirstResponder];
    [self.yrBusinessUnit2 resignFirstResponder];
    [self.yrGPATextField resignFirstResponder];
    [self.yrPreferenceTextField resignFirstResponder];
    [self removeViews];
}

- (IBAction)emailCandidate:(id)sender {
    [self removeViews];
    [self updateCoreData];
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:[self.appDelegate managedObjectContext]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@",self.dataSource.code]];
    NSError* error = nil;
    NSMutableArray* mutableFetchResults = [[[self.appDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error] mutableCopy];
    CandidateEntry* selected = mutableFetchResults[0];
    [[self.appDelegate emailGenerator] setSelectedCandidate:selected];
    //reset appointments
    [[self.appDelegate emailGenerator].selectedAppointments removeAllObjects];
    
    for (Appointment* ap in selected.appointments)
    {
        [[self.appDelegate emailGenerator].selectedAppointments addObject:ap];
    }
    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.emailOptionView = [[UIView alloc] initWithFrame:CGRectMake(self.yrEmailButton.center.x-75, self.yrEmailButton.center.y+[self.yrEmailButton layer].cornerRadius+5, 150, 200)];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.emailOptionView = [[UIView alloc] initWithFrame:CGRectMake(self.yrEmailButton.center.x-75, self.yrEmailButton.center.y+[self.yrEmailButton layer].cornerRadius+5, 100, 200)];
    }
    [[self.emailOptionView layer] setCornerRadius:12];
    
    self.emailOptionTable = [[UITableView alloc] initWithFrame:CGRectMake(5, 40, self.emailOptionView.frame.size.width-10, 155) style:UITableViewStylePlain];
    [[self.emailOptionTable layer] setCornerRadius:10];
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.emailOptionView.frame.size.width-20, 20)];
    titleLabel.text = @"Options";
    titleLabel.textColor = [UIColor purpleColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    
    [self.emailOptionView addSubview:titleLabel];
    [self.emailOptionView addSubview:self.emailOptionTable];
    
   
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIViewController* newController = [UIViewController new];
        self.popOver = [[UIPopoverController alloc] initWithContentViewController:newController];
        newController.view = self.emailOptionView;
        [self.popOver setPopoverContentSize:CGSizeMake(150, 200)];
        [self.popOver presentPopoverFromRect:CGRectMake(self.yrEmailButton.center.x-75, self.yrEmailButton.center.y+[self.yrEmailButton layer].cornerRadius+5, 150, -2) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self.emailOptionView setBackgroundColor:[UIColor purpleColor]];
        titleLabel.textColor = [UIColor whiteColor];
        self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
        self.grayView.backgroundColor = [UIColor darkGrayColor];
        self.grayView.alpha = 0.5;
        [self.grayView addTarget:self action:@selector(removeViews) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.grayView];

        [self.view addSubview:self.emailOptionView];
    }
    self.emailOptionTable.delegate = self;
    self.emailOptionTable.dataSource = self;
}

- (IBAction)scheduleInterview:(id)sender {
    [self updateCoreData];
    NSDictionary* dic = @{@"code" : self.yrCodeLabel.text};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SetUpInterview" object:dic];
    
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)checkSchedule:(id)sender {
    [self checkScheduleFunction];
}

- (IBAction)recommendChange:(id)sender {
    if (self.yrRecommendSwitch.isOn) {
        self.yrRecommendLabel.hidden = NO;
        [self.yrRecommandMark setTextColor:[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0]];
    }
    else
    {
        self.yrRecommendLabel.hidden = YES;
        [self.yrRecommandMark setTextColor:[UIColor blackColor]];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    self.chosenImage = info[UIImagePickerControllerOriginalImage];
    //self.imageView.image = chosenImage;
    //compress into Jpeg file
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Image Generated" message:@"Adding a new page or replacing an old one?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Adding New Page",@"Replacing Old Page", nil];
    
    [alertView show];
    
    
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)cancelScrollView
{
    [self.yrScrollView removeFromSuperview];
    [self.yrScrollViewCancelButton removeFromSuperview];
    [self.grayView removeFromSuperview];
    [self.yrGoBackButton setHidden:NO];
}

-(void)updateCoreData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:[self.appDelegate managedObjectContext]]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@",self.dataSource.code]];
    
    NSError* error = nil;
    NSMutableArray* mutableFetchResults = [[[self.appDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    CandidateEntry* selected = mutableFetchResults[0];
    
    [selected setFirstName:self.yrFirstNameTextField.text];
    [selected setLastName:self.yrLastNameTextField.text];
    [selected setEmailAddress:self.yrEmailTextField.text];
    [selected setPosition:[self.yrPositionSegmentControl titleForSegmentAtIndex:self.yrPositionSegmentControl.selectedSegmentIndex]];
    [selected setNotes:self.yrCommentTextView.text];
    [selected setBusinessUnit1:self.yrBusinessUnit1.text];
    [selected setBusinessUnit2:self.yrBusinessUnit2.text];
    [selected setGpa:[NSNumber numberWithFloat:[self.yrGPATextField.text floatValue]]];
    [selected setPreference:self.yrPreferenceTextField.text];
    if (self.yrRecommendSwitch.isOn) {
        [selected setRecommand:[NSNumber numberWithBool:YES]];
    }
    else
    {
        [selected setRecommand:[NSNumber numberWithBool:NO]];
    }
    
    self.dataSource = selected;
    if (![[self.appDelegate managedObjectContext] save:&error]) {
        NSLog(@"ERROR -- saving coredata");
    }
}

- (void) spinWithOptions: (UIViewAnimationOptions) options onView:(UIView*)view withDuration:(NSTimeInterval)duration withAngle:(CGFloat)angle{
    [UIView animateWithDuration: duration
                          delay: 0.0f
                        options: options
                     animations: ^{
                         view.transform = CGAffineTransformRotate(view.transform, angle);
                     }
                     completion: ^(BOOL finished) {
                         if (finished) {
                             if (spin || !CGAffineTransformEqualToTransform(view.transform, CGAffineTransformIdentity))
                             {
                                 // if flag still set, keep spinning with constant speed
                                 [self spinWithOptions: UIViewAnimationOptionCurveLinear onView:view withDuration:duration withAngle:angle];
                             }
                         }
                     }];
}


-(void)email
{
    if ([MFMailComposeViewController canSendMail]) {
        NSString *emailTitle = [NSString stringWithFormat:@"Yahoo is Interested in Speaking with You! - %@",[[self.appDelegate emailGenerator] generateEmail:@"#studentFirstName# #studentLastName#"][@"message"]];
        //NSString *messageBody = @"Message goes here!";
        
        NSDictionary* result = [[self.appDelegate emailGenerator] generateEmail:[self.formList[currentSelectedEmailForm] allValues][0]];
        
        NSArray *toRecipents = [NSArray arrayWithObject:self.yrEmailTextField.text];
        
        self.yrMailViewController = [[MFMailComposeViewController alloc] init];
        self.yrMailViewController.mailComposeDelegate = self;
        [self.yrMailViewController setSubject:emailTitle];
        [self.yrMailViewController setMessageBody:result[@"message"] isHTML:NO];
        [self.yrMailViewController setToRecipients:toRecipents];
        
        if (! self.yrFileNameButton.isHidden && [result[@"pdfFlag"] boolValue]) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
            
            NSError *error;
            if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
            
            for (NSString* fileName in self.dataSource.fileNames) {
                NSString *fullPath = [dataPath stringByAppendingPathComponent:fileName];
                
                [self.yrMailViewController addAttachmentData:[NSData dataWithContentsOfFile:fullPath] mimeType:@"image/jpeg" fileName:fileName];
            }
        }
        // Present mail view controller on screen
        [self presentViewController:self.yrMailViewController animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"Fail");
    }
}

-(void)tapOnLabel:(UITapGestureRecognizer*)gestureRecognizer
{
    [self removeViews];
    
    self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
    self.grayView.backgroundColor = [UIColor darkGrayColor];
    self.grayView.alpha = 0.5;
    [self.grayView addTarget:self action:@selector(cancelRankChange) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.grayView];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.rankOneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.rankOneButton setTitle:@"1" forState:UIControlStateNormal];
        [self.rankOneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rankOneButton.backgroundColor = [UIColor redColor];
        [[self.rankOneButton layer] setCornerRadius:30];
        [[self.rankOneButton layer] setBorderWidth:5];
        [[self.rankOneButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.rankOneButton.titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:50]];
        [self.rankOneButton addTarget:self action:@selector(changeRank:) forControlEvents:UIControlEventTouchUpInside];
        self.rankOneButton.alpha = 0.6;
        
        self.rankTwoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.rankTwoButton setTitle:@"2" forState:UIControlStateNormal];
        [self.rankTwoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rankTwoButton.backgroundColor = [UIColor redColor];
        [[self.rankTwoButton layer] setCornerRadius:35];
        [[self.rankTwoButton layer] setBorderWidth:5];
        [[self.rankTwoButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.rankTwoButton.titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:60]];
        [self.rankTwoButton addTarget:self action:@selector(changeRank:) forControlEvents:UIControlEventTouchUpInside];
        self.rankTwoButton.alpha = 0.7;
        
        self.rankThreeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.rankThreeButton setTitle:@"3" forState:UIControlStateNormal];
        [self.rankThreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rankThreeButton.backgroundColor = [UIColor redColor];
        [[self.rankThreeButton layer] setCornerRadius:40];
        [[self.rankThreeButton layer] setBorderWidth:5];
        [[self.rankThreeButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.rankThreeButton.titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:70]];
        [self.rankThreeButton addTarget:self action:@selector(changeRank:) forControlEvents:UIControlEventTouchUpInside];
        self.rankThreeButton.alpha = 0.8;
        
        self.rankThreeHalfButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.rankThreeHalfButton setTitle:@"3.5" forState:UIControlStateNormal];
        [self.rankThreeHalfButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rankThreeHalfButton.backgroundColor = [UIColor redColor];
        [[self.rankThreeHalfButton layer] setCornerRadius:45];
        [[self.rankThreeHalfButton layer] setBorderWidth:5];
        [[self.rankThreeHalfButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.rankThreeHalfButton.titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:50]];
        [self.rankThreeHalfButton addTarget:self action:@selector(changeRank:) forControlEvents:UIControlEventTouchUpInside];
        self.rankThreeHalfButton.alpha = 0.9;
        
        self.rankFourButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.rankFourButton setTitle:@"4" forState:UIControlStateNormal];
        [self.rankFourButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rankFourButton.backgroundColor = [UIColor redColor];
        [[self.rankFourButton layer] setCornerRadius:50];
        [[self.rankFourButton layer] setBorderWidth:5];
        [[self.rankFourButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.rankFourButton.titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:80]];
        [self.rankFourButton addTarget:self action:@selector(changeRank:) forControlEvents:UIControlEventTouchUpInside];
        self.rankFourButton.alpha = 1.0;
        
        [self.rankOneButton setFrame:CGRectMake(603, 157, 80, 80)];
        [self.rankTwoButton setFrame:CGRectMake(603, 157, 85, 85)];
        [self.rankThreeButton setFrame:CGRectMake(603, 157, 90, 90)];
        [self.rankThreeHalfButton setFrame:CGRectMake(603, 157, 95, 95)];
        [self.rankFourButton setFrame:CGRectMake(603, 157, 100, 100)];
        
        [self.rankOneButton setCenter:CGPointMake(603, 157)];
        [self.rankTwoButton setCenter:CGPointMake(603, 157)];
        [self.rankThreeButton setCenter:CGPointMake(603, 157)];
        [self.rankThreeHalfButton setCenter:CGPointMake(603, 157)];
        [self.rankFourButton setCenter:CGPointMake(603, 157)];
        
        
        [self.view addSubview:self.rankOneButton];
        [self.view addSubview:self.rankTwoButton];
        [self.view addSubview:self.rankThreeButton];
        [self.view addSubview:self.rankThreeHalfButton];
        [self.view addSubview:self.rankFourButton];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.rankOneButton setFrame:CGRectMake(555, 7, 60, 60)];
            [self.rankTwoButton setFrame:CGRectMake(470, 42, 70, 70)];
            [self.rankThreeButton setFrame:CGRectMake(434, 131, 80, 80)];
            [self.rankThreeHalfButton setFrame:CGRectMake(482, 229, 90, 90)];
            [self.rankFourButton setFrame:CGRectMake(604, 237, 100, 100)];} completion:^(BOOL finished){spin = NO;}];
        spin = YES;
        [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.rankOneButton withDuration:0.1f withAngle:M_PI/2];
        [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.rankTwoButton withDuration:0.1f withAngle:M_PI/2];
        [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.rankThreeButton withDuration:0.1f withAngle:M_PI/2];
        [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.rankThreeHalfButton withDuration:0.1f withAngle:M_PI/2];
        [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.rankFourButton withDuration:0.1f withAngle:M_PI/2];
        
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        self.rankOneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.rankOneButton setTitle:@"1" forState:UIControlStateNormal];
        [self.rankOneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rankOneButton.backgroundColor = [UIColor redColor];
        [[self.rankOneButton layer] setCornerRadius:15];
        [[self.rankOneButton layer] setBorderWidth:2];
        [[self.rankOneButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.rankOneButton.titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:30]];
        [self.rankOneButton addTarget:self action:@selector(changeRank:) forControlEvents:UIControlEventTouchUpInside];
        self.rankOneButton.alpha = 0.6;
        
        self.rankTwoButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.rankTwoButton setTitle:@"2" forState:UIControlStateNormal];
        [self.rankTwoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rankTwoButton.backgroundColor = [UIColor redColor];
        [[self.rankTwoButton layer] setCornerRadius:17.5];
        [[self.rankTwoButton layer] setBorderWidth:2];
        [[self.rankTwoButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.rankTwoButton.titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:35]];
        [self.rankTwoButton addTarget:self action:@selector(changeRank:) forControlEvents:UIControlEventTouchUpInside];
        self.rankTwoButton.alpha = 0.7;
        
        self.rankThreeButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.rankThreeButton setTitle:@"3" forState:UIControlStateNormal];
        [self.rankThreeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rankThreeButton.backgroundColor = [UIColor redColor];
        [[self.rankThreeButton layer] setCornerRadius:20];
        [[self.rankThreeButton layer] setBorderWidth:2];
        [[self.rankThreeButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.rankThreeButton.titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:40]];
        [self.rankThreeButton addTarget:self action:@selector(changeRank:) forControlEvents:UIControlEventTouchUpInside];
        self.rankThreeButton.alpha = 0.8;
        
        self.rankThreeHalfButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.rankThreeHalfButton setTitle:@"3.5" forState:UIControlStateNormal];
        [self.rankThreeHalfButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rankThreeHalfButton.backgroundColor = [UIColor redColor];
        [[self.rankThreeHalfButton layer] setCornerRadius:22.5];
        [[self.rankThreeHalfButton layer] setBorderWidth:2];
        [[self.rankThreeHalfButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.rankThreeHalfButton.titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:30]];
        [self.rankThreeHalfButton addTarget:self action:@selector(changeRank:) forControlEvents:UIControlEventTouchUpInside];
        self.rankThreeHalfButton.alpha = 0.9;
        
        self.rankFourButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [self.rankFourButton setTitle:@"4" forState:UIControlStateNormal];
        [self.rankFourButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.rankFourButton.backgroundColor = [UIColor redColor];
        [[self.rankFourButton layer] setCornerRadius:25];
        [[self.rankFourButton layer] setBorderWidth:2];
        [[self.rankFourButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.rankFourButton.titleLabel setFont:[UIFont fontWithName:@"Iowan Old Style" size:50]];
        [self.rankFourButton addTarget:self action:@selector(changeRank:) forControlEvents:UIControlEventTouchUpInside];
        self.rankFourButton.alpha = 1.0;
        
        [self.rankOneButton setFrame:CGRectMake(255, 102, 30, 30)];
        [self.rankTwoButton setFrame:CGRectMake(255, 102, 35, 35)];
        [self.rankThreeButton setFrame:CGRectMake(255, 102, 40, 40)];
        [self.rankThreeHalfButton setFrame:CGRectMake(255, 102, 45, 45)];
        [self.rankFourButton setFrame:CGRectMake(255, 102, 50, 50)];
        
        [self.rankOneButton setCenter:CGPointMake(255, 102)];
        [self.rankTwoButton setCenter:CGPointMake(255, 102)];
        [self.rankThreeButton setCenter:CGPointMake(255, 102)];
        [self.rankThreeHalfButton setCenter:CGPointMake(255, 102)];
        [self.rankFourButton setCenter:CGPointMake(255, 102)];
        
        
        [self.view addSubview:self.rankOneButton];
        [self.view addSubview:self.rankTwoButton];
        [self.view addSubview:self.rankThreeButton];
        [self.view addSubview:self.rankThreeHalfButton];
        [self.view addSubview:self.rankFourButton];
        
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.rankOneButton setFrame:CGRectMake(240, 11, 30, 30)];
            [self.rankTwoButton setFrame:CGRectMake(192, 28, 35, 35)];
            [self.rankThreeButton setFrame:CGRectMake(169, 82, 40, 40)];
            [self.rankThreeHalfButton setFrame:CGRectMake(192, 134, 45, 45)];
            [self.rankFourButton setFrame:CGRectMake(251, 146, 50, 50)];} completion:^(BOOL finished){spin = NO;}];
        spin = YES;
        [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.rankOneButton withDuration:0.1f withAngle:M_PI/2];
        [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.rankTwoButton withDuration:0.1f withAngle:M_PI/2];
        [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.rankThreeButton withDuration:0.1f withAngle:M_PI/2];
        [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.rankThreeHalfButton withDuration:0.1f withAngle:M_PI/2];
        [self spinWithOptions:UIViewAnimationOptionCurveEaseIn onView:self.rankFourButton withDuration:0.1f withAngle:M_PI/2];
    }
//    self.yrRankTextLabel.hidden = NO;
//    [self.yrRankTextLabel becomeFirstResponder];
}

-(void)doneWithPad
{
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.2];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.yrCommentTextView.frame = CGRectMake(84, 610, 600, 325);
    }
    else{
        self.yrCommentTextView.frame = CGRectMake(10, 417, 300, 120);
    }
    [UIView commitAnimations];
    
//    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
//        [self.rankOneButton setFrame:CGRectMake(603, 157, 80, 80)];
//        [self.rankTwoButton setFrame:CGRectMake(603, 157, 85, 85)];
//        [self.rankThreeButton setFrame:CGRectMake(603, 157, 90, 90)];
//        [self.rankThreeHalfButton setFrame:CGRectMake(603, 157, 95, 95)];
//        [self.rankFourButton setFrame:CGRectMake(603, 157, 100, 100)];;} completion:nil];
    
    [self.yrCommentTextView resignFirstResponder];
    [self.yrFirstNameTextField resignFirstResponder];
    [self.yrLastNameTextField resignFirstResponder];
    [self.yrEmailTextField resignFirstResponder];
    [self.yrEmailTextField acceptSuggestion];
    [self.yrBusinessUnit1 resignFirstResponder];
    [self.yrBusinessUnit2 resignFirstResponder];
    [self.yrGPATextField resignFirstResponder];
    [self.yrPreferenceTextField resignFirstResponder];
}

-(void)changeRank:(id)sender
{
    self.dataSource.rank = [NSNumber numberWithFloat:[[[(UIButton*)sender titleLabel] text] floatValue]];
    
    if ([self.dataSource.rank floatValue] == 3.5) {
        self.yrHalfRankLabel.hidden = NO;
        self.yrRankLabel.text = @"3";
    }
    else
    {
        self.yrRankLabel.text = [self.dataSource.rank stringValue];
        self.yrHalfRankLabel.hidden = YES;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.rankOneButton setCenter:CGPointMake(603, 157)];
            [self.rankTwoButton setCenter:CGPointMake(603, 157)];
            [self.rankThreeButton setCenter:CGPointMake(603, 157)];
            [self.rankThreeHalfButton setCenter:CGPointMake(603, 157)];
            [self.rankFourButton setCenter:CGPointMake(603, 157)];} completion:^(BOOL finished){[self.grayView removeFromSuperview];
                [self.rankOneButton removeFromSuperview];
                [self.rankTwoButton removeFromSuperview];
                [self.rankThreeButton removeFromSuperview];
                [self.rankThreeHalfButton removeFromSuperview];
                [self.rankFourButton removeFromSuperview];}];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.rankOneButton setCenter:CGPointMake(255, 102)];
            [self.rankTwoButton setCenter:CGPointMake(255, 102)];
            [self.rankThreeButton setCenter:CGPointMake(255, 102)];
            [self.rankThreeHalfButton setCenter:CGPointMake(255, 102)];
            [self.rankFourButton setCenter:CGPointMake(255, 102)];} completion:^(BOOL finished){[self.grayView removeFromSuperview];
                [self.rankOneButton removeFromSuperview];
                [self.rankTwoButton removeFromSuperview];
                [self.rankThreeButton removeFromSuperview];
                [self.rankThreeHalfButton removeFromSuperview];
                [self.rankFourButton removeFromSuperview];}];
    }
}

-(void)cancelRankChange
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.rankOneButton setCenter:CGPointMake(603, 157)];
            [self.rankTwoButton setCenter:CGPointMake(603, 157)];
            [self.rankThreeButton setCenter:CGPointMake(603, 157)];
            [self.rankThreeHalfButton setCenter:CGPointMake(603, 157)];
            [self.rankFourButton setCenter:CGPointMake(603, 157)];} completion:^(BOOL finished){[self.grayView removeFromSuperview];
                [self.rankOneButton removeFromSuperview];
                [self.rankTwoButton removeFromSuperview];
                [self.rankThreeButton removeFromSuperview];
                [self.rankThreeHalfButton removeFromSuperview];
                [self.rankFourButton removeFromSuperview];}];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.rankOneButton setCenter:CGPointMake(255, 102)];
            [self.rankTwoButton setCenter:CGPointMake(255, 102)];
            [self.rankThreeButton setCenter:CGPointMake(255, 102)];
            [self.rankThreeHalfButton setCenter:CGPointMake(255, 102)];
            [self.rankFourButton setCenter:CGPointMake(255, 102)];} completion:^(BOOL finished){[self.grayView removeFromSuperview];
                [self.rankOneButton removeFromSuperview];
                [self.rankTwoButton removeFromSuperview];
                [self.rankThreeButton removeFromSuperview];
                [self.rankThreeHalfButton removeFromSuperview];
                [self.rankFourButton removeFromSuperview];}];
    }
}

-(void)removeViews
{
    [self.scheduleView removeFromSuperview];
    [self.emailOptionView removeFromSuperview];
    [self.resumeOptionView removeFromSuperview];
    [self.grayView removeFromSuperview];
}

-(void)checkScheduleFunction
{
    [self removeViews];
    int half = 0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        half = 150;
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        half = 120;
    }
    
    for (Appointment* ap in self.dataSource.appointments)
    {
        if (ap.interviewers == nil) {
            NSLog(@"%@ with - TBA",ap.startTime);
        }
        else
        {
            NSLog(@"%@ with - %@",ap.startTime,ap.interviewers.name);
        }
    }
    
    self.scheduleView = [[UIView alloc] initWithFrame:CGRectMake(self.checkInterviewButton.center.x-half, self.checkInterviewButton.center.y+[self.checkInterviewButton layer].cornerRadius+5, 2*half, 200)];
    [[self.scheduleView layer] setCornerRadius:12];
    
    self.scheduleTable = [[UITableView alloc] initWithFrame:CGRectMake(5, 40, 2*half - 10, 155) style:UITableViewStylePlain];
    [[self.scheduleTable layer] setCornerRadius:10];
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 2*half - 100, 20)];
    titleLabel.text = @"Schedule Info";
    titleLabel.textColor = [UIColor purpleColor];
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.font = [UIFont boldSystemFontOfSize:15];
    
    [self.scheduleView addSubview:titleLabel];
    [self.scheduleView addSubview:self.scheduleTable];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIViewController* newController = [UIViewController new];
        self.popOver = [[UIPopoverController alloc] initWithContentViewController:newController];
        newController.view = self.scheduleView;
        
        [self.popOver setPopoverContentSize:CGSizeMake(2*half, 200)];
        
        [self.popOver presentPopoverFromRect:CGRectMake(self.checkInterviewButton.center.x-half, self.checkInterviewButton.center.y+[self.checkInterviewButton layer].cornerRadius+5, 2*half, -2) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
    else
    {
        self.scheduleView.backgroundColor = [UIColor purpleColor];
        titleLabel.textColor = [UIColor whiteColor];
        self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
        self.grayView.backgroundColor = [UIColor darkGrayColor];
        self.grayView.alpha = 0.5;
        [self.grayView addTarget:self action:@selector(removeViews) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:self.grayView];
        
        [self.view addSubview:self.scheduleView];
    }
    
    
    self.scheduleTable.delegate = self;
    self.scheduleTable.dataSource = self;
}

-(void)scrollLeft
{
    NSLog(@"Left");
    if (showingImageIndex+1<[self.dataSource.fileNames count]) {
        showingImageIndex = showingImageIndex + 1;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
        
        NSError *error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        
        //    NSDateFormatter* format = [[NSDateFormatter alloc] init];
        //    [format setDateFormat:@"MMddyyyHHmm"];
        //    NSString* date = [format stringFromDate:[(CandidateEntry*)[self.yrdataEntry objectAtIndex:indexPath.row] date]];
        
        NSString* fileName = self.dataSource.fileNames[showingImageIndex];
        
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
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Last Page" message:@"This is the last Page" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
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
        
        //    NSDateFormatter* format = [[NSDateFormatter alloc] init];
        //    [format setDateFormat:@"MMddyyyHHmm"];
        //    NSString* date = [format stringFromDate:[(CandidateEntry*)[self.yrdataEntry objectAtIndex:indexPath.row] date]];
        
        NSString* fileName = self.dataSource.fileNames[showingImageIndex];
        
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
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"First Page" message:@"This is the first Page" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
}


#pragma mark - UIScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return [scrollView.subviews objectAtIndex:0];
}

#pragma mark - UITextViewDelegate

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.4];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.yrCommentTextView.frame = CGRectMake(30, 350, 708, 385);
    }
    else{
        self.yrCommentTextView.frame = CGRectMake(10, 145, 300, 200);
    }
    
    [UIView commitAnimations];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    [self.yrCommentTextView resignFirstResponder];
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

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.yrFirstNameTextField resignFirstResponder];
    [self.yrLastNameTextField resignFirstResponder];
    [self.yrEmailTextField resignFirstResponder];
    [self.yrEmailTextField acceptSuggestion];
    [self.yrBusinessUnit1 resignFirstResponder];
    [self.yrBusinessUnit2 resignFirstResponder];
    [self.yrGPATextField resignFirstResponder];
    [self.yrPreferenceTextField resignFirstResponder];
}

#pragma mark - AutoSuggestDelegate

- (NSString *)suggestedStringForInputString:(NSString *)input
{
    static NSArray *domains;
    if (!domains) {
        domains = @[@"gmail.com",
                    @"gmail.co.uk",
                    @"yahoo.com",
                    @"yahoo.cn",
                    @"hotmail.com",
                    @"yahoo-inc.com"];
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

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.scheduleTable) {
        return [self.dataSource.appointments count];
    }
    else if (tableView == self.emailOptionTable)
    {
        self.formList = [[NSUserDefaults standardUserDefaults] objectForKey:kYREmailFormsKey];
        
        if (self.formList == nil) {
            return 0;
        }else
        {
            return [self.formList count];
        }
    }
    else if (tableView == self.resumeOptionTable)
    {
        return [self.dataSource.fileNames count];
    }
    else
    {
        return 0;
    }
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* identifier;
    if (tableView == self.scheduleTable) {
        identifier = @"scheduleIdentifier";
    }
    else if (tableView == self.emailOptionTable)
    {
        identifier = @"emailOptionIdentifier";
    }
    else if (tableView == self.resumeOptionTable)
    {
        identifier = @"resumeOptionIdentifier";
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (tableView == self.scheduleTable) {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        }
        
        if ([(Appointment*)[self.dataSource.appointments allObjects][indexPath.row] interviewers] == nil) {
            cell.textLabel.text = [NSString stringWithFormat:@"%@   with - TBA",[(Appointment*)[self.dataSource.appointments allObjects][indexPath.row] startTime]];
        }
        else
        {
            cell.textLabel.text = [NSString stringWithFormat:@"%@   with - %@",[(Appointment*)[self.dataSource.appointments allObjects][indexPath.row] startTime], [[(Appointment*)[self.dataSource.appointments allObjects][indexPath.row] interviewers] name]];
        }
        
        //cell.detailLabel
        cell.detailTextLabel.text = [NSString stringWithFormat:@"Room %d",[[(Appointment*)[self.dataSource.appointments allObjects][indexPath.row] apIndex_y] intValue]+1];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            cell.textLabel.font = [UIFont systemFontOfSize:12];
        }
        cell.contentView.alpha = 0.5;
    }
    else if (tableView == self.emailOptionTable)
    {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.textLabel.text = [self.formList[indexPath.row] allKeys][0];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            cell.textLabel.font = [UIFont systemFontOfSize:12];
        }
    }
    else if (tableView == self.resumeOptionTable)
    {
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        
        cell.textLabel.text = self.dataSource.fileNames[indexPath.row];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            cell.textLabel.font = [UIFont systemFontOfSize:12];
        }
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView == self.emailOptionTable) {
        currentSelectedEmailForm = indexPath.row;
        //if (indexPath.row == 0) {
            //default now
            [self email];
        //}
    }
    else if (tableView == self.resumeOptionTable)
    {
        [self.popOver dismissPopoverAnimated:YES];
        
        [self removeViews];
        
        if (!replacingMode)
        {
            showingImageIndex = indexPath.row;
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
            
            NSError *error;
            if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
            //
            //        NSDateFormatter* format = [[NSDateFormatter alloc] init];
            //        [format setDateFormat:@"MMddyyyHHmm"];
            //        NSString* date = [format stringFromDate:self.dataSource.date];
            
            NSString* fileName = self.dataSource.fileNames[indexPath.row];
            
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
            
            [self.yrGoBackButton setHidden:YES];
            
            [self.yrScrollViewCancelButton setTitle:@"Done" forState:UIControlStateNormal];
            [self.yrScrollViewCancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [[self.yrScrollViewCancelButton layer] setCornerRadius:50];
                [[self.yrScrollViewCancelButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
                [[self.yrScrollViewCancelButton layer] setBorderWidth:5];
                
                self.yrScrollViewCancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:25];
            }
            else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            {
                [[self.yrScrollViewCancelButton layer] setCornerRadius:25];
                [[self.yrScrollViewCancelButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
                [[self.yrScrollViewCancelButton layer] setBorderWidth:3];
                
                self.yrScrollViewCancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
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
        else
        {
            replacingMode = NO;
            NSString* fileToReplace = self.dataSource.fileNames[indexPath.row];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                NSData* imageData = [NSData dataWithData: UIImageJPEGRepresentation(self.chosenImage, 0.2)];
                //save in local resource
                NSLog(@"%ul",imageData.length);
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
                
                NSError *error;
                if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                    [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
                
//                NSDateFormatter* format = [[NSDateFormatter alloc] init];
//                [format setDateFormat:@"MMddyyyHHmm"];
//                NSString* date = [format stringFromDate:self.dataSource.date];
//                
//                NSString* fileName = [self.yrCodeLabel.text stringByAppendingString:[NSString stringWithFormat:@"_%@_%d",date,[self.dataSource.fileNames count]+1]];
                
                NSString *fullPath = [dataPath stringByAppendingPathComponent:fileToReplace];
                
                bool ret = [imageData writeToFile:fullPath options:0 error:&error];
                
                if (!ret) {
                    NSLog(@"Error while saving Image");
                }
            });
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIAlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Adding New Page"]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData* imageData = [NSData dataWithData: UIImageJPEGRepresentation(self.chosenImage, 0.2)];
            //save in local resource
            
            NSLog(@"%ul",imageData.length);
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
            
            NSError *error;
            if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
            
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"MMddyyyHHmm"];
            NSString* date = [format stringFromDate:self.dataSource.date];
            
            NSString* fileName = [self.yrCodeLabel.text stringByAppendingString:[NSString stringWithFormat:@"_%@_%d",date,[self.dataSource.fileNames count]+1]];
            
            NSString *fullPath = [dataPath stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"jpg"]];
            
            bool ret = [imageData writeToFile:fullPath options:0 error:&error];
            
            if (ret) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
                    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:[self.appDelegate managedObjectContext]]];
                    
                    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@ and firstName = %@ and lastName = %@",self.dataSource.code,self.dataSource.firstName,self.dataSource.lastName]];
                    
                    NSError* error = nil;
                    NSMutableArray* mutableFetchResults = [[[self.appDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error] mutableCopy];
                    
                    CandidateEntry* selected = mutableFetchResults[0];
                    
                    [selected setPdf:[NSNumber numberWithBool:YES]];
                    
                    [self.yrFileNameButton setTitle:@"Resume" forState:UIControlStateNormal];
                    [self.yrFileNameButton setHidden:NO];
                    
                    NSMutableArray* fileNames = [selected.fileNames mutableCopy];
                    
                    [fileNames addObject:[NSString stringWithFormat:@"%@.jpg",fileName]];
                    
                    [selected setFileNames:[NSArray arrayWithArray:fileNames]];
                    
                    self.dataSource = selected;
                    
                    if (![[self.appDelegate managedObjectContext] save:&error]) {
                        NSLog(@"ERROR -- saving coredata");
                    }
                });
                
            } else{
                NSLog(@"Error while saving Image");
            }
        });
    }
    else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Replacing Old Page"])
    {
        //pop up options
        replacingMode = YES;
        
        int half = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            half = 150;
        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            half = 120;
        }
        
        self.resumeOptionView = [[UIView alloc] initWithFrame:CGRectMake(self.yrFileNameButton.center.x-half, self.yrFileNameButton.center.y+20, 2*half, 160)];
        [[self.resumeOptionView layer] setCornerRadius:12];
        
        self.resumeOptionTable = [[UITableView alloc] initWithFrame:CGRectMake(5, 5, 2*half - 10, 150) style:UITableViewStylePlain];
        [[self.resumeOptionTable layer] setCornerRadius:10];
//        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, 2*half - 100, 20)];
//        titleLabel.text = @"Files";
//        titleLabel.textColor = [UIColor purpleColor];
//        titleLabel.textAlignment = NSTextAlignmentLeft;
//        titleLabel.font = [UIFont boldSystemFontOfSize:15];
        
//        [self.resumeOptionView addSubview:titleLabel];
        [self.resumeOptionView addSubview:self.resumeOptionTable];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            UIViewController* newController = [UIViewController new];
            self.popOver = [[UIPopoverController alloc] initWithContentViewController:newController];
            newController.view = self.resumeOptionView;
            
            [self.popOver setPopoverContentSize:CGSizeMake(2*half, 160)];
            
            [self.popOver presentPopoverFromRect:CGRectMake(self.yrFileNameButton.center.x-half, self.yrFileNameButton.center.y+20, 2*half, -2) inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        }
        else
        {
            self.resumeOptionView.backgroundColor = [UIColor purpleColor];
//            titleLabel.textColor = [UIColor whiteColor];
            self.grayView = [[UIControl alloc] initWithFrame:self.view.frame];
            self.grayView.backgroundColor = [UIColor darkGrayColor];
            self.grayView.alpha = 0.5;
            [self.grayView addTarget:self action:@selector(removeViews) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:self.grayView];
            
            [self.view addSubview:self.resumeOptionView];
        }
        self.resumeOptionTable.delegate = self;
        self.resumeOptionTable.dataSource = self;
    }
}

@end
