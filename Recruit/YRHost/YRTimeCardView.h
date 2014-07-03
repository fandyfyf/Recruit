//
//  YRTimeCardView.h
//  Recruit
//
//  Created by Yifan Fu on 6/24/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YRTimeCardView : UIControl

@property (assign) int roomIndex;
@property (assign) int slotIndex;
@property (strong, nonatomic) UILabel* codeLabel;
@property (strong, nonatomic) UILabel* candidateNameLabel;
@property (strong, nonatomic) UILabel* interviewerNameLabel;
@property (strong, nonatomic) NSString* interviewStartTime;
@property (assign) BOOL candidateLock;


@end
