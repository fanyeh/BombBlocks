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

@interface GameStatsViewController () <ChartboostDelegate,GADInterstitialDelegate>
{
    CustomLabel *bestScoreLabel;
    CustomLabel *comLabel;
    CustomLabel *bombLabel;
    CustomLabel *currentScoreLabel;
    SocialShare *socialShare;
    GADInterstitial *interstitialAd;
    NSNumberFormatter *numFormatter; //Formatter for score
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
    
    numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setGroupingSeparator:@","];
    [numFormatter setGroupingSize:3];
    [numFormatter setUsesGroupingSeparator:YES];
    
    socialShare = [[SocialShare alloc]init];
    socialShare.screenshot = _gameImage;
    
    interstitialAd = [[GADInterstitial alloc] init];
    interstitialAd.delegate = self;
    interstitialAd.adUnitID = @"ca-app-pub-5576864578595597/8891080263";
    
    CGFloat pauseLabelWidth = self.view.frame.size.width;
    CGFloat pauseLabelHeight = self.view.frame.size.height;
    CGFloat socialButtonHeight = 35;
    CGFloat socialButtonWidth = socialButtonHeight;
    
    // Social share button
    UIButton *facbookButton = [[UIButton alloc]initWithFrame:CGRectMake(225,
                                                                        10,
                                                                        socialButtonWidth,
                                                                        socialButtonHeight)];
    
    [facbookButton setBackgroundImage:[UIImage imageNamed:@"facebook40.png"] forState:UIControlStateNormal];
    facbookButton.layer.cornerRadius = socialButtonHeight/2;
    facbookButton.layer.masksToBounds = YES;
    facbookButton.backgroundColor = [UIColor whiteColor];
    [facbookButton addTarget:self action:@selector(facebookShare) forControlEvents:UIControlEventTouchDown];
    
    
    UIButton *twitterButton = [[UIButton alloc]initWithFrame:CGRectMake(0,
                                                                        0,
                                                                        socialButtonWidth,
                                                                        socialButtonHeight)];
    [twitterButton setBackgroundImage:[UIImage imageNamed:@"twitter40.png"] forState:UIControlStateNormal];
    twitterButton.frame = CGRectOffset(facbookButton.frame, 45, 0);
    twitterButton.layer.cornerRadius = socialButtonHeight/2;
    twitterButton.backgroundColor = [UIColor whiteColor];
    twitterButton.layer.masksToBounds = YES;
    [twitterButton addTarget:self action:@selector(twitterShare) forControlEvents:UIControlEventTouchDown];
    
    
    // Game Center Label
    UIButton *gamecenterButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 10, socialButtonHeight, socialButtonHeight)];
    [gamecenterButton setBackgroundImage:[UIImage imageNamed:@"gamecenter2.png"] forState:UIControlStateNormal];
    [gamecenterButton addTarget:self action:@selector(showGameCenter) forControlEvents:UIControlEventTouchDown];
    
    CGFloat yoffset = 285;
    CGFloat labelWidth = 90;
    CGFloat labelHeight = 25;
    CGFloat fontSize = 25;
    
    currentScoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, 175, pauseLabelWidth, 65) fontName:@"GeezaPro-Bold" fontSize:65];
    
    
    CustomLabel *comboXLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((320-labelHeight)/2,yoffset,labelHeight,labelHeight)
                                                        fontName:@"GeezaPro-Bold"
                                                        fontSize:fontSize];
    comboXLabel.text = @"x";
    
    CustomLabel *comboLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(comboXLabel.frame.origin.x - 30 - labelWidth,yoffset,labelWidth,labelHeight)
                                                       fontName:@"GeezaPro-Bold"
                                                       fontSize:fontSize];
    comboLabel.text = @"Combo";
    
    
    comLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(comboXLabel.frame.origin.x + 30 + labelHeight ,yoffset,labelWidth,labelHeight)
                                        fontName:@"GeezaPro-Bold"
                                        fontSize:fontSize];
    
    
    
    CustomLabel *bombXLabel = [[CustomLabel alloc]initWithFrame:CGRectMake((320-labelHeight)/2,yoffset+60,labelHeight,labelHeight)
                                                       fontName:@"GeezaPro-Bold"
                                                       fontSize:fontSize];
    bombXLabel.text = @"x";
    
    CustomLabel *bLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(bombXLabel.frame.origin.x - 30 - labelWidth,yoffset+60,labelWidth,labelHeight)
                                                   fontName:@"GeezaPro-Bold"
                                                   fontSize:fontSize];
    bLabel.text = @"Bomb";
    
    bombLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(bombXLabel.frame.origin.x + 30 + labelHeight,yoffset+60,labelWidth,labelHeight)
                                         fontName:@"GeezaPro-Bold"
                                         fontSize:fontSize];
    
    bestScoreLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, 110, pauseLabelWidth, 35) fontName:@"GeezaPro-Bold" fontSize:35];
    bestScoreLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    
    UIImageView *replayView = [[UIImageView alloc]initWithFrame:self.view.frame];
    //replayView.frame = CGRectOffset(replayView.frame, 0, -self.view.frame.size.height);
    replayView.image = [UIImage imageNamed:@"Background.png"];
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
    
    UIImageView *replayBg = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-60)/2,pauseLabelHeight-60-30, 50, 50)];
    replayBg.image = [UIImage imageNamed:@"replayButton.png"];
    replayBg.userInteractionEnabled = YES;
    [self.view addSubview:replayBg];
    
    UITapGestureRecognizer *replayTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(replayGame)];
    [replayBg addGestureRecognizer:replayTap];
    
    [self showReplayView];
}

-(void)showReplayView
{
    comLabel.text = [NSString stringWithFormat:@"%ld",_combos];
    bombLabel.text = [NSString stringWithFormat:@"%ld",_bombs];
    
    NSInteger bestScore = [[NSUserDefaults standardUserDefaults]integerForKey:@"BestScore"];
    
    currentScoreLabel.text = [numFormatter stringFromNumber:[NSNumber numberWithInteger:_score]];
    
    if (_score > bestScore)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:_score forKey:@"BestScore"];
        [[GCHelper sharedInstance] submitScore:_score leaderboardId:kHighScoreLeaderboardId];
        bestScoreLabel.text = @"New Record";
        bestScoreLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        bestScoreLabel.text = [NSString stringWithFormat:@"Best %@",[numFormatter stringFromNumber:[NSNumber numberWithInteger:bestScore]]];
        bestScoreLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    }
}

-(void)replayGame
{
    [self dismissViewControllerAnimated:YES completion:^{
        
        [_delegate replayGame];

    }];
}

#pragma mark - Game center

- (void)showGameCenter
{
    [[GCHelper sharedInstance] showGameCenterViewController:self];
}

- (void)facebookShare
{
    [socialShare setScore:_score];
    [socialShare showShareSheet:kShareTypeFacebook viewController:self];
}

- (void)twitterShare
{
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
