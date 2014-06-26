//
//  YRClientSignInViewController.m
//  Recruit
//
//  Created by Yifan Fu on 6/19/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRClientSignInViewController.h"
#import "YRFormViewController.h"
#import <Guile/UITextField+AutoSuggestAdditions.h>
#import <Guile/Guile.h>

@interface YRClientSignInViewController ()

-(void)needUpdateCodeNotification:(NSNotification *)notification;

@end

@implementation YRClientSignInViewController

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"SignInToForm"]) {
        [(YRFormViewController*)segue.destinationViewController setSource:self];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    if ([[self.tabBarController.viewControllers[0] valueForKey:@"yrIDCode"] length] != 0) {
        [self.yrcodeLabel setText:[self.tabBarController.viewControllers[0] valueForKey:@"yrIDCode"]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(needUpdateCodeNotification:) name:@"NeedUpdateCodeNotification" object:nil];
    self.yrFirstNameTextField.delegate = self;
    self.yrLastNameTextField.delegate = self;
    self.yrEmailTextField.delegate = self;
    self.yrEmailTextField.suggestionDelegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)continueGo:(id)sender {
    [self performSegueWithIdentifier:@"SignInToForm" sender:self];
    //[self.yrcodeLabel setText:@"No Connection!"];
}

- (IBAction)backgroundTapped:(id)sender {
    [self.yrFirstNameTextField resignFirstResponder];
    [self.yrLastNameTextField resignFirstResponder];
    [self.yrEmailTextField resignFirstResponder];
    [self.yrEmailTextField acceptSuggestion];
}

-(void)setCodeLabel:(NSString*)label
{
    self.yrcodeLabel.text = label;
    self.yrFirstNameTextField.text = @"";
    self.yrLastNameTextField.text = @"";
    self.yrEmailTextField.text = @"";
}

-(void)needUpdateCodeNotification:(NSNotification *)notification
{
    NSMutableString *code = [[notification userInfo] objectForKey:@"recruitID"];
    [self.yrcodeLabel performSelectorOnMainThread:@selector(setText:) withObject:code waitUntilDone:NO];
}

#pragma mark - UITextFieldDelegate

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    [self.yrFirstNameTextField resignFirstResponder];
    [self.yrLastNameTextField resignFirstResponder];
    [self.yrEmailTextField resignFirstResponder];
    [self.yrEmailTextField acceptSuggestion];
}

#pragma mark - AutoSuggestDelegate

- (NSString *)suggestedStringForInputString:(NSString *)input
{
    static NSArray *domains;
    if (!domains) {
        domains = @[@"gmail.com",
                    @"gmail.co.uk",
                    @"yahoo.com",
                    @"yahoo.cn",
                    @"hotmail.com",
                    @"yahoo-inc.com"];
    }
    
    NSArray *parts = [input componentsSeparatedByString:@"@"];
    NSString *suggestion = nil;
    if (parts.count == 2) {
        NSString *domain = [parts lastObject];
        
        if (domain.length == 0) {
            suggestion = nil;
        }
        else {
            for (NSString *current in domains) {
                if ([current isEqualToString:domain]) {
                    suggestion = nil;
                    break;
                }
                else if ([current hasPrefix:domain]) {
                    suggestion = [current substringFromIndex:domain.length];
                    break;
                }
            }
        }
    }
    return suggestion;
}

-(UIColor *)suggestedTextColor
{
    return [UIColor grayColor];
}


@end
