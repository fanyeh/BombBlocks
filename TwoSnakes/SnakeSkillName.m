//
//  SnakeSkillName.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/20.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "SnakeSkillName.h"

@implementation SnakeSkillName

- (id)initWithSkillType:(SkillType)type skillName:(SkillName)name
{
    self = [super init];
    if (self) {
        self.type = type;
        self.skillName = name;
        _damage = 0;
        _timer = 0;
        _heal = 0;
        _buff = 0;
        _damageAbsorb = 0 ;
    }
    
    return self;
}

- (void)calculateSkillEffect
{
    switch (self.skillName) {
        case kSkillNameMeleeAttack:
            
            _damage = 10 + 2*([self adderModifier]);
            
            break;
        case kSkillNameMagicAttack:
            
            _damage = 10 + 2*([self adderModifier]);
            
            break;
        case kSkillNameStun:
            
            _timer = 0.5* [self adderModifier];
            
            break;
        case kSkillNameHeal:
            
            _heal = 10 + 2*([self adderModifier]);
            
            break;
        case kSkillNameDamageOverTime:
            
            _damage = 2*([self adderModifier]);
            _timer = 6 + 0.5*([self adderModifier]);

            break;
        case kSkillNameDamageShield:
            
            _damage = 2*([self adderModifier]);
            _timer = 6 + 0.5*([self adderModifier]);
            
            break;
        case kSkillNameDefenseBuff:
            
            _buff = 6;
            _timer = 6 + 0.5*([self adderModifier]);
            
            break;
        case kSkillNameAttackBuff:
            
            _buff = 6;
            _timer = 6 + 0.5*([self adderModifier]);
            
            break;
        case kSkillNameLeech:
            
            _timer = 6 + 0.5*([self adderModifier]);
            _damage = 2*([self adderModifier]);
            
            break;
        case kSkillNameDamageAbsorb:
            
            _damageAbsorb = 10 * 5 + 2*([self adderModifier]);

            break;
        case kSkillNameRegeneration:
            
            _heal = 2*([self adderModifier]);
            _timer = 6 + 0.5*([self adderModifier]);
            
            break;
        case kSkillNameCounterAttack:
        
            
            break;

    }
}

- (float)adderModifier
{
    return (self.adder/3)-1;
}

@end
