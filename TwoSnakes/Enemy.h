//
//  Enemy.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Enemy : NSObject

@property (nonatomic) NSInteger hitPoint;
@property (nonatomic) NSInteger meleeAttackPoint;
@property (nonatomic) NSInteger magicAttackPoint;
@property (nonatomic) NSInteger meleeDefensePoint;
@property (nonatomic) NSInteger magicDefensePoint;
@property (nonatomic) float   attackSpeed;
@property (nonatomic) NSInteger evadePoint;
@property (nonatomic) NSInteger regeneration;

@end
