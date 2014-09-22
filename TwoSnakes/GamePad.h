//
//  GamePad.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Snake.h"

@interface GamePad : UIView

- (id)initGamePad;
- (void)showEmptyNodeBorder:(SnakeNode *)node;
- (void)resetEmptyNodeBorder;
-(void)createBombWithReminder:(NSInteger)reminder body:(NSMutableArray *)snakeBody complete:(void(^)(void))completBlock;
- (void)reset;
- (void)bombExplosionWithPosX:(float)posX andPosY:(float)posY bomb:(SnakeNode *)bomb;
- (void)bombExplosionSquare:(float)posX andPosY:(float)posY bomb:(SnakeNode *)bomb;

@property (strong,nonatomic) NSMutableArray *emptyNodeArray;
@property (strong,nonatomic) SnakeNode  *initialNode;

@end
