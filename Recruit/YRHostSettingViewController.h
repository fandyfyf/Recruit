//
//  YRHostSettingViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/13/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Guile/AutoSuggestDelegate.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "YREventDataCell.h"
#import "YRViewerDataCell.h"
#import "YRDatePickerView.h"
#import "YRYDayPickerView.h"

@class AutoSuggestTextField;

@interface YRHostSettingViewController : UIViewController <AutoSuggestTextFieldDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextViewDelegate,MFMailComposeViewControllerDelegate, YREventDataCellDelegate, YRViewerDataCellDelegate,YRYDayPickerViewDelegate, UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet AutoSuggestTextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITableView *interviewerList;

//new interviewer info
@property (strong, nonatomic) AutoSuggestTextField* interviewerEmail;
@property (strong, nonatomic) UITextField* interviewerName;
@property (strong,nonatomic) UITextField* interviewerCode;
//new event card info
@property (strong, nonatomic) UITextField* eventCode;
@property (strong, nonatomic) UITextField* eventName;
@property (strong, nonatomic) UITextField* eventAddress;

//table view contents
@property (strong, nonatomic) NSMutableArray* eventArray;
@property (strong, nonatomic) NSMutableArray* interviewerArray;
@property (strong, nonatomic) NSMutableArray* formList;
@property (strong, nonatomic) NSArray* emailKeywordArray;
@property (strong, nonatomic) NSMutableArray* YdayList;


@property (weak, nonatomic) IBOutlet UIButton *uploadButton;

//schedule configuration
@property (weak, nonatomic) IBOutlet UITextField *interviewStartTime;
@property (weak, nonatomic) IBOutlet UITextField *interviewDuration;
@property (weak, nonatomic) IBOutlet UITextField *interviewLocations;
@property (weak, nonatomic) IBOutlet UITextField *interviewStartDate;
@property (weak, nonatomic) IBOutlet UITextField *interviewEndDate;
@property (strong, nonatomic) UITapGestureRecognizer* tapGestureRecognizer;
@property (strong, nonatomic) YRDatePickerView* datePickerView;
@property (strong, nonatomic) YRYDayPickerView* yDayPickerView;

//addButtons, remove buttons are not used
@property (weak, nonatomic) IBOutlet UIButton *yrRemoveButton;
@property (weak, nonatomic) IBOutlet UIButton *yrAddButton;
@property (weak, nonatomic) IBOutlet UIButton *yrAddFormButton;
@property (weak, nonatomic) IBOutlet UIButton *yrRemoveFormButton;
@property (weak, nonatomic) IBOutlet UIButton *yrAddEventButton;

@property (weak, nonatomic) IBOutlet UISegmentedControl *yrDebriefSegCtrl;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITextView* yrEditingView;
@property (strong, nonatomic) UITableView* yrEditingTable;
@property (strong, nonatomic) UIButton* removeFromViewButton;
@property (strong, nonatomic) UIControl* grayView;
@property (strong, nonatomic) MFMailComposeViewController* yrMailViewController;

//pull down menu for existing event code
@property (strong, nonatomic) UITableView* eventListView;

- (IBAction)addInterviewer:(id)sender;
- (IBAction)removeAll:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)addEmailForm:(id)sender;
- (IBAction)removeEmailForms:(id)sender;
- (IBAction)addEvent:(id)sender;

- (IBAction)changeDebriefStatus:(id)sender;

- (IBAction)uploadData:(id)sender;

@end
