//
//  SnakeDot.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/2.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeDot.h"

@implementation SnakeDot

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _smallDot = [[UIView alloc]initWithFrame:CGRectMake(4, 4, 12, 12)];
        _smallDot.layer.cornerRadius = 6;
        //        _smallDot.center = self.center;
        [self addSubview:_smallDot];    }
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
