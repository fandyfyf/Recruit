//
//  YRDebriefSearchModeDetailViewController.h
//  Recruit
//
//  Created by Yifan Fu on 7/16/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YRDebriefSearchModeDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSDictionary* currentDataEntry;
@property (strong, nonatomic) NSMutableArray* tagList;

@property (strong, nonatomic) UIButton* tagButton;

@property (strong, nonatomic) UIImageView* flagView;
@property (strong, nonatomic) UILabel* modeLabel;

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

@property (strong, nonatomic) UIButton* backButton;

-(void)loadData;

-(void)cancelScrollView;
-(void)tagCandidates;

@end
