//
//  SnakeSkill.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SnakeSkillType.h"
#import "SnakeSkillTree.h"

@interface SnakeSkill : NSObject

- (void)setInitialSkill:(SkillType)type;
- (void)setSupplementSkill:(SkillType)type;
- (void)executeSkillCombo;


@end
