//
//  TutorialViewController.m
//  Bomb Blocks
//
//  Created by Jack Yeh on 2014/9/23.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "TutorialViewController.h"
#import "ParticleView.h"

@interface TutorialViewController ()
@property (weak, nonatomic) IBOutlet UILabel *tut1;
@property (weak, nonatomic) IBOutlet UILabel *tut2;
@property (weak, nonatomic) IBOutlet UILabel *tut3;
@property (weak, nonatomic) IBOutlet UILabel *tut4;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;
@property (weak, nonatomic) IBOutlet UIView *labelGroupView;


@end

@implementation TutorialViewController

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
    UIImageView *bgImageView = [[UIImageView alloc]initWithImage:_bgImage];
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    
    _labelGroupView.frame = CGRectOffset(_labelGroupView.frame,
                                         (screenWidth-_labelGroupView.frame.size.width)/2 ,
                                         (screenHeight-_labelGroupView.frame.size.height)/2);
    
    _tut1.text = [NSString stringWithFormat:@"1. %@", NSLocalizedString(@"Swipe to move blocks", nil)];
    _tut2.text = [NSString stringWithFormat:@"2. %@", NSLocalizedString(@"Line up blocks to cancel blocks", nil)];
    _tut3.text = [NSString stringWithFormat:@"3. %@", NSLocalizedString(@"Cancel more blocks to pop bombs", nil)];
    _tut4.text = [NSString stringWithFormat:@"4. %@", NSLocalizedString(@"Line up with blocks to trigger bomb", nil)];
    
    
    
    _doneButton.frame = CGRectMake((screenWidth-40)/2,screenHeight-40-30,40,40);
    _doneButton.layer.cornerRadius = 20;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)doneAction:(id)sender {
    
    [self buttonAnimation:sender];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)buttonAnimation:(UIButton *)button
{
    [_particleView playButtonSound];
    CGAffineTransform t = button.transform;
    
    [UIView animateWithDuration:0.15 animations:^{
        
        button.transform = CGAffineTransformScale(t, 0.85, 0.85);
        
    } completion:^(BOOL finished) {
        
        button.transform = t;
    }];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}
@end
