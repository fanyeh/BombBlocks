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

    }
    return self;
}

- (id)initWithFrame:(CGRect)frame dotShape:(DotShape)shape
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setShape:shape];
        _shape = shape;
    }
    return self;
}

- (void)setShape:(DotShape)shape
{
    switch (shape) {
        case kDotShapeCircle:
            _smallDot = [[UIView alloc]initWithFrame:CGRectMake(4, 4, 12, 12)];
            _smallDot.layer.cornerRadius = _smallDot.frame.size.width/2;
            [self addSubview:_smallDot];
            break;
        case kDotShapeSquare:
            _smallDot = [[UIView alloc]initWithFrame:CGRectMake(4, 4, 12, 12)];
            _smallDot.layer.cornerRadius = _smallDot.frame.size.width/4;
            [self addSubview:_smallDot];
            break;

    }
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
