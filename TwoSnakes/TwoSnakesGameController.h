//
//  TwoSnakesGameController.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/4/29.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SnakeButton.h"

@interface TwoSnakesGameController : UIViewController

@property (strong,nonatomic) SnakeButton *snakeButton;
- (void)backgroundPauseGame;


@end
