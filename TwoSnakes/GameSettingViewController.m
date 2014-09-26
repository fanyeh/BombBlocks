//
//  GameSettingViewController.m
//  Bomb Blocks
//
//  Created by Jack Yeh on 2014/9/12.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GameSettingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <StoreKit/StoreKit.h>
#import "Reachability.h"
#import "MKAppDelegate.h"
#import "CustomLabel.h"
#import "ParticleView.h"
#import "ClassicGameController.h"
#import "TutorialViewController.h"

@interface GameSettingViewController () <SKStoreProductViewControllerDelegate>
{
    UIButton *soundButton;
    UIButton *musicButton;
    UIButton *rateButton;
    UIButton *tutorial;
    BOOL musicOn;
    BOOL soundOn;
    MKAppDelegate *appDelegate;
    CustomLabel *soundOnLabel;
    CustomLabel *musicOnLabel;
}

@end

@implementation GameSettingViewController

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
    UIImageView *bgImageView = [[UIImageView alloc]initWithImage:_bgImage];
    [self.view addSubview:bgImageView];
    musicOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"music"];
    soundOn = [[NSUserDefaults standardUserDefaults] boolForKey:@"sound"];
    
    [self settingPage];
}

#pragma mark - Setting

- (void)settingPage
{
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, 35, 35)];
    [backButton setImage:[UIImage imageNamed:@"back70.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToGame:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:backButton];
    
    CGFloat fontSize = 30;
    CGFloat labelSize = 90;
    CGFloat xGap = screenWidth*80/320;
    CGFloat yGap = screenWidth*0.3125;
    CGFloat xCord = (screenWidth - labelSize)/2 - xGap;
    CGFloat centerY = (screenHeight - 45*4 - (yGap-45)*3)/2 ;
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([language isEqualToString:@"ja"]) {
        fontSize = 25;
    }
    
    // Sound
    soundButton = [[UIButton alloc]initWithFrame:CGRectMake(xCord, centerY, 45, 45)];
    [soundButton setImage:[UIImage imageNamed:@"soundOn90.png"] forState:UIControlStateNormal];
    [soundButton addTarget:self action:@selector(turnSound) forControlEvents:UIControlEventTouchDown];
    [self.view  addSubview:soundButton];
    
    CustomLabel *soundLabel;
    if([language isEqualToString:@"ja"])
        soundLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap, centerY, labelSize+30, 45) fontSize:fontSize];
    else
        soundLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap, centerY, labelSize, 45) fontSize:fontSize];

    soundLabel.text = NSLocalizedString(@"Sound",nil);
    soundLabel.textAlignment = NSTextAlignmentLeft;
    [self.view  addSubview:soundLabel];
    
    soundOnLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap+115, centerY, labelSize, 45) fontSize:25];
    [self setSoundOnLabel];
    [self.view  addSubview:soundOnLabel];
    
    // Music
    musicButton = [[UIButton alloc]initWithFrame:CGRectMake(xCord, centerY+yGap, 45, 45)];
    [musicButton setImage:[UIImage imageNamed:@"musicOn90.png"] forState:UIControlStateNormal];
    [musicButton addTarget:self action:@selector(turnMusic) forControlEvents:UIControlEventTouchDown];
    [self.view  addSubview:musicButton];
    
    CustomLabel *musicLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap, centerY+yGap, labelSize, 45) fontSize:fontSize];
    musicLabel.text = NSLocalizedString(@"Music",nil);
    musicLabel.textAlignment = NSTextAlignmentLeft;
    [self.view  addSubview:musicLabel];
    
    musicOnLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap+115, centerY+yGap, labelSize, 45) fontSize:25];
    [self setMusicOnLabel];
    [self.view  addSubview:musicOnLabel];
    
    // Rating
    rateButton = [[UIButton alloc]initWithFrame:CGRectMake(xCord, centerY+yGap*2, 45, 45)];
    [rateButton setImage:[UIImage imageNamed:@"rating90.png"] forState:UIControlStateNormal];
    [rateButton addTarget:self action:@selector(rateThisApp) forControlEvents:UIControlEventTouchDown];
    [self.view  addSubview:rateButton];
    
    CustomLabel *ratingLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap, centerY+yGap*2, labelSize+30, 45) fontSize:fontSize];
    ratingLabel.text = NSLocalizedString(@"Rate Me",nil);
    ratingLabel.textAlignment = NSTextAlignmentLeft;
    [self.view  addSubview:ratingLabel];
    
    // Tutorial
    tutorial = [[UIButton alloc]initWithFrame:CGRectMake(xCord, centerY+yGap*3, 45, 45)];
    [tutorial setImage:[UIImage imageNamed:@"tutorial90.png"] forState:UIControlStateNormal];
    [tutorial addTarget:self action:@selector(startTutorial:) forControlEvents:UIControlEventTouchDown];
    [self.view  addSubview:tutorial];
    
    CustomLabel *tutorialLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap, centerY+yGap*3, labelSize+90, 45) fontSize:fontSize];
    tutorialLabel.text = NSLocalizedString(@"Tutorial",nil);
    tutorialLabel.textAlignment = NSTextAlignmentLeft;
    [self.view  addSubview:tutorialLabel];
    
    appDelegate = [[UIApplication sharedApplication] delegate];

}

-(void)backToGame:(UIButton *)sender
{
    [self buttonAnimation:sender];
    [_delegate continueGame];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)startTutorial:(UIButton *)sender
{
    [self buttonAnimation:sender];
    TutorialViewController *controller = [[TutorialViewController alloc]init];
    controller.bgImage = _bgImage;
    controller.particleView = _particleView;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)turnMusic
{
    [self buttonAnimation:musicButton];
//    [_particleView playButtonSound];
    [_particleView playSound:kSoundTypeButtonSound];

    if (musicOn) {
        musicOn = NO;
        [appDelegate.audioPlayer stop];
    }
    else {
        musicOn = YES;
        [appDelegate.audioPlayer play];
    }

    [self setMusicOnLabel];
    [[NSUserDefaults standardUserDefaults] setBool:musicOn forKey:@"music"];
}

- (void)turnSound
{
    [self buttonAnimation:soundButton];
//    [_particleView playButtonSound];
    [_particleView playSound:kSoundTypeButtonSound];

    if (soundOn)
        soundOn = NO;
    else
        soundOn = YES;
    [self setSoundOnLabel];
    [[NSUserDefaults standardUserDefaults] setBool:soundOn forKey:@"sound"];
}

-(void)setSoundOnLabel
{
    if (!soundOn) {
        soundOnLabel.text = NSLocalizedString(@"OFF", nil);
        [soundButton setImage:[UIImage imageNamed:@"soundOff90.png"] forState:UIControlStateNormal];
    }
    else {
        soundOnLabel.text = NSLocalizedString(@"ON", nil);
        [soundButton setImage:[UIImage imageNamed:@"soundOn90.png"] forState:UIControlStateNormal];
    }
}

-(void)setMusicOnLabel
{
    if (!musicOn) {
        musicOnLabel.text = NSLocalizedString(@"OFF", nil);
        [musicButton setImage:[UIImage imageNamed:@"musicOff90.png"] forState:UIControlStateNormal];
    } else {
        musicOnLabel.text = NSLocalizedString(@"ON", nil);
        [musicButton setImage:[UIImage imageNamed:@"musicOn90.png"] forState:UIControlStateNormal];
    }
}

-(void)rateThisApp
{
    if ([self checkInternetConnection]) {
        
        SKStoreProductViewController *storeController = [[SKStoreProductViewController alloc] init];
        storeController.delegate = self;
        
        NSDictionary *productParameters = @{ SKStoreProductParameterITunesItemIdentifier :@"916465725"};
        
        [storeController loadProductWithParameters:productParameters completionBlock:^(BOOL result, NSError *error) {
            if (result) {
                
                [self presentViewController:storeController animated:YES completion:nil];
                
            }
        }];
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)buttonAnimation:(UIButton *)button
{
//    [_particleView playButtonSound];
    [_particleView playSound:kSoundTypeButtonSound];

    CGAffineTransform t = button.transform;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        button.transform = CGAffineTransformScale(t, 0.85, 0.85);
        
    } completion:^(BOOL finished) {
        
        button.transform = t;
    }];
}

- (BOOL)checkInternetConnection
{
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *noInternetAlert = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"No Internet Connection", nil)
                                                                 message:NSLocalizedString(@"Check your internet connection and try again",nil)
                                                                delegate:self cancelButtonTitle:NSLocalizedString(@"Close",nil)
                                                       otherButtonTitles:nil, nil];
        [noInternetAlert show];
        return NO;
    } else {
        return YES;
    }
}

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
