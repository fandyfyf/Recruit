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

@interface YRHostDetailViewController ()

-(void)cancelScrollView;
-(void)updateCoreData;

@end

@implementation YRHostDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.appDelegate = (YRAppDelegate* )[[UIApplication sharedApplication] delegate];
    
    self.yrCodeLabel.text = self.dataSource.code;
    if ([self.dataSource.gender isEqualToString:@"M"]) {
        self.yrGenderLabel.text = @"Male";
    }
    else
    {
        self.yrGenderLabel.text = @"Female";
    }
    if ([self.dataSource.preference isEqualToString:@"FE"]) {
        self.yrPreferenceLabel.text = @"Back End";
    }
    else if ([self.dataSource.preference isEqualToString:@"BE"])
    {
        self.yrPreferenceLabel.text = @"Front End";
    }
    else
    {
        self.yrPreferenceLabel.text = self.dataSource.preference;
    }
    
    self.yrFirstNameTextField.delegate = self;
    self.yrLastNameTextField.delegate = self;
    self.yrEmailTextField.delegate = self;
    self.yrEmailTextField.suggestionDelegate = self;
    
    self.yrFirstNameTextField.text = self.dataSource.firstName;
    self.yrLastNameTextField.text = self.dataSource.lastName;
    self.yrEmailTextField.text = self.dataSource.emailAddress;
    
    if ([self.dataSource.recommand boolValue]) {
        self.yrRecommendedLabel.text = self.dataSource.interviewer;
        self.yrRecommandMark.textColor = [UIColor redColor];
    }
    if ([self.dataSource.pdf boolValue]) {
        [self.yrRetakeButton setHidden:NO];
        
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MMddyyyHHmm"];
        NSString* date = [format stringFromDate:self.dataSource.date];
        
        NSString* fileName = [self.yrCodeLabel.text stringByAppendingString:[NSString stringWithFormat:@"_%@",date]];
        
        NSString *fullPath = [fileName stringByAppendingPathExtension:@"jpg"];
        
        [self.yrSnapshotButton setTitle:fullPath forState:UIControlStateNormal];
    }
    
    [self.yrCommentTextView setDelegate:self];
    
    [[self.yrCommentTextView layer] setCornerRadius:10];
    
    [self.yrCommentTextView setText:self.dataSource.notes];
    
    if (self.yrEmailTextField.text.length == 0) {
        [self.yrEmailCandidateButton setEnabled:NO];
    }
    else
    {
        [self.yrEmailCandidateButton setEnabled:YES];
    }
    
    if ([self.dataSource.position isEqualToString:@"Intern"]) {
        self.yrPositionSegmentControl.selectedSegmentIndex = 0;
    }
    else
    {
        self.yrPositionSegmentControl.selectedSegmentIndex = 1;
    }
    
    
    if ([self.dataSource.rank floatValue] == 3.5) {
        self.yrHalfRankLabel.hidden = NO;
        self.yrRankLabel.text = @"3";
    }
    else
    {
        self.yrRankLabel.text = [self.dataSource.rank stringValue];
    }
    
    
    self.yrGPALabel.text = [NSString stringWithFormat:@"GPA: %@/%@",self.dataSource.gpa,self.dataSource.maxgpa];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)takeAnImage:(id)sender {
    if (self.yrRetakeButton.isHidden) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:NULL];
    }
    else
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
        
        NSError *error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
        
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MMddyyyHHmm"];
        NSString* date = [format stringFromDate:self.dataSource.date];
        
        NSString* fileName = [self.yrCodeLabel.text stringByAppendingString:[NSString stringWithFormat:@"_%@",date]];
        
        NSString *fullPath = [dataPath stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"jpg"]];
        
        UIImage* image = [UIImage imageWithData:[NSData dataWithContentsOfFile:fullPath]];
        
        
        UIImageView* imageview = [[UIImageView alloc] initWithImage:image];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [imageview setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        }
        else{
            [imageview setFrame:CGRectMake(0, 0, self.view.frame.size.width, 480)];
        }
        
        self.yrScrollViewCancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.yrScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
            self.yrScrollViewCancelButton.frame = CGRectMake(self.view.frame.size.width-50, 0, 50, 50);
        }
        else{
            self.yrScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 45, self.view.frame.size.width, 480)];
            self.yrScrollViewCancelButton.frame = CGRectMake(self.view.frame.size.width-50, 45, 50, 50);
        }
        //self.yrScrollView.contentSize = image.size;
        self.yrScrollView.contentSize = imageview.frame.size;
        [self.yrScrollView addSubview:imageview];
        [self.yrScrollView setDelegate:self];
        [self.yrScrollView setMaximumZoomScale:4];
        [self.yrScrollView setMinimumZoomScale:1];
        
        [self.view addSubview:self.yrScrollView];
        
        [self.yrGoBackButton setHidden:YES];
        
        [self.yrScrollViewCancelButton setTitle:@"X" forState:UIControlStateNormal];
        
        self.yrScrollViewCancelButton.titleLabel.textColor = [UIColor redColor];
        self.yrScrollViewCancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:25];
        [self.yrScrollViewCancelButton addTarget:self action:@selector(cancelScrollView) forControlEvents:UIControlEventTouchUpInside];
        
        [self.view addSubview:self.yrScrollViewCancelButton];
    }
}

- (IBAction)goBack:(id)sender {
    [self updateCoreData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)retakeImage:(id)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = NO;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

- (IBAction)backgroundTapped:(id)sender {
    [UIView beginAnimations:@"move" context:nil];
    [UIView setAnimationDuration:0.5];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.yrCommentTextView.frame = CGRectMake(84, 530, 600, 385);
    }
    else{
        self.yrCommentTextView.frame = CGRectMake(10, 363, 300, 150);
    }
    [UIView commitAnimations];
    [self.yrCommentTextView resignFirstResponder];
    [self.yrFirstNameTextField resignFirstResponder];
    [self.yrLastNameTextField resignFirstResponder];
    [self.yrEmailTextField resignFirstResponder];
    [self.yrEmailTextField acceptSuggestion];
}

- (IBAction)emailCandidate:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        NSString *emailTitle = @"Letter From Yahoo!";
        NSString *messageBody = @"Message goes here!";
        NSArray *toRecipents = [NSArray arrayWithObject:self.yrEmailTextField.text];
        
        self.yrMailViewController = [[MFMailComposeViewController alloc] init];
        self.yrMailViewController.mailComposeDelegate = self;
        [self.yrMailViewController setSubject:emailTitle];
        [self.yrMailViewController setMessageBody:messageBody isHTML:NO];
        [self.yrMailViewController setToRecipients:toRecipents];
        
        if (! self.yrRetakeButton.isHidden) {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
            
            NSError *error;
            if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
            
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"MMddyyyHHmm"];
            NSString* date = [format stringFromDate:self.dataSource.date];
            
            NSString* fileName = [self.yrCodeLabel.text stringByAppendingString:[NSString stringWithFormat:@"_%@",date]];
            
            NSString *fullPath = [dataPath stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:@"jpg"]];
            
            [self.yrMailViewController addAttachmentData:[NSData dataWithContentsOfFile:fullPath] mimeType:@"image/jpeg" fileName:[NSString stringWithFormat:@"%@.jpg",[self.yrCodeLabel text]]];
        }
        // Present mail view controller on screen
        [self presentViewController:self.yrMailViewController animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"Fail");
    }
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    UIImage *chosenImage = info[UIImagePickerControllerOriginalImage];
    //self.imageView.image = chosenImage;
    //compress into Jpeg file
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData* imageData = [NSData dataWithData: UIImageJPEGRepresentation(chosenImage, 1.0)];
        //save in local resource
    
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
    
        NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"Candidates_PDF_Folder"];
    
        NSError *error;
        if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
            [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error]; //Create folder
    
        NSDateFormatter* format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MMddyyyHHmm"];
        NSString* date = [format stringFromDate:self.dataSource.date];
        
        NSString* fileName = [self.yrCodeLabel.text stringByAppendingString:[NSString stringWithFormat:@"_%@",date]];
        
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
                
                [self.yrSnapshotButton setTitle:[NSString stringWithFormat:@"%@.jpg",fileName] forState:UIControlStateNormal];
                [self.yrRetakeButton setHidden:NO];
                
                if (![[self.appDelegate managedObjectContext] save:&error]) {
                    NSLog(@"ERROR -- saving coredata");
                }
            });
            
        } else{
            NSLog(@"Error while saving Image");
        }
        
    });
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

-(void)cancelScrollView
{
    [self.yrScrollView removeFromSuperview];
    [self.yrScrollViewCancelButton removeFromSuperview];
    [self.yrGoBackButton setHidden:NO];
}

-(void)updateCoreData
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"CandidateEntry" inManagedObjectContext:[self.appDelegate managedObjectContext]]];
    
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"code = %@ and firstName = %@ and lastName = %@",self.dataSource.code,self.dataSource.firstName,self.dataSource.lastName]];
    
    NSError* error = nil;
    NSMutableArray* mutableFetchResults = [[[self.appDelegate managedObjectContext] executeFetchRequest:fetchRequest error:&error] mutableCopy];
    
    CandidateEntry* selected = mutableFetchResults[0];
    
    [selected setFirstName:self.yrFirstNameTextField.text];
    [selected setLastName:self.yrLastNameTextField.text];
    [selected setEmailAddress:self.yrEmailTextField.text];
    [selected setPosition:[self.yrPositionSegmentControl titleForSegmentAtIndex:self.yrPositionSegmentControl.selectedSegmentIndex]];
    [selected setNotes:self.yrCommentTextView.text];
    
    if (![[self.appDelegate managedObjectContext] save:&error]) {
        NSLog(@"ERROR -- saving coredata");
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
    [UIView setAnimationDuration:0.5];
    
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

@end
