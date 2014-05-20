//
//  SnakeType.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/20.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeType.h"

@implementation SnakeType
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

-(id)initWithSnakeType:(Type)snakeType
{
    self = [super init];
    if (self) {
        
        _type = snakeType;
        [self statsSetup];
    }
    
    return self;
}

- (void)statsSetup
{
    switch (_type) {
        case kSnakeTypeStrength:
            
            self.hitPoint = 100;
            self.meleeAttackPoint = 5;
            self.magicAttackPoint = 0;
            self.meleeDefensePoint = 10;
            self.magicDefensePoint = 10;
            self.attackSpeed = 1;
            self.evadePoint = 5;
            self.regeneration = 5;
            self.regenerationRate = 6;
            
            break;
        case kSnakeTypeStamina:
            
            self.hitPoint = 100;
            self.meleeAttackPoint = 5;
            self.magicAttackPoint = 0;
            self.meleeDefensePoint = 10;
            self.magicDefensePoint = 10;
            self.attackSpeed = 1;
            self.evadePoint = 5;
            self.regeneration = 5;
            self.regenerationRate = 6;
            
            break;
        case kSnakeTypeAgility:
            
            self.hitPoint = 100;
            self.meleeAttackPoint = 5;
            self.magicAttackPoint = 0;
            self.meleeDefensePoint = 10;
            self.magicDefensePoint = 10;
            self.attackSpeed = 1;
            self.evadePoint = 5;
            self.regeneration = 5;
            self.regenerationRate = 6;
            
            break;
        case kSnakeTypeMagic:
            
            self.hitPoint = 100;
            self.meleeAttackPoint = 5;
            self.magicAttackPoint = 0;
            self.meleeDefensePoint = 10;
            self.magicDefensePoint = 10;
            self.attackSpeed = 1;
            self.evadePoint = 5;
            self.regeneration = 5;
            self.regenerationRate = 6;
            
            break;
    }
}

- (void)heal:(float)hitpoint
{
    self.hitPoint += hitpoint;
}

- (void)reduceHitPoint:(float)damage
{
    self.hitPoint -= damage;
}

- (void)damageShieldBuff:(float)timer hitpoint:(float)hitpoint
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

- (void)attackBuff:(float)timer adder:(float)percentage
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

- (void)defenseBuff:(float)timer adder:(float)percentage
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
    [self heal:regenHitPoint];
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
    [self heal:leechHitPoint];
    
    leechTimeCount -= 1;
    
    if (leechTimeCount == 0)
        [self.leechTimer invalidate];

}



@end
