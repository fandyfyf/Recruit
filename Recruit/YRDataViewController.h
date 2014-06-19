//
//  YRDataViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/10/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YRAppDelegate.h"

@interface YRDataViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *infoDataList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yrSortingSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yrPositionFilter;

@property (strong, nonatomic) NSString * yrPrefix;
@property (strong, nonatomic) NSMutableArray *yrdataEntry;
@property (strong, nonatomic) YRAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
