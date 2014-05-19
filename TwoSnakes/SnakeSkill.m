//
//  SnakeSkill.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeSkill.h"


@implementation SnakeSkill
{
    SnakeSkillType *sword;
    SnakeSkillType *heart;
    SnakeSkillType *magic;
    NSMutableArray *skillComboContainer;
    SnakeSkillTree *skillTree;
}

-(id)init
{
    self = [super init];
    if (self) {
        
        sword = [[SnakeSkillType alloc]initWithSkillType:kSkillTypeSword];
        heart = [[SnakeSkillType alloc]initWithSkillType:kSkillTypeHeart];
        magic = [[SnakeSkillType alloc]initWithSkillType:kSkillTypeMagic];
        skillComboContainer = [[NSMutableArray alloc]init];
        skillTree = [[SnakeSkillTree alloc]init];
        
    }
    return self;
}

- (void)setInitialSkill:(SkillType)type
{
    // Remove all object in container to make sure init skill is first object
    [skillComboContainer removeAllObjects];
    [self addSkillToContainer:type];
}

- (void)setSupplementSkill:(SkillType)type
{
    [self addSkillToContainer:type];
}

- (void)addSkillToContainer:(SkillType)type
{
    switch (type) {
        case kSkillTypeSword:
            [skillComboContainer addObject:sword];
            break;
        case kSkillTypeHeart:
            [skillComboContainer addObject:heart];
            break;
        case kSkillTypeMagic:
            [skillComboContainer addObject:magic];
            break;
    }
}

- (void)executeSkillCombo
{
    if ([skillComboContainer count] > 0) {
        [skillTree executeSkillCombo:skillComboContainer];
        [skillComboContainer removeAllObjects];
    }
}

@end
