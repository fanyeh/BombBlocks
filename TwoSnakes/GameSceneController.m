//
//  GameSceneController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/19.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GameSceneController.h"
#import "GamePad.h"
#import "Snake.h"
#import <Social/Social.h>
#import "MenuController.h"
#import "MenuButton.h"
#import "SnakeDot.h"
#import "SnakeSkill.h"
#import "TestBoss.h"
#import "SnakeSkillName.h"

@interface GameSceneController ()
{
    NSTimer *moveTimer;
    float timeInterval; // Movement speed of snake
    NSInteger numDotAte;
    NSTimer *countDownTimer;
    NSInteger counter;
    NSInteger maxCombos;
    NSInteger score;
    UITapGestureRecognizer *snakeButtonTap;
    BOOL isCheckingCombo;
    GamePad *newGamePad;
    Snake *newSnake;
    MenuButton *menuButton;
    //    NSNumberFormatter *numFormatter; Formatter for score
    
    UIView *initSkillView;
    UIView *supplementSkillView1;
    UIView *supplementSkillView2;
    
    TestBoss *Enemy;
    UIProgressView *snakeHP;
    UIProgressView *bossHP;
    
    UILabel *stunLabel;
    UILabel *dotLabel;
    UILabel *leechLabel;
    
    UILabel *dotDamageLabel;
    UILabel *meleeDamageLabel;
    UILabel *magicDamageLabel;

}


@end

@implementation GameSceneController

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
    //    numFormatter = [[NSNumberFormatter alloc] init];
    //    [numFormatter setGroupingSeparator:@","];
    //    [numFormatter setGroupingSize:3];
    //    [numFormatter setUsesGroupingSeparator:YES];
    
    
    // Setup menu button
    menuButton = [[MenuButton alloc]initWithFrame:CGRectMake(10, 10, 106, 25)];
    [self.view addSubview:menuButton];
    UITapGestureRecognizer *menuTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(backToMenu)];
    [menuButton addGestureRecognizer:menuTap];
    menuButton.hidden = YES;
    
    // Skill View
    initSkillView = [[UIView alloc]initWithFrame:CGRectMake(10, 45 , 25, 25)];
    initSkillView.layer.borderWidth = 1;
    [self.view addSubview:initSkillView];
    
    supplementSkillView1 = [[UIView alloc]initWithFrame:CGRectMake(55, 45, 25, 25)];
    supplementSkillView1.layer.borderWidth = 1;
    [self.view addSubview:supplementSkillView1];
    
    supplementSkillView2 = [[UIView alloc]initWithFrame:CGRectMake(90, 45, 25, 25)];
    supplementSkillView2.layer.borderWidth = 1;
    [self.view addSubview:supplementSkillView2];
    
    initSkillView.backgroundColor = [UIColor whiteColor];
    supplementSkillView1.backgroundColor = [UIColor whiteColor];
    supplementSkillView2.backgroundColor = [UIColor whiteColor];
    
    // Setup game pad
    newGamePad = [[GamePad alloc]initGamePad];
    newGamePad.center = self.view.center;
    UITapGestureRecognizer *gamePadTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(directionChange:)];
    [newGamePad addGestureRecognizer:gamePadTap];
    [self.view addSubview:newGamePad];
    
    // Setup snake head
    newSnake = [[Snake alloc]initWithSnakeHeadDirection:kMoveDirectionDown gamePad:newGamePad];
    newSnake.initSkillView = initSkillView;
    newSnake.supplementSkillView1 = supplementSkillView1;
    newSnake.supplementSkillView2 = supplementSkillView2;
    [newGamePad addSubview:newSnake];

    // Setup snake button
    snakeButtonTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startCoundDown)];
    _snakeButton = [[SnakeButton alloc]initWithTitle:@"play" gesture:snakeButtonTap];
    [self.view addSubview:_snakeButton];
    
    // Test Boss
    Enemy = [[TestBoss alloc]initWithFrame:CGRectMake(135, 45, 50, 50)];
    [self.view addSubview:Enemy];
    
    // Damage Label
    dotDamageLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 15, 20, 20)];
    dotDamageLabel.textColor = [UIColor redColor];
    dotDamageLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:dotDamageLabel];
    Enemy.boss.dotDamageLabel = dotDamageLabel;
    
    meleeDamageLabel = [[UILabel alloc]initWithFrame:CGRectMake(150, 15, 20, 20)];
    meleeDamageLabel.textColor = [UIColor redColor];
    meleeDamageLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:meleeDamageLabel];
    Enemy.boss.meleeDamageLabel = meleeDamageLabel;
    
    magicDamageLabel = [[UILabel alloc]initWithFrame:CGRectMake(170, 15, 20, 20)];
    magicDamageLabel.textColor = [UIColor redColor];
    magicDamageLabel.adjustsFontSizeToFitWidth = YES;
    [self.view addSubview:magicDamageLabel];
    Enemy.boss.magicDamageLabel = magicDamageLabel;
    
    // Enemy State
    stunLabel = [[UILabel alloc]initWithFrame:CGRectMake(205, 45, 25, 25)];
    stunLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:10];
    stunLabel.textColor = [UIColor redColor];
    stunLabel.textAlignment = NSTextAlignmentCenter;
    stunLabel.text = @"Stun";
    [self.view addSubview:stunLabel];
    stunLabel.hidden = YES;
    
    dotLabel = [[UILabel alloc]initWithFrame:CGRectMake(235, 45, 25, 25)];
    dotLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:10];
    dotLabel.textColor = [UIColor redColor];
    dotLabel.textAlignment = NSTextAlignmentCenter;
    dotLabel.text = @"Dot";
    [self.view addSubview:dotLabel];
    dotLabel.hidden = YES;
    
    leechLabel = [[UILabel alloc]initWithFrame:CGRectMake(275, 45, 25, 25)];
    leechLabel.font = [UIFont fontWithName:@"ChalkboardSE-Bold" size:10];
    leechLabel.textColor = [UIColor redColor];
    leechLabel.textAlignment = NSTextAlignmentCenter;
    leechLabel.text = @"Leech";
    [self.view addSubview:leechLabel];
    leechLabel.hidden = YES;
    
    // HP progress
    snakeHP = [[UIProgressView alloc]initWithFrame:CGRectMake(10, 20, 100, 30)];
    snakeHP.progressViewStyle = UIProgressViewStyleDefault;
    snakeHP.progress = 1;
    [self.view addSubview:snakeHP];
    
    bossHP = [[UIProgressView alloc]initWithFrame:CGRectMake(200, 20, 100, 30)];
    bossHP.progressViewStyle = UIProgressViewStyleDefault;
    bossHP.progress = 1;
    bossHP.tintColor = [UIColor redColor];
    [self.view addSubview:bossHP];

    // Game Settings
    timeInterval = 0.2;
    numDotAte = 0;
    counter =  3;
    maxCombos = 0;
    score = 0;
    newGamePad.userInteractionEnabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(snakeAttack:) name:@"snakeAttack" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(enemyAttack:) name:@"enemyAttack" object:nil];

}

// Received Snake Attack
- (void)snakeAttack:(NSNotification *)notification
{
    NSLog(@"Snake Attack!");
//    NSLog(@"%@",[notification userInfo]);
    
    NSArray *skillSet = [notification userInfo].allValues;
    
    for (SnakeSkillName *s in skillSet) {
        [s calculateSkillEffect];
        
        switch (s.skillName) {
            case kSkillNameMeleeAttack:
                
                [Enemy.boss reduceHitPointByMelee:s.damage];
                
                break;
            case kSkillNameMagicAttack:
                
                [Enemy.boss reduceHitPointByMagic:s.damage];

                break;
            case kSkillNameStun:
                
                [Enemy.boss getStunned:s.timer];
                stunLabel.hidden = NO;
                [NSTimer scheduledTimerWithTimeInterval:s.timer target:self selector:@selector(hideStunLabel) userInfo:nil repeats:NO];
                
                break;
            case kSkillNameHeal:
                
                [newSnake.snakeType getHeal:s.heal];
                
                break;
            case kSkillNameDamageOverTime:

                [Enemy.boss getDotted:s.timer hitpoint:s.damage];
                dotLabel.hidden = NO;
                [NSTimer scheduledTimerWithTimeInterval:s.timer target:self selector:@selector(hideDotLabel) userInfo:nil repeats:NO];
                
                break;
            case kSkillNameDamageShield:
                
                [newSnake.snakeType getDamageShieldBuff:s.timer hitpoint:s.damage];
                
                break;
            case kSkillNameDefenseBuff:
                
                [newSnake.snakeType getDefenseBuff:s.timer adder:s.buff];
                
                break;
            case kSkillNameAttackBuff:
                
                [newSnake.snakeType getAttackBuff:s.timer adder:s.buff];
                
                break;
            case kSkillNameLeech:
                
                [newSnake.snakeType getLeech:s.timer hitpoint:s.damage];
                [Enemy.boss getLeeched:s.timer hitpoint:s.damage];
                
                leechLabel.hidden = NO;
                [NSTimer scheduledTimerWithTimeInterval:s.timer target:self selector:@selector(hideLeechLabel) userInfo:nil repeats:NO];
                
                break;
            case kSkillNameDamageAbsorb:
                
                [newSnake.snakeType getDamageAbsorb:s.heal];
                
                break;
            case kSkillNameRegeneration:
                
                [newSnake.snakeType getRegeneration:s.timer hitpoint:s.heal];
                
                break;
            case kSkillNameCounterAttack:
                
                break;
        }
        [bossHP setProgress:[Enemy.boss currentHitPoint]/1000];
    }
}

// Received Enemy Attack
- (void)enemyAttack:(NSNotification *)notification
{
    NSLog(@"Enemy Attack!");

}

-(void)directionChange:(UITapGestureRecognizer *)sender
{
    if (newGamePad.userInteractionEnabled) {
        CGPoint location = [sender locationInView:newGamePad];
        [newSnake setTurningNode:location];
        newGamePad.userInteractionEnabled = NO;
    }
    
//    CGPoint location = [sender locationInView:newGamePad];
//
//    // Show tap point
//        UIView *tapDot = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
//        tapDot.center = location;
//        tapDot.layer.cornerRadius = 5;
//        tapDot.backgroundColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
//        tapDot.alpha = 0;
//        tapDot.layer.borderColor = [[UIColor colorWithWhite:0.400 alpha:1.000]CGColor];
//        tapDot.layer.borderWidth = 1.5;
//        [newGamePad addSubview:tapDot];
//    
//        [UIView animateWithDuration:0.3 animations:^{
//            tapDot.alpha = 1;
//        } completion:^(BOOL finished) {
//            [UIView animateWithDuration:0.3 animations:^{
//                tapDot.alpha = 0;
//    
//            } completion:^(BOOL finished) {
//                [tapDot removeFromSuperview];
//            }];
//        }];
    
}

-(void)changeDirection
{
    newGamePad.userInteractionEnabled = YES;
    
    if ([newSnake changeDirectionWithGameIsOver:NO]) {
        
        [moveTimer invalidate];
        
        // Submit score to game center
        [[GCHelper sharedInstance] submitScore:score leaderboardId:kHighScoreLeaderboardId];
        
        NSString *alertTitle = @"Game Over";
        
        // Set score record
        if (score > [[NSUserDefaults standardUserDefaults]integerForKey:@"highestScore"]) {
            [[NSUserDefaults standardUserDefaults]setInteger:score forKey:@"highestScore"];
            alertTitle = @"New Score Record";
        }
        
        if (maxCombos > [[NSUserDefaults standardUserDefaults]integerForKey:@"maxCombo"]) {
            [[NSUserDefaults standardUserDefaults]setInteger:maxCombos forKey:@"maxCombo"];
            alertTitle = @"New Combo Record";
        }
        
        UIColor *gameOverColor = [UIColor colorWithRed:0.435 green:0.529 blue:0.529 alpha:1.000];
        
        [newSnake gameOver];
        
        [UIView animateWithDuration:1 animations:^{
            
            for (SnakeDot *d in [newGamePad dotArray]) {
                d.smallDot.backgroundColor = gameOverColor;
            }
            
            for (UIView *v in [newSnake snakeBody]) {
                if (v.tag > 0) {
                    v.backgroundColor = gameOverColor;
                }
            }
            
        } completion:^(BOOL finished) {
            
            [_snakeButton changeState:kSnakeButtonReplay];
            [snakeButtonTap removeTarget:self action:@selector(pauseGame)];
            [snakeButtonTap addTarget:self action:@selector(replayGame)];
            menuButton.hidden = NO;
            
        }];
        
    } else {
        for (SnakeDot *d in [newGamePad dotArray]) {
            if (d.hidden) {
                d.hidden = NO;
            }
        }
        [self isEatingDot];
    }
}

#pragma mark - Game state

- (void)countDown
{
    if (counter == 0) {
        newGamePad.userInteractionEnabled = YES;
        [countDownTimer invalidate];
        counter = 3;
        
        [newGamePad hideAllDots];
        
        newGamePad.alpha = 0;
        [UIView animateWithDuration:1 animations:^{
            [newSnake snakeHead].alpha = 1;
            [newGamePad setupDotForGameStart:[newSnake snakeHead].frame];
            
        } completion:^(BOOL finished) {
            
            moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self
                                                       selector:@selector(changeDirection)
                                                       userInfo:nil
                                                        repeats:YES];
        }];
    }
    else {
        [newGamePad counterDots:counter];
        counter--;
    }
}

- (void)startCoundDown
{
//    newGamePad.hidden = YES;
    [_snakeButton changeState:kSnakeButtonPause];
    [snakeButtonTap removeTarget:self action:@selector(startCoundDown)];
    [snakeButtonTap addTarget:self action:@selector(pauseGame)];
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self
                                                    selector:@selector(countDown)
                                                    userInfo:nil
                                                     repeats:YES];
}

- (void)pauseGame
{
    [_snakeButton changeState:kSnakeButtonResume];
    [moveTimer invalidate];
    [snakeButtonTap removeTarget:self action:@selector(pauseGame)];
    [snakeButtonTap addTarget:self action:@selector(resumeGame)];
}

- (void)backgroundPauseGame
{
    [_snakeButton backgroundPause:kSnakeButtonResume];
    [moveTimer invalidate];
    [snakeButtonTap removeTarget:self action:@selector(pauseGame)];
    [snakeButtonTap addTarget:self action:@selector(resumeGame)];
}

- (void)resumeGame
{
    [_snakeButton changeState:kSnakeButtonPause];
    [snakeButtonTap removeTarget:self action:@selector(resumeGame)];
    [snakeButtonTap addTarget:self action:@selector(pauseGame)];
    
    // Only resume timer when game is not checking combos
    if (!isCheckingCombo)
        moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval
                                                     target:self
                                                   selector:@selector(changeDirection)
                                                   userInfo:nil
                                                    repeats:YES];
}

- (void)replayGame
{
    // Game settings
    timeInterval = 0.2;
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                      target:self
                                                    selector:@selector(countDown)
                                                    userInfo:nil
                                                     repeats:YES];
    numDotAte = 0;
    score = 0;

    
    [newSnake snakeHead].frame = CGRectMake(147, 189, 20, 20);
    [[newSnake snakeHead].layer removeAllAnimations];
    [newSnake snakeHead].alpha = 0;
    
//    _scoreLabel.text =  [numFormatter stringFromNumber:[NSNumber numberWithInteger:score]];
    
    [newSnake resetSnake:[newSnake snakeHead] andDirection:[newSnake headDirection]];
    
    [_snakeButton changeState:kSnakeButtonPause];
    [snakeButtonTap removeTarget:self action:@selector(replayGame)];
    [snakeButtonTap addTarget:self action:@selector(pauseGame)];
}

#pragma mark - Dot

- (void)isEatingDot
{
    for (SnakeDot *d in [newGamePad dotArray]) {
        if (!d.hidden && CGRectIntersectsRect([newSnake snakeHead].frame, d.frame)) {
            
            newSnake.snakeMouth.hidden = NO;
            
            d.hidden = YES;
            
            [newGamePad bringSubviewToFront:[newSnake snakeHead]];
            
            score += 10;
            
//            _scoreLabel.text =  [numFormatter stringFromNumber:[NSNumber numberWithInteger:score]];
            
            [newGamePad addSubview:[newSnake addSnakeBodyWithDot:d]];
            
            [moveTimer invalidate];
            
            newGamePad.userInteractionEnabled = NO;
            
            isCheckingCombo = YES;
            
            [newSnake checkCombo:^{
                
                [newSnake.skill executeSkillCombo];
                
                newGamePad.userInteractionEnabled = YES;
                
                isCheckingCombo = NO;
                
                if (newSnake.isRotate)
                    [newSnake stopRotate];
                
                [newSnake mouthAnimation:timeInterval];
                
                newSnake.snakeMouth.backgroundColor = [UIColor whiteColor];
                
                // Increase speed for every 30 dots eaten
                if (numDotAte%30==0 && numDotAte != 0)
                    timeInterval -= 0.005;
                
                [self setScore];
                [newSnake updateExclamationText];
                [d changeType];
                
                if (moveTimer.isValid)
                    [moveTimer invalidate];
                
                // If game paused during combo animation , timer will not activate after combo animation is completed. Need to presse resume button to continue the game
                if (_snakeButton.state != kSnakeButtonResume)
                    moveTimer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(changeDirection) userInfo:nil repeats:YES];
                
                initSkillView.backgroundColor = [UIColor whiteColor];
                supplementSkillView1.backgroundColor = [UIColor whiteColor];
                supplementSkillView2.backgroundColor = [UIColor whiteColor];
            }];
            
            break;
        }
    }
    [newGamePad sendSubviewToBack:[newSnake snakeHead]];
}

- (void)hideStunLabel
{
    stunLabel.hidden = YES;
}

- (void)hideDotLabel
{
    dotLabel.hidden = YES;
    
}

- (void)hideLeechLabel
{
    leechLabel.hidden = YES;
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Hide statu bar

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - Menu


- (void)backToMenu
{
    if (_snakeButton.state == kSnakeButtonPause)
        [self backgroundPauseGame];
    
    MenuController *controller = [[MenuController alloc]init];
    controller.state = kGameStateContinue;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Setscore

- (void)setScore
{
    NSInteger comboAdder = 50;
    for (int i = 0 ; i < [newSnake combos] ; i ++) {
        score += comboAdder;
        comboAdder *= 2;
    }
    newSnake.combos = 0;
    numDotAte++;
}

@end
