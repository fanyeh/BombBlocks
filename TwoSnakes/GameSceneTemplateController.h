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

@interface GameSceneTemplateController : UIViewController

@property(strong,nonatomic) GamePad *gamePad;
@property(strong,nonatomic) Snake *snake;
@property(strong,nonatomic) NSTimer *moveTimer;

@property(nonatomic) BOOL gamePause;

- (void)directionChange:(UITapGestureRecognizer *)sender;
- (void)pauseGame;
- (void)backgroundPauseGame;
- (void)resumeGame;
- (void)retryGame;
- (void)backToMenu;
- (void)startMoveTimer;
- (void)menuFade:(BOOL)fade;
-(void)changeDirection;

@end
