//
//  YRinfoDataCell.h
//  Recruit
//
//  Created by Yifan Fu on 6/10/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YRinfoDataCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *yrnameLabel;
@property (weak, nonatomic) IBOutlet UILabel *yremailLabel;
@property (weak, nonatomic) IBOutlet UILabel *yrinterviewerLabel;
@property (weak, nonatomic) IBOutlet UILabel *yrcodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *yrstatusLabel;

@end
