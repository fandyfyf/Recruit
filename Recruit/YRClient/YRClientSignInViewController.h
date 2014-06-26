//
//  YRClientSignInViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/19/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Guile/AutoSuggestDelegate.h>

@class AutoSuggestTextField;

@interface YRClientSignInViewController : UIViewController <UITextFieldDelegate, AutoSuggestTextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *yrcodeLabel;

@property (weak, nonatomic) IBOutlet UITextField *yrFirstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *yrLastNameTextField;

@property (weak, nonatomic) IBOutlet AutoSuggestTextField *yrEmailTextField;

- (IBAction)continueGo:(id)sender;
- (IBAction)backgroundTapped:(id)sender;

-(void)setCodeLabel:(NSString*)label;
@end
