//
//  YRYDayPickerView.m
//  Recruit
//
//  Created by Yifan Fu on 8/18/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRYDayPickerView.h"

@implementation YRYDayPickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 30, 300, 300)];
            self.datePicker.datePickerMode = UIDatePickerModeDate;
            
            cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
            doneButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
            
            [cancelButton setFrame:CGRectMake(20, 250, 100, 40)];
            [doneButton setFrame:CGRectMake(self.frame.size.width-120, 250, 100, 40)];
            
        }

    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
