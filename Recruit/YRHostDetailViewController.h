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

@interface YRHostDetailViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIScrollViewDelegate, UITextViewDelegate, MFMailComposeViewControllerDelegate, UITextFieldDelegate, AutoSuggestTextFieldDelegate, UITableViewDataSource, UITableViewDelegate,UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) CandidateEntry *dataSource;
@property (strong, nonatomic) NSNumber *checkScheduleFlag;
@property (strong, nonatomic) NSMutableArray *formList;
@property (strong, nonatomic) YRAppDelegate* appDelegate;
@property (weak, nonatomic) IBOutlet UILabel *yrCodeLabel;

@property (weak, nonatomic) IBOutlet UITextField *yrFirstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *yrLastNameTextField;

@property (weak, nonatomic) IBOutlet AutoSuggestTextField *yrEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *yrBusinessUnit1;
@property (weak, nonatomic) IBOutlet UITextField *yrBusinessUnit2;

@property (weak, nonatomic) IBOutlet UISegmentedControl *yrPositionSegmentControl;
@property (weak, nonatomic) IBOutlet UILabel *yrGPALabel;
@property (weak, nonatomic) IBOutlet UITextField *yrGPATextField;
@property (weak, nonatomic) IBOutlet UILabel *yrRankLabel;
@property (weak, nonatomic) IBOutlet UILabel *yrHalfRankLabel;

@property (weak, nonatomic) IBOutlet UITextField *yrPreferenceTextField;

@property (weak, nonatomic) IBOutlet UILabel *yrRecommandMark;
@property (weak, nonatomic) IBOutlet UISwitch *yrRecommendSwitch;
@property (weak, nonatomic) IBOutlet UILabel *yrRecommendLabel;
@property (weak, nonatomic) IBOutlet UIButton *yrSnapshotButton;
@property (weak, nonatomic) IBOutlet UIButton *yrFileNameButton;
@property (weak, nonatomic) IBOutlet UIButton *yrGoBackButton;

@property (strong, nonatomic) UIScrollView* yrScrollView;
@property (strong, nonatomic) UIImageView* showingImageView;
@property (strong, nonatomic) UIButton* yrScrollViewCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *yrScheduleButton;
@property (weak, nonatomic) IBOutlet UIButton *yrEmailButton;
@property (weak, nonatomic) IBOutlet UIButton *checkInterviewButton;

@property (weak, nonatomic) IBOutlet UILabel *YRCommentLabel;
@property (weak, nonatomic) IBOutlet UITextView *yrCommentTextView;
@property (strong, nonatomic) UIView* scheduleView;
@property (strong, nonatomic) UITableView* scheduleTable;
@property (strong, nonatomic) UIView* emailOptionView;
@property (strong, nonatomic) UITableView* emailOptionTable;
@property (strong, nonatomic) UIView* resumeOptionView;
@property (strong, nonatomic) UITableView* resumeOptionTable;

@property (strong, nonatomic) UIControl* grayView;
@property (strong, nonatomic) UIButton* rankOneButton;
@property (strong, nonatomic) UIButton* rankTwoButton;
@property (strong, nonatomic) UIButton* rankThreeButton;
@property (strong, nonatomic) UIButton* rankThreeHalfButton;
@property (strong, nonatomic) UIButton* rankFourButton;

@property (strong, nonatomic) UIPopoverController* popOver;

@property (strong, nonatomic) MFMailComposeViewController* yrMailViewController;
@property (strong, nonatomic) UIImage* chosenImage;

- (IBAction)takeAnImage:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)checkImage:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)emailCandidate:(id)sender;
- (IBAction)scheduleInterview:(id)sender;
- (IBAction)checkSchedule:(id)sender;
- (IBAction)recommendChange:(id)sender;

@end
