//
//  YRTimeCardView.m
//  Recruit
//
//  Created by Yifan Fu on 6/24/14.
//  Copyright (c) 2014 Yahoo-inc. All rights reserved.
//

#import "YRTimeCardView.h"

@implementation YRTimeCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 120, 20)];
        [_codeLabel setFont:[UIFont boldSystemFontOfSize:15]];
        _candidateNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 25, 120, 20)];
        [_candidateNameLabel setFont:[UIFont boldSystemFontOfSize:15]];
        _interviewerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 120, 20)];
        [_interviewerNameLabel setFont:[UIFont boldSystemFontOfSize:12]];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            
            _codeLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 175, 30)];
            [_codeLabel setFont:[UIFont boldSystemFontOfSize:20]];
            _candidateNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 40, 175, 30)];
            [_candidateNameLabel setFont:[UIFont boldSystemFontOfSize:20]];
            _interviewerNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 120, 175, 30)];
            [_interviewerNameLabel setFont:[UIFont boldSystemFontOfSize:15]];
        }
        
        [_codeLabel setTextAlignment:NSTextAlignmentLeft];
        [_codeLabel setTextColor:[UIColor redColor]];
        [self addSubview:_codeLabel];
        [_candidateNameLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_candidateNameLabel];
        [_interviewerNameLabel setTextAlignment:NSTextAlignmentRight];
        [_interviewerNameLabel setTextColor:[UIColor purpleColor]];
        [self addSubview:_interviewerNameLabel];
        
        _interviewStartTime = [NSString new];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
