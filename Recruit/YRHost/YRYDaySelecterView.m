//
//  YRYDaySelecterView.m
//  Recruit
//
//  Created by Yifan Fu on 8/21/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRYDaySelecterView.h"

@implementation YRYDaySelecterView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
            
            self.yDayPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, self.frame.size.width, 300)];
            self.yDayPicker.dataSource = self;
            self.yDayPicker.delegate = self;
            
            cancelButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
            doneButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size: 20];
            
            [cancelButton setFrame:CGRectMake(20, 250, 100, 40)];
            [doneButton setFrame:CGRectMake(self.frame.size.width-120, 250, 100, 40)];
        }
        
        self.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        [self addSubview:self.yDayPicker];
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
    self.tappedTextField.text = self.selectedYDate;
    
    [self.delegate uploadCoreDate];
    
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

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.yDayList == nil) {
        return 0;
    }
    else
    {
        return [self.yDayList count];
    }
}

-(NSString*)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (self.yDayList == nil) {
        return @"--Pending--";
    }
    else
    {
        return [self.yDayList objectAtIndex:row];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

#pragma mark - UIPickerViewDelegate

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedYDate = [self.yDayList objectAtIndex:row];
}

@end
