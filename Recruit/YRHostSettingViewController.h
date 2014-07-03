//
//  YRHostSettingViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/13/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Guile/AutoSuggestDelegate.h>

@class AutoSuggestTextField;

@interface YRHostSettingViewController : UIViewController <AutoSuggestTextFieldDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate, UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet AutoSuggestTextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITableView *interviewerList;

@property (strong, nonatomic) AutoSuggestTextField* interviewerEmail;
@property (strong, nonatomic) UITextField* interviewerName;

@property (strong,nonatomic) UITextField* interviewerCode;

@property (strong, nonatomic) NSMutableArray* interviewerArray;
@property (strong, nonatomic) NSArray* emailKeywordArray;
@property (weak, nonatomic) IBOutlet UITextField *interviewStartTime;
@property (weak, nonatomic) IBOutlet UITextField *interviewDuration;
@property (weak, nonatomic) IBOutlet UITextField *interviewLocations;
@property (weak, nonatomic) IBOutlet UIButton *yrRemoveButton;
@property (weak, nonatomic) IBOutlet UIButton *yrAddButton;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UITextView* yrEditingView;
@property (strong, nonatomic) UITableView* yrEditingTable;
@property (strong, nonatomic) UIButton* removeFromViewButton;
@property (strong, nonatomic) UIControl* grayView;


- (IBAction)addInterviewer:(id)sender;
- (IBAction)removeAll:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
@end
