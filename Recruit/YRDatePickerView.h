//
//  YRDatePickerView.h
//  Recruit
//
//  Created by Yifan Fu on 8/1/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YRAppDelegate.h"

@interface YRDatePickerView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UIDatePicker* datePicker;
@property (strong, nonatomic) UIPickerView* numberPicker;
@property (weak, nonatomic) UIView* grayView;

@property (weak, nonatomic) UITextField* startDate;

@property (weak, nonatomic) UITextField* numberOfDay;

@property (strong, nonatomic) NSString* selectedDays;

@end
