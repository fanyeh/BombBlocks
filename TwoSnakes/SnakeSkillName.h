//
//  SnakeSkillName.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/20.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeSkillType.h"

typedef enum {
    kSkillNameMeleeAttack = 0,
    kSkillNameMagicAttack,
    kSkillNameStun,
    kSkillNameHeal,
    kSkillNameDamageOverTime,
    kSkillNameDamageShield,
    kSkillNameDefenseBuff,
    kSkillNameAttackBuff,
    kSkillNameLeech,
    kSkillNameDamageAbsorb,
    kSkillNameRegeneration,
    kSkillNameCounterAttack
} SkillName;

@interface SnakeSkillName : SnakeSkillType


- (id)initWithSkillType:(SkillType)type skillName:(SkillName)name;

@property (nonatomic) SkillName skillName;
@property (nonatomic)float damage;
@property (nonatomic)float timer;
@property (nonatomic)float heal;
@property (nonatomic)float buff;
@property (nonatomic)float damageAbsorb;

@end
