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
    UILabel *comboCountLabel;
    UILabel *comboLabel;
    UIView *comboView;
    UIView *rankView;
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
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    // Setup game pad
    self.gamePad = [[GamePad alloc]initGamePad];
    self.gamePad.center = self.view.center;
    self.gamePad.backgroundColor = [UIColor whiteColor];
    self.gamePad.layer.cornerRadius = 10;
    self.gamePad.layer.masksToBounds = YES;
    UITapGestureRecognizer *gamePadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(directionChange:)];
    [self.gamePad addGestureRecognizer:gamePadTap];
    
    
    // Background
    UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.gamePad.frame.size.width+16, self.gamePad.frame.size.height+16)];
    backgroundView.backgroundColor = PadBackgroundColor;
    backgroundView.layer.cornerRadius = 10;
    backgroundView.center = self.view.center;
    [self.view addSubview:backgroundView];
    [self.view addSubview:self.gamePad];
    
    CGFloat viewHeight = 40;
    CGFloat viewWidth = 50;
    
    // Combo
    comboView = [[UIView alloc]initWithFrame:CGRectMake(320-13.5-50, 20, viewWidth, viewHeight)];
    comboView.backgroundColor = PadBackgroundColor;
    comboView.layer.cornerRadius = 5;
    [self.view addSubview:comboView];
    
    comboLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 20)];
    comboLabel.text = @"Combo";
    comboLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:15];
    comboLabel.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    comboLabel.textAlignment = NSTextAlignmentCenter;
    comboLabel.userInteractionEnabled = YES;
    [comboView addSubview:comboLabel];
    
    comboCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, viewWidth, 13)];
    comboCountLabel.text = [NSString stringWithFormat:@"%ld",maxCombos];
    comboCountLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:13];
    comboCountLabel.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    comboCountLabel.textAlignment = NSTextAlignmentCenter;
    [comboView addSubview:comboCountLabel];
    
    
    // Rank
    rankView = [[UIView alloc]initWithFrame:CGRectMake(13.5, 20, viewWidth, viewHeight)];
    rankView.backgroundColor = PadBackgroundColor;
    rankView.layer.cornerRadius = 5;
    [self.view addSubview:rankView];
    
    UILabel *rankLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 20)];
    rankLabel.text = @"Rank";
    rankLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:15];
    rankLabel.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    rankLabel.textAlignment = NSTextAlignmentCenter;
    [rankView addSubview:rankLabel];
    
    UILabel *currentRank = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 50, 13)];
    currentRank.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:13];
    currentRank.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    currentRank.textAlignment = NSTextAlignmentCenter;
    [rankView addSubview:currentRank];
    
    [[GCHelper sharedInstance]getScoreRankFromLeaderboard:^(NSArray *topScores) {
        
        GKScore *topScore = [topScores firstObject];
        currentRank.text = [numFormatter stringFromNumber:[NSNumber numberWithInteger:topScore.rank]];

    }];
    
    // Setup score label
    CGFloat labelWidth = 120;
    _scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - labelWidth)/2,20, labelWidth, 40)];
    _scoreLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:20];
    _scoreLabel.text = @"Score";
    _scoreLabel.textColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
    _scoreLabel.textAlignment = NSTextAlignmentCenter;
    _scoreLabel.backgroundColor =  [UIColor colorWithRed:0.851 green:0.902 blue:0.894 alpha:1.000];
    _scoreLabel.layer.cornerRadius = 5;
    _scoreLabel.layer.masksToBounds = YES;
    [self.view addSubview:_scoreLabel];
    
    // Setup player snake head
    startFrame = CGRectMake(140 , 209 , 22 , 22);
    self.snake = [[Snake alloc]initWithSnakeHeadDirection:kMoveDirectionDown gamePad:self.gamePad headFrame:startFrame snakeType:kSnakeTypePlayer];
    [self.gamePad addSubview:self.snake];
    
    // Set up enemy snake
    enemySnake = [[Snake alloc]initWithSnakeHeadDirection:kMoveDirectionDown gamePad:self.gamePad headFrame:startFrame snakeType:kSnakeTypeEnemy];
    int c = arc4random()%3;
    
    switch (c) {
        case 0:
            enemySnake.backgroundColor = BlueDotColor;
            break;
        case 1:
            enemySnake.backgroundColor = RedDotColor;
        case 2:
            enemySnake.backgroundColor = YellowDotColor;
            break;
    }
 
    [self.gamePad addSubview:enemySnake];
    enemySnake.hidden = YES;
    
    // Game Settings
    numDotAte = 0;
    score = 0;
    timeInterval = 0.20;
    maxCombos = 0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(attackEnemy:) name:@"attackEnemy" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showAttack:) name:@"showAttack" object:nil];

    
    UITapGestureRecognizer *changeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeGameState)];
    [self.pauseLabel addGestureRecognizer:changeTap];
    
    // Game Center Label
    UILabel *gameCenterLabel = [[UILabel alloc]initWithFrame:CGRectMake(13.5, 508, viewWidth, viewHeight)];
    gameCenterLabel.backgroundColor = PadBackgroundColor;
    gameCenterLabel.layer.cornerRadius = 5;
    gameCenterLabel.layer.masksToBounds = YES;
    UIImageView *gamecenterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
    UIImage *gamecenterImage = [UIImage imageNamed:@"gamecenter.png"];
    gamecenterImageView.image = gamecenterImage;
    [gameCenterLabel addSubview:gamecenterImageView];
    [self.view addSubview:gameCenterLabel];
    
    UITapGestureRecognizer *gamecenterTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showGameCenter)];
    [gameCenterLabel addGestureRecognizer:gamecenterTap];
    gameCenterLabel.userInteractionEnabled = YES;
}

- (void)attackEnemy:(NSNotification *)notification
{
    NSDictionary *comboColorDict = [notification userInfo];
    
    UIColor *color = [comboColorDict objectForKey:@"comboColor"];
    
    if ([color isEqual:enemySnake.backgroundColor] && !enemySnake.hidden) {
        
        
        UIView *body = [enemySnake.snakeBody lastObject];

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

- (void)showAttack:(NSNotification *)notification
{
    if (!enemySnake.hidden)
        [enemySnake showAttackEnemyAnimation];
}

- (void)changeEnemyDirection
{
    int i = arc4random()%3;
    if (i == 2 || [enemyPath count] < 1 || enemyPath == nil) {
        
        enemyPath =  [self.gamePad searchPathPlayer:self.snake.frame enemy:enemySnake.frame moveDirection:[enemySnake headDirection]];
        
    }
    
    CGPoint nextMoveOrigin = [[enemyPath firstObject]frame].origin;
    [enemySnake setTurningNode:nextMoveOrigin];

    UIView *breakBody = nil;
    
    // Enemy touched snake body
    for (UIView *s in [self.snake snakeBody]) {
        
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
        
        // Enemy eating animation
        CGAffineTransform currentTransform = enemySnake.transform;
        [UIView animateWithDuration:0.5 animations:^{
            
            enemySnake.transform = CGAffineTransformScale(currentTransform, 2.0, 2.0);
            enemySnake.snakeMouth.frame = CGRectInset( enemySnake.snakeMouth.frame, -offset, -offset*1.1);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.5 animations:^{
                
                enemySnake.transform = CGAffineTransformScale(currentTransform, 1, 1);
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

- (void)enemyAttack:(UIView *)body
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
        
        [self stopEnemyTimer];
        
        [self stopMoveTimer];
        
        UIColor *gameOverColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
        
        [self.snake gameOver];
        
        self.gameState = kCurrentGameStateReplay;
        self.stateSign.image = [UIImage imageNamed:@"replay.png"];
        
        NSInteger bestScore = [[NSUserDefaults standardUserDefaults]integerForKey:@"BestScore"];
        
        if (score > bestScore) {
            
            [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"BestScore"];
            [[GCHelper sharedInstance] submitScore:score leaderboardId:kHighScoreLeaderboardId];
        }
        
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
                
                if (self.gameState == kCurrentGameStatePlay) {
                    
                    [self startMoveTimer];
                    
                    if (!enemyTimer.isValid && !enemySnake.hidden)
                        
                        [self startEnemyTimer];
                    
                }
                
            }];
            
            break;
        }
    }
}

- (void)changeGameState
{
        [super changeGameState];
        
        // Current game start after change
        switch (self.gameState) {
                
            case kCurrentGameStatePlay:
                
                if (!isCheckingCombo)
                    [self startMoveTimer];
                
                break;
            case kCurrentGameStatePause:
                
                [self stopMoveTimer];
                
                [self stopEnemyTimer];
                
                break;
            case kCurrentGameStateReplay:
                
                numDotAte = 0;
                maxCombos = 0;
                score = 0;
                timeInterval = 0.30;
                maxCombos = 0;
                
                [self setScore];
                [self.snake resetSnake];
                [self.gamePad resetClassicGamePad];
                [self startMoveTimer];
                
                self.gameState = kCurrentGameStatePlay;
                
                break;
        }
}

- (void)noLifeAlert
{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"No Lives!"
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"Close"
                                         otherButtonTitles:nil, nil];
    [alert show];

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

- (void)minuteFromSeconds:(NSInteger)seconds
{
    NSInteger sec = seconds%60;
    NSString *secondString;
    
    if (sec < 10)
        secondString = [NSString stringWithFormat:@"0%ld",sec];
    else
        secondString = [NSString stringWithFormat:@"%ld",sec];

    
    NSInteger minutes = seconds/60;
    
    comboCountLabel.text = [NSString stringWithFormat:@"%ld:%@",minutes,secondString];
    
}

#pragma mark - Setscore

- (void)setScore
{
    NSInteger comboAdder = 50;
    for (int i = 0 ; i < [self.snake combos] ; i ++) {
        score += comboAdder;
        comboAdder *= 2;
    }
    
    if (self.snake.combos > maxCombos) {
        maxCombos = self.snake.combos;
        comboCountLabel.text = [NSString stringWithFormat:@"%ld",maxCombos];
    }
    
    self.snake.combos = 0;
    numDotAte++;
    score++;
    self.scoreLabel.text = [numFormatter stringFromNumber:[NSNumber numberWithInteger:score]];
}

#pragma mark - Game center

- (void)showGameCenter
{
    [[GCHelper sharedInstance] showGameCenterViewController:self];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
