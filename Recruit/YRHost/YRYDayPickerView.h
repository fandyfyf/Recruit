//
//  YRYDayPickerView.h
//  Recruit
//
//  Created by Yifan Fu on 8/18/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YRYDayPickerViewDelegate <NSObject>

@required

-(void)reloadYDayList;

@end

@interface YRYDayPickerView : UIView

@property (strong, nonatomic) UIDatePicker* datePicker;
@property (weak, nonatomic) UIView* grayView;
@property (strong, nonatomic) id<YRYDayPickerViewDelegate> delegate;

@end
