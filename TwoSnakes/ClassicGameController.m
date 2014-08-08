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

@interface ClassicGameController () <gameoverDelegate>
{
    NSNumberFormatter *numFormatter; //Formatter for score
    NSInteger score;
    CGRect startFrame;
    UILabel *comboLabel;
    SnakeNode *nextNode;
    SnakeNode *nextNode2;
    SnakeNode *nextNode3;
    GamePad *gamePad;
    Snake *snake;
    UIView *replayView;
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
    
    self.view.backgroundColor = [UIColor colorWithRed:0.064 green:0.056 blue:0.056 alpha:1.000];

    // Do any additional setup after loading the view.
    UILabel *gameoverLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 250, 40)];
    gameoverLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:40];
    gameoverLabel.text = @"Game Over";
    gameoverLabel.textColor = [UIColor colorWithWhite:0.502 alpha:1.000];
    gameoverLabel.textAlignment = NSTextAlignmentCenter;
    
    UIButton *replayButton = [[UIButton alloc]initWithFrame:CGRectMake(75, 50, 100, 100)];
    [replayButton setBackgroundImage:[UIImage imageNamed:@"replay.png"] forState:UIControlStateNormal];
    [replayButton addTarget:self action:@selector(replayGame) forControlEvents:UIControlEventTouchDown];
    
    UIButton *facbookButton = [[UIButton alloc]initWithFrame:CGRectMake(25, 170, 50, 50)];
    [facbookButton setBackgroundImage:[UIImage imageNamed:@"facebook40.png"] forState:UIControlStateNormal];
    
    UIButton *twitterButton = [[UIButton alloc]initWithFrame:CGRectMake(100, 170, 50, 50)];
    [twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter40.png"] forState:UIControlStateNormal];
    
    // Setup game state label
    UILabel *pauseLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 250, 250)];
    pauseLabel.backgroundColor = [UIColor whiteColor];
    pauseLabel.center = self.view.center;
    [pauseLabel addSubview:replayButton];
    [pauseLabel addSubview:facbookButton];
    [pauseLabel addSubview:twitterButton];
    [pauseLabel addSubview:gameoverLabel];
    pauseLabel.userInteractionEnabled = YES;

    
    replayView = [[UIView alloc]initWithFrame:self.view.frame];
    replayView.frame = CGRectOffset(replayView.frame, 0, -self.view.frame.size.height);
    replayView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.650];
    [replayView addSubview:pauseLabel];
    [self.view addSubview:replayView];

    CGFloat viewHeight = 40;
    CGFloat viewWidth = 60;

    // Game Center Label
    UILabel *gameCenterLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, viewWidth, viewHeight)];
    UIImageView *gamecenterImageView = [[UIImageView alloc]initWithFrame:CGRectMake(10, 5, 30, 30)];
    UIImage *gamecenterImage = [UIImage imageNamed:@"gamecenter.png"];
    gamecenterImageView.image = gamecenterImage;
    [gameCenterLabel addSubview:gamecenterImageView];
    UITapGestureRecognizer *gamecenterTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showGameCenter)];
    [gameCenterLabel addGestureRecognizer:gamecenterTap];
    gameCenterLabel.userInteractionEnabled = YES;
    // [self.view addSubview:gameCenterLabel];
    
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

    // Create and configure the scene.
    ParticleView *particle = [[ParticleView alloc]initWithSize:skView.bounds.size];
    particle.scaleMode = SKSceneScaleModeAspectFill;
    [gamePad addSubview:skView];
    [gamePad sendSubviewToBack:skView];

    // Present the scene.
    [skView presentScene:particle];
    [self.view addSubview:gamePad];
    
    // Setup score label
    CGFloat labelWidth = 120;
    score = 0;
    _scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - labelWidth)/2, 30 , labelWidth, 40)];
    _scoreLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:40];
    _scoreLabel.text = @"Score";
    _scoreLabel.textColor = [UIColor whiteColor];
    _scoreLabel.textAlignment = NSTextAlignmentCenter;
    _scoreLabel.backgroundColor =  [UIColor clearColor];
    [self.view addSubview:_scoreLabel];
    
    // Setup player snake head
    CGFloat snakeSize = 55 ;
    startFrame = CGRectMake(116, 173, snakeSize , snakeSize);
    snake = [[Snake alloc]initWithFrame:startFrame gamePad:gamePad];
    snake.delegate = self;
    [gamePad addSubview:snake];
    snake.particleView = particle;
    
    // Combo
    comboLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, gamePad.frame.origin.y, 320, 40)];
    comboLabel.hidden = YES;
    comboLabel.font = [UIFont fontWithName:@"GeezaPro-Bold" size:30];
    comboLabel.textColor = [UIColor whiteColor];
    comboLabel.textAlignment = NSTextAlignmentCenter;
    comboLabel.userInteractionEnabled = YES;
    [self.view addSubview:comboLabel];

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
    
    CGFloat nextNodeSize = 40;
    nextNode = [[SnakeNode alloc]initWithFrame:CGRectMake(160-(nextNodeSize*1.5), 505, nextNodeSize, nextNodeSize)];
    [self setNextNode:nextNode];
    [self.view addSubview:nextNode];

    nextNode2 = [[SnakeNode alloc]initWithFrame:CGRectOffset(nextNode.frame, nextNodeSize, 0)];
    [self setNextNode:nextNode2];
    [self.view addSubview:nextNode2];

    nextNode3 = [[SnakeNode alloc]initWithFrame:CGRectOffset(nextNode2.frame, nextNodeSize, 0)];
    [self setNextNode:nextNode3];
    [self.view addSubview:nextNode3];
    
    snake.comingNodeArray = [[NSMutableArray alloc]initWithArray:@[nextNode,nextNode2,nextNode3]];
    
    // ------ Gyroscope --------//
    
    CMMotionManager *motionManager = [[CMMotionManager alloc]init];
    
    motionManager.gyroUpdateInterval = 1.0/60.0;
    
    if (motionManager.isGyroAvailable) {
        
        [motionManager startGyroUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMGyroData *gyroData, NSError *error) {
            
            if (gyroData.rotationRate.y > 5)
                NSLog(@"Postivie Y : %f",motionManager.gyroData.rotationRate.y);
            
            if (gyroData.rotationRate.y < -5)
                NSLog(@"Negative Y : %f",motionManager.gyroData.rotationRate.y);
            
            if (gyroData.rotationRate.x > 5)
                NSLog(@"Postivie X : %f",motionManager.gyroData.rotationRate.x);
            
            if (gyroData.rotationRate.x < -5)
                NSLog(@"Negative X : %f",motionManager.gyroData.rotationRate.x);
            
        }];
    }

}

-(void)setNextNode:(SnakeNode *)node
{
    int randomAsset = arc4random()%4;
    switch (randomAsset) {
        case 0:
            node.assetType = kAssetTypeBlue;
            node.nodeImageView.image = [UIImage imageNamed:@"blue.png"];
            break;
        case 1:
            node.assetType = kAssetTypeRed;
            node.nodeImageView.image = [UIImage imageNamed:@"red.png"];
            break;
        case 2:
            node.assetType = kAssetTypeGreen;
            node.nodeImageView.image = [UIImage imageNamed:@"green.png"];
            break;
        case 3:
            node.assetType = kAssetTypeYellow;
            node.nodeImageView.image = [UIImage imageNamed:@"yellow.png"];
            break;
        case 4:
            node.assetType = kAssetTypePurple;
            node.nodeImageView.image = [UIImage imageNamed:@"purple.png"];
            break;
    }
}

-(void)swipeDirection:(UISwipeGestureRecognizer *)sender
{
    
    if (gamePad.userInteractionEnabled) {
        
        gamePad.userInteractionEnabled = NO;
        [snake swipeToMove:sender.direction complete:^{
            
            if (snake.combos > 0) {
                
                [self showComboSlogan];

            } else {
                gamePad.userInteractionEnabled = YES;

            }
            snake.combos = 0;
            [self setScore];
            
            if([snake checkIsGameover]) {

                gamePad.userInteractionEnabled = NO;
                [snake setGameoverImage];
                
                [self grayOutNode:nextNode];
                [self grayOutNode:nextNode2];
                [self grayOutNode:nextNode3];

                NSInteger bestScore = [[NSUserDefaults standardUserDefaults]integerForKey:@"BestScore"];
                
                if (score > bestScore) {
                    
                    [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"BestScore"];
                    [[GCHelper sharedInstance] submitScore:score leaderboardId:kHighScoreLeaderboardId];
                }

            }
            
        }];
    }
}

-(void)grayOutNode:(SnakeNode *)n
{
    switch (n.assetType) {
        case kAssetTypeBlue:
            n.nodeImageView.image = [UIImage imageNamed:@"go_blue.png"];
            break;
        case kAssetTypeRed:
            n.nodeImageView.image = [UIImage imageNamed:@"go_red.png"];
            break;
        case kAssetTypeGreen:
            n.nodeImageView.image = [UIImage imageNamed:@"go_green.png"];
            break;
        case kAssetTypeYellow:
            n.nodeImageView.image = [UIImage imageNamed:@"go_yellow.png"];
            break;
        default:
            break;
    }
}

-(void)changeNodeToNormal:(SnakeNode *)n
{
    switch (n.assetType) {
        case kAssetTypeBlue:
            n.nodeImageView.image = [UIImage imageNamed:@"blue.png"];
            break;
        case kAssetTypeRed:
            n.nodeImageView.image = [UIImage imageNamed:@"red.png"];
            break;
        case kAssetTypeGreen:
            n.nodeImageView.image = [UIImage imageNamed:@"green.png"];
            break;
        case kAssetTypeYellow:
            n.nodeImageView.image = [UIImage imageNamed:@"yellow.png"];
            break;
        default:
            break;
    }
}


- (void)showComboSlogan
{
    switch (snake.combos) {
        case 1:
            comboLabel.text = @"Nice";
            break;
        case 2:
            comboLabel.text = @"Good Job";
            break;
        case 3:
            comboLabel.text = @"Well Done";
            
            break;
        case 4:
            comboLabel.text = @"Excellent";
            
            break;
        case 5:
            comboLabel.text = @"Amazing";
            
            break;
        case 6:
            comboLabel.text = @"Incredible";
            
            break;
        case 7:
            comboLabel.text = @"God-Like";
            
            break;
        default:
            comboLabel.text = @"";
            
            break;
    }
    
    comboLabel.hidden = NO;
    comboLabel.alpha = 0;
    
    [UIView animateWithDuration:1.5 animations:^{
        
        comboLabel.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        comboLabel.hidden = YES;
        gamePad.userInteractionEnabled = YES;

    }];
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
#pragma mark - Dot

- (void)replayGame
{
    gamePad.userInteractionEnabled = YES;
    score = 0;
    [self setScore];
    [snake resetSnake];
    [gamePad resetClassicGamePad];
    [self changeNodeToNormal:nextNode];
    [self changeNodeToNormal:nextNode2];
    [self changeNodeToNormal:nextNode3];
    
    [UIView animateWithDuration:0.5 animations:^{
        
        replayView.frame = CGRectOffset(replayView.frame, 0, -self.view.frame.size.height);
        
    }];

}

#pragma mark - Setscore

- (void)setScore
{
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

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)showReplayView
{
    [self.view bringSubviewToFront:replayView];
    
    [UIView animateWithDuration:0.5 animations:^{
       
        replayView.frame = CGRectOffset(replayView.frame, 0, self.view.frame.size.height);
        
    }];
}

@end
