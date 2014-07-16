//
//  YRDebriefSearchModeViewController.h
//  Recruit
//
//  Created by Yifan Fu on 7/15/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YRDebriefSearchModeDetailViewController.h"

@interface YRDebriefSearchModeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSMutableArray* tagList;
@property (strong, nonatomic) UILabel * modeLabel;
@property (strong, nonatomic) UILabel * queryLabel;
@property (strong, nonatomic) UITableView * taggedListTableView;
@property (strong, nonatomic) UITableView * searchResultListTableView;
@property (strong, nonatomic) UIPickerView * searchOptionPicker;

@property (strong, nonatomic) NSMutableArray* searchResult;

@property (strong, nonatomic) NSArray* SearchOptions;
@property (strong, nonatomic) NSArray* rankingOptions;
@property (strong, nonatomic) NSArray* positionOptions;

@property (strong, nonatomic) UIButton* searchButton;
@property (strong, nonatomic) UILabel* resultCountLabel;

@property (strong, nonatomic) NSString* option;
@property (strong, nonatomic) NSString* ranking;
@property (strong, nonatomic) NSString* position;

@property (strong, nonatomic) YRDebriefSearchModeDetailViewController* detailView;
@property (strong, nonatomic) UIButton* broadcastButton;
@property (strong, nonatomic) UIViewController* source;

@end
