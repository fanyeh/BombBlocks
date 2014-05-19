//
//  TestBoss.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "TestBoss.h"
#import "Enemy.h"

@implementation TestBoss
{
    Enemy *boss;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        boss = [[Enemy alloc]init];
        boss.hitPoint = 100;
        boss.meleeAttackPoint = 5;
        boss.magicAttackPoint = 0;
        boss.meleeDefensePoint = 10;
        boss.magicDefensePoint = 10;
        boss.attackSpeed = 1;
        boss.evadePoint = 5;
        boss.regeneration = 5;
        
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
