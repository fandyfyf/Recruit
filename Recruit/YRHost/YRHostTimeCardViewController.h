//
//  YRHostTimeCardViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/20/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YRAppDelegate.h"
#import "YRSchedulingViewController.h"

@interface YRHostTimeCardViewController : UIViewController <UIScrollViewDelegate>

@property (strong, nonatomic) NSNumber* yrRowNumber;
@property (strong, nonatomic) NSNumber* yrColumNumber;
@property (strong, nonatomic) NSNumber *cardWidth;
@property (strong, nonatomic) NSNumber *cardHeight;
@property (strong, nonatomic) NSNumber *toTop;
@property (strong, nonatomic) NSNumber  *toLeft;
@property (strong, nonatomic) UIScrollView *yrTimeCardScrollView;
@property (strong, nonatomic) UIScrollView *yrTimeLabelScrollView;
@property (strong, nonatomic) UIScrollView * yrPlaceOrNameScrollView;
@property (strong, nonatomic) YRSchedulingViewController * yrSchedulingController;

@property (strong, nonatomic) NSMutableArray* columLabels;
@property (strong, nonatomic) NSMutableArray* rowLabels;

@property (strong, nonatomic) UIView * cardDetailView;
//@property (strong, nonatomic) UITableView * recommandListTable;
@property (strong, nonatomic) UIPickerView* candidatesPickerView;
@property (strong, nonatomic) UIPickerView* interviewerPickerView;

@property (strong, nonatomic) UIControl* yrTriggeringView;
@property (strong, nonatomic) NSMutableArray *yrdataEntry;
@property (strong, nonatomic) NSMutableArray *yrinterviewerEntry;
@property (strong, nonatomic) YRAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSMutableArray *yrAppointmentInfo;

@end