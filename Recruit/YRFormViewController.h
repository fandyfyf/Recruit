//
//  YRFormViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Guile/AutoSuggestDelegate.h>
#import "YRAppDelegate.h"
@class AutoSuggestTextField;

@interface YRFormViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, AutoSuggestTextFieldDelegate>

@property (strong, nonatomic) NSKeyedArchiver* yrarchiver;
@property (strong, nonatomic) YRAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet UILabel *yrcodeLabel;
@property (weak, nonatomic) IBOutlet UITextField *yrfirstnameLabel;
@property (weak, nonatomic) IBOutlet UITextField *yrlastnameLabel;
@property (weak, nonatomic) IBOutlet AutoSuggestTextField *yremailLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yrgenderSegmentControl;
@property (weak, nonatomic) IBOutlet UIButton *sendButton;
- (IBAction)refreshInformation:(id)sender;

- (IBAction)sendInformation:(id)sender;

- (IBAction)backgroundTapped:(id)sender;

@end
