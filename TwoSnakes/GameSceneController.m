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
#import "SnakeSkill.h"
#import "TestBoss.h"
#import "SnakeSkillName.h"
#import "GameMenu.h"

@interface GameSceneController ()
{
    NSTimer *moveTimer;
    float timeInterval; // Movement speed of snake
    NSInteger numDotAte;
    NSTimer *countDownTimer;
    NSInteger counter;
    NSInteger maxCombos;
    NSInteger score;
    BOOL isCheckingCombo;

    //    NSNumberFormatter *numFormatter; Formatter for score
    
    GamePad *newGamePad;
    Snake *newSnake;
    UITapGestureRecognizer *snakeButtonTap;

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
    
    CircleLabel *pauseLabel;
    GameMenu *menu;
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
