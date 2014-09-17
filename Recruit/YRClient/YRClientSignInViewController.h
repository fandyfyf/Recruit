//
//  YRClientSignInViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/19/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YRAppDelegate.h"
#import <Guile/AutoSuggestDelegate.h>
#import "YRDebriefViewController.h"

@class AutoSuggestTextField;

@interface YRClientSignInViewController : UIViewController <UITextFieldDelegate, AutoSuggestTextFieldDelegate,UITableViewDataSource,UITableViewDelegate,MCNearbyServiceBrowserDelegate, UIAlertViewDelegate>


@property (weak, nonatomic) IBOutlet UILabel *queuingNumberLabel;
@property (strong, nonatomic) YRAppDelegate *appDelegate;
@property (strong, nonatomic) NSMutableString *yrIDCode;
@property (strong, nonatomic) YRDebriefViewController* debriefingViewController;
@property (strong, nonatomic) UIView * yrNameListView;
@property (strong, nonatomic) UITableView *yrNameList;
@property (strong, nonatomic) UIView * grayView;

@property (weak, nonatomic) IBOutlet UILabel *yrcodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *yrnameLabel;
@property (weak, nonatomic) IBOutlet UIButton *yrSignOutButton;
@property (weak, nonatomic) IBOutlet UIButton *yrContinueButton;
@property (weak, nonatomic) IBOutlet UITextField *yrFirstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *yrLastNameTextField;
@property (weak, nonatomic) IBOutlet AutoSuggestTextField *yrEmailTextField;

-(IBAction)continueGo:(id)sender;
-(IBAction)backgroundTapped:(id)sender;
-(IBAction)signOut:(id)sender;
-(void)setCodeLabel:(NSString*)label;
@end
