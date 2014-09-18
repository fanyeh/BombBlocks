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
    countDownLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(135, 35, 50, 50) fontSize:50];
    countDownLabel.text = [NSString stringWithFormat:@"%ld",count];
    countDownLabel.layer.cornerRadius = 5;
    [self.view addSubview:countDownLabel];
    [self hideScoreLabel];
    [self hideLevelLabel];
    
    clockImageView = [[UIImageView alloc]initWithFrame:CGRectMake(110, 10, 100, 100)];
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
    [self setScanSpeed:4];
    
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
    [anim setDuration:6]; // rotate speed
    [anim setRepeatCount:HUGE_VAL];
    [anim setAutoreverses:NO];
//    anim.fillMode =  kCAFillModeForwards;
//    anim.removedOnCompletion = NO;
    
    [pinView.layer addAnimation:anim forKey:nil];
    
    redView =  [[UIView alloc]initWithFrame:self.view.frame];
    redView.backgroundColor = [UIColor clearColor];
    redView.userInteractionEnabled = NO;
    [self.view addSubview:redView];
}

-(void)countDown
{
    count--;
    countDownLabel.text = [NSString stringWithFormat:@"%ld",count];
    if (count < 10) {
        countDownLabel.textColor = [UIColor redColor];
        redView.backgroundColor = [UIColor colorWithRed:0.434 green:0.005 blue:0.010 alpha:0.400];
        [self.particleView sirenSound];

    } else
        [self.particleView tickSound];
    
    if (count ==  0)
        [self gameOver];
}

-(void)gameOver
{
    [super gameOver];
    [countDownTimer invalidate];
    [pinView.layer removeAllAnimations];
    pinView.hidden = YES;
}

- (void)replayGame
{
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
