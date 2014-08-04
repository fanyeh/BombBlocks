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
    kPatternTypeDiagonalUp,
    kPatternTypeCross,
    kPatternTypeX,
    kPatternTypeHallowSquare
} PatternType;

typedef void (^completeComboCallback)(AssetType type , BOOL hasCombo);

@interface Snake : SnakeNode

@property (strong,nonatomic) NSMutableArray *snakeBody;
@property (strong,nonatomic) GamePad *gamePad;
@property (strong,nonatomic) ParticleView *particleView;
@property (strong,nonatomic) NSMutableArray *comingNodeArray;
@property (nonatomic) CGFloat xOffset;
@property (nonatomic) CGFloat yOffset;
@property (nonatomic) NSInteger combos;

- (id)initWithFrame:(CGRect)frame gamePad:(GamePad *)gamePad;
- (MoveDirection)headDirection;
- (SnakeNode *)snakeHead;
- (SnakeNode *)snakeTail;
-(void)swipeToMove:(UISwipeGestureRecognizerDirection)swipeDirection complete:(void(^)(void))completBlock;
- (void)resetSnake;
- (void)gameOver;

@end
