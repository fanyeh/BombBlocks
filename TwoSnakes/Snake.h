//
//  Snake.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/1.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnakeBody.h"
#import "SnakeType.h"
@class SnakeSkill;
@class GameAsset;

typedef enum {
    kMoveDirectionUp = 0,
    kMoveDirectionDown,
    kMoveDirectionLeft,
    kMoveDirectionRight
} MoveDirection;

@interface Snake : UIView

@property (nonatomic) int snakeLength;
@property (nonatomic) MoveDirection snakeDirection;
@property (strong,nonatomic) NSMutableArray *snakeBody;
@property (strong,nonatomic) NSMutableDictionary *bodyDirections;
@property (strong,nonatomic) NSMutableDictionary *turningNodes;
@property (strong,nonatomic) UIView *gamePad;
@property (strong,nonatomic) UIView *leftEye;
@property (strong,nonatomic) UIView *rightEye;
@property (strong,nonatomic) UIView *snakeMouth;
@property (strong,nonatomic) UIView *initSkillView;
@property (strong,nonatomic) UIView *supplementSkillView1;
@property (strong,nonatomic) UIView *supplementSkillView2;
@property (strong,nonatomic) SnakeSkill *skill;

@property (nonatomic) CGFloat xOffset;
@property (nonatomic) CGFloat yOffset;
@property (nonatomic) BOOL isRotate;
@property (nonatomic) NSInteger combos;
@property (nonatomic) SnakeType *snakeType;


- (id)initWithSnakeHeadDirection:(MoveDirection)direction gamePad:(UIView *)gamePad headFrame:(CGRect)frame;
- (SnakeBody *)addSnakeBody:(UIColor *)backgroundColor;
- (MoveDirection)headDirection;
- (UIView *)snakeHead;
- (UIView *)snakeTail;
- (void)setTurningNode:(CGPoint)location;
- (BOOL)changeDirectionWithGameIsOver:(BOOL)gameIsOver;
- (void)resetSnake;
- (void)removeSnakeBody:(UIView *)body;
- (void)removeSnakeBodyFromArray:(NSMutableArray *)removeArray;
- (void)updateTurningNode;
- (void)startRotate;
- (void)stopRotate;
- (void)gameOver;
- (void)updateExclamationText:(NSString *)text;
- (void)mouthAnimation:(float)timeInterval;
- (BOOL)checkCombo:(void(^)(void))completeBlock;
- (void)setWallBounds:(NSMutableArray *)wallbounds;
- (void)showExclamation:(BOOL)show;
-(void)removeSnakeBodyByRangeStart:(NSInteger)start andRange:(NSInteger)range complete:(void(^)(void))completeBlock;

@end
