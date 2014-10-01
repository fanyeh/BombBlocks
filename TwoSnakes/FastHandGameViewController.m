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
    CGFloat labelSize = 50;
    if (screenHeight < 568) {
        counterPos = 27.5;
        labelSize = 45;
    }
    
    if (IS_IPad) {
//        counterPos = counterPos/IPadMiniRatio;
        labelSize = 100;
        counterPos = 80;
    } else if (IS_IPhone && screenHeight > 568) {
        counterPos = counterPos * screenWidth/320;
        labelSize = labelSize * screenWidth/320;
    }
    
    // Count down label
    countDownLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth-labelSize)/2,
                                                                  counterPos,
                                                                  labelSize,
                                                                  labelSize)
                                              fontSize:labelSize];
    
    countDownLabel.text = [NSString stringWithFormat:@"%ld",count];
    countDownLabel.layer.cornerRadius = 5;
    [self.view addSubview:countDownLabel];
    [self hideScoreLabel];
    [self hideLevelLabel];
    
    // Count down clock image
    clockImageView = [[UIImageView alloc]initWithFrame:CGRectMake((screenWidth-labelSize*2)/2,
                                                                  counterPos-labelSize/2,
                                                                  labelSize*2,
                                                                  labelSize*2)];
    
    clockImageView.image = [UIImage imageNamed:@"clock100.png"];
    [self.view addSubview:clockImageView];
    
    // Clock pin
    pinView = [[UIView alloc]initWithFrame:CGRectMake(labelSize*2/2-(3/IPadMiniRatio/2),labelSize/2+11,3/IPadMiniRatio,labelSize*2/2-22)];
    pinView.backgroundColor = [UIColor redColor];
    pinView.layer.anchorPoint = CGPointMake(0.5, 1);
    pinView.layer.shouldRasterize = YES;
    [clockImageView addSubview:pinView];
    
    // Count down timer
    [self startCountDown];
    
    // Disable level check
    [self disableLevelCheck];
        
    // Scan speed default is 6
    [self setScanSpeed:5];
    
    [self setBgImage:[UIImage imageNamed:@"timebackground.png"]];
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
    if (count == 60)
        [self pinAnimation];

    count--;
    countDownLabel.text = [NSString stringWithFormat:@"%ld",count];
    if (count < 10) {

        if (count == 9)
            [self stopMusic];

        if (count%2 == 1) {
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
        [self.particleView playSound:kSoundTypeTickSound];

    if (count ==  0) {
        self.chainLabel.text = NSLocalizedString(@"Time's up!",nil);
        [self gameOver];
    }
}

-(void)showSetting:(UIButton *)button
{
    [super showSetting:button];
    [countDownTimer invalidate];
    [self pauseLayer:pinView.layer];
}

-(void)gameOver
{
    clockImageView.hidden = YES;
    countDownLabel.hidden = YES;
    [countDownTimer invalidate];
    [pinView.layer removeAllAnimations];
    self.scoreLabel.alpha = 0;
    [super showScoreLabel];
    [UIView animateWithDuration:0.5 animations:^{
        
        self.scoreLabel.alpha = 1;
        
    } completion:^(BOOL finished) {
        
        [super gameOver];
        
    }];
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
    [self startCountDown];
    [self setScanSpeed:4];
}

//-(void)continueGame
//{
//    [super continueGame];
//    [self startCountDown];
//    [self resumeLayer:pinView.layer];
//}

-(void)pauseGamePress
{
    [super pauseGamePress];
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
    [self startCountDown];
    [self resumeLayer:pinView.layer];
}

- (void)backToHome:(UIButton *)button
{
    [super backToHome:button];
    [countDownTimer invalidate];
}

-(void)startCountDown
{
    countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(countDown) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
