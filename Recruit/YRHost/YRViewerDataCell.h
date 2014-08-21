//
//  YRViewerDataCell.h
//  Recruit
//
//  Created by Yifan Fu on 6/17/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YRViewerDataCellDelegate <NSObject>

@required
-(void)emailEngineer:(NSIndexPath*)indexPath;

@end

@interface YRViewerDataCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *yrNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *yrEmailLabel;
@property (weak, nonatomic) IBOutlet UILabel *yrCodeLabel;

@property (strong, nonatomic) NSIndexPath* indexPath;
@property (strong, nonatomic) id<YRViewerDataCellDelegate> delegate;

- (IBAction)emailEngineerSchedule:(id)sender;
@end
