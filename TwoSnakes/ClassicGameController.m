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
    SnakeNode *nextNode;
    SnakeNode *nextNode2;
    SnakeNode *nextNode3;

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
    self.view.backgroundColor = [UIColor blackColor];
    // Do any additional setup after loading the view.
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    // Setup game pad
    self.gamePad = [[GamePad alloc]initGamePad];
    self.gamePad.center = self.view.center;
    //self.gamePad.frame = CGRectOffset(self.gamePad.frame, 0, 20);
    //self.gamePad.backgroundColor = [UIColor whiteColor];

    // Configure the SKView
    SKView * skView = [[SKView alloc]initWithFrame:CGRectMake(0, 0, self.gamePad.frame.size.width, self.gamePad.frame.size.height)];

    // Create and configure the scene.
    ParticleView *particle = [[ParticleView alloc]initWithSize:skView.bounds.size];
    particle.scaleMode = SKSceneScaleModeAspectFill;
    [self.gamePad addSubview:skView];
    [self.gamePad sendSubviewToBack:skView];

    // Present the scene.
    [skView presentScene:particle];
    [self.view addSubview:self.gamePad];
    
    CGFloat viewHeight = 40;
    CGFloat viewWidth = 60;
    
    // Combo
    comboView = [[UIView alloc]initWithFrame:CGRectMake(320-13.5-50, 20, viewWidth, viewHeight)];
    //[self.view addSubview:comboView];
    
    comboLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 20)];
    comboLabel.text = @"Combo";
    comboLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:17];
    comboLabel.textColor = FontColor;
    comboLabel.textAlignment = NSTextAlignmentCenter;
    comboLabel.userInteractionEnabled = YES;
    [comboView addSubview:comboLabel];
    
    comboCountLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, viewWidth, 13)];
    comboCountLabel.text = [NSString stringWithFormat:@"%ld",maxCombos];
    comboCountLabel.font = [UIFont fontWithName:@"AvenirNext-Medium" size:15];
    comboCountLabel.textColor = FontColor;
    comboCountLabel.textAlignment = NSTextAlignmentCenter;
    [comboView addSubview:comboCountLabel];
    
    // ------------------------ Rank --------------------------- //
    rankView = [[UIView alloc]initWithFrame:CGRectMake(13.5, 15 , viewWidth, viewHeight)];
    //[self.view addSubview:rankView];
    UILabel *rankLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, viewWidth, 20)];
    rankLabel.text = @"Rank";
    rankLabel.font = [UIFont fontWithName:@"AvenirNext-Heavy" size:20];
    rankLabel.textColor = FontColor;
    rankLabel.textAlignment = NSTextAlignmentCenter;
    [rankView addSubview:rankLabel];
    UILabel *currentRank = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, 50, 13)];
    currentRank.text = @"1";
    currentRank.font = [UIFont fontWithName:@"AvenirNext-Medium" size:15];
    currentRank.textColor = FontColor;
    currentRank.textAlignment = NSTextAlignmentCenter;
    [rankView addSubview:currentRank];
    
    [[GCHelper sharedInstance]getScoreRankFromLeaderboard:^(NSArray *topScores) {
        
        GKScore *topScore = [topScores firstObject];
        currentRank.text = [numFormatter stringFromNumber:[NSNumber numberWithInteger:topScore.rank]];

    }];
    
    // Setup score label
    CGFloat labelWidth = 120;
    _scoreLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - labelWidth)/2, 30 , labelWidth, 40)];
    _scoreLabel.font = [UIFont fontWithName:@"AvenirNext-Bold" size:25];
    _scoreLabel.text = @"Score";
    _scoreLabel.textColor = FontColor;
    _scoreLabel.textAlignment = NSTextAlignmentCenter;
    _scoreLabel.backgroundColor =  [UIColor clearColor];
    _scoreLabel.layer.cornerRadius = 5;
    _scoreLabel.layer.masksToBounds = YES;
    [self.view addSubview:_scoreLabel];
    
    // Setup player snake head
    CGFloat snakeSize = 55 ;
    startFrame = CGRectMake(116, 173, snakeSize , snakeSize);
    self.snake = [[Snake alloc]initWithSnakeHeadDirection:kMoveDirectionDown gamePad:self.gamePad headFrame:startFrame];
    [self.gamePad addSubview:self.snake];
    self.snake.particleView = particle;
    
    score = 0;
    maxCombos = 0;
    
    UITapGestureRecognizer *replayTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(replayGame)];
    [self.pauseLabel addGestureRecognizer:replayTap];
    
    // Game Center Label
    UILabel *gameCenterLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 10, viewWidth, viewHeight)];
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
    
    self.snake.comingNodeArray = [[NSMutableArray alloc]initWithArray:@[nextNode,nextNode2,nextNode3]];

}

-(void)setNextNode:(SnakeNode *)node
{
//    node.layer.borderWidth = 3;
//    node.layer.borderColor = FontColor.CGColor;
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
    
    if ([self moveDirecton:sender.direction]) {
        
        self.gamePad.userInteractionEnabled = NO;
        score++;
        [self.snake swipeToMove:sender.direction complete:^{
            
            [self setScore];

        }];

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

- (void)replayGame
{
    maxCombos = 0;
    score = 0;

    [self setScore];
    [self.snake resetSnake];
    [self.gamePad resetClassicGamePad];
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
