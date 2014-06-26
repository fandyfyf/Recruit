//
//  Interviewer.h
//  Recruit
//
//  Created by Yifan Fu on 6/26/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Interviewer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * interviewerId;
@property (nonatomic, retain) NSString * code;

@end
