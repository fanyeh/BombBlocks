//
//  Snake.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/1.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ParticleView.h"
#import "GameAsset.h"
#import "SnakeNode.h"

@class GamePad;

typedef enum {
    kPatternTypeSquare = 0,
    kPatternTypeRow,
    kPatternTypeCol,
    kPatternTypeDiagonalDown,
    kPatternTypeDiagonalUp
} PatternType;

typedef void (^completeComboCallback)(AssetType type , BOOL hasCombo);

@interface Snake : SnakeNode

@property (strong,nonatomic) NSMutableArray *snakeBody;
@property (strong,nonatomic) GamePad *gamePad;
@property (strong,nonatomic) ParticleView *particleView;
@property (nonatomic) CGFloat xOffset;
@property (nonatomic) CGFloat yOffset;
@property (nonatomic) BOOL isRotate;
@property (nonatomic) NSInteger combos;

- (id)initWithSnakeHeadDirection:(MoveDirection)direction gamePad:(GamePad *)gamePad headFrame:(CGRect)frame;
- (MoveDirection)headDirection;
- (SnakeNode *)snakeHead;
- (SnakeNode *)snakeTail;
//- (void)setTurningNode:(CGPoint)location;
- (void)setTurningNodeBySwipe:(UISwipeGestureRecognizerDirection)swipeDirection;
- (void)resetSnake;
- (void)startRotate;
- (void)stopRotate;
- (void)gameOver;
//- (BOOL)checkCombo:(completeComboCallback)completeBlock;
- (void)setWallBounds:(NSMutableArray *)wallbounds;
//- (void)removeSnakeBodyByRangeStart:(NSInteger)start andRange:(NSInteger)range complete:(completeComboCallback)completeBlock;
-(CABasicAnimation *)stunAnimation:(NSInteger)i;

@end
