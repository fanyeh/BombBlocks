//
//  SnakeType.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/20.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeType.h"

@implementation SnakeType

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

@end
