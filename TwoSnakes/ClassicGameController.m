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
    BOOL gameIsOver;
    NSInteger scoreGap;
    NSMutableArray *scoreArray;
    MKAppDelegate *appDelegate;
    
    UIImage *screenShot;
    NSInteger maxBombChain;
    UIImageView *scanner;
    UIView *scannerMask;
    BOOL scanFromRight;
    NSTimeInterval scanTimeInterval;
    UIView *pauseView;
    
    // Buttons
    UIButton *pauseButton;
    UIButton *settingButton;
    UIButton *playButton;
    UIButton *homeButton;

    UIImageView *bgImageView;
    
    // Timers
    NSTimer *scanTimer;
    NSTimer *changeScoreTimer;
    
    NSDate *pauseStart, *previousFireDate;
    UIView *slider1 , *slider2;
    
    NSURL *currentSongURL;
    CGFloat sliderWidth;
    CGFloat sliderLength;
    
    BOOL controllerIsPresenting;
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

    self.view.backgroundColor = [UIColor colorWithWhite:0.063 alpha:1.000];
    
    // App delegate
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    // Play Mode
    _timeMode = NO;
    
    // BG image
    bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Background.png"]];
    [self.view addSubview:bgImageView];
    
    // Score number formatter
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    // -------------------- Setup game pad -------------------- //
    gamePad = [[GamePad alloc]initGamePad];
    gamePad.center = self.view.center;
    CGFloat nextNodePos = gamePad.frame.origin.y+gamePad.frame.size.height+25;
    
    if (screenHeight < 568 && IS_IPhone) {
        gamePad.frame = CGRectOffset(gamePad.frame, 0, 20);
        nextNodePos = gamePad.frame.origin.y+gamePad.frame.size.height+5;
    } else if (IS_IPad)
        nextNodePos = gamePad.frame.origin.y+gamePad.frame.size.height+25/0.6;
    
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

    // Size adjustment between IPhone and IPad
    CGFloat scoreLabelSize = 60;
    CGFloat scoreOffsetY = 105;
    CGFloat nextNodeSize = 40;
    CGFloat nextLabelWidth = 90;
    CGFloat nextLabelFontSize = 15;
    CGFloat levelLabelSize = 20;
    CGFloat levelLabelOffsetY = 40;
    CGFloat buttonSize = 30;
    sliderLength = 9;
    sliderWidth =3;
    if (IS_IPad) {
        nextNodeSize = nextNodeSize/IPadMiniRatio;
        nextLabelWidth = nextLabelWidth/IPadMiniRatio;
        nextLabelFontSize = (nextLabelFontSize-3)/IPadMiniRatio;
        levelLabelSize = (levelLabelSize-3)/IPadMiniRatio;
        levelLabelOffsetY =levelLabelOffsetY/IPadMiniRatio+10;
        buttonSize = buttonSize/IPadMiniRatio;
        scoreLabelSize = (scoreLabelSize-3)/IPadMiniRatio;
        scoreOffsetY = scoreOffsetY/IPadMiniRatio+10;
        sliderLength = sliderLength/IPadMiniRatio;
        sliderWidth = sliderWidth/IPadMiniRatio;
    }
    
    if (IS_IPhone && screenHeight > 568) {
        scoreOffsetY = scoreOffsetY * screenWidth/320;
        levelLabelOffsetY = levelLabelOffsetY * screenWidth/320;
        scoreLabelSize  = scoreLabelSize * screenWidth/320;
        levelLabelSize = levelLabelSize * screenWidth/320;
        nextNodePos = nextNodePos + 10;
        nextNodeSize = nextNodeSize * screenWidth/320;
        nextLabelFontSize = nextLabelFontSize * screenWidth/320;
        nextLabelWidth= nextLabelWidth * screenWidth/320;
    }
    
    // Score Label
    _scoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0,
                                                              gamePad.frame.origin.y-scoreOffsetY,
                                                              screenWidth,
                                                              scoreLabelSize)
                                          fontSize:scoreLabelSize];
    
    _scoreLabel.textColor = [UIColor whiteColor];
    _scoreLabel.text = @"0";
    [self.view addSubview:_scoreLabel];
    scoreArray = [[NSMutableArray alloc]init];

    // Setup player snake head
    snake = [[Snake alloc]initWithSnakeNode:gamePad.initialNode gamePad:gamePad];
    snake.delegate = self;
    [gamePad addSubview:snake];
    snake.particleView = _particleView;
    
    // Next Node
    nextNode = [[SnakeNode alloc]initWithFrame:CGRectMake((screenWidth-nextNodeSize)/2,nextNodePos,nextNodeSize,nextNodeSize)];
    snake.nextNode = nextNode;
    [snake updateNextNode:nextNode animation:YES];
    [self.view addSubview:nextNode];
    
    // Next Label
    CustomLabel *nextLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth-nextLabelWidth)/2,
                                                                          nextNode.frame.origin.y + nextNodeSize,
                                                                          nextLabelWidth,
                                                                          nextLabelFontSize)
                                                      fontSize:nextLabelFontSize];
    nextLabel.text = NSLocalizedString(@"Next", nil) ;
    [self.view addSubview:nextLabel];

    // Turn music
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"music"])
        [appDelegate.audioPlayer play];
    
    // Effects
    _levelLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth-150)/2,
                                                              gamePad.frame.origin.y-levelLabelOffsetY,
                                                              150,
                                                              levelLabelSize+5)
                                          fontSize:levelLabelSize];
    
    [self resetLevelLabel];
    [self.view addSubview:_levelLabel];
    
    
    // Chain Label
    CGFloat chainWidth = gamePad.frame.size.width;
    _chainLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth-chainWidth)/2,
                                                              180,
                                                              chainWidth,
                                                              scoreLabelSize/1.6)
                                          fontSize:scoreLabelSize/1.6];
    
    _chainLabel.hidden = YES;
    _chainLabel.center = self.view.center;
    [self.view addSubview:_chainLabel];
    
    // -------------- Scanner ----------------------------- //
    scannerMask = [[UIView alloc]initWithFrame:CGRectMake(gamePad.frame.origin.x,gamePad.frame.origin.y,sliderWidth,gamePad.frame.size.height)];
    scannerMask.backgroundColor = [UIColor colorWithRed:0.000 green:0.098 blue:0.185 alpha:0.400];
    scannerMask.alpha = 0;
    [self.view addSubview:scannerMask];

    // Slider holder
    slider1 = [[UIView alloc]initWithFrame:CGRectMake(gamePad.frame.origin.x-sliderWidth,gamePad.frame.origin.y-sliderLength,sliderLength,sliderLength)];
    slider1.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:slider1];
    slider1.alpha = 0;

    slider2 = [[UIView alloc]initWithFrame:CGRectMake(gamePad.frame.origin.x-sliderWidth,gamePad.frame.origin.y+gamePad.frame.size.height,sliderLength,sliderLength)];
    slider2.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:slider2];
    slider2.alpha = 0;
    
    scanner = [[UIImageView alloc]initWithFrame:CGRectMake(gamePad.frame.origin.x,gamePad.frame.origin.y,sliderWidth,gamePad.frame.size.height)];
    scanner.image = [UIImage imageNamed:@"scanner.png"];
    scanner.alpha = 0;
    [self.view addSubview:scanner];
    
    scanFromRight = YES;
    scanTimeInterval = 6;
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:scanTimeInterval target:self selector:@selector(scannerAnimation) userInfo:nil repeats:YES];
    
    // ------------------------------- Controll Buttons ---------------------------------------//
    // Home Button
    homeButton = [[UIButton alloc]initWithFrame:CGRectMake(10, screenHeight-(buttonSize+10), buttonSize, buttonSize)];
    [homeButton setImage:[UIImage imageNamed:@"home60.png"] forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(backToHome:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:homeButton];
    
    // Setting Button
    settingButton = [[UIButton alloc]initWithFrame:CGRectMake(buttonSize+20, screenHeight-(buttonSize+10), buttonSize, buttonSize)];
    [settingButton setImage:[UIImage imageNamed:@"setting60.png"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:settingButton];
    
    // Pause Button
    pauseButton = [[UIButton alloc]initWithFrame:CGRectMake(screenWidth-(buttonSize+10),screenHeight-(buttonSize+10), buttonSize, buttonSize)];
    [pauseButton setImage:[UIImage imageNamed:@"pauseButton60.png"] forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(pauseGamePress) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:pauseButton];
    
    // View when pause
    pauseView = [[UIView alloc]initWithFrame:self.view.frame];
    pauseView.frame = CGRectOffset(pauseView.frame, 0, - screenHeight);
    pauseView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.800];
    [self.view addSubview:pauseView];
    
    // Play Button
    playButton = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth-buttonSize*2)/2,
                                                           (screenHeight-buttonSize*2)/2-20,
                                                           buttonSize*2,
                                                           buttonSize*2)];
    
    [playButton setImage:[UIImage imageNamed:@"playButton120.png"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playGame) forControlEvents:UIControlEventTouchDown];
    [pauseView addSubview:playButton];
    
    CustomLabel *continueLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth-200)/2,
                                                                              (screenHeight-nextLabelFontSize*4)/2+nextLabelFontSize*4,
                                                                              200,
                                                                              nextLabelFontSize*2)
                                                          fontSize:nextLabelFontSize*2];
    
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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(resumeGameFromBackground) name:@"becomeActive" object:nil];
    
    _gameIsPaused = NO;
}

- (void)resetLevelLabel
{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"zh-Hans"])
        _levelLabel.text = @"第 1 关";
    else if ([language isEqualToString:@"zh-Hant"])
        _levelLabel.text = @"第 1 關";
    else if ([language isEqualToString:@"ja"])
        _levelLabel.text = @"ステージ 1 ";
    else
        _levelLabel.text = @"Stage 1";
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    pauseView.hidden = NO;
    controllerIsPresenting = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    controllerIsPresenting = NO;
}

#pragma mark - Effects

-(void)buttonAnimation:(UIButton *)button
{
    [_particleView playSound:kSoundTypeButtonSound];
    
    CGAffineTransform t = button.transform;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        button.transform = CGAffineTransformScale(t, 0.85, 0.85);
        
    } completion:^(BOOL finished) {
        
        button.transform = t;
    }];
}

-(void)showLevel:(NSInteger)level
{
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"zh-Hans"])
        _levelLabel.text = [NSString stringWithFormat:@"第 %ld 关",level];
    else if ([language isEqualToString:@"zh-Hant"])
        _levelLabel.text = [NSString stringWithFormat:@"第 %ld 關",level];
    else if ([language isEqualToString:@"ja"])
        _levelLabel.text = [NSString stringWithFormat:@"ステージ %ld",level];
    else
        _levelLabel.text = [NSString stringWithFormat:@"Stage %ld",level];
    
    _levelLabel.alpha = 0;

    [UIView animateWithDuration:2 animations:^{
        
        _levelLabel.alpha = 1;
        
    }];
}

-(void)showBombChain:(NSInteger)bombChain
{
    _chainLabel.text = [NSString stringWithFormat:@"%@ x %ld", NSLocalizedString(@"Chain", nil) ,bombChain];
    CGRect originalFrame = _chainLabel.frame;
    _chainLabel.hidden = NO;
    [UIView animateWithDuration:2.0 animations:^{
        _chainLabel.frame = CGRectOffset(_chainLabel.frame, 0, -40);
        _chainLabel.alpha = 0;
    } completion:^(BOOL finished) {
        _chainLabel.hidden = YES;
        _chainLabel.alpha = 1;
        _chainLabel.frame = originalFrame;
    }];
    
    [self updateScore:bombChain*250];
    
    if (bombChain > maxBombChain)
        maxBombChain = bombChain;
}

-(void)hideLevelLabel
{
    _levelLabel.hidden = YES;
}

-(void)showLevelLabel
{
    _levelLabel.hidden = NO;
    _levelLabel.text = NSLocalizedString( @"Score", nil);
}

-(void)hideScoreLabel
{
    _scoreLabel.hidden = YES;
}

-(void)showScoreLabel
{
    _scoreLabel.hidden = NO;
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

#pragma mark - Control Buttons

-(void)backToHome:(UIButton *)button
{
    [self buttonAnimation:button];
    
    currentSongURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"goodbye-dream" ofType:@"mp3"]];
    [self doVolumeFade];
    pauseView.hidden = YES;
    
    [scanTimer invalidate];
    [changeScoreTimer invalidate];
    
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

// Pause button Presssed
-(void)pauseGamePress
{
    [self buttonAnimation:pauseButton];
    [self pauseGame];
}

- (void)pauseGame
{
    [self.view bringSubviewToFront:pauseView];
    [self changeScoreWithoutAnimation];
    if(!_gameIsPaused) {
        _gameIsPaused = YES;
        gamePad.userInteractionEnabled = NO;
        [self pauseSlider];
        [UIView animateWithDuration:0.5 animations:^{
            
            pauseView.frame = CGRectOffset(pauseView.frame, 0, screenHeight);
            
        }];
    }
}

// Play button pressed
-(void)playGame
{
    [self buttonAnimation:playButton];
    [self continueGame];
}

-(void)continueGame
{
    [UIView animateWithDuration:0.5 animations:^{
        
        pauseView.frame = CGRectOffset(pauseView.frame, 0, -screenHeight);
        
    } completion:^(BOOL finished) {
        
        _gameIsPaused = NO;
        gamePad.userInteractionEnabled = YES;
        [self resumeSlider];
    }];
}

// Background or Setting button pressed
-(void)showSetting:(UIButton *)button
{
    [self buttonAnimation:button];
    [self pauseGameFromBackground];

    // Present setting view controller
    GameSettingViewController *controller =  [[GameSettingViewController alloc]init];
    controller.delegate = self;
    controller.bgImage = bgImageView.image;
    controller.particleView = _particleView;
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)continueGameFromSetting
{
    _gameIsPaused = NO;
    gamePad.userInteractionEnabled = YES;
    [self resumeSlider];
}

-(void)pauseGameFromBackground
{
    if (controllerIsPresenting) {
        NSLog(@"Enter BG");
        [self changeScoreWithoutAnimation];
        if (!_gameIsPaused) {
            _gameIsPaused = YES;
            gamePad.userInteractionEnabled = NO;
            [self pauseSlider];
        } else {
            pauseView.frame = CGRectOffset(pauseView.frame, 0, -screenHeight);
        }
    }
}

- (void)resumeGameFromBackground
{
    if (controllerIsPresenting) {
        NSLog(@"Resume from BG");
        _gameIsPaused = NO;
        gamePad.userInteractionEnabled = YES;
        [self resumeSlider];
    }
}

// Timer and Layers
-(void) pauseTimer:(NSTimer *)timer
{
    pauseStart = [NSDate date];
    [timer invalidate];
}

-(void) resumeTimer:(NSTimer *)timer
{
    NSTimeInterval remainTime = scanTimeInterval - [pauseStart timeIntervalSinceDate:previousFireDate]; // 2 seconds is scanning animation time
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:remainTime target:self selector:@selector(startScan) userInfo:nil repeats:NO];
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

#pragma mark - Scan

-(void)scannerAnimation
{
    previousFireDate = [NSDate date];
    // Show Scanner
    [UIView animateWithDuration:0.4 animations:^{
        
        scannerMask.alpha = 1;
        scanner.alpha = 1;
        slider1.alpha = 1;
        slider2.alpha = 1;
        
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
    [_particleView playSound:kSoundTypeScanSound];

    CGFloat xOffset = gamePad.frame.size.width - sliderWidth;
    [UIView animateWithDuration:0.8 animations:^{
        
        if (scanFromRight) {
            scanner.frame = CGRectOffset(scanner.frame, xOffset, 0);
            slider1.frame = CGRectOffset(slider1.frame, xOffset, 0);
            slider2.frame = CGRectOffset(slider2.frame, xOffset, 0);
            scannerMask.frame = CGRectMake(scannerMask.frame.origin.x,scannerMask.frame.origin.y,xOffset,gamePad.frame.size.height);
        } else {
            scanner.frame = CGRectOffset(scanner.frame, -xOffset, 0);
            slider1.frame = CGRectOffset(slider1.frame, -xOffset, 0);
            slider2.frame = CGRectOffset(slider2.frame, -xOffset, 0);
            scannerMask.frame = CGRectMake(scannerMask.frame.origin.x,scannerMask.frame.origin.y,-xOffset,gamePad.frame.size.height);
        }
        
    }completion:^(BOOL finished) {
        
        // Check block combos and bomb trigger
        [snake cancelPattern:^{
            if([snake checkIsGameover]) {
                _chainLabel.text = NSLocalizedString(@"No More Moves", nil) ;
                [self gameOver];
            }
            else {
                if (snake.combos == 0 ) {
                    // Reduce count check
                    for (SnakeNode *node in snake.snakeBody) {
                        if (node.hasCount)
                            [node reduceCount];
                    }
                    [snake createBody:^ {
                        [self actionsAfterMove];
                    }];
                } else {
                    
                    [self actionsAfterMove];
                }
            }
        }];
        [self hideScanner];
    }];
}

-(void)hideScanner
{
    CGFloat xOffset = gamePad.frame.size.height - sliderWidth;
    [UIView animateWithDuration:0.4 animations:^{
        
        scannerMask.alpha = 0;
        scanner.alpha = 0;
        slider1.alpha = 0;
        slider2.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        if (scanFromRight) {
            scannerMask.frame = CGRectOffset(scannerMask.frame, xOffset, 0);
            scannerMask.frame = CGRectMake(scannerMask.frame.origin.x,scannerMask.frame.origin.y,sliderWidth,gamePad.frame.size.height);
            scanFromRight = NO;
        } else {
            scannerMask.frame = CGRectMake(scannerMask.frame.origin.x,scannerMask.frame.origin.y,sliderWidth,gamePad.frame.size.height);
            scanFromRight = YES;
        }
    }];
}

-(void)startScan
{
    [self scannerAnimation];
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:scanTimeInterval target:self selector:@selector(scannerAnimation) userInfo:nil repeats:YES];
}

-(void)pauseSlider
{
    [self pauseTimer:scanTimer];
    [self pauseLayer:scanner.layer];
    [self pauseLayer:scannerMask.layer];
    [self pauseLayer:slider1.layer];
    [self pauseLayer:slider2.layer];
}

-(void)resumeSlider
{
    [self resumeLayer:scanner.layer];
    [self resumeLayer:scannerMask.layer];
    [self resumeLayer:slider1.layer];
    [self resumeLayer:slider2.layer];
    [self resumeTimer:scanTimer];
}

#pragma mark - Move

-(void)swipeDirection:(UISwipeGestureRecognizer *)sender
{
    if (gamePad.userInteractionEnabled && ![snake checkIsGameover]) {
        
        [_particleView playSound:kSoundTypeMoveSound];
        
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
            
            // Reduce count check
            for (SnakeNode *node in snake.snakeBody) {
                if (node.hasCount)
                    [node reduceCount];
            }

            [snake createBody:^ {
                // Do nothing
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
    
    // Determine play mode
    controller.timeMode = _timeMode;
    if (_timeMode)
        controller.leaderboardID = kFastHandHighScoreLeaderboardId;
    else
        controller.leaderboardID = kHighScoreLeaderboardId;
    
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
    _scoreLabel.text = [numFormatter stringFromNumber:[NSNumber numberWithInteger:score]];
    
    if (scoreGap == 0) {
        [changeScoreTimer invalidate];
        [scoreArray removeObjectAtIndex:0];
        
        if ([scoreArray count]>0) {
            ScoreObject *scoreObject = [scoreArray firstObject];
            scoreGap = scoreObject.score;
            changeScoreTimer = [NSTimer scheduledTimerWithTimeInterval:scoreObject.interval target:self selector:@selector(changeScore) userInfo:nil repeats:YES];
        }
    }
}

-(void)changeScoreWithoutAnimation
{
    [changeScoreTimer invalidate];
    score += scoreGap;
    for (ScoreObject *so in scoreArray) {
        score += so.score;
    }
    _scoreLabel.text = [numFormatter stringFromNumber:[NSNumber numberWithInteger:score]];
    [scoreArray removeAllObjects];
}

- (UIImage *)captureView:(UIView *)view
{
    settingButton.hidden = YES;
    homeButton.hidden = YES;
    pauseButton.hidden = YES;
    gamePad.backgroundColor = [UIColor blackColor];
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:context];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    settingButton.hidden = NO;
    homeButton.hidden = NO;
    pauseButton.hidden = NO;
    gamePad.backgroundColor = [UIColor clearColor];

    return img;
}

-(void)updateScanTimeInterval
{
    [scanTimer invalidate];
    scanTimeInterval -= 0.5;
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:scanTimeInterval target:self selector:@selector(scannerAnimation) userInfo:nil repeats:YES];
}

#pragma mark - Sound & Music

-(void)doVolumeFade
{
    if (appDelegate.audioPlayer.volume > 0.1) {
        
        appDelegate.audioPlayer.volume -=  0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.2];
        
    } else {
        // Stop and get the sound ready for playing again
        [appDelegate.audioPlayer stop];
        appDelegate.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:currentSongURL error:nil];
        appDelegate.audioPlayer.numberOfLoops = -1;
        [appDelegate.audioPlayer prepareToPlay];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"music"]) {
            [appDelegate.audioPlayer play];
            appDelegate.audioPlayer.volume = 0;
            [self volumeFadeIn];
        }
    }
}

- (void)volumeFadeIn
{
    if (appDelegate.audioPlayer.volume < 1) {
        
        appDelegate.audioPlayer.volume +=  0.1;
        [self performSelector:@selector(volumeFadeIn) withObject:nil afterDelay:0.2];
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
    gameIsOver = YES;
    
    // Stop music
    [appDelegate.audioPlayer stop];
    [_particleView playSound:kSoundTypeGameoverSound];
    
    // Stop timer
    [scanTimer invalidate];
    [changeScoreTimer invalidate];

    // Update score to latest
    [self changeScoreWithoutAnimation];
    
    // Take game screen shot
    screenShot = [self captureView:self.view];

    // Trigger Game Over Image and push to stat view controller
    [snake setGameoverImage];
    
    // Show Game Over message
    _chainLabel.hidden = NO;
    [UIView animateWithDuration:3.0 animations:^{
        
        _chainLabel.alpha = 0;
        
    } completion:^(BOOL finished) {
        
        _chainLabel.hidden = YES;
        _chainLabel.alpha = 1;
        
    }];
}

#pragma mark - Replay

- (void)replayGame
{
    // Reset labels
    [self resetLevelLabel];
    _scoreLabel.text = @"0";
    
    // Reset Stats
    gamePad.userInteractionEnabled = YES;
    score = 0;
    totalCombos = 0;
    gameIsOver = NO;

    // Reset Snake
    [snake resetSnake];
    [snake updateNextNode:nextNode animation:NO];

    // Rest Gamepad
    [gamePad reset];
    nextNode.hidden = NO;

    // Reset scanner
    scannerMask.frame =CGRectMake(gamePad.frame.origin.x,gamePad.frame.origin.y,sliderWidth,gamePad.frame.size.height);
    slider1.frame = CGRectMake(gamePad.frame.origin.x-sliderWidth,gamePad.frame.origin.y-sliderLength,sliderLength,sliderLength);
    slider2.frame = CGRectMake(gamePad.frame.origin.x-sliderWidth,gamePad.frame.origin.y+gamePad.frame.size.height,sliderLength,sliderLength);
    scanner.frame = CGRectMake(gamePad.frame.origin.x,gamePad.frame.origin.y,sliderWidth,gamePad.frame.size.height);
    
    scannerMask.alpha = 0;
    slider1.alpha = 0;
    slider2.alpha = 0;
    scanner.alpha =0;
    
    scanFromRight = YES;
    scanTimeInterval = 6;
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:scanTimeInterval target:self selector:@selector(scannerAnimation) userInfo:nil repeats:YES];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    [_particleView removeAllChildren];
    [_particleView removeAllActions];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
