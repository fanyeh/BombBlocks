//
//  SnakeSkillType.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SnakeSkillType : NSObject

typedef enum {
    kSkillTypeSword = 0,
    kSkillTypeHeart,
    kSkillTypeMagic
} SkillType;

-(id)init;
-(id)initWithSkillType:(SkillType)type;
@property (nonatomic) SkillType type;
@property (nonatomic) NSInteger adder;

@end
