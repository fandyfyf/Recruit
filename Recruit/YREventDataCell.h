//
//  YREventDataCell.h
//  Recruit
//
//  Created by Yifan Fu on 7/28/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YREventDataCellDelegate <NSObject>

@required
-(void)showInfoData:(NSIndexPath*)indexPath;

@end

@interface YREventDataCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventAddressLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventCodeLabel;
@property (strong, nonatomic) NSIndexPath* indexPath;
@property (strong, nonatomic) id<YREventDataCellDelegate> delegate;

- (IBAction)editInfo:(id)sender;

@end
