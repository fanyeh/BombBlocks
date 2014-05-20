//
//  SnakeType.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/20.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "BaseStats.h"

typedef enum {
    kSnakeTypeStrength = 0,
    kSnakeTypeStamina,
    kSnakeTypeAgility,
    kSnakeTypeMagic
} Type;

@interface SnakeType : BaseStats

@property (nonatomic) Type type;

- (id)initWithSnakeType:(Type)type;
- (void)heal:(float)hitpoint;
- (void)damageShieldBuff:(float)timer hitpoint:(float)hitpoint;
- (void)attackBuff:(float)timer adder:(float)percentage;
- (void)defenseBuff:(float)timer adder:(float)percentage;
- (void)getDamageAbsorb:(float)hitpoint;
- (void)getRegeneration:(float)timer hitpoint:(float)hitpoint;
- (void)getDotted:(float)timer hitpoint:(float)hitpoint;
- (void)getLeech:(float)timer hitpoint:(float)hitpoint;


@end
