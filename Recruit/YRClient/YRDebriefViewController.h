//
//  YRDebriefViewController.h
//  Recruit
//
//  Created by Yifan Fu on 7/11/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YRDebriefViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSDictionary* currentDataEntry;
@property (strong, nonatomic) UILabel* yrPromptMessageLabel;

@property (strong, nonatomic) UIView* controlPanel;
@property (strong, nonatomic) UIButton* tagButton;
@property (strong, nonatomic) UIButton* switchModeButton;
@property (strong, nonatomic) UIButton* signOutButton;
@property (strong, nonatomic) UIGestureRecognizer* gestureRecognizer;

@property (strong, nonatomic) UIImageView* flagView;
@property (strong, nonatomic) UILabel* modeLabel;
@property (assign, getter = isBroadcast) BOOL Broadcast;

@property (strong, nonatomic) UILabel* codeLabel;
@property (strong, nonatomic) UILabel* nameLabel;
@property (strong, nonatomic) UILabel* emailLabel;
@property (strong, nonatomic) UILabel* GPALabel;
@property (strong, nonatomic) UILabel* rankLabel;
@property (strong, nonatomic) UILabel* rankPointFiveLabel;
@property (strong, nonatomic) UILabel* interviewerLabel;
@property (strong, nonatomic) UILabel* positionLabel;
@property (strong, nonatomic) UILabel* preferenceLabel;
@property (strong, nonatomic) UILabel* statusLabel;
@property (strong, nonatomic) UITextView* noteView;
@property (strong, nonatomic) UILabel* businessUnit1Label;
@property (strong, nonatomic) UILabel* businessUnit2Label;

@property (strong, nonatomic) UILabel* codeTitleLabel;
@property (strong, nonatomic) UILabel* nameTitleLabel;
@property (strong, nonatomic) UILabel* emailTitleLabel;
@property (strong, nonatomic) UILabel* GPATitleLabel;
@property (strong, nonatomic) UILabel* rankTitleLabel;
@property (strong, nonatomic) UILabel* interviewerTitleLabel;
@property (strong, nonatomic) UILabel* positionTitleLabel;
@property (strong, nonatomic) UILabel* preferenceTitleLabel;
@property (strong, nonatomic) UILabel* statusTitleLabel;
@property (strong, nonatomic) UILabel* noteViewTitleLabel;
@property (strong, nonatomic) UILabel* businessUnit1TitleLabel;
@property (strong, nonatomic) UILabel* businessUnit2TitleLabel;
@property (strong, nonatomic) UILabel* resumeTitleLabel;
@property (strong, nonatomic) UITableView* resumeList;

@property (strong, nonatomic) UIScrollView* yrScrollView;
@property (strong, nonatomic) UIImageView* showingImageView;
@property (strong, nonatomic) UIButton* yrScrollViewCancelButton;
@property (strong, nonatomic) UIControl* grayView;


@end
