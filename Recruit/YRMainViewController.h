//
//  YRViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YRMainViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *yrtextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yrsegmentedControl;
@property (strong, nonatomic) NSString* userName;
- (IBAction)backGroundTapped:(id)sender;

- (IBAction)signIn:(id)sender;

@end
