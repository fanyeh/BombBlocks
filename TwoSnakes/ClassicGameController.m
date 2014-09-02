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
#import "ParticleView.h"
#import "GamePad.h"
#import "Snake.h"
#import "MKAppDelegate.h"
#import "CustomLabel.h"
#import "ScoreObject.h"
#import <AVFoundation/AVFoundation.h>
#import "GameStatsViewController.h"

@interface ClassicGameController () <gameoverDelegate,replayDelegate>
{
    NSNumberFormatter *numFormatter; //Formatter for score
    NSInteger score;
    SnakeNode *nextNode;
    GamePad *gamePad;
    Snake *snake;
    NSInteger totalCombos;
    NSInteger combosToCreateBomb;
    BOOL swap;
    CustomLabel *nextLabel;
    CustomLabel *scoreLabel;
    BOOL gameIsOver;
    NSInteger scoreGap;
    NSTimer *changeScoreTimer;
    NSMutableArray *scoreArray;
    AVAudioPlayer *audioPlayer;
    ParticleView *particle;
    UIButton *settingButton;
    UIButton *soundButton;
    UIButton *musicButton;
    UIButton *rateButton;
    UIView *settingBG;
    BOOL isSetting;
    CGAffineTransform settingTransform;
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
    
    self.view.backgroundColor = [UIColor colorWithWhite:0.063 alpha:1.000];
    UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Background.png"]];
    [self.view addSubview:bgImageView];
    
    // Do any additional setup after loading the view.
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    // -------------------- Setup game pad -------------------- //
    gamePad = [[GamePad alloc]initGamePad];
    gamePad.center = self.view.center;

    // -------------------- Setup particle views -------------------- //
    // Configure the SKView
    SKView * skView = [[SKView alloc]initWithFrame:CGRectMake(0, 0, gamePad.frame.size.width, gamePad.frame.size.height)];
    skView.backgroundColor = [UIColor clearColor];
    
    // Create and configure the scene.
    particle = [[ParticleView alloc]initWithSize:skView.bounds.size];
    particle.scaleMode = SKSceneScaleModeAspectFill;
    [gamePad addSubview:skView];
    [gamePad sendSubviewToBack:skView];

    // Present the scene.
    [skView presentScene:particle];
    [self.view addSubview:gamePad];
    
    // Count down
    scoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 250)/2, 40 , 250, 65) fontName:@"GeezaPro-Bold" fontSize:65];
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.text = @"0";
    [self.view addSubview:scoreLabel];
    
    // Setup player snake head
    snake = [[Snake alloc]initWithSnakeNode:gamePad.initialNode gamePad:gamePad];
    snake.delegate = self;
    [gamePad addSubview:snake];
    snake.particleView = particle;
    
    // Next Node
    CGFloat nextNodeSize = 40;
    nextNode = [[SnakeNode alloc]initWithFrame:CGRectMake((320-nextNodeSize)/2, self.view.frame.size.height - 90 , nextNodeSize, nextNodeSize)];
    snake.nextNode = nextNode;
    [snake updateNextNode:nextNode animation:YES];
    [self.view addSubview:nextNode];
    
    nextLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(120, self.view.frame.size.height - 50, 80, 15) fontName:@"GeezaPro-Bold" fontSize:15];
    nextLabel.text = @"Next";
    nextLabel.textColor = [UIColor whiteColor];
    [self.view addSubview:nextLabel];

    // Setup swipe gestures
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDirection:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [gamePad addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDirection:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [gamePad addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDirection:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [gamePad addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDirection:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [gamePad addGestureRecognizer:swipeUp];
    
    scoreArray = [[NSMutableArray alloc]init];
    
    settingBG = [[UIView alloc]initWithFrame:CGRectMake(320-40, 5, 35, 35)];
    settingBG.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.400];
    settingBG.layer.cornerRadius = 35/2;
    [self.view addSubview:settingBG];
    
    settingButton = [[UIButton alloc]initWithFrame:CGRectMake(320-40, 5, 35, 35)];
    [settingButton setImage:[UIImage imageNamed:@"setting70.png"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:settingButton];
    
    soundButton = [[UIButton alloc]initWithFrame:CGRectMake(200, 10, 35, 35)];
    [soundButton setImage:[UIImage imageNamed:@"sound70.png"] forState:UIControlStateNormal];
    [soundButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:soundButton];
    
    musicButton = [[UIButton alloc]initWithFrame:CGRectMake(227.5, 55, 35, 35)];
    [musicButton setImage:[UIImage imageNamed:@"music70.png"] forState:UIControlStateNormal];
    [musicButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:musicButton];
    
    rateButton = [[UIButton alloc]initWithFrame:CGRectMake(320-45, 85, 35, 35)];
    [rateButton setImage:[UIImage imageNamed:@"rating70.png"] forState:UIControlStateNormal];
    [rateButton addTarget:self action:@selector(settings) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:rateButton];
    
    settingBG.hidden = YES;
    soundButton.hidden = YES;
    musicButton.hidden = YES;
    rateButton.hidden = YES;
    settingTransform = settingBG.transform;
    
    NSString* path = [[NSBundle mainBundle] pathForResource:@"cool-space-flight" ofType:@"mp3"];
    NSURL* file = [NSURL URLWithString:path];
    
    audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:file error:nil];
    audioPlayer.numberOfLoops = -1;
    [audioPlayer prepareToPlay];
    [audioPlayer play];
}

-(void)settings
{
    if (!isSetting) {
        
        isSetting = YES;
        settingBG.hidden = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            settingBG.transform = CGAffineTransformScale(settingTransform, 6.5, 6.5);
            
        }completion:^(BOOL finished) {
            
            soundButton.hidden = NO;
            musicButton.hidden = NO;
            rateButton.hidden = NO;
            
        }];
        
    } else {
        
        isSetting = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            
            settingBG.transform = settingTransform;
            soundButton.hidden = YES;
            musicButton.hidden = YES;
            rateButton.hidden = YES;
            
        }completion:^(BOOL finished) {
            
            settingBG.hidden = YES;
            
        }];
    }
}


#pragma mark - Game Over

-(void)gameOver
{
    gamePad.userInteractionEnabled = NO;
    [snake setGameoverImage];
    gameIsOver = YES;
}

#pragma mark - Move
-(void)swipeDirection:(UISwipeGestureRecognizer *)sender
{
    if (gamePad.userInteractionEnabled) {
                
        SnakeNode *head = [snake.snakeBody firstObject];
        [head.layer removeAllAnimations];
        
        gamePad.userInteractionEnabled = NO;
        
        MoveDirection dir;
        switch (sender.direction) {
            case UISwipeGestureRecognizerDirectionDown:
                dir = kMoveDirectionDown;
                break;
            case UISwipeGestureRecognizerDirectionUp:
                dir = kMoveDirectionUp;
                break;
            case UISwipeGestureRecognizerDirectionLeft:
                dir = kMoveDirectionLeft;
                break;
            case UISwipeGestureRecognizerDirectionRight:
                dir = kMoveDirectionRight;
                break;
        }
        
        [snake moveAllNodesBySwipe:dir complete:^{
            
            if (snake.combos == 0 ) {
                [snake createBody:^ {
                    [self actionsAfterMove];
                }];
            } else
                [self actionsAfterMove];
              
        }];
    }
}

- (void)actionsAfterMove
{
    totalCombos += snake.combos;
    combosToCreateBomb += snake.combos;
    snake.combos = 0;

    // Create Bomb
    if (combosToCreateBomb > 2) {
        
        combosToCreateBomb = 0;
        
        gamePad.userInteractionEnabled = NO;
        
        [gamePad createBombWithReminder:snake.reminder body:[snake snakeBody] complete:^{
            
            [snake cancelPattern:^{
                
                if([snake checkIsGameover])
                    [self gameOver];
                else
                    gamePad.userInteractionEnabled = YES;
                
            }];

        }];
    }
    else {
        
        gamePad.userInteractionEnabled = YES;
        if([snake checkIsGameover]) {
            [self gameOver];
        }
    }
}

- (BOOL)moveDirecton:(UISwipeGestureRecognizerDirection)swipeDirection
{
    MoveDirection headDirection = [snake headDirection];
    
    switch (headDirection) {
        case kMoveDirectionUp:
            if (swipeDirection == UISwipeGestureRecognizerDirectionDown)
                return NO;
            break;
        case kMoveDirectionDown:
            if (swipeDirection == UISwipeGestureRecognizerDirectionUp)
                return NO;
            break;
        case kMoveDirectionLeft:
            if (swipeDirection == UISwipeGestureRecognizerDirectionRight)
                return NO;
            break;
        case kMoveDirectionRight:
            if (swipeDirection == UISwipeGestureRecognizerDirectionLeft)
                return NO;
            break;
    }
    return YES;
}

#pragma mark - Replay

- (void)replayGame
{
    nextNode.hidden = NO;
    nextLabel.hidden = NO;
    gamePad.userInteractionEnabled = YES;
    scoreLabel.text = @"0";
    score = 0;
    totalCombos = 0;
    [snake resetSnake];
    [gamePad reset];
    gameIsOver = NO;
    [snake updateNextNode:nextNode animation:NO];
}

#pragma mark - Snake Delegate

-(void)showReplayView:(NSInteger)totalBombs
{
    GameStatsViewController *controller =  [[GameStatsViewController alloc]init];
    controller.bombs = totalBombs;
    controller.combos = totalCombos;
    controller.score = score;
    controller.gameImage = [self captureView:self.view];
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)updateScore:(NSInteger)s
{
    ScoreObject *so = [[ScoreObject alloc]initWithScore:s];
    [scoreArray addObject:so];
    
    if (!changeScoreTimer.isValid) {
        ScoreObject *scoreObject = [scoreArray firstObject];
        scoreGap = scoreObject.score;
        changeScoreTimer = [NSTimer scheduledTimerWithTimeInterval:scoreObject.interval target:self selector:@selector(changeScore) userInfo:nil repeats:YES];
    }
}

-(void)changeScore
{
    scoreGap--;
    score++;
    scoreLabel.text = [numFormatter stringFromNumber:[NSNumber numberWithInteger:score]];
    
    if (scoreGap == 0)
    {
        [changeScoreTimer invalidate];

        [scoreArray removeObjectAtIndex:0];
        
        if ([scoreArray count]>0) {
            ScoreObject *scoreObject = [scoreArray firstObject];
            scoreGap = scoreObject.score;
            changeScoreTimer = [NSTimer scheduledTimerWithTimeInterval:scoreObject.interval
                                                                target:self
                                                              selector:@selector(changeScore)
                                                              userInfo:nil
                                                               repeats:YES];
        }
    }
}
- (UIImage *)captureView:(UIView *)view
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
