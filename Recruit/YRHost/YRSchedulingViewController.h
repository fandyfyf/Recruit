//
//  YRSchedulingViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/24/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YRTimeCardView.h"

@interface YRSchedulingViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) UIPickerView* candidatesPickerView;
//@property (strong, nonatomic) UIPickerView* interviewerPickerView;
@property (strong, nonatomic) YRTimeCardView* yrTriggeringView;
@property (strong, nonatomic) NSMutableArray *yrdataEntry;
@property (strong, nonatomic) NSMutableArray *yrinterviewerEntry;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSString* selectedCode;
@property (strong, nonatomic) NSString* selectedCandidate;
@property (strong, nonatomic) NSString* selectedInterviewer;

@property (strong, nonatomic) UIViewController* source;
@property (strong, nonatomic) UILabel* startTimeLabel;
@property (strong, nonatomic) UILabel* roomLabel;

@property (assign, getter = isDataReady) BOOL dataReady;

@property (weak, nonatomic) NSDate* currentDate;

-(void)cancelDetail;
-(void)saveDetail;
-(void)deleteDetail;

@end
