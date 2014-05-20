//
//  TestBoss.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "TestBoss.h"

@implementation TestBoss

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _boss = [[EnemyType alloc]initWithType];
        
        UILabel *bossName = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        bossName.text = @"Boss";
        bossName.textAlignment = NSTextAlignmentCenter;
        bossName.textColor = [UIColor whiteColor];
        bossName.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
        
        [self addSubview:bossName];
        
        self.backgroundColor = [UIColor blackColor];
        
    }
    return self;
}

@end
