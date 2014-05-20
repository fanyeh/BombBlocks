//
//  EnemyType.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/20.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "EnemyType.h"

@implementation EnemyType

-(id)initWithType
{
    self = [super init];
    if (self) {
        
        [self statsSetup];
    }
    
    return self;
}

- (void)statsSetup
{
    self.hitPoint = 100;
    self.meleeAttackPoint = 5;
    self.magicAttackPoint = 0;
    self.meleeDefensePoint = 10;
    self.magicDefensePoint = 10;
    self.attackSpeed = 1;
    self.evadePoint = 5;
    self.regeneration = 5;
    self.regenerationRate = 6;
}

@end
