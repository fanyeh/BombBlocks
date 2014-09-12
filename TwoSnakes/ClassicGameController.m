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

@interface ClassicGameController () <gameoverDelegate,replayDelegate,SKStoreProductViewControllerDelegate>
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
    NSTimer *changeScoreTimer;
    NSMutableArray *scoreArray;
    ParticleView *particle;
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
    NSTimer *scanTimer;
    BOOL scanFromRight;
    NSTimeInterval scanTimeInterval;
    UIButton *pauseButton;
    UIView *pauseView;

    UIButton *playButton;


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
    scoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 250)/2, 15 , 250, 65) fontSize:65];
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
    nextNode = [[SnakeNode alloc]initWithFrame:CGRectMake((320-nextNodeSize)/2, self.view.frame.size.height - 100 , nextNodeSize, nextNodeSize)];
    snake.nextNode = nextNode;
    [snake updateNextNode:nextNode animation:YES];

    scoreArray = [[NSMutableArray alloc]init];

    // App delegate
    appDelegate = [[UIApplication sharedApplication] delegate];

    // Turn music
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"music"])
        [appDelegate.audioPlayer play];
    
    tutorialMode = [[NSUserDefaults standardUserDefaults]integerForKey:@"tutorial"];
    if (tutorialMode == 1)
        [self showTutorial1];
    
    // Effects
    levelLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((320-150)/2, 88.5, 150,30) fontSize:30];
    levelLabel.alpha = 0;
    [self.view addSubview:levelLabel];
    
    chainLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((320-300)/2, 180, 300,40) fontSize:40];
    chainLabel.hidden = YES;
    chainLabel.center = self.view.center;
    [self.view addSubview:chainLabel];
    
    // Scanner
    scannerMask = [[UIView alloc]initWithFrame:CGRectMake(gamePad.frame.origin.x,gamePad.frame.origin.y,3,314)];
    scannerMask.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
    scannerMask.alpha = 0;
    [self.view addSubview:scannerMask];

    scanner = [[UIImageView alloc]initWithFrame:CGRectMake(gamePad.frame.origin.x-3,gamePad.frame.origin.y-17.5,9,349)];
    scanner.image = [UIImage imageNamed:@"scanner.png"];
    scanner.alpha = 0;
    [self.view addSubview:scanner];
    
    scanFromRight = YES;
    scanTimeInterval = 6;
    scanTimer = [NSTimer scheduledTimerWithTimeInterval:scanTimeInterval target:self selector:@selector(scannerAnimation) userInfo:nil repeats:YES];
    
    // Setting Button
    settingButton = [[UIButton alloc]initWithFrame:CGRectMake(320-35, 5, 30, 30)];
    [settingButton setImage:[UIImage imageNamed:@"setting70.png"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:settingButton];
    
    // Pause Button
    pauseButton = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-40)/2,self.view.frame.size.height-40-30, 40, 40)];
    [pauseButton setImage:[UIImage imageNamed:@"pauseButton120.png"] forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(pauseGame) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:pauseButton];
    
    pauseView = [[UIView alloc]initWithFrame:self.view.frame];
    pauseView.frame = CGRectOffset(pauseView.frame, 0, -self.view.frame.size.height);
    pauseView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.600];
    [self.view addSubview:pauseView];
    
    playButton = [[UIButton alloc]initWithFrame:CGRectMake((self.view.frame.size.width-60)/2,(self.view.frame.size.height-60)/2, 60, 60)];
    [playButton setImage:[UIImage imageNamed:@"playButton120.png"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(playGame) forControlEvents:UIControlEventTouchDown];
    [pauseView addSubview:playButton];
    
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
        
    levelLabel.text = [NSString stringWithFormat:@"Level %ld",level];
    [UIView animateWithDuration:1.0 animations:^{
        
        levelLabel.alpha = 1;
        
    } completion:^(BOOL finished) {

        [UIView animateWithDuration:1.0 animations:^{
            
            levelLabel.alpha = 0;
        }];
        
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
    
    if (bombChain > maxBombChain)
        maxBombChain = bombChain;
}

#pragma mark - Controls

-(void)pauseGame
{
    [self buttonAnimation:pauseButton];
    gamePad.userInteractionEnabled = NO;
    [scanTimer invalidate];
    
    [UIView animateWithDuration:0.5 animations:^{
        pauseView.frame = CGRectOffset(pauseView.frame, 0, 568);
    }];
}

-(void)playGame
{
    [self buttonAnimation:pauseButton];
    
    [UIView animateWithDuration:0.5 animations:^{
        pauseView.frame = CGRectOffset(pauseView.frame, 0, -568);
    } completion:^(BOOL finished) {
        gamePad.userInteractionEnabled = YES;
        scanTimer = [NSTimer scheduledTimerWithTimeInterval:6 target:self selector:@selector(scannerAnimation) userInfo:nil repeats:YES];
    }];
}

-(void)showSetting:(UIButton *)button
{
    [self buttonAnimation:button];
    [particle playButtonSound];
    
    GameSettingViewController *controller =  [[GameSettingViewController alloc]init];
    [self presentViewController:controller animated:YES completion:nil];

}

-(void)buttonAnimation:(UIButton *)button
{
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
        
        [self performScanning];
        gamePad.userInteractionEnabled = NO;

    }];
}

-(void)performScanning
{
    // Scanning animation
    [particle scanSound];
    [UIView animateWithDuration:1 animations:^{
        
        if (scanFromRight) {
            scanner.frame = CGRectOffset(scanner.frame, 311, 0);
            scannerMask.frame = CGRectMake(scannerMask.frame.origin.x,scannerMask.frame.origin.y,311,314);
        } else {
            scanner.frame = CGRectOffset(scanner.frame, -311, 0);
            scannerMask.frame = CGRectMake(scannerMask.frame.origin.x,scannerMask.frame.origin.y,-311,314);
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
    [UIView animateWithDuration:0.5 animations:^{
        
        scannerMask.alpha = 0;
        scanner.alpha = 0;

        
    } completion:^(BOOL finished) {
        
        if (scanFromRight) {
            scannerMask.frame = CGRectOffset(scannerMask.frame, 311, 0);
            scannerMask.frame = CGRectMake(scannerMask.frame.origin.x,scannerMask.frame.origin.y,3,314);
            scanFromRight = NO;
        } else {
            scannerMask.frame = CGRectMake(scannerMask.frame.origin.x,scannerMask.frame.origin.y,3,314);
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
        
        [particle playMoveSound];

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
    if (combosToCreateBomb > 2) {
        
        if (tutorialMode==3)
            [self showTutorial4];
        
        combosToCreateBomb = 0;
        [gamePad createBombWithReminder:snake.reminder body:[snake snakeBody] complete:^{
            
            gamePad.userInteractionEnabled = YES;

        }];
    }
    else
        gamePad.userInteractionEnabled = YES;

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
    tutorial1BG = [[UIView alloc]initWithFrame:CGRectMake(0, -130, 320, 130)];
    tutorial1BG.backgroundColor = [UIColor clearColor];
    [self.view addSubview:tutorial1BG];
    
    scoreLabel.hidden = YES;
    settingButton.hidden = YES;
    
    // 1. Swipe
    CustomLabel *swipeText = [[CustomLabel alloc]initWithFrame:CGRectMake(0,10, 320, 35) fontSize:30];
    swipeText.text = @"Swipe to move";
    [tutorial1BG addSubview:swipeText];
    
    UIImageView *swipe = [[UIImageView alloc]initWithFrame:CGRectMake((320-70)/2, 50, 70, 70)];
    swipe.image = [UIImage imageNamed:@"tutorialSwipe140.png"];
    [tutorial1BG addSubview:swipe];
    
    [self showTutorial:tutorial1BG];
}

-(void)showTutorial2
{
    tutorialMode++;
    [self hideTutorial:tutorial1BG complete:^{
        
        tutorial2BG = [[UIView alloc]initWithFrame:CGRectMake(0, -130, 320, 130)];
        tutorial2BG.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tutorial2BG];
        
        // 2. Combo
        CustomLabel *tutComboText = [[CustomLabel alloc]initWithFrame:CGRectMake(0,10, 320, 35) fontSize:30];
        tutComboText.text = @"Move for combo";
        [tutorial2BG addSubview:tutComboText];
        
        UIImageView *tutorialCombo = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 320, 70)];
        tutorialCombo.image = [UIImage imageNamed:@"tutorialCombo140.png"];
        [tutorial2BG addSubview:tutorialCombo];
        
        [self showTutorial:tutorial2BG];

    }];
}

-(void)showTutorial3
{
    tutorialMode++;
    [self hideTutorial:tutorial2BG complete:^{
        
        tutorial3BG = [[UIView alloc]initWithFrame:CGRectMake(0, -130, 320, 130)];
        tutorial3BG.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tutorial3BG];
        
        // 3. Bomb
        CustomLabel *tutBombText = [[CustomLabel alloc]initWithFrame:CGRectMake(0,10, 320, 35) fontSize:30];
        tutBombText.text = @"More combo more bomb";
        [tutorial3BG addSubview:tutBombText];
        
        UIImageView *tutorialBomb = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 320, 70)];
        tutorialBomb.image = [UIImage imageNamed:@"tutorialCreateBomb140.png"];
        [tutorial3BG addSubview:tutorialBomb];
        
        [self showTutorial:tutorial3BG];
        
    }];
}

-(void)showTutorial4
{
    tutorialMode++;
    [self hideTutorial:tutorial3BG complete:^{
        
        tutorial4BG = [[UIView alloc]initWithFrame:CGRectMake(0, -130, 320, 130)];
        tutorial4BG.backgroundColor = [UIColor clearColor];
        [self.view addSubview:tutorial4BG];
        
        // 3. Bomb
        CustomLabel *tutBombText = [[CustomLabel alloc]initWithFrame:CGRectMake(0,10, 320, 35) fontSize:30];
        tutBombText.text = @"Trigger bomb by combo";
        [tutorial4BG addSubview:tutBombText];
        
        UIImageView *tutorialBomb = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50, 320, 70)];
        tutorialBomb.image = [UIImage imageNamed:@"tutorialBomb140.png"];
        [tutorial4BG addSubview:tutorialBomb];
        
        [self showTutorial:tutorial4BG];
        
    }];
}

-(void)hideTutorial:(UIView *)tutorialView  complete:(void(^)(void))completeBlock
{
    [UIView animateWithDuration:0.5 animations:^{
        
        tutorialView.frame = CGRectOffset(tutorialView.frame, 0, -130);
        
    }completion:^(BOOL finished) {

        [tutorialView removeFromSuperview];
        completeBlock();
    } ];
}

-(void)showTutorial:(UIView *)tutorialView
{
    [UIView animateWithDuration:0.5 animations:^{
        
        tutorialView.frame = CGRectOffset(tutorialView.frame, 0, 130);
        
    }];
}

- (void)hideLastTutorial
{
    if (tutorialMode == 4) {
        
        [self hideTutorial:tutorial4BG complete:^{
            
            scoreLabel.hidden = NO;
            settingButton.hidden = NO;
            
            CGAffineTransform t =  scoreLabel.transform;
            CGAffineTransform t1 =  settingButton.transform;
            
            scoreLabel.transform = CGAffineTransformScale(t1, 0.1, 0.1);
            settingButton.transform = CGAffineTransformScale(t1, 0.1, 0.1);
            
            [UIView animateWithDuration:0.2 animations:^{
                
                scoreLabel.transform = CGAffineTransformScale(t1, 1.2, 1.2);
                settingButton.transform = CGAffineTransformScale(t1, 1.2, 1.2);
                
            }completion:^(BOOL finished) {
                
                scoreLabel.transform = t;
                settingButton.transform = t1;
                tutorialMode = 0;
                
                [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"tutorial"];

            }];
            
        }];
    }
}

#pragma mark - Game Over

-(void)gameOver
{
    gamePad.userInteractionEnabled = NO;
    [scanTimer invalidate];
    screenShot = [self captureView:self.view];
    [snake setGameoverImage];
    gameIsOver = YES;
}

#pragma mark - Replay

- (void)replayGame
{
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
    [particle removeAllChildren];
    [particle removeAllActions];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
