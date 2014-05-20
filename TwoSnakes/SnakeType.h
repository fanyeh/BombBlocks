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

@end
