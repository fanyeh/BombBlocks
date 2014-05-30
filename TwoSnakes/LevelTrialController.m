//
//  LevelTrialController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/26.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "LevelTrialController.h"
#import "GameAsset.h"

@interface LevelTrialController ()
{
    float timeInterval; // Movement speed of snake
    BOOL isCheckingCombo;
}
@end

@implementation LevelTrialController

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
    
    if (_assetArray)
        self.gamePad = [[GamePad alloc]initGamePadWithAsset:_assetArray];
    else if (_assetDict) {
        self.gamePad = [[GamePad alloc]initGamePadWithAssetDict:_assetDict];
        for (GameAsset *a in self.gamePad.assetArray) {
            a.layer.borderWidth = 1;
        }
    }

    self.gamePad.center = self.view.center;
    self.gamePad.frame = CGRectOffset(self.gamePad.frame, 0, 25);

    UITapGestureRecognizer *gamePadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(directionChange:)];
    [self.gamePad addGestureRecognizer:gamePadTap];
    [self.view addSubview:self.gamePad];
    
    // Setup snake head
    self.snake = [[Snake alloc]initWithSnakeHeadDirection:kMoveDirectionUp gamePad:self.gamePad headFrame:CGRectMake(147, 441, 20, 20)];
    [self.snake setWallBounds:[self walls]];
    [self.gamePad addSubview:self.snake];

    UIButton *exitButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
    [exitButton setTitle:@"Exit" forState:UIControlStateNormal];
    exitButton.titleLabel.textColor = [UIColor blackColor];
    [exitButton addTarget:self action:@selector(exitTrial) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:exitButton];
    timeInterval = 0.25;
    
}

- (void)exitTrial
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *)walls
{
    NSMutableArray *wallBounds = [[NSMutableArray alloc]init];
    
    for (GameAsset *asset in [self.gamePad assetArray]) {
        if (asset.gameAssetType == kAssetTypeWall)
            [wallBounds addObject:asset];
    }

    return wallBounds;
}

-(void)changeDirection
{
    [super changeDirection];
    
    if ([self.snake changeDirectionWithGameIsOver:NO]) {
        
        [self.moveTimer invalidate];
        
        UIColor *gameOverColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
        
        [self.snake gameOver];
        
        [UIView animateWithDuration:1 animations:^{
            
            for (GameAsset *v in [self.gamePad assetArray]) {
                v.classicAssetLabel.backgroundColor = gameOverColor;
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
        //[self isEatingDot];
        [self isHittingGoal];
    }
}

#pragma mark - Events

- (void)isEatingDot
{
    for (GameAsset *v in [self.gamePad assetArray]) {
        if (!v.hidden && CGRectIntersectsRect([self.snake snakeHead].frame, v.frame) && v.gameAssetType != kAssetTypeEmpty) {
            
            self.snake.snakeMouth.hidden = NO;
            
            v.hidden = YES;
            
            [self.gamePad bringSubviewToFront:[self.snake snakeHead]];
            
            [self.gamePad addSubview:[self.snake addSnakeBodyWithAsset:v]];
            
            [self.moveTimer invalidate];
            
            self.gamePad.userInteractionEnabled = NO;
            
            isCheckingCombo = YES;
            
            [self.snake checkCombo:^{
                
                self.gamePad.userInteractionEnabled = YES;
                
                isCheckingCombo = NO;
                
                if (self.snake.isRotate)
                    [self.snake stopRotate];
                
                [self.snake mouthAnimation:timeInterval];
                
                self.snake.snakeMouth.backgroundColor = [UIColor whiteColor];
                
                [self.snake updateExclamationText];
                
                [self.gamePad changeAssetType:v];
                
                if (self.moveTimer.isValid)
                    [self.moveTimer invalidate];
                
                if (!self.gamePause)
                    self.moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self
                                                                    selector:@selector(changeDirection)
                                                                    userInfo:nil
                                                                     repeats:YES];
                
            }];
            
            break;
        }
    }
}

-(void)isHittingGoal
{
    for (GameAsset *v in [self.gamePad assetArray]) {
        if (!v.hidden && CGRectIntersectsRect([self.snake snakeHead].frame, v.frame) && v.gameAssetType == kAssetTypeGoal) {
            
            [self.moveTimer invalidate];
            NSLog(@"level pass");
            break;
        }
    }
}


#pragma mark - menu controls

- (void)pauseGame
{
    [super pauseGame];
    if (!self.gamePause) {
        [super menuFade:NO];
        self.gamePause = YES;
        [self.moveTimer invalidate];
    } else {
        [self startMoveTimer];
    }
}

- (void)backgroundPauseGame
{
    [super backgroundPauseGame];
    [self.moveTimer invalidate];
}

- (void)resumeGame
{
    [super resumeGame];
    if (!isCheckingCombo)
        self.moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                          target:self
                                                        selector:@selector(changeDirection)
                                                        userInfo:nil
                                                         repeats:YES];
}

- (void)retryGame
{
    [super retryGame];
    timeInterval = 0.2;
    [self.snake resetSnake];
    [self.gamePad resetClassicGamePad];
    [self startMoveTimer];
}

- (void)backToMenu
{
    [self.moveTimer invalidate];
    [super backToMenu];
}

- (void)startMoveTimer
{
    [super startMoveTimer];
    self.moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self
                                                    selector:@selector(changeDirection)
                                                    userInfo:nil
                                                     repeats:YES];
}

@end
