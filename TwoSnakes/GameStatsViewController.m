//
//  GameStatsViewController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/9/2.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "GameStatsViewController.h"
#import "CustomLabel.h"
#import "SocialShare.h"
#import "GADInterstitial.h"
#import "Chartboost.h"
#import "MKAppDelegate.h"
#import "GameSettingViewController.h"

@interface GameStatsViewController () <ChartboostDelegate,GADInterstitialDelegate>
{
    CustomLabel *bestScoreLabel;
    CustomLabel *comLabel;
    CustomLabel *bombLabel;
    CustomLabel *chainLabel;
    CustomLabel *currentScoreLabel;
    SocialShare *socialShare;
    GADInterstitial *interstitialAd;
    NSNumberFormatter *numFormatter; //Formatter for score
    MKAppDelegate *appDelegate;
    NSMutableArray *levelArray;
}
@end

@implementation GameStatsViewController

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
    
    self.view.backgroundColor = [UIColor blackColor];
    
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    socialShare = [[SocialShare alloc]init];
    socialShare.screenshot = _gameImage;
    
    interstitialAd = [[GADInterstitial alloc] init];
    interstitialAd.delegate = self;
    interstitialAd.adUnitID = @"ca-app-pub-5576864578595597/8891080263";
    
    CGFloat socialButtonSize = 35;
    
    // Social share button
    UIButton *facbookButton = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth-35)/2,
                                                                        10,
                                                                        socialButtonSize,
                                                                        socialButtonSize)];
    
    [facbookButton setBackgroundImage:[UIImage imageNamed:@"facebook35.png"] forState:UIControlStateNormal];
    facbookButton.layer.cornerRadius = socialButtonSize/2;
    facbookButton.layer.masksToBounds = YES;
    facbookButton.backgroundColor = [UIColor whiteColor];
    [facbookButton addTarget:self action:@selector(facebookShare:) forControlEvents:UIControlEventTouchDown];
    
    UIButton *twitterButton = [[UIButton alloc]initWithFrame:facbookButton.frame];
    [twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter35.png"] forState:UIControlStateNormal];
    twitterButton.frame = CGRectOffset(twitterButton.frame, 80, 0);
    twitterButton.layer.cornerRadius = socialButtonSize/2;
    twitterButton.backgroundColor = [UIColor whiteColor];
    twitterButton.layer.masksToBounds = YES;
    [twitterButton addTarget:self action:@selector(twitterShare:) forControlEvents:UIControlEventTouchDown];
    
    // Game Center Label
    UIButton *gamecenterButton = [[UIButton alloc]initWithFrame:facbookButton.frame];
    gamecenterButton.frame = CGRectOffset(gamecenterButton.frame, -80, 0);
    [gamecenterButton setBackgroundImage:[UIImage imageNamed:@"gamecenter35.png"] forState:UIControlStateNormal];\
    gamecenterButton.layer.cornerRadius = socialButtonSize/2;
    [gamecenterButton addTarget:self action:@selector(showGameCenter:) forControlEvents:UIControlEventTouchDown];
    
    // Best Score Label
    bestScoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0,
                                                                  screenHeight*0.15,
                                                                  screenWidth,
                                                                  35)
                                              fontSize:35];
    
    bestScoreLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    
    // Current Score Label
    currentScoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0,
                                                                     screenHeight*0.25,
                                                                     screenWidth,
                                                                     65)
                                                 fontSize:65];
    
    CGFloat yoffset = currentScoreLabel.frame.origin.y + currentScoreLabel.frame.size.height + 30;
    CGFloat yGap;

    if (_timeMode) {
        yoffset -= 60;
        yGap = 0.123*screenHeight;
        if (screenHeight < 568)
            yoffset = 130;
    }
    else {
//        yoffset = 240;
        yGap = 0.0968*screenHeight;
    }
    
    CGFloat fontSize = 24;
    CGFloat labelYOffset = yoffset+80;
    CGFloat labelWidth = 100;
    CGFloat labelHeight = fontSize;
    CGFloat labelGap = 0.0625*screenWidth + labelWidth;
    CGFloat labelGap2 = 0.09375*screenWidth + labelHeight;
    
    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([language isEqualToString:@"ja"]) {
        fontSize = 23;
    }

    // ------------------- Combo ------------------- //
    CustomLabel *comboXLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth-labelHeight)/2,
                                                                            labelYOffset,
                                                                            labelHeight,
                                                                            labelHeight)
                                                        fontSize:fontSize];
    comboXLabel.text = @"x";
    
    CustomLabel *comboLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(comboXLabel.frame.origin.x - labelGap,
                                                                           labelYOffset,
                                                                           labelWidth,
                                                                           labelHeight)
                                                       fontSize:fontSize];
    comboLabel.text = NSLocalizedString(@"Combo",nil);
    comboLabel.textAlignment = NSTextAlignmentLeft;

    
    comLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(comboXLabel.frame.origin.x + labelGap2 ,
                                                            labelYOffset,
                                                            labelWidth-20,
                                                            labelHeight) fontSize:fontSize];
    
    // Level
    levelArray = [[NSMutableArray alloc]init];
    CustomLabel *levelLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(comboXLabel.frame.origin.x - labelGap,
                                                                           yoffset-10,
                                                                           labelWidth,
                                                                           labelHeight)
                                                       fontSize:fontSize];
    
    levelLabel.text = NSLocalizedString(@"Level", nil);
    levelLabel.textAlignment = NSTextAlignmentLeft;
    [levelArray addObject:levelLabel];
    
    // ------------------- Bomb -------------------------- //
    CustomLabel *bombXLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth-labelHeight)/2,
                                                                           labelYOffset+yGap,
                                                                           labelHeight,
                                                                           labelHeight)
                                                       fontSize:fontSize];
    bombXLabel.text = @"x";
    
    CustomLabel *bLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(bombXLabel.frame.origin.x - labelGap,
                                                                       labelYOffset+yGap,
                                                                       labelWidth,
                                                                       labelHeight)
                                                   fontSize:fontSize];
    bLabel.text = NSLocalizedString(@"Bomb",nil);
    bLabel.textAlignment = NSTextAlignmentLeft;

    
    bombLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(bombXLabel.frame.origin.x + labelGap2,
                                                             labelYOffset+yGap,
                                                             labelWidth-20,
                                                             labelHeight)
                                         fontSize:fontSize];
    
    // ------------------- Chain ------------------- //
    CustomLabel *chainXLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((screenWidth-labelHeight)/2,
                                                                            labelYOffset+yGap*2,
                                                                            labelHeight,
                                                                            labelHeight)
                                                        fontSize:fontSize];
    chainXLabel.text = @"x";
    
    CustomLabel *cLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(bombXLabel.frame.origin.x - labelGap,
                                                                       labelYOffset+yGap*2,
                                                                       labelWidth,
                                                                       labelHeight)
                                                   fontSize:fontSize];
    cLabel.text = NSLocalizedString(@"chain",nil);
    cLabel.textAlignment = NSTextAlignmentLeft;
    
    chainLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(bombXLabel.frame.origin.x + labelGap2,
                                                              labelYOffset+yGap*2,
                                                              labelWidth-20,
                                                              labelHeight)
                                          fontSize:fontSize];
    
    
    UIImageView *replayView = [[UIImageView alloc]initWithFrame:self.view.frame];
    replayView.image = _bgImage;
    replayView.userInteractionEnabled = YES;
    [self.view addSubview:replayView];

    // Social Button
    [self.view addSubview:facbookButton];
    [self.view addSubview:twitterButton];
    
    // Gamecenter Button
    [self.view addSubview:gamecenterButton];
    
    // Score stats
    [self.view addSubview:currentScoreLabel];
    [self.view addSubview:bestScoreLabel];
    [self.view addSubview:comLabel];
    [self.view addSubview:bombLabel];

    [self.view addSubview:comboLabel];
    [self.view addSubview:comboXLabel];

    
    [self.view addSubview:bombXLabel];
    [self.view addSubview:bLabel];
    
    [self.view addSubview:chainXLabel];
    [self.view addSubview:cLabel];
    [self.view addSubview:chainLabel];

    [self.view addSubview:levelLabel];
    
    CGFloat xoffset = levelLabel.frame.origin.x + 15;
    CGFloat offset = levelLabel.frame.origin.y+labelHeight+15;
    
    // Levels label
    if (!_timeMode) {
        for (NSInteger i = 0; i < 10; i++) {
            
            CustomLabel *subLevelLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xoffset,
                                                                                      offset,
                                                                                      fontSize,
                                                                                      fontSize)
                                                                  fontSize:fontSize];
            
            subLevelLabel.text = [NSString stringWithFormat:@"%ld",i+1];
            
            if (i+1 <= _level)
                subLevelLabel.textColor =[UIColor whiteColor];
            else
                subLevelLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
            
            [self.view addSubview:subLevelLabel];
            xoffset += fontSize;
            
            [levelArray addObject:subLevelLabel];
        }
    } else
        levelLabel.hidden = YES;
    
    UIButton *replayBg = [[UIButton alloc]initWithFrame:CGRectMake((screenWidth-40)/2,
                                                                   screenHeight-40-30,
                                                                   40,
                                                                   40)];
    
    [replayBg setImage:[UIImage imageNamed:@"replayButton40.png"] forState:UIControlStateNormal];
    [replayBg addTarget:self action:@selector(replayGame:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:replayBg];
    
    [self showReplayView];
    
    //[self showChartboost];
    
    appDelegate = [[UIApplication sharedApplication] delegate];

    if([[NSUserDefaults standardUserDefaults] boolForKey:@"music"])
        [self doVolumeFade];

    // Home Button
    UIButton *homeButton = [[UIButton alloc]initWithFrame:CGRectMake(5,screenHeight-35, 30, 30)];
    [homeButton setImage:[UIImage imageNamed:@"home60.png"] forState:UIControlStateNormal];
    [homeButton addTarget:self action:@selector(backToHome:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:homeButton];
    
    // Setting Button
    UIButton *settingButton = [[UIButton alloc]initWithFrame:CGRectMake(45, screenHeight-35, 30, 30)];
    [settingButton setImage:[UIImage imageNamed:@"setting60.png"] forState:UIControlStateNormal];
    [settingButton addTarget:self action:@selector(showSetting:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:settingButton];
}

-(void)backToHome:(UIButton *)button
{
    [self buttonAnimation:button];
    [self.view.window.rootViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)showSetting:(UIButton *)button
{
    [self buttonAnimation:button];
    GameSettingViewController *controller =  [[GameSettingViewController alloc]init];
    controller.bgImage = _bgImage;
    controller.particleView = _particleView;
    [self presentViewController:controller animated:YES completion:nil];
}

-(void)doVolumeFade
{
    if (appDelegate.audioPlayer.volume > 0.1) {
        
        appDelegate.audioPlayer.volume -=  0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.2];
        
    } else {
        // Stop and get the sound ready for playing again
        [appDelegate.audioPlayer stop];
        //appDelegate.audioPlayer.currentTime = 0;
        appDelegate.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"easy-living" ofType:@"mp3"]] error:nil];
        appDelegate.audioPlayer.numberOfLoops = -1;
        [appDelegate.audioPlayer prepareToPlay];
        
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"music"]) {
            [appDelegate.audioPlayer play];
            appDelegate.audioPlayer.volume = 0;
            [self volumeFadeIn];
        }
    }
}

- (void)volumeFadeIn
{
    if (appDelegate.audioPlayer.volume < 1) {
        
        appDelegate.audioPlayer.volume +=  0.1;
        [self performSelector:@selector(volumeFadeIn) withObject:nil afterDelay:0.2];
    }
}

-(void)showReplayView
{
    comLabel.text = [NSString stringWithFormat:@"%ld",_combos];
    bombLabel.text = [NSString stringWithFormat:@"%ld",_bombs];
    chainLabel.text = [NSString stringWithFormat:@"%ld",_maxBombChain];
    currentScoreLabel.text = [numFormatter stringFromNumber:[NSNumber numberWithInteger:_score]];

    NSInteger bestScore;
    
    if (_timeMode) {
        bestScore = [[NSUserDefaults standardUserDefaults]integerForKey:@"TimeBestScore"];
        if (_score > bestScore)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:_score forKey:@"TimeBestScore"];
            [[GCHelper sharedInstance] submitScore:_score leaderboardId:kFastHandHighScoreLeaderboardId];
            bestScoreLabel.text = @"New Record";
            bestScoreLabel.textColor = [UIColor whiteColor];
        } else {
            bestScoreLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Best",nil),[numFormatter stringFromNumber:[NSNumber numberWithInteger:bestScore]]];
            bestScoreLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
        }
    }
    else {
        bestScore = [[NSUserDefaults standardUserDefaults]integerForKey:@"ClassicBestScore"];
        if (_score > bestScore)
        {
            [[NSUserDefaults standardUserDefaults] setInteger:_score forKey:@"ClassicBestScore"];
            [[GCHelper sharedInstance] submitScore:_score leaderboardId:kHighScoreLeaderboardId];
            bestScoreLabel.text = @"New Record";
            bestScoreLabel.textColor = [UIColor whiteColor];
        } else {
            bestScoreLabel.text = [NSString stringWithFormat:@"%@ %@",NSLocalizedString(@"Best",nil),[numFormatter stringFromNumber:[NSNumber numberWithInteger:bestScore]]];
            bestScoreLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
        }

    }
    
    // Get Rank
//    [[GCHelper sharedInstance] getScoreRankFromLeaderboard:^(NSArray *topScores) {
//        
//        NSLog(@"Top scores %@",topScores);
//    }];
}

-(void)replayGame:(UIButton *)button
{
    [self buttonAnimation:button];
    [_delegate replayGame];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Game center

- (void)showGameCenter:(UIButton *)button
{
    [self buttonAnimation:button];
    [[GCHelper sharedInstance] showGameCenterViewController:self];
}

- (void)facebookShare:(UIButton *)button
{
    [self buttonAnimation:button];
    [socialShare setScore:_score];
    [socialShare showShareSheet:kShareTypeFacebook viewController:self];
}

- (void)twitterShare:(UIButton *)button
{
    [self buttonAnimation:button];
    [socialShare setScore:_score];
    [socialShare showShareSheet:kShareTypeTwitter viewController:self];
}

#pragma mark - Admob
- (void)showAdmob
{
    GADRequest *adRequest = [GADRequest request];
    [interstitialAd loadRequest:adRequest];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    NSLog(@"load ad success");
    
    [interstitial presentFromRootViewController:self];
    
}
- (void)interstitial:(GADInterstitial *)interstitial didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"load ad failed");
}

#pragma mark - Chartboost

- (void)showChartboost
{
    [Chartboost startWithAppId:@"54052883c26ee42eda8330a3" appSignature:@"45663b2388358acf2efc5fe6792588bb7e99e328" delegate:self];
    
    //在 “CBLocationHomeScreen” 位置显示广告
    [[Chartboost sharedChartboost] showInterstitial:CBLocationHomeScreen];
}

- (void)didFailToLoadInterstitial:(NSString *)location withError:(CBLoadError)error {
    switch(error){
        case CBLoadErrorInternetUnavailable: {
            NSLog(@"Failed to load Interstitial, no Internet connection !");
        } break;
        case CBLoadErrorInternal: {
            NSLog(@"Failed to load Interstitial, internal error !");
        } break;
        case CBLoadErrorNetworkFailure: {
            NSLog(@"Failed to load Interstitial, network error !");
        } break;
        case CBLoadErrorWrongOrientation: {
            NSLog(@"Failed to load Interstitial, wrong orientation !");
        } break;
        case CBLoadErrorTooManyConnections: {
            NSLog(@"Failed to load Interstitial, too many connections !");
        } break;
        case CBLoadErrorFirstSessionInterstitialsDisabled: {
            NSLog(@"Failed to load Interstitial, first session !");
        } break;
        case CBLoadErrorNoAdFound : {
            NSLog(@"Failed to load Interstitial, no ad found !");
        } break;
        case CBLoadErrorSessionNotStarted : {
            NSLog(@"Failed to load Interstitial, session not started !");
        } break;
        default: {
            NSLog(@"Failed to load Interstitial, unknown error !");
        }
    }
    
    [self showAdmob];
}

-(void)buttonAnimation:(UIButton *)button
{
//    [_particleView playButtonSound];
    [self.particleView playSound:kSoundTypeButtonSound];

    CGAffineTransform t = button.transform;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        button.transform = CGAffineTransformScale(t, 0.85, 0.85);
        
    } completion:^(BOOL finished) {
        
        button.transform = t;
    }];
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
