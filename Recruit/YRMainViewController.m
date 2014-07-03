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
    
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"tempBackUp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[self.yrSignInButton layer] setCornerRadius:60];
        [[self.yrSignInButton layer] setBorderWidth:5];
        [[self.yrSignInButton layer] setBorderColor:[[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] CGColor]];
        //[[self.yrSignInButton layer] setBorderColor:[[UIColor whiteColor] CGColor]];
        [self.yrsegmentedControl setFrame:CGRectMake(self.view.center.x-200, 380, 400, 50)];
        [self.yrtextField setFrame:CGRectMake(self.view.center.x-200, 280, 400, 50)];
        
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [[self.yrSignInButton layer] setCornerRadius:30];
        [[self.yrSignInButton layer] setBorderWidth:2];
        [[self.yrSignInButton layer] setBorderColor:[[UIColor colorWithRed:118.0/255.0 green:18.0/255.0 blue:192.0/255.0 alpha:1.0] CGColor]];
    }
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
