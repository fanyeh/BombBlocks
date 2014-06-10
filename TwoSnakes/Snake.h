//
//  Snake.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/1.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameAsset;
@class GamePad;

typedef enum {
    kMoveDirectionUp = 0,
    kMoveDirectionDown,
    kMoveDirectionLeft,
    kMoveDirectionRight
} MoveDirection;

typedef enum {
    kSnakeTypePlayer = 0,
    kSnakeTypeEnemy
} SnakeType;

@interface Snake : UIView

@property (nonatomic) int snakeLength;
@property (strong,nonatomic) NSMutableArray *snakeBody;
@property (strong,nonatomic) NSMutableDictionary *bodyDirections;
@property (strong,nonatomic) NSMutableDictionary *turningNodes;
@property (strong,nonatomic) UIView *leftEye;
@property (strong,nonatomic) UIView *rightEye;
@property (strong,nonatomic) UIView *snakeMouth;
@property (strong,nonatomic) GamePad *gamePad;
@property (nonatomic) BOOL hasEnemy;


@property (nonatomic) CGFloat xOffset;
@property (nonatomic) CGFloat yOffset;
@property (nonatomic) BOOL isRotate;
@property (nonatomic) NSInteger combos;


- (id)initWithSnakeHeadDirection:(MoveDirection)direction gamePad:(GamePad *)gamePad headFrame:(CGRect)frame snakeType:(SnakeType)snakeType;
- (UIView *)addSnakeBody:(UIColor *)backgroundColor;
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
- (void)removeSnakeBodyByRangeStart:(NSInteger)start andRange:(NSInteger)range complete:(void(^)(void))completeBlock;
- (void)showAttackEnemyAnimation:(UIColor *)color;

@end
