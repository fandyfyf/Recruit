//
//  YRYDaySelecterView.h
//  Recruit
//
//  Created by Yifan Fu on 8/21/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YRYDaySelecterViewDelegate <NSObject>

@required

-(void)uploadCoreDate;

@end

@interface YRYDaySelecterView : UIView <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UIPickerView* yDayPicker;
@property (weak, nonatomic) UIView* grayView;
@property (strong, nonatomic) NSArray * yDayList;
@property (strong, nonatomic) UITextField * tappedTextField;
@property (strong, nonatomic) NSString* selectedYDate;
@property (weak, nonatomic) id<YRYDaySelecterViewDelegate> delegate;

@end
