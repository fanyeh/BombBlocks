//
//  MenuButton.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "MenuButton.h"
#import "CircleLabel.h"

@implementation MenuButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        CircleLabel *labelM = [[CircleLabel alloc]initWithFrame:CGRectMake(0, 0, 25, 25)];
        labelM.text = @"m";
        [self addSubview:labelM];
        
        CircleLabel *labelE = [[CircleLabel alloc]initWithFrame:CGRectMake(27, 0, 25, 25)];
        labelE.text = @"e";
        [self addSubview:labelE];
        
        CircleLabel *labelN = [[CircleLabel alloc]initWithFrame:CGRectMake(54, 0, 25, 25)];
        labelN.text = @"n";
        [self addSubview:labelN];
        
        CircleLabel *labelU = [[CircleLabel alloc]initWithFrame:CGRectMake(81, 0, 25, 25)];
        labelU.text = @"u";
        [self addSubview:labelU];
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
