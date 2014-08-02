//
//  YREventDataCell.m
//  Recruit
//
//  Created by Yifan Fu on 7/28/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YREventDataCell.h"

@implementation YREventDataCell

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

- (IBAction)editInfo:(id)sender {
    [self.delegate showInfoData:self.indexPath];
    NSLog(@"button is tapped");
}
@end
