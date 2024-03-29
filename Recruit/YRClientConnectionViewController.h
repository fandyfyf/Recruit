//
//  YRClientConnectionViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/9/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultipeerConnectivity/MultipeerConnectivity.h"
#import "YRAppDelegate.h"

@interface YRClientConnectionViewController : UIViewController <MCBrowserViewControllerDelegate, UITableViewDataSource, UITableViewDelegate,MCNearbyServiceBrowserDelegate>


@property (weak, nonatomic) IBOutlet UILabel *yrnameLabel;
@property (weak, nonatomic) IBOutlet UITableView *yrtableView;
@property (weak, nonatomic) IBOutlet UIButton *yrdisconnectButton;
@property (weak, nonatomic) IBOutlet UIButton *yrbrowseButton;

@property (strong, nonatomic) NSString* clientUserName;
@property (strong, nonatomic) NSMutableString *yrIDCode;

@property (strong, nonatomic) UIView * yrNameListView;
@property (strong, nonatomic) UITableView *yrNameList;

@property (strong, nonatomic) YRAppDelegate *appDelegate;


- (IBAction)browseForDevices:(id)sender;
- (IBAction)disconnectConnection:(id)sender;
- (IBAction)signOut:(id)sender;

@end
