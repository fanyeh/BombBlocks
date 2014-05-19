//
//  SnakeSkillTree.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeSkillTree.h"
#import "SnakeSkillType.h"
#import "SnakeSkill.h"

@implementation SnakeSkillTree

-(id)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)executeSkillCombo:(NSMutableArray *)comboContainer
{
    SnakeSkillType *initSkill = [comboContainer firstObject];
    
    switch (initSkill.type) {
        case kSkillTypeSword:
            [self swordSkills:comboContainer];
            break;
        case kSkillTypeHeart:
            [self heartSkills:comboContainer];
            break;
        case kSkillTypeMagic:
            [self magicSkills:comboContainer];
            break;
    }
}

- (void)swordSkills:(NSMutableArray *)comboContainer
{
    NSInteger numSkills = [comboContainer count];
    
    if (numSkills == 1) {
        // Sword Only
        NSLog(@"Attack");

        
    } else if (numSkills == 2) {
        SnakeSkillType *supplementSkill = [comboContainer objectAtIndex:1];
        if (supplementSkill.type == kSkillTypeHeart) {
            // Sword + Heart
            NSLog(@"Stun");

            
        } else {
            // Sword + Magic
            NSLog(@"Damage Buff");

        }

    } else {
       // Sword + Heart + Magic
        NSLog(@"Critical Attack");
    }
}

- (void)heartSkills:(NSMutableArray *)comboContainer
{
    NSInteger numSkills = [comboContainer count];
    
    if (numSkills == 1) {
        // Heart Only
        NSLog(@"Heal");

        
    } else if (numSkills == 2) {
        SnakeSkillType *supplementSkill = [comboContainer objectAtIndex:1];
        if (supplementSkill.type == kSkillTypeSword) {
            // Heart + Sword
            NSLog(@"Counter Attack");

        } else {
            // Heart + Magic
            NSLog(@"Regen");
        }
        
    } else {
        // Heart + Sword + Magic
        NSLog(@"Heal + DS");
    }
}

- (void)magicSkills:(NSMutableArray *)comboContainer
{
    NSInteger numSkills = [comboContainer count];
    
    if (numSkills == 1) {
        // Magic Only
        NSLog(@"Magic Damage");

    } else if (numSkills == 2) {
        SnakeSkillType *supplementSkill = [comboContainer objectAtIndex:1];
        if (supplementSkill.type == kSkillTypeHeart) {
            // Magic + Heart
            NSLog(@"Dot");

        } else {
            // Magic + Sword
            NSLog(@"AC Buff");

        }
        
    } else {
        // Magic + Heart + Sword
        NSLog(@"Leech");

        
    }
}

@end
