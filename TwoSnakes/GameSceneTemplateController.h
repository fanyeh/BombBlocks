//
//  GameSceneTemplateController.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GamePad.h"
#import "Snake.h"


typedef enum {
    kCurrentGameStatePause = 0,
    kCurrentGameStatePlay,
    kCurrentGameStateReplay
} CurrentGameState;

@interface GameSceneTemplateController : UIViewController

@property(strong,nonatomic) GamePad *gamePad;
@property(strong,nonatomic) Snake *snake;
@property(strong,nonatomic) NSTimer *moveTimer;
@property(nonatomic) CurrentGameState gameState;
@property(strong,nonatomic) UILabel *pauseLabel;
@property(strong,nonatomic) UIImageView *stateSign;

- (void)directionChange:(UITapGestureRecognizer *)sender;
- (void)startMoveTimer;
//- (void)changeDirection;
- (void)changeGameState;

@end
