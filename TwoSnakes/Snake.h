//
//  Snake.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/1.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>

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

@property (nonatomic) CGFloat xOffset;
@property (nonatomic) CGFloat yOffset;

- (id)initWithSnakeHead:(UIView *)headView andDirection:(MoveDirection)direction;
- (UIView *)addSnakeBodyWithColor:(UIColor *)color;
- (MoveDirection)headDirection;
- (UIView *)snakeHead;
- (UIView *)snakeTail;
- (void)setTurningNode:(CGPoint)location;
- (BOOL)isEatingDot:(UIView*)dot;
- (BOOL)changeDirectionWithGameIsOver:(BOOL)gameIsOver moveTimer:(NSTimer *)timer;
- (BOOL)isOverlayWithDotFrame:(CGRect)dotFrame;
- (void)resetSnake:(UIView *)headView andDirection:(MoveDirection)direction;
- (void)removeSnakeBody:(UIView *)body;
- (void)removeSnakeBodyFromArray:(NSMutableArray *)removeArray;
- (void)updateTurningNode;
- (void)setTurningNodeWithDirection:(MoveDirection)direction;

@end
