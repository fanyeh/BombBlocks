//
//  SnakeSkillType.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeSkillType.h"

@implementation SnakeSkillType

-(id)initWithSkillType:(SkillType)type
{
    self = [super init];
    if (self) {
        
        _type = type;
        _adder = 0;
        
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
