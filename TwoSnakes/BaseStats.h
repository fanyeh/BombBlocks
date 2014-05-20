//
//  BaseStats.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/20.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseStats : NSObject

@property (nonatomic) NSInteger hitPoint;
@property (nonatomic) NSInteger meleeAttackPoint;
@property (nonatomic) NSInteger magicAttackPoint;
@property (nonatomic) NSInteger meleeDefensePoint;
@property (nonatomic) NSInteger magicDefensePoint;
@property (nonatomic) float   attackSpeed; // In seconds
@property (nonatomic) NSInteger evadePoint;
@property (nonatomic) NSInteger regeneration;
@property (nonatomic) float regenerationRate; // In seconds
@property (strong,nonatomic) NSTimer *attackTimer;
@property (strong,nonatomic) NSTimer *dotTimer;
@property (strong,nonatomic) NSTimer *attackBuffTimer;
@property (strong,nonatomic) NSTimer *defenseBuffTimer;
@property (strong,nonatomic) NSTimer *damageShieldTimer;
@property (strong,nonatomic) NSTimer *regnerationTimer;
@property (strong,nonatomic) NSTimer *leechTimer;



@end
