//
//  YRViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRMainViewController.h"
#import "YRAppDelegate.h"
#import "UIColor+Util.h"

#define roleSegCtrlWidth 400
#define userNameTextWidth 400

@interface YRMainViewController ()

-(void)doneWithPad;

@end

@implementation YRMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view, typically from a nib.
    self.yrtextField.delegate = self;
    
    //reset temporary backup
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"tempBackUp"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [[self.yrSignInButton layer] setCornerRadius:60];
        [[self.yrSignInButton layer] setBorderWidth:5];
        [[self.yrSignInButton layer] setBorderColor:[[UIColor yahooPurple] CGColor]];
        [self.yrsegmentedControl setFrame:CGRectMake(self.view.center.x-roleSegCtrlWidth/2, 380, roleSegCtrlWidth, 50)];
        [self.yrtextField setFrame:CGRectMake(self.view.center.x-userNameTextWidth/2, 280, userNameTextWidth, 50)];
    }
    else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [[self.yrSignInButton layer] setCornerRadius:30];
        [[self.yrSignInButton layer] setBorderWidth:2];
        [[self.yrSignInButton layer] setBorderColor:[[UIColor yahooPurple] CGColor]];
    }
    [self.yrsegmentedControl setSelectedSegmentIndex:1];
    
    //set done button for text input
    UIToolbar* doneToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    doneToolbar.items = [NSArray arrayWithObjects:
                         [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil],
                         [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneWithPad)],nil];
    self.yrtextField.inputAccessoryView = doneToolbar;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backGroundTapped:(id)sender {
    [self.yrtextField resignFirstResponder];
}

- (IBAction)signIn:(id)sender
{
    if ([self.yrtextField.text length] == 0) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"WARNING" message:@"Username shouldn't be empty" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert show];
    }
    else
    {
        [self setUserName:self.yrtextField.text];
        
        //set up session manager property
        [[YRAppDelegate sharedMCManager] setUserName:self.userName];
        [[YRAppDelegate sharedMCManager] setUserEmail:[self.userName stringByAppendingString:@"@yahoo-inc.com"]];
        
        if (self.yrsegmentedControl.selectedSegmentIndex == 0) {
            [self performSegueWithIdentifier:@"MainToHost" sender:self];
        }
        else
        {
            [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:NO] forKey:@"SignedInAlready"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self performSegueWithIdentifier:@"MainToClient" sender:self];
        }
    }
}

-(void)doneWithPad
{
    [self.yrtextField resignFirstResponder];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.yrtextField resignFirstResponder];
    [self setUserName:self.yrtextField.text];
    return YES;
}

@end
