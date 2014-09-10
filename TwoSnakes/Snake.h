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

@protocol gameoverDelegate <NSObject>
@required

-(void)showReplayView:(NSInteger)totalBombs;
-(void)updateScore:(NSInteger)s;
-(void)hideLastTutorial;
-(void)showLevel:(NSInteger)level;
-(void)showBombChain:(NSInteger)bombChain;

@end

@interface Snake : SnakeNode
{
    __weak id<gameoverDelegate>_delegate;
}

@property (strong,nonatomic) NSMutableArray *snakeBody;
@property (strong,nonatomic) GamePad *gamePad;
@property (strong,nonatomic) ParticleView *particleView;
@property (nonatomic) CGFloat xOffset;
@property (nonatomic) CGFloat yOffset;
@property (nonatomic) NSInteger combos;
@property (weak,nonatomic) id<gameoverDelegate>delegate;
@property (strong,nonatomic) SnakeNode *nextNode;
@property (nonatomic,assign) NSInteger reminder;

- (id)initWithSnakeNode:(SnakeNode *)node gamePad:(GamePad *)gamePad;
- (MoveDirection)headDirection;
- (SnakeNode *)snakeHead;
- (SnakeNode *)snakeTail;
- (void)resetSnake;
- (BOOL)checkIsGameover;
- (void)setGameoverImage;
- (void)updateNextNode:(SnakeNode *)node animation:(BOOL)animation;
- (void)cancelPattern:(void(^)(void))completBlock;
- (void)moveAllNodesBySwipe:(MoveDirection)direction complete:(void(^)(void))completBlock;
- (void)createBody:(void(^)(void))completBlock;

@end
