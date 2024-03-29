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
        UILabel* title;
        
        UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            title = [[UILabel alloc] initWithFrame:CGRectMake(self.center.x - 100, 10, 200, 30)];
            title.textColor = [UIColor purpleColor];
            title.font = [UIFont fontWithName:@"Helvetica-Bold" size:25];
            title.text = @"YDay";
            title.textAlignment = NSTextAlignmentCenter;
            
            self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, self.frame.size.width, 300)];
            self.datePicker.datePickerMode = UIDatePickerModeDate;
            
            cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
            doneButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
            
            [cancelButton setFrame:CGRectMake(20, 250, 100, 40)];
            [doneButton setFrame:CGRectMake(self.frame.size.width-120, 250, 100, 40)];
        }
        
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [self addSubview:self.datePicker];
        [self addSubview:title];
        
        [cancelButton setTintColor:[UIColor purpleColor]];
        [cancelButton addTarget:self action:@selector(cancelDetail) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [[cancelButton layer] setCornerRadius:10];
        [[cancelButton layer] setBorderColor:[[UIColor purpleColor] CGColor]];
        [[cancelButton layer] setBorderWidth:1];
        [self addSubview:cancelButton];
        
        [doneButton setTintColor:[UIColor purpleColor]];
        [doneButton addTarget:self action:@selector(saveDetail) forControlEvents:UIControlEventTouchUpInside];
        [doneButton.titleLabel setTextAlignment:NSTextAlignmentRight];
        [[doneButton layer] setCornerRadius:10];
        [[doneButton layer] setBorderColor:[[UIColor purpleColor] CGColor]];
        [[doneButton layer] setBorderWidth:1];
        
        [self addSubview:doneButton];

    }
    return self;
}

-(void)saveDetail
{
    //save
    
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyy"];
    
    NSMutableArray* yDateList = [[[NSUserDefaults standardUserDefaults] objectForKey:@"YdayList"] mutableCopy];
    
    if (yDateList == nil) {
        yDateList = [NSMutableArray new];
    }
    
    BOOL exist = NO;
    for (NSString* string in yDateList) {
        if ([string isEqualToString:[format stringFromDate:self.datePicker.date]]) {
            exist = YES;
            break;
        }
    }
   
    if (exist) {
        UIAlertView* alerView = [[UIAlertView alloc] initWithTitle:@"YDay existed" message:@"The Date is already existing in the list." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [alerView show];
    }
    else
    {
        [yDateList addObject:[format stringFromDate:self.datePicker.date]];
    
        [[NSUserDefaults standardUserDefaults] setObject:yDateList forKey:@"YdayList"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        
        //reload
        [self.delegate reloadYDayList];
        
        [self cancelDetail];
    }
}

-(void)cancelDetail
{
    [UIView animateWithDuration:0.3 animations:^{
        self.grayView.alpha = 0.0;
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.grayView removeFromSuperview];
    }];
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
