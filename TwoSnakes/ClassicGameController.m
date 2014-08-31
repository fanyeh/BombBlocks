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

@interface ClassicGameController () <gameoverDelegate>
{
    NSNumberFormatter *numFormatter; //Formatter for score
    NSInteger score;
    SnakeNode *nextNode;
    GamePad *gamePad;
    Snake *snake;
    UIImageView *replayView;
    NSInteger totalCombos;
    NSInteger combosToCreateBomb;
    BOOL swap;
    CustomLabel *nextLabel;
    CustomLabel *bestScoreLabel;
    CustomLabel *scoreLabel;
    CustomLabel *comLabel;
    CustomLabel *bombLabel;
    CustomLabel *currentScoreLabel;
    BOOL gameIsOver;
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
    
    [self setupReplayView];
    // Do any additional setup after loading the view.
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    // -------------------- Setup game pad -------------------- //
    gamePad = [[GamePad alloc]initGamePad];
    gamePad.center = self.view.center;
    //gamePad.frame = CGRectOffset(gamePad.frame, 0, 35);

    // -------------------- Setup particle views -------------------- //
    // Configure the SKView
    SKView * skView = [[SKView alloc]initWithFrame:CGRectMake(0, 0, gamePad.frame.size.width, gamePad.frame.size.height)];
    skView.backgroundColor = [UIColor clearColor];
    
    // Create and configure the scene.
    ParticleView *particle = [[ParticleView alloc]initWithSize:skView.bounds.size];
    particle.scaleMode = SKSceneScaleModeAspectFill;
    [gamePad addSubview:skView];
    [gamePad sendSubviewToBack:skView];

    // Present the scene.
    [skView presentScene:particle];
    [self.view addSubview:gamePad];
    
    // Count down
    scoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 250)/2, 25 , 250, 65) fontName:@"GeezaPro-Bold" fontSize:65];
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
    
    //[self showReplayView:0];
}

- (void)setupReplayView
{
    CGFloat pauseLabelWidth = self.view.frame.size.width;
    CGFloat pauseLabelHeight = self.view.frame.size.height;
    CGFloat socialButtonHeight = 40;
    CGFloat socialButtonWidth = socialButtonHeight;

    // Social share button
    UIButton *facbookButton = [[UIButton alloc]initWithFrame:CGRectMake(220,
                                                                        10,
                                                                        socialButtonWidth,
                                                                        socialButtonHeight)];
    
    [facbookButton setBackgroundImage:[UIImage imageNamed:@"facebook40.png"] forState:UIControlStateNormal];
    facbookButton.layer.cornerRadius = socialButtonHeight/2;
    facbookButton.layer.masksToBounds = YES;
    facbookButton.backgroundColor = [UIColor whiteColor];

    UIButton *twitterButton = [[UIButton alloc]initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        socialButtonWidth,
                                                                        socialButtonHeight)];
    [twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter40.png"] forState:UIControlStateNormal];
    twitterButton.frame = CGRectOffset(facbookButton.frame, 50, 0);
    twitterButton.layer.cornerRadius = socialButtonHeight/2;
    twitterButton.backgroundColor = [UIColor whiteColor];
    twitterButton.layer.masksToBounds = YES;
    
    // Game Center Label
    UIButton *gamecenterButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, socialButtonHeight, socialButtonHeight)];
    [gamecenterButton setBackgroundImage:[UIImage imageNamed:@"gamecenter2.png"] forState:UIControlStateNormal];
    [gamecenterButton addTarget:self action:@selector(showGameCenter) forControlEvents:UIControlEventTouchDown];
    
    CGFloat yoffset = 235;
    CGFloat labelWidth = 200;
    CGFloat labelHeight = 25;
    CGFloat fontSize = 25;
    
    currentScoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, 135, pauseLabelWidth, 65) fontName:@"GeezaPro-Bold" fontSize:65];
    
    comLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((320-labelWidth)/2,yoffset,labelWidth,labelHeight) fontName:@"GeezaPro-Bold" fontSize:fontSize];
    comLabel.text = NSTextAlignmentLeft;
    
    bombLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((320-labelWidth)/2,yoffset+60,labelWidth,labelHeight) fontName:@"GeezaPro-Bold" fontSize:fontSize];
    bombLabel.text = NSTextAlignmentLeft;
    
    bestScoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, 385, pauseLabelWidth, 30) fontName:@"GeezaPro-Bold" fontSize:30];
    bestScoreLabel.textColor = [UIColor colorWithWhite:0.298 alpha:1.000];

    replayView = [[UIImageView alloc]initWithFrame:self.view.frame];
    replayView.frame = CGRectOffset(replayView.frame, 0, -self.view.frame.size.height);
    replayView.image = [UIImage imageNamed:@"Background.png"];
    //[replayView addSubview:pauseLabel];
    replayView.userInteractionEnabled = YES;
    
    // Social Button
    [replayView addSubview:facbookButton];
    [replayView addSubview:twitterButton];
    
    // Gamecenter Button
    [replayView addSubview:gamecenterButton];
    
    // Score stats
    [replayView addSubview:currentScoreLabel];
    [replayView addSubview:bestScoreLabel];
    [replayView addSubview:comLabel];
    [replayView addSubview:bombLabel];

    UIImageView *replayBg = [[UIImageView alloc]initWithFrame:CGRectMake(130,pauseLabelHeight-50-50, 50, 50)];
    replayBg.image = [UIImage imageNamed:@"replayButton.png"];
    replayBg.userInteractionEnabled = YES;
    [replayView addSubview:replayBg];
    
    UITapGestureRecognizer *replayTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(replayGame)];
    [replayBg addGestureRecognizer:replayTap];
    
    [self.view addSubview:replayView];
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
        if([snake checkIsGameover])
            [self gameOver];
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
    
    [UIView animateWithDuration:0.5 animations:^{
        
        replayView.frame = CGRectOffset(replayView.frame, 0, -self.view.frame.size.height);
        
    }];
}

#pragma mark - Snake Delegate

-(void)showReplayView:(NSInteger)totalBombs
{
    nextNode.hidden = YES;
    nextLabel.hidden = YES;
    comLabel.text = [NSString stringWithFormat:@"Combo    x     %ld",totalCombos];
    bombLabel.text = [NSString stringWithFormat:@"Bomb      x     %ld",totalBombs];
    
    NSInteger bestScore = [[NSUserDefaults standardUserDefaults]integerForKey:@"BestScore"];
    
    currentScoreLabel.text = [NSString stringWithFormat:@"%ld",score];
    
    if (score > bestScore) {
        
        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"BestScore"];
        [[GCHelper sharedInstance] submitScore:score leaderboardId:kHighScoreLeaderboardId];
        bestScoreLabel.text = [NSString stringWithFormat:@"Best %@",[numFormatter stringFromNumber:[NSNumber numberWithInteger:score]]];
        
    } else {
        bestScoreLabel.text = [NSString stringWithFormat:@"Best %@",[numFormatter stringFromNumber:[NSNumber numberWithInteger:bestScore]]];
    }
    
    [self.view bringSubviewToFront:replayView];
    
    [UIView animateWithDuration:0.5 animations:^{
       
        replayView.frame = CGRectOffset(replayView.frame, 0, self.view.frame.size.height);
        
    }];
}

-(void)updateScore:(NSInteger)s
{
    score += s;
    scoreLabel.text = [numFormatter stringFromNumber:[NSNumber numberWithInteger:score]];// [NSString stringWithFormat:@"%ld",score];
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

@end
