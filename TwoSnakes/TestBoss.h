//
//  TestBoss.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestBoss : UIView

- (void)reduceHitPoint:(float)damage;
- (void)getStunned:(float)timer;
- (void)startAttack;
- (void)getDotted:(float)timer hitpoint:(float)hitpoint;


@end
