//
//  CustomLabel.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/8/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "CustomLabel.h"

@implementation CustomLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame fontName:(NSString *)fontname fontSize:(CGFloat)fontSize
{
    self = [self initWithFrame:frame];
    if (self) {
        // Initialization code
        self.font = [UIFont fontWithName:@"DINAlternate-Bold" size:fontSize];
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
