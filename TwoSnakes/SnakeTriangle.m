//
//  SnakeTriangle.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/15.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeTriangle.h"

@implementation SnakeTriangle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect
{
    UIBezierPath* bezierPath = UIBezierPath.bezierPath;
    [bezierPath moveToPoint: CGPointMake(self.frame.size.width/2, 0)]; // Start point
    [bezierPath addLineToPoint: CGPointMake(0, self.frame.size.height)]; // 2nd point
//    [bezierPath addArcWithCenter:CGPointMake(self.frame.size.width/2, 0) radius:3 startAngle: -15/180 * M_PI endAngle:15/180 * M_PI  clockwise:YES];
    [bezierPath addLineToPoint: CGPointMake(self.frame.size.width, self.frame.size.height)]; // 3rd point
    [bezierPath addLineToPoint: CGPointMake(self.frame.size.width/2, 0)]; // Back to start point
    [bezierPath closePath];
    [UIColor.grayColor setFill];
    [bezierPath fill];
//    [UIColor.blackColor setStroke];
//    bezierPath.lineWidth = 1;
//    [bezierPath stroke];
}

- (void)updateColor
{
    
}

@end
