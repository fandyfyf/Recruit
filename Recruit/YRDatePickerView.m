//
//  YRDatePickerView.m
//  Recruit
//
//  Created by Yifan Fu on 8/1/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRDatePickerView.h"

@implementation YRDatePickerView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILabel* startDateTitle;
        UILabel* numberOfDaysTitle;
        
        UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        UIButton* doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 30, 300, 300)];
            self.datePicker.datePickerMode = UIDatePickerModeDate;
            self.numberPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(300, 30, 100, 300)];
            
            startDateTitle = [[UILabel alloc] initWithFrame:CGRectMake(50, 10, 200, 30)];
            startDateTitle.textColor = [UIColor purpleColor];
            startDateTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
            startDateTitle.text = @"Start Date";
            startDateTitle.textAlignment = NSTextAlignmentCenter;
            
            numberOfDaysTitle = [[UILabel alloc] initWithFrame:CGRectMake(320, 10, 60, 30)];
            numberOfDaysTitle.textColor = [UIColor purpleColor];
            numberOfDaysTitle.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];
            numberOfDaysTitle.text = @"Days";
            numberOfDaysTitle.textAlignment = NSTextAlignmentCenter;
            
            cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
            doneButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
            
            [cancelButton setFrame:CGRectMake(20, 250, 100, 40)];
            [doneButton setFrame:CGRectMake(self.frame.size.width-120, 250, 100, 40)];

        }
        else if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            
        }
        
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [self addSubview:self.datePicker];
        
        self.numberPicker.delegate = self;
        self.numberPicker.dataSource = self;
        
        [self addSubview:self.numberPicker];
        [self addSubview:startDateTitle];
        [self addSubview:numberOfDaysTitle];
        
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
    [[NSUserDefaults standardUserDefaults] setValue:self.datePicker.date forKey:kYRScheduleStartDateKey];
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInt:[self.selectedDays intValue]] forKey:kYRScheduleNumberOfDayKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyy"];
    
    self.startDate.text = [format stringFromDate:self.datePicker.date];
    self.numberOfDay.text = self.selectedDays;
    
    [self cancelDetail];
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

#pragma mark - UIPickerViewDataSource

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 5;
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [NSString stringWithFormat:@"%d",row+1];
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedDays = [NSString stringWithFormat:@"%d",row+1];
}

@end
