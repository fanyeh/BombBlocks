//
//  TestBoss.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "TestBoss.h"
#import "EnemyType.h"

@implementation TestBoss
{
    EnemyType *boss;
    float dotTime;
    float dotHitpoint;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        boss = [[EnemyType alloc]init];
        boss.hitPoint = 100;
        boss.meleeAttackPoint = 5;
        boss.magicAttackPoint = 0;
        boss.meleeDefensePoint = 10;
        boss.magicDefensePoint = 10;
        boss.attackSpeed = 1;
        boss.evadePoint = 5;
        boss.regeneration = 5;
        boss.regenerationRate = 6;
        
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

- (void)reduceHitPoint:(float)damage
{
    boss.hitPoint -= damage;
}

-(void)startAttack
{
    boss.attackTimer = [NSTimer scheduledTimerWithTimeInterval:boss.attackSpeed target:self selector:@selector(attack) userInfo:nil repeats:YES];
}

-(void)attack
{
    
}

-(void)getStunned:(float)timer
{
    [boss.attackTimer invalidate];
    [NSTimer scheduledTimerWithTimeInterval:timer target:self selector:@selector(startAttack) userInfo:nil repeats:NO];
}

- (void)getDotted:(float)timer hitpoint:(float)hitpoint
{
    dotTime = timer;
    dotHitpoint = hitpoint;
    boss.dotTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reduceHitPointByDot) userInfo:nil repeats:YES];
}

- (void)reduceHitPointByDot
{
    [self reduceHitPoint:dotHitpoint];
    dotTime -= 1;
    
    if (dotTime == 0)
        [boss.dotTimer invalidate];
}

@end
