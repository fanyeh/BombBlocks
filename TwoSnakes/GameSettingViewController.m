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
    CGFloat fontSize = 25;
    CGFloat labelSize = 90;
    CGFloat backButtonSize = 35;
    CGFloat otherButtonSize = 45;
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    CGFloat onLabelOffset = 110;
    CGFloat titleSize = 45;
    CGFloat titlePosY = 10;
    CGFloat tutorialLabelWidth = labelSize+90;
    CGFloat xGap = screenWidth*80/320;
    CGFloat yGap = 90;
    
    if ([language isEqualToString:@"ja"]||screenHeight < 568) {
        titleSize = 35;
        fontSize = 22;
    }

    if (IS_IPad) {
        fontSize = fontSize/IPadMiniRatio;
        labelSize = labelSize/IPadMiniRatio;
        backButtonSize = 60;
        otherButtonSize = otherButtonSize/IPadMiniRatio;
        onLabelOffset = onLabelOffset/IPadMiniRatio;
        titleSize = titleSize/IPadMiniRatio;
        titlePosY = 50;
        tutorialLabelWidth = labelSize+90/IPadMiniRatio;
        yGap = yGap/IPadMiniRatio;
    } else if(screenHeight > 568 && IS_IPhone) {
        titlePosY = 30;
        titleSize = titleSize + 5;
    }
    
    CGFloat xCord = (screenWidth - labelSize)/2 - xGap;
    CGFloat centerY = (screenHeight - otherButtonSize*4 - (yGap-otherButtonSize)*3)/2 ;
    
    CustomLabel *settingLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, titlePosY, screenWidth, titleSize) fontSize:titleSize-5];
    settingLabel.text = NSLocalizedString(@"Setting",nil);
    [self.view addSubview:settingLabel];
    
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth-backButtonSize)/2,
                                                                     screenHeight-(backButtonSize+10),
                                                                     backButtonSize,
                                                                     backButtonSize)];
    [backButton setImage:[UIImage imageNamed:@"closeButton.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backToGame:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:backButton];

    // Sound
    soundButton = [[UIButton alloc]initWithFrame:CGRectMake(xCord-5, centerY, otherButtonSize, otherButtonSize)];
    [soundButton setImage:[UIImage imageNamed:@"soundOn90.png"] forState:UIControlStateNormal];
    [soundButton addTarget:self action:@selector(turnSound) forControlEvents:UIControlEventTouchDown];
    [self.view  addSubview:soundButton];
    
    CustomLabel *soundLabel;
    if([language isEqualToString:@"ja"])
        soundLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap, centerY, labelSize+30, otherButtonSize) fontSize:fontSize];
    else
        soundLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap, centerY, labelSize, otherButtonSize) fontSize:fontSize];
    soundLabel.text = NSLocalizedString(@"Sound",nil);
    soundLabel.textAlignment = NSTextAlignmentLeft;
    [self.view  addSubview:soundLabel];
    
    soundOnLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap+onLabelOffset, centerY, labelSize, otherButtonSize) fontSize:fontSize];
    [self setSoundOnLabel];
    [self.view  addSubview:soundOnLabel];
    
    // Music
    musicButton = [[UIButton alloc]initWithFrame:CGRectMake(xCord-5, centerY+yGap, otherButtonSize, otherButtonSize)];
    [musicButton setImage:[UIImage imageNamed:@"musicOn90.png"] forState:UIControlStateNormal];
    [musicButton addTarget:self action:@selector(turnMusic) forControlEvents:UIControlEventTouchDown];
    [self.view  addSubview:musicButton];
    
    CustomLabel *musicLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap, centerY+yGap, labelSize, otherButtonSize) fontSize:fontSize];
    musicLabel.text = NSLocalizedString(@"Music",nil);
    musicLabel.textAlignment = NSTextAlignmentLeft;
    [self.view  addSubview:musicLabel];
    
    musicOnLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap+onLabelOffset, centerY+yGap, labelSize, otherButtonSize) fontSize:fontSize];
    [self setMusicOnLabel];
    [self.view  addSubview:musicOnLabel];
    
    // Rating
    rateButton = [[UIButton alloc]initWithFrame:CGRectMake(xCord-5, centerY+yGap*2, otherButtonSize, otherButtonSize)];
    [rateButton setImage:[UIImage imageNamed:@"rating90.png"] forState:UIControlStateNormal];
    [rateButton addTarget:self action:@selector(rateThisApp) forControlEvents:UIControlEventTouchDown];
    [self.view  addSubview:rateButton];
    
    CustomLabel *ratingLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap, centerY+yGap*2, labelSize+30, otherButtonSize) fontSize:fontSize];
    ratingLabel.text = NSLocalizedString(@"Rate Me",nil);
    ratingLabel.textAlignment = NSTextAlignmentLeft;
    [self.view  addSubview:ratingLabel];
    
    // Tutorial
    tutorial = [[UIButton alloc]initWithFrame:CGRectMake(xCord-5, centerY+yGap*3, otherButtonSize, otherButtonSize)];
    [tutorial setImage:[UIImage imageNamed:@"tutorial90.png"] forState:UIControlStateNormal];
    [tutorial addTarget:self action:@selector(startTutorial:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:tutorial];
    
    CustomLabel *tutorialLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+xGap, centerY+yGap*3, tutorialLabelWidth, otherButtonSize) fontSize:fontSize];
    tutorialLabel.text = NSLocalizedString(@"Tutorial",nil);
    tutorialLabel.textAlignment = NSTextAlignmentLeft;
    [self.view addSubview:tutorialLabel];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
}

-(void)backToGame:(UIButton *)sender
{
    [self buttonAnimation:sender];
    [_delegate continueGameFromSetting];
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
            if (result)
                [self presentViewController:storeController animated:YES completion:nil];
//            else
//                NSLog(@"rate error %@",error);
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
