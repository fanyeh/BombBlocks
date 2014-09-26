//
//  FastHandGameViewController.m
//  Bomb Blocks
//
//  Created by Jack Yeh on 2014/9/15.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "FastHandGameViewController.h"
#import "CustomLabel.h"

@interface FastHandGameViewController ()
{
    NSTimer *countDownTimer;
    NSInteger count;
    CustomLabel *countDownLabel;
    UIView *pinView;
    UIImageView *clockImageView;
    UIView *redView;
    
}

@end

@implementation FastHandGameViewController

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
    count = 60;
    CGFloat counterPos = 35;
    
    if (screenHeight < 568)
        counterPos = 27.5;
    
    countDownLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth-50)/2, counterPos, 50, 50) fontSize:50];
    countDownLabel.text = [NSString stringWithFormat:@"%ld",count];
    countDownLabel.layer.cornerRadius = 5;
    [self.view addSubview:countDownLabel];
    [self hideScoreLabel];
    [self hideLevelLabel];
    
    clockImageView = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth-100)/2, counterPos-25, 100, 100)];
    clockImageView.image = [UIImage imageNamed:@"clock100.png"];
    [self.view addSubview:clockImageView];
    
    pinView = [[UIView alloc]initWithFrame:CGRectMake(100/2-1.5,25+11,3,100/2-22)];
    pinView.backgroundColor = [UIColor redColor];
    pinView.layer.anchorPoint = CGPointMake(0.5, 1);
    pinView.layer.shouldRasterize = YES;
    [clockImageView addSubview:pinView];
        
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    
    [self disableLevelCheck];
        
    // Scan speed default is 6
    [self setScanSpeed:5];
    
    [self setBgImage:[UIImage imageNamed:@"timebackground.png"]];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [self pinAnimation];
}

-(void)pinAnimation
{
    CABasicAnimation* anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation"];
    [anim setToValue:[NSNumber numberWithFloat:0]]; // satrt angle
    [anim setFromValue:[NSNumber numberWithDouble:-2*M_PI]]; // rotation angle
    [anim setDuration:2]; // rotate speed , smaller the faster
    [anim setRepeatCount:HUGE_VAL];
    [anim setAutoreverses:NO];

    [pinView.layer addAnimation:anim forKey:nil];
    
    redView =  [[UIView alloc]initWithFrame:self.view.frame];
    redView.backgroundColor = [UIColor colorWithRed:0.434 green:0.005 blue:0.010 alpha:0.400];
    redView.alpha = 0;
    redView.userInteractionEnabled = NO;
    [self.view addSubview:redView];
}

-(void)countDown
{
    count--;
    countDownLabel.text = [NSString stringWithFormat:@"%ld",count];
    if (count < 10) {

        if (count == 9)
            [self stopMusic];

        if (count%2 == 1) {
//            [self.particleView sirenSound];
            [self.particleView playSound:kSoundTypeSirenSound];

            [UIView animateWithDuration:0.5 animations:^{
                
                redView.alpha = 1;

            } completion:^(BOOL finished) {
                
                [UIView animateWithDuration:0.5 animations:^{
                    redView.alpha = 0;
                    
                } ];
            }];
        }

    } else
//        [self.particleView tickSound];
    [self.particleView playSound:kSoundTypeTickSound];

    
    if (count ==  0)
        [self gameOver];
}

-(void)gameOver
{
    [super showScoreLabel];
    clockImageView.hidden = YES;
    countDownLabel.hidden = YES;
    
    [super gameOver];
    [countDownTimer invalidate];
    [pinView.layer removeAllAnimations];
}

- (void)replayGame
{
    [super hideScoreLabel];
    clockImageView.hidden = NO;
    countDownLabel.hidden = NO;

    [super replayGame];
    pinView.hidden = NO;
    count = 60;
    countDownLabel.text = [NSString stringWithFormat:@"%ld",count];
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [self setScanSpeed:4];
}

-(void)pauseGame
{
    [super pauseGame];
    
    [countDownTimer invalidate];
    [self pauseLayer:pinView.layer];
}

-(void)pauseGameFromBackground
{
    [super pauseGameFromBackground];
    
    if (!self.gameIsPaused) {
        [countDownTimer invalidate];
        [self pauseLayer:pinView.layer];
    }
}

-(void)playGame
{
    [super playGame];
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
    [self resumeLayer:pinView.layer];
}

- (void)backToHome:(UIButton *)button
{
    [super backToHome:button];
    [countDownTimer invalidate];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
