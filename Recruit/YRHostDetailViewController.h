//
//  YRHostDetailViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/14/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CandidateEntry.h"
#import <Guile/AutoSuggestDelegate.h>
#import "YRAppDelegate.h"
#import <MessageUI/MFMailComposeViewController.h>

@class AutoSuggestTextField;

@interface YRHostDetailViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate, AutoSuggestTextFieldDelegate>

@property (strong, nonatomic) CandidateEntry *dataSource;
@property (strong, nonatomic) YRAppDelegate* appDelegate;
@property (weak, nonatomic) IBOutlet UILabel *yrCodeLabel;

@property (weak, nonatomic) IBOutlet UITextField *yrFirstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *yrLastNameTextField;

@property (weak, nonatomic) IBOutlet AutoSuggestTextField *yrEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *yrBusinessUnit1;
@property (weak, nonatomic) IBOutlet UITextField *yrBusinessUnit2;

@property (weak, nonatomic) IBOutlet UISegmentedControl *yrPositionSegmentControl;
@property (weak, nonatomic) IBOutlet UILabel *yrGPALabel;
@property (weak, nonatomic) IBOutlet UILabel *yrRankLabel;
@property (weak, nonatomic) IBOutlet UILabel *yrHalfRankLabel;

@property (weak, nonatomic) IBOutlet UILabel *yrPreferenceLabel;
@property (weak, nonatomic) IBOutlet UILabel *yrRecommendedLabel;
@property (weak, nonatomic) IBOutlet UILabel *yrRecommandMark;
@property (weak, nonatomic) IBOutlet UIButton *yrSnapshotButton;
@property (weak, nonatomic) IBOutlet UIButton *yrRetakeButton;
@property (weak, nonatomic) IBOutlet UIButton *yrGoBackButton;
@property (weak, nonatomic) IBOutlet UIButton *yrEmailCandidateButton;
@property (strong, nonatomic) UIScrollView* yrScrollView;
@property (strong, nonatomic) UIButton* yrScrollViewCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *yrScheduleButton;
@property (weak, nonatomic) IBOutlet UIButton *yrEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *checkInterviewButton;

@property (weak, nonatomic) IBOutlet UITextView *yrCommentTextView;
@property (strong, nonatomic) MFMailComposeViewController* yrMailViewController;

- (IBAction)takeAnImage:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)retakeImage:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)emailCandidate:(id)sender;
- (IBAction)scheduleInterview:(id)sender;

@end
