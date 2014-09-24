//
//  ClassicGameController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "ClassicGameController.h"
#import "GameStatsViewController.h"
#import "MenuController.h"
#import "GameAsset.h"
#import "ParticleView.h"
#import "GamePad.h"
#import "Snake.h"
#import "CustomLabel.h"
#import "ScoreObject.h"
#import <AVFoundation/AVFoundation.h>
#import <StoreKit/StoreKit.h>
#import "Reachability.h"
#import "MKAppDelegate.h"
#import "GameSettingViewController.h"

@interface ClassicGameController () <gameoverDelegate,replayDelegate,SKStoreProductViewControllerDelegate,continueDelegate>
{
    NSNumberFormatter *numFormatter; //Formatter for score
    NSInteger score;
    SnakeNode *nextNode;
    GamePad *gamePad;
    Snake *snake;
    NSInteger totalCombos;
    NSInteger combosToCreateBomb;
    BOOL swap;
    CustomLabel *scoreLabel;
    BOOL gameIsOver;
    NSInteger scoreGap;
    NSMutableArray *scoreArray;
    UIButton *settingButton;
    MKAppDelegate *appDelegate;
    UIView *tutorial1BG;
    UIView *tutorial2BG;
    UIView *tutorial3BG;
    UIView *tutorial4BG;
    NSInteger tutorialMode;
    UIImage *screenShot;
    CustomLabel *levelLabel;
    CustomLabel *chainLabel;
    NSInteger maxBombChain;
    UIImageView *scanner;
    UIView *scannerMask;
    BOOL scanFromRight;
    NSTimeInterval scanTimeInterval;
    UIButton *pauseButton;
    UIView *pauseView;
    UIButton *playButton;
    UIImageView *bgImageView;
    UIButton *homeButton;
    
    NSTimer *scanTimer;
    NSTimer *changeScoreTimer;
    
    // Tutorial
    CGFloat tutorialViewHeight;
    CGRect tutorialFrame;
    CGRect tutorialLabelFrame;
    NSInteger tutorialFontSize;
    CGFloat tutorialLabelOffset;
    
    NSDate *pauseStart, *previousFireDate;
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
    
    // BG image
    bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Background.png"]];
    [self.view addSubview:bgImageView];
    
    // Do any additional setup after loading the view.
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    // -------------------- Setup game pad -------------------- //
    gamePad = [[GamePad alloc]initGamePad];
    gamePad.center = self.view.center;
    CGFloat nextNodePos = gamePad.frame.origin.y+gamePad.frame.size.height+25;
    
    if (screenHeight < 568) {
        gamePad.frame = CGRectOffset(gamePad.frame, 0, 20);
        nextNodePos = gamePad.frame.origin.y+gamePad.frame.size.height+5;
    }
    
    // -------------------- Setup particle views -------------------- //
    // Configure the SKView
    SKView * skView = [[SKView alloc]initWithFrame:CGRectMake(0, 0, gamePad.frame.size.width, gamePad.frame.size.height)];
    skView.backgroundColor = [UIColor clearColor];
    
    // Create and configure the scene.
    _particleView = [[ParticleView alloc]initWithSize:skView.bounds.size];
    _particleView.scaleMode = SKSceneScaleModeAspectFill;
    [gamePad addSubview:skView];
    [gamePad sendSubviewToBack:skView];

    // Present the scene.
    [skView presentScene:_particleView];
    [self.view addSubview:gamePad];
    
    // Count down
    scoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth - 250)/2,  gamePad.frame.origin.y-105 , 250, 60) fontSize:60];
    scoreLabel.textColor = [UIColor whiteColor];
    scoreLabel.text = @"0";
    [self.view addSubview:scoreLabel];
    
    // Setup player snake head
    snake = [[Snake alloc]initWithSnakeNode:gamePad.initialNode gamePad:gamePad];
    snake.delegate = self;
    [gamePad addSubview:snake];
    snake.particleView = _particleView;
    
    // Next Node
    CGFloat nextNodeSize = 40;
    nextNode = [[SnakeNode alloc]initWithFrame:CGRectMake((320-nextNodeSize)/2, nextNodePos , nextNodeSize, nextNodeSize)];
    snake.nextNode = nextNode;
    [snake updateNextNode:nextNode animation:YES];
    [self.view addSubview:nextNode];
    
    CustomLabel *nextLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth-60)/2, nextNode.frame.origin.y + nextNodeSize, 60, 15) fontSize:15];
    nextLabel.text = NSLocalizedString(@"Next", nil) ;
    [self.view addSubview:nextLabel];

    scoreArray = [[NSMutableArray alloc]init];

    // App delegate
    appDelegate = [[UIApplication sharedApplication] delegate];

    // Turn music
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"music"])
        [appDelegate.audioPlayer play];
    
    // Effects
    levelLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth-150)/2, gamePad.frame.origin.y-35, 150,20) fontSize:20];
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"zh-Hans"])
        levelLabel.text = @"第 1 关";
    else if ([language isEqualToString:@"zh-Hant"])
        levelLabel.text = @"第 1 關";
    else
        levelLabel.text = @"Stage 1";

    [self.view addSubview:levelLabel];
    
    chainLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth-300)/2, 180, 300,40) fontSize:40];
    chainLabel.hidden = YES;
    chainLabel.center = self.view.center;
    [self.view addSubview:chainLabel];
    
    // Scanner
    scannerMask = [[UIView alloc]initWithFrame:CGRectMake(gamePad.frame.origin.x,gamePad.frame.origin.y,3,gamePad.frame.size.height)];
    scannerMask.backgroundColor = [UIColor colorWithRed:0.000 green:0.098 blue:0.185 alpha:0.400];
    scannerMask.alpha = 0;
    [self.view addSubview:scannerMask];

    scanner = [[UIImageView alloc]initWithFrame:CGRectMake(gamePad.frame.origin.x-3,gamePad.frame.origin.y-8.5,9,gamePad.frame.size.height+17)];
    scanner.image = [UIImage imageNamed:@"scanner331.png"];
    scanner.alpha = 0;
    [self.view addSubview:scanner];
    
    scanFromRight = YES;
    scanTimeInterval = 6;
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:scanTimeInterval target:self selector:@selector(scannerAnimation) userInfo:nil repeats:YES];
    
    // Setting Button
    settingButton = [[UIButton alloc]initWithFrame:CGRectMake(45, screenHeight-35, 30, 30)];
    [settingButton setImage:[UIImage imageNamed:@"setting60.png"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:settingButton];
    
    // Home Button
    homeButton = [[UIButton alloc]initWithFrame:CGRectMake(5, screenHeight-35, 30, 30)];
    [homeButton setImage:[UIImage imageNamed:@"home60.png"] forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(backToHome:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:homeButton];
    
    // Pause Button
    pauseButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-35,screenHeight-35, 30, 30)];
    [pauseButton setImage:[UIImage imageNamed:@"pauseButton60.png"] forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(pauseGame) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:pauseButton];
    
    pauseView = [[UIView alloc]initWithFrame:self.view.frame];
    pauseView.frame = CGRectOffset(pauseView.frame, 0, - screenHeight);
    pauseView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.800];
    [self.view addSubview:pauseView];
    
    playButton = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth-60)/2,(screenHeight-60)/2-20, 60, 60)];
    [playButton setImage:[UIImage imageNamed:@"playButton120.png"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playGame) forControlEvents:UIControlEventTouchDown];
    [pauseView addSubview:playButton];
    
    CustomLabel *continueLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(60, (screenHeight-60)/2+60, 200, 30) fontSize:30];
    continueLabel.text = NSLocalizedString(@"Continue", nil);
    [pauseView addSubview:continueLabel];
    
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
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pauseGameFromBackground) name:@"resignActive" object:nil];
    
    _gameIsPaused = NO;
    
    // Tutorial
    tutorialFontSize = 20;
    tutorialViewHeight = gamePad.frame.origin.y-10;
    tutorialFrame = CGRectMake(0,
                               -tutorialViewHeight,
                               screenWidth ,
                               tutorialViewHeight);
    tutorialLabelOffset = 5;
    tutorialLabelFrame = CGRectMake(0,tutorialLabelOffset,screenWidth,tutorialFontSize+5);
    tutorialMode = [[NSUserDefaults standardUserDefaults]integerForKey:@"tutorial"];
    if (tutorialMode == 1)
        [self showTutorial1];
}

-(void)viewWillAppear:(BOOL)animated
{
    pauseView.hidden = NO;
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

#pragma mark - Effects
-(void)showLevel:(NSInteger)level
{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"zh-Hans"])
        levelLabel.text = [NSString stringWithFormat:@"第 %ld 关",level];
    else if ([language isEqualToString:@"zh-Hant"])
        levelLabel.text = [NSString stringWithFormat:@"第 %ld 關",level];
    else
        levelLabel.text = [NSString stringWithFormat:@"Stage %ld",level];
    
    levelLabel.alpha = 0;

    [UIView animateWithDuration:2 animations:^{
        
        levelLabel.alpha = 1;
        
    }];
}

-(void)showBombChain:(NSInteger)bombChain
{
    chainLabel.text = [NSString stringWithFormat:@"%@ x %ld", NSLocalizedString(@"Chain", nil) ,bombChain];
    CGRect originalFrame = chainLabel.frame;
    chainLabel.hidden = NO;
    [UIView animateWithDuration:2.0 animations:^{
        chainLabel.frame = CGRectOffset(chainLabel.frame, 0, -40);
        chainLabel.alpha = 0;
    } completion:^(BOOL finished) {
        chainLabel.hidden = YES;
        chainLabel.alpha = 1;
        chainLabel.frame = originalFrame;
    }];
    
    [self updateScore:bombChain*250];
    
    if (bombChain > maxBombChain)
        maxBombChain = bombChain;
}

-(void)hideLevelLabel
{
    levelLabel.hidden = YES;
}

-(void)hideScoreLabel
{
    scoreLabel.hidden = YES;
}

-(void)disableLevelCheck
{
    snake.checkLevel = NO;
    snake.reminder = 4;
}

-(void)setScanSpeed:(NSTimeInterval)interval
{
    [scanTimer invalidate];
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:interval target:self selector:@selector(scannerAnimation) userInfo:nil repeats:YES];
    scanTimeInterval = interval;
}

-(void)setBgImage:(UIImage *)image
{
    bgImageView.image = image;
}

#pragma mark - Controls

-(void)continueGame
{
    _gameIsPaused = NO;
    gamePad.userInteractionEnabled = YES;
    [self resumeLayer:scanner.layer];
    [self resumeLayer:scannerMask.layer];
    [self resumeTimer:scanTimer];
}

-(void)pauseGame
{
    if(_gameIsPaused) {
        _gameIsPaused = NO;
    } else {
        _gameIsPaused = YES;
        
        [self buttonAnimation:pauseButton];
        gamePad.userInteractionEnabled = NO;
        [self pauseTimer:scanTimer];
        [self pauseLayer:scanner.layer];
        [self pauseLayer:scannerMask.layer];
        
        [UIView animateWithDuration:0.5 animations:^{
            
            pauseView.frame = CGRectOffset(pauseView.frame, 0, screenHeight);
            
        }];
    }
}

-(void)pauseGameFromBackground
{
    if (!_gameIsPaused) {
        _gameIsPaused = YES;
        gamePad.userInteractionEnabled = NO;
        [self pauseTimer:scanTimer];
        [self pauseLayer:scanner.layer];
        [self pauseLayer:scannerMask.layer];
        pauseView.frame = CGRectOffset(pauseView.frame, 0, screenHeight);
    }
}

-(void)playGame
{
    _gameIsPaused = NO;
    [self buttonAnimation:pauseButton];
    [UIView animateWithDuration:0.5 animations:^{
        pauseView.frame = CGRectOffset(pauseView.frame, 0, -screenHeight);
    } completion:^(BOOL finished) {
        gamePad.userInteractionEnabled = YES;
        [self resumeLayer:scanner.layer];
        [self resumeLayer:scannerMask.layer];
        [self resumeTimer:scanTimer];
    }];
}

-(void)startScan
{
    [self scannerAnimation];
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:scanTimeInterval target:self selector:@selector(scannerAnimation) userInfo:nil repeats:YES];
}

-(void) pauseTimer:(NSTimer *)timer
{
    pauseStart = [NSDate date];
    previousFireDate = [timer fireDate];
    [timer invalidate];
}

-(void) resumeTimer:(NSTimer *)timer
{
    NSTimeInterval pauseTime = scanTimeInterval + [pauseStart timeIntervalSinceDate:previousFireDate];
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:pauseTime target:self selector:@selector(startScan) userInfo:nil repeats:NO];
}

-(void)showSetting:(UIButton *)button
{
    pauseView.hidden = YES;
    if(_gameIsPaused) {
        _gameIsPaused = NO;
    } else {
        _gameIsPaused = YES;
        gamePad.userInteractionEnabled = NO;
        [self pauseTimer:scanTimer];
        [self pauseLayer:scanner.layer];
        [self pauseLayer:scannerMask.layer];
    }
    [self buttonAnimation:button];
    GameSettingViewController *controller =  [[GameSettingViewController alloc]init];
    controller.delegate = self;
    controller.bgImage = bgImageView.image;
    controller.particleView = _particleView;
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)backToHome:(UIButton *)button
{
    [self buttonAnimation:button];
    pauseView.hidden = YES;
    [scanTimer invalidate];
    [changeScoreTimer invalidate];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)buttonAnimation:(UIButton *)button
{
    [_particleView playButtonSound];
    CGAffineTransform t = button.transform;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        button.transform = CGAffineTransformScale(t, 0.85, 0.85);
        
    } completion:^(BOOL finished) {
        
        button.transform = t;
    }];
}

#pragma mark - Scan

-(void)scannerAnimation
{
    // Show Scanner
    [UIView animateWithDuration:0.5 animations:^{
        
        scannerMask.alpha = 1;
        scanner.alpha = 1;

    } completion:^(BOOL finished) {
        
        [_particleView removeAllChildren];
        [_particleView removeAllActions];
        [self performScanning];
        gamePad.userInteractionEnabled = NO;

    }];
}

-(void)performScanning
{
    // Scanning animation
    [_particleView scanSound];
    CGFloat xOffset = gamePad.frame.size.height - 3;
    [UIView animateWithDuration:1 animations:^{
        
        if (scanFromRight) {
            scanner.frame = CGRectOffset(scanner.frame, xOffset, 0);
            scannerMask.frame = CGRectMake(scannerMask.frame.origin.x,
                                           scannerMask.frame.origin.y,
                                           xOffset,
                                           gamePad.frame.size.height);
        } else {
            scanner.frame = CGRectOffset(scanner.frame, -xOffset, 0);
            scannerMask.frame = CGRectMake(scannerMask.frame.origin.x,
                                           scannerMask.frame.origin.y,
                                           -xOffset,
                                           gamePad.frame.size.height);
        }
        
    }completion:^(BOOL finished) {
        
        // Check block combos and bomb trigger
        [snake cancelPattern:^{
            
            if([snake checkIsGameover])
                [self gameOver];
            else {
                if (snake.combos == 0 ) {
                    
                    [snake createBody:^ {
                        
                        [self actionsAfterMove];
                        
                    }];
                    
                } else {
                    
                    if (tutorialMode==2)
                        [self showTutorial3];
                    
                    [self actionsAfterMove];
                    
                }
            }
        }];
        
        // Hide Scanner
        [self hideScanner];
    }];

}

-(void)hideScanner
{
    CGFloat xOffset = gamePad.frame.size.height - 3;

    [UIView animateWithDuration:0.5 animations:^{
        
        scannerMask.alpha = 0;
        scanner.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        if (scanFromRight) {
            scannerMask.frame = CGRectOffset(scannerMask.frame, xOffset, 0);
            scannerMask.frame = CGRectMake(scannerMask.frame.origin.x,
                                           scannerMask.frame.origin.y,
                                           3,
                                           gamePad.frame.size.height);
            scanFromRight = NO;
        } else {
            scannerMask.frame = CGRectMake(scannerMask.frame.origin.x,
                                           scannerMask.frame.origin.y,
                                           3,
                                           gamePad.frame.size.height);
            scanFromRight = YES;
        }
    }];
}

#pragma mark - Move

-(void)swipeDirection:(UISwipeGestureRecognizer *)sender
{
    if (gamePad.userInteractionEnabled && ![snake checkIsGameover]) {
        
        if (tutorialMode==1)
            [self showTutorial2];
        
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
        
        [_particleView playMoveSound];

        [snake moveAllNodesBySwipe:dir complete:^{
            
            // Reduce count check
            for (SnakeNode *node in snake.snakeBody) {
                if (node.hasCount)
                    [node reduceCount];
            }

            [snake createBody:^ {
                
            }];
        }];
    }
}

- (void)actionsAfterMove
{
    totalCombos += snake.combos;
    combosToCreateBomb += snake.combos;
    snake.combos = 0;
    
    // Create Bomb
    if (combosToCreateBomb > 3) {

        combosToCreateBomb = 0;
        [gamePad createBombWithReminder:snake.reminder body:[snake snakeBody] complete:^{
            
            gamePad.userInteractionEnabled = YES;
            
            if (tutorialMode==3)
                [self showTutorial4];

        }];
    }
    else
        gamePad.userInteractionEnabled = YES;

}

#pragma mark - Snake Delegate

-(void)showReplayView:(NSInteger)totalBombs
{
    GameStatsViewController *controller =  [[GameStatsViewController alloc]init];
    controller.bombs = totalBombs;
    controller.combos = totalCombos;
    controller.score = score;
    controller.level = snake.reminder - 2;
    controller.gameImage = screenShot;
    controller.delegate = self;
    controller.maxBombChain = maxBombChain;
    controller.bgImage = bgImageView.image;
    controller.particleView = _particleView;
    
    if (levelLabel.hidden)
        controller.timeMode = YES;
    else
        controller.timeMode = NO;
    
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
    settingButton.hidden = YES;
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    settingButton.hidden = NO;
    return img;
}

-(void)updateScanTimeInterval
{
    [scanTimer invalidate];
    scanTimeInterval -= 0.5;
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:scanTimeInterval target:self selector:@selector(scannerAnimation) userInfo:nil repeats:YES];
}

#pragma mark - Tutorial

-(void)startTutorial
{
    [self replayGame];
    tutorialMode = 1;
    [self showTutorial1];
}

 -(void)showTutorial1
{
    tutorial1BG = [[UIView alloc]initWithFrame:tutorialFrame];
    
    tutorial1BG.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tutorial1BG];
    
    scoreLabel.hidden = YES;
    levelLabel.hidden = YES;
    
    // 1. Swipe
    CustomLabel *swipeText = [[CustomLabel alloc]initWithFrame:tutorialLabelFrame
                                                      fontSize:tutorialFontSize];
    swipeText.text = NSLocalizedString(@"Swipe to move blocks" , nil);
    [tutorial1BG addSubview:swipeText];
    
    CGFloat swipeImageSize = tutorialViewHeight - (tutorialFontSize+tutorialLabelOffset+5);
    UIImageView *swipe = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth-swipeImageSize)/2,
                                                                       tutorialFontSize+tutorialLabelOffset+5,
                                                                       swipeImageSize,
                                                                       swipeImageSize)];
    swipe.image = [UIImage imageNamed:@"tutorialSwipe140.png"];
    [tutorial1BG addSubview:swipe];
    
    [self showTutorial:tutorial1BG];
}

-(void)showTutorial2
{
    tutorialMode++;
    [self hideTutorial:tutorial1BG complete:^{
        
        tutorial2BG = [[UIView alloc]initWithFrame:tutorialFrame];
        tutorial2BG.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tutorial2BG];
        
        // 2. Combo
        CustomLabel *tutComboText = [[CustomLabel alloc]initWithFrame:tutorialLabelFrame
                                                             fontSize:tutorialFontSize];
        tutComboText.text =  NSLocalizedString(@"Line up blocks to cancel blocks" , nil);
        [tutorial2BG addSubview:tutComboText];
        
        CGFloat imageSize = tutorialViewHeight - (tutorialFontSize+tutorialLabelOffset+5);

        UIImageView *tutorialCombo = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth-(320*(imageSize/70)))/2, tutorialFontSize+tutorialLabelOffset+5, 320*(imageSize/70), imageSize)];
        tutorialCombo.image = [UIImage imageNamed:@"tutorialCombo140.png"];
        [tutorial2BG addSubview:tutorialCombo];
        
        [self showTutorial:tutorial2BG];

    }];
}

-(void)showTutorial3
{
    tutorialMode++;
    [self hideTutorial:tutorial2BG complete:^{
        
        tutorial3BG = [[UIView alloc]initWithFrame:tutorialFrame];
        tutorial3BG.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tutorial3BG];
        
        // 3. Bomb
        CustomLabel *tutBombText = [[CustomLabel alloc]initWithFrame:tutorialLabelFrame
                                                            fontSize:tutorialFontSize];
        tutBombText.text =  NSLocalizedString(@"Cancel more blocks to pop bombs" , nil);
        [tutorial3BG addSubview:tutBombText];
        
        CGFloat imageSize = tutorialViewHeight - (tutorialFontSize+tutorialLabelOffset+5);
        
        UIImageView *tutorialBomb = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth-(320*(imageSize/70)))/2, tutorialFontSize+tutorialLabelOffset+5, 320*(imageSize/70), imageSize)];

        tutorialBomb.image = [UIImage imageNamed:@"tutorialCreateBomb140.png"];
        [tutorial3BG addSubview:tutorialBomb];
        
        [self showTutorial:tutorial3BG];
        
    }];
}

-(void)showTutorial4
{
    tutorialMode++;
    [self hideTutorial:tutorial3BG complete:^{
        
        tutorial4BG = [[UIView alloc]initWithFrame:tutorialFrame];
        tutorial4BG.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tutorial4BG];
        
        // 3. Bomb
        CustomLabel *tutBombText = [[CustomLabel alloc]initWithFrame:tutorialLabelFrame
                                                            fontSize:tutorialFontSize];
        tutBombText.text =  NSLocalizedString(@"Line up with blocks to trigger bomb" , nil);
        [tutorial4BG addSubview:tutBombText];
        
        CGFloat imageSize = tutorialViewHeight - (tutorialFontSize+tutorialLabelOffset+5);
        
        UIImageView *tutorialBomb = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth-(320*(imageSize/70)))/2, tutorialFontSize+tutorialLabelOffset+5, 320*(imageSize/70), imageSize)];
        tutorialBomb.image = [UIImage imageNamed:@"tutorialBomb140.png"];
        [tutorial4BG addSubview:tutorialBomb];
        
        [self showTutorial:tutorial4BG];
        
    }];
}

-(void)hideTutorial:(UIView *)tutorialView  complete:(void(^)(void))completeBlock
{
    [UIView animateWithDuration:0.5 animations:^{
        
        tutorialView.frame = CGRectOffset(tutorialView.frame, 0, -tutorialViewHeight);
        
    }completion:^(BOOL finished) {

        [tutorialView removeFromSuperview];
        completeBlock();
    } ];
}

-(void)showTutorial:(UIView *)tutorialView
{
    [UIView animateWithDuration:0.5 animations:^{
        
        tutorialView.frame = CGRectOffset(tutorialView.frame, 0, tutorialViewHeight);
        
    }];
}

- (void)hideLastTutorial
{
    if (tutorialMode == 4) {
        
        [self hideTutorial:tutorial4BG complete:^{
            
            scoreLabel.hidden = NO;
            levelLabel.hidden = NO;
            
            CGAffineTransform t =  scoreLabel.transform;
            CGAffineTransform t2 =  levelLabel.transform;

            scoreLabel.transform = CGAffineTransformScale(t, 0.1, 0.1);
            levelLabel.transform = CGAffineTransformScale(t2, 0.1, 0.1);

            [UIView animateWithDuration:0.2 animations:^{
                
                scoreLabel.transform = CGAffineTransformScale(t, 1.2, 1.2);
                levelLabel.transform = CGAffineTransformScale(t2, 1.2, 1.2);
                
            }completion:^(BOOL finished) {
                
                scoreLabel.transform = t;
                levelLabel.transform = t2;

                tutorialMode = 0;
                
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"tutorial"];

            }];
            
        }];
    }
}

- (void)stopMusic
{
    [appDelegate.audioPlayer stop];
}

#pragma mark - Game Over

-(void)gameOver
{
    gamePad.userInteractionEnabled = NO;
    [scanTimer invalidate];
    [changeScoreTimer invalidate];
    screenShot = [self captureView:self.view];
    [snake setGameoverImage];
    gameIsOver = YES;
    
    [appDelegate.audioPlayer stop];
    
    [_particleView playGameoverSound];
    
    chainLabel.text = @"Game Over";
    chainLabel.hidden = NO;
    [UIView animateWithDuration:3.0 animations:^{
        chainLabel.alpha = 0;
    } completion:^(BOOL finished) {
        chainLabel.hidden = YES;
        chainLabel.alpha = 1;
    }];
}

#pragma mark - Replay

- (void)replayGame
{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"zh-Hans"])
        levelLabel.text = @"第 1 关";
    else if ([language isEqualToString:@"zh-Hant"])
        levelLabel.text = @"第 1 關";
    else
        levelLabel.text = @"Stage 1";
    nextNode.hidden = NO;
    gamePad.userInteractionEnabled = YES;
    scoreLabel.text = @"0";
    score = 0;
    totalCombos = 0;
    [snake resetSnake];
    [gamePad reset];
    gameIsOver = NO;
    [snake updateNextNode:nextNode animation:NO];
    scanTimeInterval = 6;
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:scanTimeInterval target:self selector:@selector(scannerAnimation) userInfo:nil repeats:YES];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_particleView removeAllChildren];
    [_particleView removeAllActions];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
