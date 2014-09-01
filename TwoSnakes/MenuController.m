//
//  MenuController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/16.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "MenuController.h"
#import "ClassicGameController.h"
#import "GADInterstitial.h"
#import "ParticleView.h"
#import "CustomLabel.h"

@interface MenuController ()
{
    ClassicGameController *classicGameController;
    GADInterstitial *interstitial_;
    ParticleView *particleView;
    CustomLabel *bombLabel;
    CustomLabel *blockLabel;
}

@property (weak, nonatomic) IBOutlet UIView *blueBomb;
@property (weak, nonatomic) IBOutlet UIView *yellowBomb;
@property (weak, nonatomic) IBOutlet UIView *yellowBody;
@property (weak, nonatomic) IBOutlet UIView *blueBody2;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIView *blueBody1;

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
    
    interstitial_ = [[GADInterstitial alloc] init];
    interstitial_.adUnitID = @"ca-app-pub-5576864578595597/8891080263";
    [interstitial_ loadRequest:[GADRequest request]];
    
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
    bombLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, 568/2-labelSize-labelSize, 320, labelSize) fontName:nil fontSize:labelSize];
    bombLabel.text = @"Bomb";
    bombLabel.hidden = YES;
    [self.view addSubview:bombLabel];
    
    blockLabel = [[CustomLabel alloc]initWithFrame:bombLabel.frame fontName:nil fontSize:labelSize];
    blockLabel.frame = CGRectOffset(blockLabel.frame, 0, labelSize);
    blockLabel.text = @"Block";
    blockLabel.hidden= YES;
    [self.view addSubview:blockLabel];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self setCombo];
}

- (void)setCombo
{
    [UIView animateWithDuration:0.8 animations:^{
        
        _blueBody1.frame = CGRectOffset(_blueBody1.frame, 0, 70);
        _blueBody2.frame = CGRectOffset(_blueBody2.frame, 0, 70);

    } completion:^(BOOL finished) {
        
        CGAffineTransform t1 = _blueBody1.transform;
        CGAffineTransform t2 = _blueBody2.transform;
        CGAffineTransform t3 = _blueBomb.transform;
        
//        _blueBody1.layer.cornerRadius = 3;
//        _blueBody1.layer.borderWidth = 2.5;
//        _blueBody1.layer.borderColor = BlueDotColor.CGColor;
//        
//        _blueBody2.layer.cornerRadius = 3;
//        _blueBody2.layer.borderWidth = 2.5;
//        _blueBody2.layer.borderColor = BlueDotColor.CGColor;
//        
//        _blueBomb.layer.cornerRadius = 3;
//        _blueBomb.layer.borderWidth = 2.5;
//        _blueBomb.layer.borderColor = BlueDotColor.CGColor;
    
        
        [UIView animateWithDuration:0.3
                              delay:0.0
                            options:
         UIViewAnimationOptionCurveEaseInOut
         
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
                                 [self explodeBody:_blueBody1 type:kAssetTypeBlue];
                                 [self explodeBody:_blueBody2 type:kAssetTypeBlue];
                                 [self vExplosion];
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
    

    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        
        beamView1.frame = CGRectMake(posX-1/2,posY-1/2,1,-350);
        beamView2.frame = CGRectMake(posX-1/2,posY-1/2,1,350);
        
        beamView1.alpha = 0.3;
        beamView2.alpha = 0.3;

        _blueBody1.hidden = YES;
        _blueBody2.hidden = YES;
        _blueBomb.hidden = YES;
        _yellowBody.hidden = YES;
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
                blockLabel.hidden = NO;
                _playButton.hidden = NO;
                
                CGAffineTransform b1 =  bombLabel.transform;
                CGAffineTransform b2 =  blockLabel.transform;
                CGAffineTransform p1 =  _playButton.transform;
                
                bombLabel.transform = CGAffineTransformScale(b1, 0.1, 0.1);
                blockLabel.transform = CGAffineTransformScale(b2, 0.1, 0.1);
                _playButton.transform = CGAffineTransformScale(p1, 0.1, 0.1);
                
                [UIView animateWithDuration:0.2 animations:^{
                    
                    bombLabel.transform = b1;
                    blockLabel.transform = b2;
                    _playButton.transform = p1;
                    
                }];
            }];
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

#pragma mark - Show Ad
- (IBAction)showAd:(id)sender 
{
    [interstitial_ presentFromRootViewController:self];
}

#pragma mark - New Game
- (IBAction)playGame:(id)sender {
    
    classicGameController =  [[ClassicGameController alloc]init];
    [self presentViewController:classicGameController animated:YES completion:nil];

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
