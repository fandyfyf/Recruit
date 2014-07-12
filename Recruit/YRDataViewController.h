//
//  YRDataViewController.h
//  Recruit
//
//  Created by Yifan Fu on 6/10/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YRAppDelegate.h"

@interface YRDataViewController : UIViewController <UITableViewDelegate, UITableViewDataSource,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UITableView *infoDataList;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yrSortingSegmentControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *yrPositionFilter;

@property (strong, nonatomic) NSString * yrPrefix;
@property (strong, nonatomic) NSMutableArray *yrdataEntry;
@property (strong, nonatomic) YRAppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) UIScrollView* yrScrollView;
@property (strong, nonatomic) UIButton* yrScrollViewCancelButton;
@property (weak, nonatomic) IBOutlet UIButton *yrAdministorDeleteButton;
@property (strong, nonatomic) UIControl* grayView;
@property (weak, nonatomic) IBOutlet UISearchBar *yrSearchBar;


- (IBAction)deleteCoreData:(id)sender;
- (IBAction)cancelSearch:(id)sender;

@end
