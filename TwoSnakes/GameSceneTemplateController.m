//
//  GameSceneTemplateController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GameSceneTemplateController.h"
#import "MenuController.h"
#import "GameMenu.h"
#import "GameAsset.h"


@interface GameSceneTemplateController ()
{
    CircleLabel *pauseLabel;
    GameMenu *menu;
    NSTimer *moveTimer;
    float timeInterval; // Movement speed of snake
    NSInteger numDotAte;
    NSTimer *countDownTimer;
    NSInteger counter;
    NSInteger maxCombos;
    BOOL isCheckingCombo;
}

@end

@implementation GameSceneTemplateController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    menu = [[GameMenu alloc]initWithFrame:self.view.frame];
    menu.frame = CGRectOffset(menu.frame, 0, -568);
    [self.view addSubview:menu];
    
    UITapGestureRecognizer *homeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backToMenu)];
    [menu.homeLabel addGestureRecognizer:homeTap];
    
    UITapGestureRecognizer *resumeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(resumeGame)];
    [menu.resumeLabel addGestureRecognizer:resumeTap];
    
    UITapGestureRecognizer *retryTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(retryGame)];
    [menu.retryLabel addGestureRecognizer:retryTap];
    
    pauseLabel = [[CircleLabel alloc]initWithFrame:CGRectMake(280, 10, 30, 30)];
    pauseLabel.text = @"P";
    pauseLabel.backgroundColor = [UIColor blackColor];
    [self.view addSubview:pauseLabel];
    
    UITapGestureRecognizer *pauseTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(pauseGame)];
    [pauseLabel addGestureRecognizer:pauseTap];
    
    // Game Settings
    timeInterval = 0.2;
    numDotAte = 0;
    counter =  3;
    maxCombos = 0;
    self.gamePad.userInteractionEnabled = NO;
    _gamePause = YES;
}

-(void)directionChange:(UITapGestureRecognizer *)sender
{
    if (_gamePad.userInteractionEnabled) {
        CGPoint location = [sender locationInView:_gamePad];
        [_snake setTurningNode:location];
        _gamePad.userInteractionEnabled = NO;

    }
    
    //    CGPoint location = [sender locationInView:newGamePad];
    //
    //    // Show tap point
    //        UIView *tapDot = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    //        tapDot.center = location;
    //        tapDot.layer.cornerRadius = 5;
    //        tapDot.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    //        tapDot.alpha = 0;
    //        tapDot.layer.borderColor = [[UIColor colorWithWhite:0.400 alpha:1.000]CGColor];
    //        tapDot.layer.borderWidth = 1.5;
    //        [newGamePad addSubview:tapDot];
    //
    //        [UIView animateWithDuration:0.3 animations:^{
    //            tapDot.alpha = 1;
    //        } completion:^(BOOL finished) {
    //            [UIView animateWithDuration:0.3 animations:^{
    //                tapDot.alpha = 0;
    //
    //            } completion:^(BOOL finished) {
    //                [tapDot removeFromSuperview];
    //            }];
    //        }];
    
}

#pragma mark - menu controls

- (void)pauseGame
{
    if (!_gamePause) {
        [self menuFade:NO];
        _gamePause = YES;
        [moveTimer invalidate];
    } else {
        [self startMoveTimer];
    }
}

- (void)backgroundPauseGame
{
    [self menuFade:NO];
    _gamePause = YES;
    [moveTimer invalidate];

}

- (void)resumeGame
{
    [self menuFade:YES];
    _gamePause = NO;
    if (!isCheckingCombo)
        moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                     target:self
                                                   selector:@selector(changeDirection)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)retryGame
{
    [self menuFade:YES];
    _gamePause = NO;
    
    timeInterval = 0.2;
    numDotAte = 0;
    
    //    [self.snake snakeHead].frame = CGRectMake(147, 189, 20, 20);
    [[self.snake snakeHead].layer removeAllAnimations];
    [self.snake snakeHead].alpha = 0;
    
    [self.snake resetSnake];
    
//    [self startCoundDown];
}

- (void)backToMenu
{
    [self menuFade:YES];
    _gamePause = YES;
    
    MenuController *controller = [[MenuController alloc]init];
    controller.state = kGameStateContinue;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)menuFade:(BOOL)fade
{
    if (fade) {
        [UIView animateWithDuration:0.5 animations:^{
            menu.frame = CGRectOffset(menu.frame, 0, -568);
        }];
    } else {
        [self.view bringSubviewToFront:menu];
        [UIView animateWithDuration:0.5 animations:^{
            menu.frame = CGRectOffset(menu.frame, 0, 568);
        }];
    }
    
}

#pragma change direction

-(void)changeDirection
{
    self.gamePad.userInteractionEnabled = YES;
    
    if ([self.snake changeDirectionWithGameIsOver:NO]) {
        
        [moveTimer invalidate];
        
        UIColor *gameOverColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
        
        [self.snake gameOver];
        
        [UIView animateWithDuration:1 animations:^{
            
            for (GameAsset *v in [self.gamePad assetArray]) {
                v.backgroundColor = gameOverColor;
            }
            
            for (UIView *v in [self.snake snakeBody]) {
                if (v.tag > 0) {
                    v.backgroundColor = gameOverColor;
                }
            }
            
        }];
        
    } else {
        for (GameAsset *v in [self.gamePad assetArray]) {
            if (v.hidden) {
                v.hidden = NO;
            }
        }
        [self isEatingDot];
    }
}

#pragma mark - Dot

- (void)isEatingDot
{
    for (GameAsset *v in [self.gamePad assetArray]) {
        if (!v.hidden && CGRectIntersectsRect([self.snake snakeHead].frame, v.frame) && v.gameAssetType != kAssetTypeEmpty) {
            
            self.snake.snakeMouth.hidden = NO;
            
            v.hidden = YES;
            
            [self.gamePad bringSubviewToFront:[self.snake snakeHead]];
            
            [self.gamePad addSubview:[self.snake addSnakeBodyWithAsset:v]];
            
            [moveTimer invalidate];
            
            self.gamePad.userInteractionEnabled = NO;
            
            isCheckingCombo = YES;
            
            [self.snake checkCombo:^{
                
                self.gamePad.userInteractionEnabled = YES;
                
                isCheckingCombo = NO;
                
                if (self.snake.isRotate)
                    [self.snake stopRotate];
                
                [self.snake mouthAnimation:timeInterval];
                
                self.snake.snakeMouth.backgroundColor = [UIColor whiteColor];
                
                // Increase speed for every 30 dots eaten
                if (numDotAte%30==0 && numDotAte != 0)
                    timeInterval -= 0.005;
                
                [self.snake updateExclamationText];
                
                [self.gamePad changeAssetType:v];
                
                if (moveTimer.isValid)
                    [moveTimer invalidate];
                
                if (!self.gamePause)
                    moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self
                                                               selector:@selector(changeDirection)
                                                               userInfo:nil
                                                                repeats:YES];
                
            }];
            
            break;
        }
    }
//    [self.gamePad sendSubviewToBack:[self.snake snakeHead]];
}

//#pragma mark - Game state
//
//- (void)countDown
//{
//    if (counter == 0) {
//        self.gamePad.userInteractionEnabled = YES;
//        [countDownTimer invalidate];
//        counter = 3;
//        
//        [self.gamePad hideAllAssets];
//        
//        self.gamePad.alpha = 0;
//        [UIView animateWithDuration:1 animations:^{
//            [self.snake snakeHead].alpha = 1;
//            [self.gamePad setupDotForGameStart:[self.snake snakeHead].frame];
//            
//        } completion:^(BOOL finished) {
//            
//            moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self
//                                                       selector:@selector(changeDirection)
//                                                       userInfo:nil
//                                                        repeats:YES];
//        }];
//    }
//    else {
////        [self.gamePad counterDots:counter];
//        counter--;
//    }
//}
//
//- (void)startCoundDown
//{
//    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
//                                                    selector:@selector(countDown)
//                                                    userInfo:nil
//                                                     repeats:YES];
//}

- (void)startMoveTimer
{
    self.gamePad.userInteractionEnabled = YES;
    _gamePause = NO;

    moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self
                                               selector:@selector(changeDirection)
                                               userInfo:nil
                                                repeats:YES];
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Hide statu bar

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
