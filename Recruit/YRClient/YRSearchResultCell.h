//
//  YRSearchResultCell.h
//  Recruit
//
//  Created by Yifan Fu on 7/16/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YRSearchResultCell : UITableViewCell

@property(strong, nonatomic) UILabel* codeLabel;
@property(strong, nonatomic) UILabel* nameLabel;
@property(strong, nonatomic) UIImageView* flagView;
@property(strong, nonatomic) UILabel* rankLabel;
@property(strong, nonatomic) UILabel* halfRankLabel;

@end
