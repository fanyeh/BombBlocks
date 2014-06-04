//
//  ClassicGameController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "ClassicGameController.h"
#import "MenuController.h"
#import "GameAsset.h"

@interface ClassicGameController ()
{

    UILabel *scoreLabel;
    NSNumberFormatter *numFormatter; //Formatter for score
    NSInteger score;
    NSInteger numDotAte;
    NSInteger maxCombos;
    float timeInterval; // Movement speed of snake
    BOOL isCheckingCombo;
    NSTimer *enemyTimer;
    Snake *enemySnake;
    NSMutableArray *enemyPath;
    
    CGRect startFrame;
    
    //    NSTimer *countDownTimer;
    //    NSInteger counter;

}
@end

@implementation ClassicGameController

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
    //self.view.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];

    UILabel *backLabel = [[UILabel alloc]initWithFrame:CGRectMake(13.5, 5, 50, 30)];
    backLabel.backgroundColor = [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    backLabel.text = @"Back";
    backLabel.layer.cornerRadius = 5;
    backLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:15];
    backLabel.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    backLabel.textAlignment = NSTextAlignmentCenter;
    backLabel.layer.masksToBounds = YES;
    backLabel.userInteractionEnabled = YES;
    [self.view addSubview:backLabel];
    
    UITapGestureRecognizer *homeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backToMenu)];
    [backLabel addGestureRecognizer:homeTap];
    
    UILabel *menuLabel = [[UILabel alloc]initWithFrame:CGRectMake(320-13.5-50, 5, 50, 30)];
    menuLabel.backgroundColor = [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    menuLabel.text = @"Menu";
    menuLabel.layer.cornerRadius = 5;
    menuLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:15];
    menuLabel.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    menuLabel.textAlignment = NSTextAlignmentCenter;
    menuLabel.layer.masksToBounds = YES;
    [self.view addSubview:menuLabel];
    
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 293, 461)];
    
    backgroundView.backgroundColor = [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    backgroundView.layer.cornerRadius = 10;
    backgroundView.center = self.view.center;
    [self.view addSubview:backgroundView];
    
    // Setup game pad
    self.gamePad = [[GamePad alloc]initGamePad];
    self.gamePad.center = self.view.center;
    self.gamePad.backgroundColor = [UIColor whiteColor];
    self.gamePad.layer.cornerRadius = 10;
    self.gamePad.layer.masksToBounds = YES;
    UITapGestureRecognizer *gamePadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(directionChange:)];
    [self.gamePad addGestureRecognizer:gamePadTap];
    [self.view addSubview:self.gamePad];
    
    startFrame = CGRectMake(128, 212, 20, 20);
    // Setup snake head
    self.snake = [[Snake alloc]initWithSnakeHeadDirection:kMoveDirectionDown gamePad:self.gamePad headFrame:startFrame];
    [self.gamePad addSubview:self.snake];
    
    enemySnake = [[Snake alloc]initWithSnakeHeadDirection:kMoveDirectionDown gamePad:self.gamePad headFrame:startFrame];
    
    int c = arc4random()%3;
    
    switch (c) {
        case 0:
            enemySnake.backgroundColor = [UIColor colorWithRed:0.235 green:0.729 blue:0.784 alpha:1.000];
            break;
        case 1:
            enemySnake.backgroundColor = [UIColor colorWithRed:1.000 green:0.208 blue:0.545 alpha:1.000];
        case 2:
            enemySnake.backgroundColor = [UIColor colorWithRed:1.000 green:0.733 blue:0.125 alpha:1.000];
            break;
//        case 3:
//            enemySnake.backgroundColor = [UIColor colorWithRed:0.592 green:0.408 blue:0.820 alpha:1.000];
//            break;
    }
 
    [self.gamePad addSubview:enemySnake];
    enemySnake.hidden = YES;
    
    // Setup score label
    CGFloat labelWidth = 120;
    scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - labelWidth)/2, 30, labelWidth, 30)];
    scoreLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
    scoreLabel.text = @"Score";
    scoreLabel.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    scoreLabel.textAlignment = NSTextAlignmentCenter;
    scoreLabel.backgroundColor =  [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    scoreLabel.layer.cornerRadius = 10;
    scoreLabel.layer.masksToBounds = YES;
    [self.view addSubview:scoreLabel];
    
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    // Game Settings
    numDotAte = 0;
    maxCombos = 0;
    score = 0;
    timeInterval = 0.2;
    maxCombos = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attackEnemy:) name:@"attackEnemy" object:nil];

}

- (void)attackEnemy:(NSNotification *)notification
{
    NSDictionary *comboColorDict = [notification userInfo];
    
    UIColor *color = [comboColorDict objectForKey:@"comboColor"];
    
    if ([color isEqual:enemySnake.backgroundColor] && !enemySnake.hidden) {
        
        
        SnakeBody *body = [enemySnake.snakeBody lastObject];

        [UIView animateWithDuration:1.0
                         animations:^{
                             
                             body.alpha = 0;
                             
                         } completion:^(BOOL finished) {
                             if ([enemySnake.snakeBody count]==1) {
                                 
                                 enemySnake.frame =  startFrame;
                                 enemySnake.hidden = YES;
                                 
                             } else {
                                 [body removeFromSuperview];
                                 [enemySnake.snakeBody removeLastObject];
                             }
                         }];
    }
}

- (void)changeEnemyDirection
{
    int i = arc4random()%3;
    if (i == 2 || [enemyPath count] < 1 || enemyPath == nil) {
        
        enemyPath =  [self.gamePad searchPathPlayer:self.snake.frame enemy:enemySnake.frame moveDirection:[enemySnake headDirection]];
        
    }
    
    CGPoint nextMoveOrigin = [[enemyPath firstObject]frame].origin;
    [enemySnake setTurningNode:nextMoveOrigin];

    SnakeBody *breakBody = nil;
    
    // Enemy touched snake body
    for (SnakeBody *s in [self.snake snakeBody]) {
        
        if ([[NSValue valueWithCGRect:[[enemyPath firstObject]frame]] isEqualToValue:[NSValue valueWithCGRect:s.frame]]) {
            breakBody = s;
            break;
        }
    }
    
    if (breakBody) {
        [self stopMoveTimer];
        [self stopEnemyTimer];
        
        [enemySnake updateExclamationText:@"Yummy!"];
        [enemySnake showExclamation:YES];
        
        [self.snake updateExclamationText:@"Ouch!"];
        [self.snake startRotate];
        
        CGFloat offset = 7;
        enemySnake.snakeMouth.frame = CGRectInset( enemySnake.snakeMouth.frame,offset, offset);
        
        enemySnake.snakeMouth.backgroundColor = [UIColor whiteColor];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            enemySnake.snakeMouth.frame = CGRectInset( enemySnake.snakeMouth.frame, -offset, -offset*1.1);
            
        } completion:^(BOOL finished) {
            
            
            [UIView animateWithDuration:0.5 animations:^{
                
                [enemySnake changeDirectionWithGameIsOver:NO];
                enemySnake.snakeMouth.frame = CGRectInset( enemySnake.snakeMouth.frame, offset, offset*1.1);
                breakBody.frame = CGRectInset( breakBody.frame, 20, 20);
                
            }completion:^(BOOL finished) {
                
                enemySnake.snakeMouth.backgroundColor = [UIColor clearColor];
                enemySnake.snakeMouth.frame = CGRectInset( enemySnake.snakeMouth.frame, -offset, -offset*1.1);
                [enemyPath removeObjectAtIndex:0];
                [self enemyAttack:breakBody];

                
            }];
            
        }];

    } else {
        
        [enemySnake changeDirectionWithGameIsOver:NO];
        
        [enemyPath removeObjectAtIndex:0];
    }

}

- (void)enemyAttack:(SnakeBody *)body
{

    [self.gamePad bringSubviewToFront:enemySnake];
    
    NSInteger i = [self.snake.snakeBody indexOfObject:body];
    NSInteger range = [self.snake.snakeBody count]-i;
    
    [self.snake removeSnakeBodyByRangeStart:i
                                   andRange:range
                                   complete:^{
                                       
                                       [enemySnake showExclamation:NO];
                                       
                                       [self.snake stopRotate];

                                       [self startMoveTimer];
                                       
                                       [self startEnemyTimer];
                                       
                                       [self.gamePad addSubview:[enemySnake addSnakeBody:enemySnake.backgroundColor]];
                                       
                                       
                                   }];

}

-(void)changeDirection
{
    [super changeDirection];
    
    
    if ([self.snake changeDirectionWithGameIsOver:NO]) {
        
        [self stopMoveTimer];
        
        UIColor *gameOverColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
        
        [self.snake gameOver];
        
        [UIView animateWithDuration:1 animations:^{
            
            for (GameAsset *v in [self.gamePad assetArray]) {
                if (v.gameAssetType != kAssetTypeEmpty)
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
            
            [self.gamePad addSubview:[self.snake addSnakeBody:v.classicAssetLabel.backgroundColor]];
            
            
            [self stopMoveTimer];
            [self stopEnemyTimer];
            
            self.gamePad.userInteractionEnabled = NO;
            
            isCheckingCombo = YES;
            
            [self.snake checkCombo:^{
                
                self.gamePad.userInteractionEnabled = YES;
                
                isCheckingCombo = NO;
                
                [self setScore];
                
                if (self.snake.isRotate)
                    [self.snake stopRotate];
                
                [self.snake mouthAnimation:timeInterval];
                
                self.snake.snakeMouth.backgroundColor = [UIColor whiteColor];
                
                // Increase speed for every 30 dots eaten
                if (numDotAte%30==0 && numDotAte != 0) {
                    
                    timeInterval -= 0.005;
                    
                    if (enemySnake.hidden) {
                        
                        [self startEnemyTimer];
                        
                    }
                }
                
                [self.snake updateExclamationText:nil];
                
                [self.gamePad changeAssetType:v];
                
                if (self.moveTimer.isValid)
                    
                    [self.moveTimer invalidate];
                
                if (!self.gamePause) {
                    
                    [self startMoveTimer];
                    
                    if (!enemyTimer.isValid && !enemySnake.hidden)
                        [self startEnemyTimer];
                    
                }
                
            }];
            
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
    numDotAte = 0;
    maxCombos = 0;
    score = 0;
    timeInterval = 0.2;
    maxCombos = 0;
    [self setScore];
    
//    [self.snake snakeHead].alpha = 0;
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

- (void)startEnemyTimer
{
    enemyTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval*1.5 target:self
                                            selector:@selector(changeEnemyDirection)
                                            userInfo:nil
                                             repeats:YES];

    enemySnake.hidden = NO;
    enemySnake.alpha = 1;
}

- (void)stopEnemyTimer
{
    [enemyTimer invalidate];
}

- (void)stopMoveTimer
{
    [self.moveTimer invalidate];
}

#pragma mark - Setscore

- (void)setScore
{
    NSInteger comboAdder = 50;
    for (int i = 0 ; i < [self.snake combos] ; i ++) {
        score += comboAdder;
        comboAdder *= 2;
    }
    self.snake.combos = 0;
    numDotAte++;
    score++;
    scoreLabel.text = [numFormatter stringFromNumber:[NSNumber numberWithInteger:score]];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
