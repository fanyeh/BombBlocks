//
//  BaseStats.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/20.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "BaseStats.h"

@implementation BaseStats
{
    BOOL hasDamageShield;
    float damageShieldDamage;
    float attackBuffPercentage;
    float defenseBuffPercentage;
    float damageAbsorb;
    float regenTimeCount;
    float regenHitPoint;
    float dotTimeCount;
    float dotHitPoint;
    float leechTimeCount;
    float leechHitPoint;
}

-(void)startAttack
{
    _attackTimer = [NSTimer scheduledTimerWithTimeInterval:_attackSpeed target:self selector:@selector(attack) userInfo:nil repeats:YES];
}

-(void)attack
{
    
}

-(void)getStunned:(float)timer
{
    [_attackTimer invalidate];
    [NSTimer scheduledTimerWithTimeInterval:timer target:self selector:@selector(startAttack) userInfo:nil repeats:NO];
}

- (void)getHeal:(float)hitpoint
{
    self.hitPoint += hitpoint;
}

- (void)reduceHitPoint:(float)damage
{
    self.hitPoint -= damage;
}

- (void)getDamageShieldBuff:(float)timer hitpoint:(float)hitpoint
{
    hasDamageShield = YES;
    damageShieldDamage = hitpoint;
    
    if ([self.damageShieldTimer isValid])
        [self.damageShieldTimer invalidate];
    
    self.damageShieldTimer = [NSTimer scheduledTimerWithTimeInterval:timer target:self selector:@selector(removeDamageShield) userInfo:nil repeats:NO];
}

- (void)removeDamageShield
{
    damageShieldDamage = 0;
    hasDamageShield = NO;
}

- (void)getAttackBuff:(float)timer adder:(float)percentage
{
    attackBuffPercentage = percentage;
    
    if ([self.attackBuffTimer isValid])
        [self.attackBuffTimer invalidate];
    
    self.attackBuffTimer = [NSTimer scheduledTimerWithTimeInterval:timer target:self selector:@selector(removeAttackBuff) userInfo:nil repeats:NO];
}

- (void)removeAttackBuff
{
    attackBuffPercentage = 0;
}

- (void)getDefenseBuff:(float)timer adder:(float)percentage
{
    defenseBuffPercentage = percentage;
    
    if ([self.defenseBuffTimer isValid])
        [self.defenseBuffTimer invalidate];
    
    self.defenseBuffTimer = [NSTimer scheduledTimerWithTimeInterval:timer target:self selector:@selector(removeDefenseBuff) userInfo:nil repeats:NO];
}

- (void)removeDefenseBuff
{
    defenseBuffPercentage = 0;
}

- (void)getDamageAbsorb:(float)hitpoint
{
    damageAbsorb = hitpoint;
}

- (void)getRegeneration:(float)timer hitpoint:(float)hitpoint
{
    regenTimeCount = timer;
    regenHitPoint = hitpoint;
    self.regnerationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(healByRegeneration) userInfo:nil repeats:YES];
}

- (void)healByRegeneration
{
    [self getHeal:regenHitPoint];
    regenTimeCount -= 1;
    
    if (regenTimeCount == 0)
        [self.regnerationTimer invalidate];
}

- (void)getDotted:(float)timer hitpoint:(float)hitpoint
{
    dotTimeCount = timer;
    dotHitPoint = hitpoint;
    self.dotTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(reduceHitPointByDot) userInfo:nil repeats:YES];
}

- (void)reduceHitPointByDot
{
    [self reduceHitPoint:dotHitPoint];
    dotTimeCount -= 1;
    
    if (dotTimeCount == 0)
        [self.dotTimer invalidate];
}

- (void)getLeech:(float)timer hitpoint:(float)hitpoint
{
    leechTimeCount = timer;
    leechHitPoint = hitpoint;
    self.leechTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(leech) userInfo:nil repeats:YES];
    
}

- (void)leech
{
    [self reduceHitPoint:leechHitPoint];
    [self getHeal:leechHitPoint];
    
    leechTimeCount -= 1;
    
    if (leechTimeCount == 0)
        [self.leechTimer invalidate];
}

- (float)currentHitPoint
{
    NSLog(@"Boss hit point %f",_hitPoint);
    return _hitPoint;
}


@end
