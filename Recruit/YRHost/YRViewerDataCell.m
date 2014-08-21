//
//  YRViewerDataCell.m
//  Recruit
//
//  Created by Yifan Fu on 6/17/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRViewerDataCell.h"

@implementation YRViewerDataCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)emailEngineerSchedule:(id)sender {
    [self.delegate emailEngineer:self.indexPath];
}
@end
