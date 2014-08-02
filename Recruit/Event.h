//
//  Event.h
//  Recruit
//
//  Created by Yifan Fu on 7/28/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * eventCode;
@property (nonatomic, retain) NSString * eventName;
@property (nonatomic, retain) NSString * eventAddress;
@property (nonatomic, retain) NSNumber * eventInterviewerCount;

@end
