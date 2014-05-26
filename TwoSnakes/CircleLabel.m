//
//  CircleLabel.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/16.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "CircleLabel.h"

@implementation CircleLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = self.frame.size.width/2;
        self.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];
        self.textAlignment = NSTextAlignmentCenter;
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = YES;

    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = self.frame.size.width/2;
        self.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];
        self.textAlignment = NSTextAlignmentCenter;
        self.layer.masksToBounds = YES;
        self.userInteractionEnabled = YES;

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
