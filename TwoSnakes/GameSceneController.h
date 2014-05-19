//
//  GameSceneController.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnakeButton.h"

@interface GameSceneController : UIViewController

@property (strong,nonatomic) SnakeButton *snakeButton;
- (void)backgroundPauseGame;

@end
