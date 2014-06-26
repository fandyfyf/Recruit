//
//  YRFormViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YRAppDelegate.h"

@interface YRFormViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) NSKeyedArchiver* yrarchiver;
@property (strong, nonatomic) YRAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UILabel *yrcodeLabel;

@property (strong, nonatomic) UIViewController* source;

@property (weak, nonatomic) IBOutlet UITextField *yrGPATextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yrPositionSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yrGraduationSegCtrl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yrPreferenceSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yrPlatformSegCtrl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yrRankingSegmentControl;
@property (weak, nonatomic) IBOutlet UITextView *yrNoteTextView;


@property (weak, nonatomic) IBOutlet UIButton *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;



- (IBAction)refreshInformation:(id)sender;

- (IBAction)sendInformation:(id)sender;

- (IBAction)backgroundTapped:(id)sender;

- (IBAction)cancelTapped:(id)sender;
@end
