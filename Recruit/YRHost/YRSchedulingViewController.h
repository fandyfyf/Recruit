//
//  YRSchedulingViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/24/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>


FOUNDATION_EXPORT NSString* const kYRAppointmentInfoKey;

@interface YRSchedulingViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UIPickerView* candidatesPickerView;
@property (strong, nonatomic) UIPickerView* interviewerPickerView;
@property (strong, nonatomic) UIControl* yrTriggeringView;
@property (strong, nonatomic) NSMutableArray *yrdataEntry;
@property (strong, nonatomic) NSMutableArray *yrinterviewerEntry;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSString* selectedCode;
@property (strong, nonatomic) NSString* selectedCandidate;
@property (strong, nonatomic) NSString* selectedInterviewer;

@end
