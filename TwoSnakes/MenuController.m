//
//  MenuController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/16.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "MenuController.h"
#import "ClassicGameController.h"
#import "ParticleView.h"
#import "CustomLabel.h"
#import "MKAppDelegate.h"
#import "FastHandGameViewController.h"

@interface MenuController ()
{
//    ClassicGameController *classicGameController;
//    FastHandGameViewController *fastHandGameController;
    ParticleView *particleView;
    CustomLabel *bombLabel;
    CustomLabel *blockLabel;
    CustomLabel *boomLabel;
    UIImageView *launchBomb;
    MKAppDelegate  *appDelegate;
    BOOL loadAnim;
}

@property (weak, nonatomic) IBOutlet UIView *blueBomb;
@property (weak, nonatomic) IBOutlet UIView *yellowBomb;
@property (weak, nonatomic) IBOutlet UIView *yellowBody;
@property (weak, nonatomic) IBOutlet UIView *blueBody2;
@property (weak, nonatomic) IBOutlet UIView *blueBody1;
@property (weak, nonatomic) IBOutlet UIView *classicView;
@property (weak, nonatomic) IBOutlet UIView *fastHandView;
@property (weak, nonatomic) IBOutlet UILabel *classicLabel;
@property (weak, nonatomic) IBOutlet UILabel *fastHandLabel;


@end

@implementation MenuController

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
    // Do any additional setup after loading the view from its nib.

    // Configure the SKView
    SKView * skView = [[SKView alloc]initWithFrame:self.view.frame];
    skView.backgroundColor = [UIColor clearColor];
    
    // Create and configure the scene.
    particleView = [[ParticleView alloc]initWithSize:skView.bounds.size];
    particleView.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [skView presentScene:particleView];
    [self.view addSubview:skView];
    
    [self.view sendSubviewToBack:skView];
    
    CGFloat labelSize = 65;

    bombLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, 568/2-labelSize-labelSize-10, 320, labelSize) fontSize:labelSize];
    bombLabel.text = NSLocalizedString(@"bomb", nil);
    bombLabel.hidden = YES;
    
    boomLabel = [[CustomLabel alloc]initWithFrame:bombLabel.frame fontSize:labelSize];
    boomLabel.frame = CGRectOffset(boomLabel.frame, 0, labelSize+10);
    boomLabel.text = NSLocalizedString(@"Boom",nil);
    boomLabel.hidden= YES;
    
    blockLabel = [[CustomLabel alloc]initWithFrame:boomLabel.frame fontSize:labelSize];
    blockLabel.frame = CGRectOffset(blockLabel.frame, 0, labelSize+10);
    blockLabel.text = NSLocalizedString(@"Blocks",nil);
    blockLabel.hidden= YES;
    
    _fastHandLabel.text = NSLocalizedString(@"Fast Hand",nil);
    _classicLabel.text = NSLocalizedString(@"Classic",nil);
    

    NSString * language = [[NSLocale preferredLanguages] objectAtIndex:0];
    if ([language isEqualToString:@"zh-Hans"] || [language isEqualToString:@"zh-Hant"]) {
        [self.view addSubview:bombLabel];
        [self.view addSubview:boomLabel];
        [self.view addSubview:blockLabel];
        launchBomb = [[UIImageView alloc]initWithFrame:CGRectMake(170, 568/2-labelSize-labelSize-52*2, 52, 52)];
        


    } else {
        [self.view addSubview:bombLabel];
        [self.view addSubview:boomLabel];
        launchBomb = [[UIImageView alloc]initWithFrame:CGRectMake(200, 568/2-labelSize-labelSize-52*2+10, 52, 52)];
    }
    
//    bombLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, 568/2-labelSize-labelSize, 320, labelSize) fontSize:labelSize];
//    bombLabel.text = @"Bomb";
//    bombLabel.hidden = YES;
//    [self.view addSubview:bombLabel];
//    
//    boomLabel = [[CustomLabel alloc]initWithFrame:bombLabel.frame fontSize:labelSize];
//    boomLabel.frame = CGRectOffset(boomLabel.frame, 0, labelSize);
//    boomLabel.text = @"Blocks";
//    boomLabel.hidden= YES;
//    [self.view addSubview:boomLabel];
//    
//    blockLabel = [[CustomLabel alloc]initWithFrame:boomLabel.frame fontSize:labelSize];
//    blockLabel.frame = CGRectOffset(blockLabel.frame, 0, labelSize);
//    blockLabel.text = @"Blocks";
//    blockLabel.hidden= YES;
//    [self.view addSubview:blockLabel];
//    launchBomb = [[UIImageView alloc]initWithFrame:CGRectMake(200, 568/2-labelSize-labelSize-52*2+10, 52, 52)];

    launchBomb.image = [UIImage imageNamed:@"bomb_yellow.png"];
    launchBomb.hidden = YES;
    
    UIImageView *bombType = [[UIImageView alloc]initWithFrame:CGRectMake(14, 14, 24, 24)];
    bombType.image = [UIImage imageNamed:@"explode.png"];
    [launchBomb addSubview:bombType];
    
    [self.view addSubview:launchBomb];
    
    UITapGestureRecognizer *playClassic = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playClassicGame)];
    [_classicView addGestureRecognizer:playClassic];
    
    UITapGestureRecognizer *playFastHand= [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playfastHandGame)];
    [_fastHandView addGestureRecognizer:playFastHand];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    loadAnim = YES;
    
//    _classicView.layer.cornerRadius = 35;
//    _fastHandView.layer.cornerRadius = 35;

}

-(void)viewDidAppear:(BOOL)animated
{
    if (loadAnim) {
        
        [particleView introMoveSound];
        [UIView animateWithDuration:1.0 animations:^{
            
            _blueBody2.frame = CGRectOffset(_blueBody2.frame, 0, 70);
            
        } completion:^(BOOL finished) {
            
            _yellowBody.alpha = 1;
            CGAffineTransform yellowT = _yellowBody.transform;
            _yellowBody.transform = CGAffineTransformScale(yellowT, 0.3, 0.3);
            
            [UIView animateWithDuration:0.15 animations:^{
                
                _yellowBody.transform = yellowT;
                
            } completion:^(BOOL finished) {
                
                [particleView introMoveSound];
                [UIView animateWithDuration:1.0 animations:^{
                    
                    _blueBody2.frame = CGRectOffset(_blueBody2.frame, -71, 0);
                    _yellowBody.frame = CGRectOffset(_yellowBody.frame, -71, 0);

                } completion:^(BOOL finished) {
                    
                    _blueBody1.alpha = 1;
                    CGAffineTransform blueT = _yellowBody.transform;
                    _blueBody1.transform = CGAffineTransformScale(blueT, 0.3, 0.3);
                    
                    [UIView animateWithDuration:0.15 animations:^{
                        
                        _blueBody1.transform = blueT;
                        
                    } completion:^(BOOL finished) {
                        
                        [self setCombo];
                        
                    }];
                }];
            }];
        }];
        
        loadAnim = NO;
    }
}

- (void)setCombo
{
    
    [particleView introMoveSound];

    [UIView animateWithDuration:1.0 animations:^{
        
        _blueBody1.frame = CGRectOffset(_blueBody1.frame, 0, 69);
        _blueBody2.frame = CGRectOffset(_blueBody2.frame, 0, 69);

    } completion:^(BOOL finished) {
        
        CGAffineTransform t1 = _blueBody1.transform;
        CGAffineTransform t2 = _blueBody2.transform;
        CGAffineTransform t3 = _blueBomb.transform;
    
        _yellowBomb.alpha = 1;
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             _blueBody1.transform = CGAffineTransformScale(t1, 0.5, 0.5);
                             _blueBody2.transform = CGAffineTransformScale(t2, 0.5, 0.5);
                             _blueBomb.transform = CGAffineTransformScale(t3, 0.5, 0.5);
                         }
                         completion:^(BOOL finished){
                             
                             [UIView animateWithDuration:0.3 animations:^{
                                 _blueBody1.transform = t1;
                                 _blueBody2.transform = t2;
                                 _blueBomb.transform = t3;

                             } completion:^(BOOL finished) {
                                 _blueBody1.hidden = YES;
                                 _blueBody2.hidden = YES;
                                 _blueBomb.hidden = YES;
                                 _yellowBody.hidden = YES;

                                 [particleView playBreakSound];

                                 [self vExplosion];
                                 [self explodeBody:_blueBody1 type:kAssetTypeBlue];
                                 [self explodeBody:_blueBody2 type:kAssetTypeBlue];

                             }];
                         }];
    }];
}

- (void)vExplosion
{
    UIView *beamView1;
    UIView *beamView2;
    CGFloat beamSize = 10;
    
    float posX = _blueBomb.center.x;
    float posY = _blueBomb.center.y;
    
    beamView1 = [[UIView alloc]initWithFrame:CGRectMake(posX-beamSize/2,posY-beamSize/2,beamSize,0)];
    beamView2 = [[UIView alloc]initWithFrame:CGRectMake(posX-beamSize/2,posY-beamSize/2,beamSize,0)];

    [self.view addSubview:beamView1];
    [self.view addSubview:beamView2];
    
    beamView1.backgroundColor = BlueDotColor;
    beamView2.backgroundColor = BlueDotColor;
    
    beamView1.alpha = 0.8;
    beamView2.alpha = 0.8;

    [particleView explodeSound];

    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        beamView1.frame = CGRectMake(posX-1/2,posY-1/2,1,-350);
        beamView2.frame = CGRectMake(posX-1/2,posY-1/2,1,350);
        
        beamView1.alpha = 0.3;
        beamView2.alpha = 0.3;

        [self explodeBody:_yellowBody type:kAssetTypeYellow];
        
    } completion:^(BOOL finished) {
        
        [self bombExplosionSquare];

        [beamView1 removeFromSuperview];
        [beamView2 removeFromSuperview];
    }];
}

-(void)bombExplosionSquare
{
    CGFloat beamSize1 = 640;
    UIView *beamView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, beamSize1, beamSize1)];
    beamView.center = _yellowBomb.center;
    beamView.layer.borderWidth = 20;
    beamView.layer.borderColor = YellowDotColor.CGColor;
    beamView.layer.cornerRadius = beamSize1/2;
    beamView.alpha = 1;
    
    [self.view addSubview:beamView];
    
    CGAffineTransform t = beamView.transform;
    
    beamView.transform = CGAffineTransformScale(t, 0.3, 0.3);
    
    _yellowBomb.hidden = YES;
    [particleView explodeSquareSound];
    [self explodeBody:_yellowBomb type:kAssetTypeYellow];
    
    [UIView animateWithDuration:0.6 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        
        beamView.alpha = 0.0;
        
        beamView.transform = t;
        
    } completion:^(BOOL finished) {
        
        [beamView removeFromSuperview];
        
        UIView *blinkView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 640, 640)];
        blinkView.center = self.view.center;
        blinkView.backgroundColor = [UIColor colorWithWhite:1.000 alpha:0.700];
        blinkView.alpha = 0;
        blinkView.layer.cornerRadius = 320;
        [self.view addSubview:blinkView];
        
        [UIView animateWithDuration:0.15 animations:^{
            
            blinkView.alpha = 1;

        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.3 animations:^{
                blinkView.transform = CGAffineTransformScale(blinkView.transform, 0.1, 0.1);

            } completion:^(BOOL finished) {
                [blinkView removeFromSuperview];
                bombLabel.hidden = NO;
                boomLabel.hidden = NO;
                blockLabel.hidden = NO;
                //_playButtonView.hidden = NO;

                CGAffineTransform b1 =  bombLabel.transform;
                CGAffineTransform b2 =  blockLabel.transform;
                CGAffineTransform b3 =  boomLabel.transform;

                bombLabel.transform = CGAffineTransformScale(b1, 0.1, 0.1);
                blockLabel.transform = CGAffineTransformScale(b2, 0.1, 0.1);
                boomLabel.transform = CGAffineTransformScale(b3, 0.1, 0.1);

                [UIView animateWithDuration:0.2 animations:^{
                    
                    bombLabel.transform = b1;
                    blockLabel.transform = b2;
                    boomLabel.transform = b3;
                    
                } completion:^(BOOL finished) {
                    
                    [self launchBombAnimation];
                    
                }];
            }];
        }];
    }];
}

- (void)launchBombAnimation
{
    launchBomb.hidden = NO;
    [UIView animateWithDuration:0.15 animations:^{
        
        launchBomb.frame = CGRectOffset(launchBomb.frame, 0, 52);
        
    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.15 animations:^{
            
            launchBomb.frame = CGRectOffset(launchBomb.frame, 0, -52/2);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:0.15 animations:^{
                
                launchBomb.frame = CGRectOffset(launchBomb.frame, 15 , (52/2+5));
                
            } completion:^(BOOL finished) {
                
                launchBomb.transform = CGAffineTransformRotate(launchBomb.transform, M_PI_4/2);
                
                if([[NSUserDefaults standardUserDefaults] boolForKey:@"music"]) {
                    
                    [appDelegate.audioPlayer play];
                    appDelegate.audioPlayer.volume = 0;

                    [self firstLauchMusicPlay];
                }

                [self gameButtonAnimation];
            }];
        }];
    }];
}

- (void)gameButtonAnimation
{
    [UIView animateWithDuration:0.5 animations:^{
        
        _classicView.frame = CGRectOffset(_classicView.frame, -235, 0);

    } completion:^(BOOL finished) {
        
        [UIView animateWithDuration:0.5 animations:^{
            
            _fastHandView.frame = CGRectOffset(_fastHandView.frame, 235, 0);
            
        }];
    }];
}


-(void)explodeBody:(UIView *)body type:(AssetType)type
{
    CGRect bodyFrame = [body convertRect:body.bounds toView:self.view];
    bodyFrame.origin.y = self.view.frame.size.height - bodyFrame.origin.y;
    CGFloat posX = bodyFrame.origin.x+bodyFrame.size.width/2;
    CGFloat posY = bodyFrame.origin.y-bodyFrame.size.height/2;
    [particleView newExplosionWithPosX:posX andPosY:posY assetType:type];
}

- (void)firstLauchMusicPlay
{
    if (appDelegate.audioPlayer.volume < 1) {
        
        appDelegate.audioPlayer.volume +=  0.1;

        [self performSelector:@selector(firstLauchMusicPlay) withObject:nil afterDelay:0.2];
    }
}

#pragma mark - New Game
- (void)playClassicGame
{
    [particleView playGameSound];
    
    CGAffineTransform t = _classicView.transform;
    _classicView.transform = CGAffineTransformScale(t, 0.9, 0.9);
    
    [UIView animateWithDuration:0.2 animations:^{
        
        _classicView.transform = CGAffineTransformScale(t, 1.1, 1.1);

    } completion:^(BOOL finished) {
        
        _classicView.transform = t;
        ClassicGameController *classicGameController =  [[ClassicGameController alloc]init];
        [self presentViewController:classicGameController animated:YES completion:nil];
    }];
}

- (void)playfastHandGame
{
    [particleView playGameSound];
    
    CGAffineTransform t = _fastHandView.transform;
    _fastHandView.transform = CGAffineTransformScale(t, 0.9, 0.9);
    
    [UIView animateWithDuration:0.2 animations:^{
        
        _fastHandView.transform = CGAffineTransformScale(t, 1.1, 1.1);
        
    } completion:^(BOOL finished) {
        
        _fastHandView.transform = t;
        FastHandGameViewController *fastHandGameController =  [[FastHandGameViewController alloc]init];
        [self presentViewController:fastHandGameController animated:YES completion:nil];
    }];
}

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

@end
