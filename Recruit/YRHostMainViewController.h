//
//  YRHostMainViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MultipeerConnectivity/MultipeerConnectivity.h>
#import "YRAppDelegate.h"

@interface YRHostMainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIAlertViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) UIViewController* source;
@property (weak, nonatomic) IBOutlet UILabel *yrnameLabel;
@property (weak, nonatomic) IBOutlet UITableView *yrtableView;
@property (strong, nonatomic) UITableView *eventList;
@property (strong, nonatomic) UIControl* grayView;
@property (weak, nonatomic) IBOutlet UIButton *yrdisconnectButton;
@property (weak, nonatomic) IBOutlet UIButton *yrbrowseButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yrOnOffControl;

@property (strong, nonatomic) NSArray* eventArray;
@property (weak, nonatomic) IBOutlet UIButton *yrSignOutButton;
@property (weak, nonatomic) IBOutlet UITextField *yrPrefixTextField;

@property (strong, nonatomic) NSString *yrPrefix;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;


@property (strong, nonatomic) YRAppDelegate *appDelegate;

- (IBAction)signOut:(id)sender;
- (IBAction)backgroundTapped:(id)sender;
- (IBAction)onOffSwitch:(id)sender;

@end
