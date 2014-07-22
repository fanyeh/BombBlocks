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

@interface ClassicGameController ()
{
    NSNumberFormatter *numFormatter; //Formatter for score
    NSInteger score;
    NSInteger maxCombos;
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
    //self.gamePad.layer.cornerRadius = 10;
    //self.gamePad.layer.masksToBounds = YES;
    //UITapGestureRecognizer *gamePadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(directionChange:)];
    //[self.gamePad addGestureRecognizer:gamePadTap];

    // Configure the SKView
    SKView * skView = [[SKView alloc]initWithFrame:CGRectMake(0, 0, self.gamePad.frame.size.width, self.gamePad.frame.size.height)];

    // Create and configure the scene.
    ParticleView *particle = [[ParticleView alloc]initWithSize:skView.bounds.size];
    particle.scaleMode = SKSceneScaleModeAspectFill;
    //[particle newExplosion:200  :100 :[UIColor blueColor].CGColor];
    [self.gamePad addSubview:skView];
    [self.gamePad sendSubviewToBack:skView];

    // Present the scene.
    [skView presentScene:particle];
    
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
    startFrame = CGRectMake(125, 166, 40 , 40);
    self.snake = [[Snake alloc]initWithSnakeHeadDirection:kMoveDirectionDown gamePad:self.gamePad headFrame:startFrame];
    [self.gamePad addSubview:self.snake];
    self.snake.particleView = particle;
    
    score = 0;
    maxCombos = 0;
    
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

    // Setup swipe gestures
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDirection:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [self.gamePad addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDirection:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self.gamePad addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDirection:)];
    [swipeDown setDirection:UISwipeGestureRecognizerDirectionDown];
    [self.gamePad addGestureRecognizer:swipeDown];
    
    UISwipeGestureRecognizer *swipeUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeDirection:)];
    [swipeUp setDirection:UISwipeGestureRecognizerDirectionUp];
    [self.gamePad addGestureRecognizer:swipeUp];

}

-(void)swipeDirection:(UISwipeGestureRecognizer *)sender
{
    
    if ([self moveDirecton:sender.direction]) {
        
        [self.snake setTurningNodeBySwipe:sender.direction];
        
//        [self.snake checkCombo:^(AssetType type, BOOL hasCombo) {
//            
//            [self setScore];
//            if (self.snake.isRotate)
//                [self.snake stopRotate];
//            
//        }];
    }

    
    // If game is over
//    [self.snake gameOver];
//    self.gameState = kCurrentGameStateReplay;
//    self.stateSign.image = [UIImage imageNamed:@"replay.png"];
//    
//    NSInteger bestScore = [[NSUserDefaults standardUserDefaults]integerForKey:@"BestScore"];
//    
//    if (score > bestScore) {
//        
//        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"BestScore"];
//        [[GCHelper sharedInstance] submitScore:score leaderboardId:kHighScoreLeaderboardId];
//    }
    
}

- (BOOL)moveDirecton:(UISwipeGestureRecognizerDirection)swipeDirection
{
    MoveDirection headDirection = [self.snake headDirection];
    
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

- (void)changeGameState
{
        [super changeGameState];
        
        // Current game start after change
        switch (self.gameState) {
                
            case kCurrentGameStatePlay:
                
                break;
            case kCurrentGameStatePause:
                
                break;
            case kCurrentGameStateReplay:
                
                maxCombos = 0;
                score = 0;
                
                [self setScore];
                [self.snake resetSnake];
                [self.gamePad resetClassicGamePad];
                [self startMoveTimer];
                
                self.gameState = kCurrentGameStatePlay;
                
                break;
        }
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
