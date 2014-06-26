//
//  YRViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRMainViewController.h"
#import "YRAppDelegate.h"

@interface YRMainViewController ()

@end

@implementation YRMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.yrtextField.delegate = self;
    self.yrsegmentedControl.selectedSegmentIndex = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backGroundTapped:(id)sender {
    [self.yrtextField resignFirstResponder];
}

- (IBAction)signIn:(id)sender {
    
    if ([self.yrtextField.text length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Username shouldn't be empty" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        [self setUserName:self.yrtextField.text];
        
        
        [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager] setUserName:self.userName];
        [[(YRAppDelegate*)[[UIApplication sharedApplication] delegate] mcManager] setUserEmail:[self.userName stringByAppendingString:@"@yahoo-inc.com"]];
        
        if (self.yrsegmentedControl.selectedSegmentIndex == 0) {
            [self performSegueWithIdentifier:@"MainToHost" sender:self];
        }
        else
        {
            [self performSegueWithIdentifier:@"MainToClient" sender:self];
        }
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.yrtextField resignFirstResponder];
    
    [self setUserName:self.yrtextField.text];
    
    return YES;
}

@end
