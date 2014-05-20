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
#import "SnakeSkillName.h"

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
    NSMutableDictionary *skillSet = [[NSMutableDictionary alloc]init];
    
    // Sword Only
    NSLog(@"kSkillNameMeleeAttack");
    SnakeSkillType *initSkill = [comboContainer firstObject];
    SnakeSkillName *initSkillName = [[SnakeSkillName alloc]initWithSkillType:initSkill.type skillName:kSkillNameMeleeAttack];
    initSkillName.adder = initSkill.adder;
    [skillSet setObject:initSkillName forKey:[NSNumber numberWithInt:initSkillName.skillName]];
    
    SnakeSkillName *supplementSkillName;

    if (numSkills == 2) {
        SnakeSkillType *supplementSkill = [comboContainer objectAtIndex:1];
        if (supplementSkill.type == kSkillTypeHeart) {
            // Sword + Heart
            NSLog(@"kSkillNameStun");
            supplementSkillName = [[SnakeSkillName alloc]initWithSkillType:kSkillTypeSword skillName:kSkillNameStun];
            supplementSkillName.adder = supplementSkill.adder;
            [skillSet setObject:supplementSkillName forKey:[NSNumber numberWithInt:supplementSkillName.skillName]];
            
        } else {
            // Sword + Magic
            NSLog(@"kSkillNameDamageOverTime");
            supplementSkillName = [[SnakeSkillName alloc]initWithSkillType:kSkillTypeMagic skillName:kSkillNameDamageOverTime];
            supplementSkillName.adder = supplementSkill.adder;
            [skillSet setObject:supplementSkillName forKey:[NSNumber numberWithInt:supplementSkillName.skillName]];

        }

    } else if (numSkills == 3) {
        // Sword + Heart + Magic
        NSLog(@"kSkillNameDamageAbsorb");
        
        SnakeSkillType *supplementSkill1 = [comboContainer objectAtIndex:1];
        SnakeSkillType *supplementSkill2 = [comboContainer objectAtIndex:2];

        supplementSkillName = [[SnakeSkillName alloc]initWithSkillType:kSkillTypeHeart skillName:kSkillNameDamageAbsorb];
        supplementSkillName.adder = (supplementSkill1.adder + supplementSkill2.adder )/2;
        [skillSet setObject:supplementSkillName forKey:[NSNumber numberWithInt:supplementSkillName.skillName]];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"snakeAttack" object:nil userInfo:skillSet];
}

- (void)heartSkills:(NSMutableArray *)comboContainer
{
    NSInteger numSkills = [comboContainer count];
    NSMutableDictionary *skillSet = [[NSMutableDictionary alloc]init];
    
    // Heart Only
    NSLog(@"Heal");
    SnakeSkillType *initSkill = [comboContainer firstObject];
    SnakeSkillName *initSkillName = [[SnakeSkillName alloc]initWithSkillType:initSkill.type skillName:kSkillNameHeal];
    initSkillName.adder = initSkill.adder;
    [skillSet setObject:initSkillName forKey:[NSNumber numberWithInt:initSkillName.skillName]];
    
    SnakeSkillName *supplementSkillName;
    
    if (numSkills == 2) {
        SnakeSkillType *supplementSkill = [comboContainer objectAtIndex:1];
        if (supplementSkill.type == kSkillTypeSword) {
            // Heart + Sword
            NSLog(@"Counter Attack");
            supplementSkillName = [[SnakeSkillName alloc]initWithSkillType:kSkillTypeSword skillName:kSkillNameCounterAttack];
            supplementSkillName.adder = supplementSkill.adder;
            [skillSet setObject:supplementSkillName forKey:[NSNumber numberWithInt:supplementSkillName.skillName]];

        } else {
            // Heart + Magic
            NSLog(@"Regen");
            supplementSkillName = [[SnakeSkillName alloc]initWithSkillType:kSkillTypeHeart skillName:kSkillNameRegeneration];
            supplementSkillName.adder = supplementSkill.adder;
            [skillSet setObject:supplementSkillName forKey:[NSNumber numberWithInt:supplementSkillName.skillName]];
        }
        
    } else if (numSkills == 3) {
        // Heart + Sword + Magic
        NSLog(@"Heal + DS");
        SnakeSkillType *supplementSkill1 = [comboContainer objectAtIndex:1];
        SnakeSkillType *supplementSkill2 = [comboContainer objectAtIndex:2];
        
        supplementSkillName = [[SnakeSkillName alloc]initWithSkillType:kSkillTypeMagic skillName:kSkillNameDamageShield];
        supplementSkillName.adder = (supplementSkill1.adder + supplementSkill2.adder )/2;
        [skillSet setObject:supplementSkillName forKey:[NSNumber numberWithInt:supplementSkillName.skillName]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"snakeAttack" object:nil userInfo:skillSet];
}

- (void)magicSkills:(NSMutableArray *)comboContainer
{
    NSInteger numSkills = [comboContainer count];
    NSMutableDictionary *skillSet = [[NSMutableDictionary alloc]init];
    
    // Magic Only
    NSLog(@"Magic Damage");
    SnakeSkillType *initSkill = [comboContainer firstObject];
    SnakeSkillName *initSkillName = [[SnakeSkillName alloc]initWithSkillType:initSkill.type skillName:kSkillNameMagicAttack];
    initSkillName.adder = initSkill.adder;
    [skillSet setObject:initSkillName forKey:[NSNumber numberWithInt:initSkillName.skillName]];
    
    SnakeSkillName *supplementSkillName;

    if (numSkills == 2) {
        SnakeSkillType *supplementSkill = [comboContainer objectAtIndex:1];
        if (supplementSkill.type == kSkillTypeHeart) {
            // Magic + Heart
            NSLog(@"Attack Buff");
            supplementSkillName = [[SnakeSkillName alloc]initWithSkillType:kSkillTypeMagic skillName:kSkillNameAttackBuff];
            supplementSkillName.adder = supplementSkill.adder;
            [skillSet setObject:supplementSkillName forKey:[NSNumber numberWithInt:supplementSkillName.skillName]];

        } else {
            // Magic + Sword
            NSLog(@"AC Buff");
            supplementSkillName = [[SnakeSkillName alloc]initWithSkillType:kSkillTypeMagic skillName:kSkillNameDefenseBuff];
            supplementSkillName.adder = supplementSkill.adder;
            [skillSet setObject:supplementSkillName forKey:[NSNumber numberWithInt:supplementSkillName.skillName]];

        }
        
    } else if (numSkills == 3) {
        // Magic + Heart + Sword
        NSLog(@"Leech");
        SnakeSkillType *supplementSkill1 = [comboContainer objectAtIndex:1];
        SnakeSkillType *supplementSkill2 = [comboContainer objectAtIndex:2];
        
        supplementSkillName = [[SnakeSkillName alloc]initWithSkillType:kSkillTypeMagic skillName:kSkillNameLeech];
        supplementSkillName.adder = (supplementSkill1.adder + supplementSkill2.adder )/2;
        [skillSet setObject:supplementSkillName forKey:[NSNumber numberWithInt:supplementSkillName.skillName]];

    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"snakeAttack" object:nil userInfo:skillSet];
}

@end
