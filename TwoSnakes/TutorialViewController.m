//
//  TutorialViewController.m
//  Bomb Blocks
//
//  Created by Jack Yeh on 2014/9/23.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "TutorialViewController.h"
#import "ParticleView.h"
#import "CustomLabel.h"

@interface TutorialViewController ()
{
    UIView *blockTypeView;
    UIView *bombTypeView;
    CustomLabel *howToPlayLabel;
    CGFloat titleSize;
    CGFloat titlePosY;
    CGRect nextButtonFrame;
    CGRect previousButtonFrame;
    UIButton *mainNextButton;
    UIButton *mainCloseButton;
    NSString * language;
    CGFloat blockFontSize;
    CGFloat subFontSize;

}
@property (weak, nonatomic) IBOutlet UILabel *tut1;
@property (weak, nonatomic) IBOutlet UILabel *tut2;
@property (weak, nonatomic) IBOutlet UILabel *tut3;
@property (weak, nonatomic) IBOutlet UILabel *tut4;
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
    
//    UIImageView *bgImageView = [[UIImageView alloc]initWithImage:_bgImage];
    UIImageView *bgImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"Background.png"]];
    [self.view addSubview:bgImageView];
    [self.view sendSubviewToBack:bgImageView];
    language = [[NSLocale preferredLanguages] objectAtIndex:0];
    titleSize = 45;
    titlePosY = 10;
    blockFontSize = 20;
    // If Japanese sub font size = 14 , else 17;
    subFontSize = 17;
    _labelGroupView.frame = CGRectOffset(_labelGroupView.frame,
                                         (screenWidth-_labelGroupView.frame.size.width)/2 ,
                                         (screenHeight-_labelGroupView.frame.size.height)/2);
    
    if ([language isEqualToString:@"ja"]) {
        _tut1.font = [UIFont fontWithName:@"DINAlternate-Bold" size:17];
        _tut2.font = [UIFont fontWithName:@"DINAlternate-Bold" size:17];
        _tut3.font = [UIFont fontWithName:@"DINAlternate-Bold" size:17];
        _tut4.font = [UIFont fontWithName:@"DINAlternate-Bold" size:17];
        titleSize = 35;
        blockFontSize = 17;
        subFontSize = 14;
    }
    
    _tut1.text = [NSString stringWithFormat:@"1. %@", NSLocalizedString(@"Swipe to move blocks", nil)];
    _tut2.text = [NSString stringWithFormat:@"2. %@", NSLocalizedString(@"Line up blocks to cancel blocks", nil)];
    _tut3.text = [NSString stringWithFormat:@"3. %@", NSLocalizedString(@"Cancel more blocks to pop bombs", nil)];
    _tut4.text = [NSString stringWithFormat:@"4. %@", NSLocalizedString(@"Line up with blocks to trigger bomb", nil)];
    
    nextButtonFrame = CGRectMake(screenWidth-50,screenHeight-50,40,40);
    previousButtonFrame = CGRectMake(10,screenHeight-50,40,40);
    
    mainNextButton = [[UIButton alloc]initWithFrame:nextButtonFrame];
    [mainNextButton setImage:[UIImage imageNamed:@"nextButton"] forState:UIControlStateNormal];
    [mainNextButton addTarget:self action:@selector(nextToBlock) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:mainNextButton];
    
    mainCloseButton = [[UIButton alloc]initWithFrame:previousButtonFrame];
    [mainCloseButton setImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
    [mainCloseButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:mainCloseButton];
    

    howToPlayLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, titlePosY, screenWidth, titleSize) fontSize:titleSize];
    howToPlayLabel.text = NSLocalizedString(@"How To Play",nil);
    [self.view addSubview:howToPlayLabel];
}

-(void)nextToBlock
{
    _labelGroupView.hidden = YES;
    howToPlayLabel.hidden = YES;
    mainCloseButton.hidden = YES;
    mainNextButton.hidden = YES;
    [self showBlockTypeView];
}

-(void)previousToMain
{
    [UIView animateWithDuration:0.5 animations:^{
        blockTypeView.frame = CGRectOffset(blockTypeView.frame, screenWidth, 0);
    }completion:^(BOOL finished) {
        _labelGroupView.hidden = NO;
        howToPlayLabel.hidden = NO;
        mainCloseButton.hidden = NO;
        mainNextButton.hidden = NO;
    }];
}

-(void)nextToBomb
{
    blockTypeView.frame = CGRectOffset(blockTypeView.frame, -screenWidth, 0);
    [self showBombTypeView];
}

-(void)previousToBlock
{
    [UIView animateWithDuration:0.5 animations:^{
        bombTypeView.frame = CGRectOffset(bombTypeView.frame, screenWidth, 0);
    }completion:^(BOOL finished) {
        blockTypeView.frame = CGRectOffset(blockTypeView.frame, screenWidth, 0);
    }];
}

- (void)showBlockTypeView
{
    blockTypeView = [[UIView alloc]initWithFrame:self.view.frame];
    blockTypeView.frame = CGRectOffset(blockTypeView.frame, screenWidth,0);
    [self.view addSubview:blockTypeView];
    
    UIButton *nextButton = [[UIButton alloc]initWithFrame:nextButtonFrame];
    [nextButton setImage:[UIImage imageNamed:@"nextButton"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextToBomb) forControlEvents:UIControlEventTouchDown];
    [blockTypeView addSubview:nextButton];
    
    UIButton *previousButton = [[UIButton alloc]initWithFrame:previousButtonFrame];
    [previousButton setImage:[UIImage imageNamed:@"previousButton"] forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousToMain) forControlEvents:UIControlEventTouchDown];
    [blockTypeView addSubview:previousButton];
    
    CustomLabel *titleLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, titlePosY, screenWidth, titleSize) fontSize:titleSize];
    titleLabel.text = NSLocalizedString(@"Block Type",nil);
    [blockTypeView addSubview:titleLabel];
    
    CGFloat imageHeight = 45;
    CGFloat imageWidth = 249;
    CGFloat xCord = (screenWidth - imageWidth)/2;
    CGFloat labelSize = 60;
    CGFloat gapBetweenBlock = 30;
    CGFloat gapOffest = 5;
    CGFloat yStart = titleLabel.frame.origin.y+titleSize+20;
    CGFloat descOffsetX = 20;
    CGFloat descLabelWidth = screenWidth - descOffsetX*2;


    // Level 1
    CustomLabel *level1Label = [[CustomLabel alloc]initWithFrame:CGRectMake(descOffsetX,
                                                                            yStart,
                                                                            descLabelWidth,
                                                                            labelSize)
                                                        fontSize:blockFontSize];
    level1Label.numberOfLines = -1;
    level1Label.lineBreakMode = NSLineBreakByTruncatingTail;
    level1Label.text = NSLocalizedString(@"Type A : Movable , 1 x combo to eliminate", nil);
    [blockTypeView addSubview:level1Label];
    UIImageView *level1Block = [[UIImageView alloc]initWithFrame:CGRectMake(xCord,
                                                                            level1Label.frame.origin.y+labelSize+gapOffest,
                                                                            imageWidth,
                                                                            imageHeight)];
    level1Block.image = [UIImage imageNamed:@"Level1Block.png"];
    
    // Level 2
    CustomLabel *level2Label = [[CustomLabel alloc]initWithFrame:CGRectMake(descOffsetX,
                                                                            level1Block.frame.origin.y+imageHeight+gapBetweenBlock,
                                                                            descLabelWidth,
                                                                            labelSize)
                                                        fontSize:blockFontSize];
    level2Label.numberOfLines = -1;
    level2Label.text = NSLocalizedString(@"Type B : Unmovable , 2 x combo to eliminate", nil);
    [blockTypeView addSubview:level2Label];
    UIImageView *level2Block = [[UIImageView alloc]initWithFrame:CGRectMake(xCord,
                                                                            level2Label.frame.origin.y+labelSize+gapOffest,
                                                                            imageWidth,
                                                                            imageHeight)];
    level2Block.image = [UIImage imageNamed:@"Level2Block.png"];
    
    // Level 3
    CustomLabel *level3Label = [[CustomLabel alloc]initWithFrame:CGRectMake(descOffsetX,
                                                                            level2Block.frame.origin.y+imageHeight+gapBetweenBlock,
                                                                            descLabelWidth,
                                                                            labelSize)
                                                        fontSize:blockFontSize];
    level3Label.numberOfLines = -1;
    level3Label.text = NSLocalizedString(@"Type C : Unmovable , 3 x combo to eliminate", nil);
    [blockTypeView addSubview:level3Label];
    UIImageView *level3Block = [[UIImageView alloc]initWithFrame:CGRectMake(xCord,
                                                                            level3Label.frame.origin.y+labelSize+gapOffest,
                                                                            imageWidth,
                                                                            imageHeight)];
    level3Block.image = [UIImage imageNamed:@"Level3Block.png"];
    
    [blockTypeView addSubview:level1Block];
    [blockTypeView addSubview:level2Block];
    [blockTypeView addSubview:level3Block];
    
    [UIView animateWithDuration:0.5 animations:^{
        blockTypeView.frame = CGRectOffset(blockTypeView.frame,  -screenWidth,0);
    }];
}

-(void)showBombTypeView
{
    bombTypeView = [[UIView alloc]initWithFrame:self.view.frame];
    bombTypeView.frame = CGRectOffset(bombTypeView.frame, screenWidth, 0);
    [self.view addSubview:bombTypeView];
    
    UIButton *closeButton = [[UIButton alloc]initWithFrame:nextButtonFrame];
    [closeButton setImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
    [closeButton addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchDown];
    [bombTypeView addSubview:closeButton];
    
    UIButton *previousButton = [[UIButton alloc]initWithFrame:previousButtonFrame];
    [previousButton setImage:[UIImage imageNamed:@"previousButton"] forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousToBlock) forControlEvents:UIControlEventTouchDown];
    [bombTypeView addSubview:previousButton];
    
    CustomLabel *titleLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(0, titlePosY, screenWidth, titleSize) fontSize:titleSize];
    titleLabel.text = NSLocalizedString(@"Bomb Type",nil);
    [bombTypeView addSubview:titleLabel];
    
    CGFloat imageSize = 45;
    CGFloat xCord = 10;
    CGFloat xGap = 20;
    CGFloat yOffset = imageSize+40;
    CGFloat labelWidth = screenWidth - (xCord+imageSize+xGap+5);
    CGFloat fontSize = 23;

    CGFloat yStart = titleLabel.frame.origin.y+titleSize+40;
    CGFloat descLabelHeight = 50;
    
    // Vertical Bomb
    UIImageView *verticalBombView = [[UIImageView alloc]initWithFrame:CGRectMake(xCord, yStart , imageSize, imageSize)];
    verticalBombView.image = [UIImage imageNamed:@"verticalBomb.png"];
    CustomLabel *verticalLabel  = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+imageSize+xGap,
                                                                               yStart-20,
                                                                               labelWidth,
                                                                               imageSize)
                                                           fontSize:fontSize];
    verticalLabel.text = NSLocalizedString(@"V-Bomb", nil) ;
    verticalLabel.textAlignment = NSTextAlignmentLeft;
    
    CustomLabel *verticalDescLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(xCord+imageSize+xGap, yStart-20, labelWidth, descLabelHeight) fontSize:subFontSize];
    verticalDescLabel.frame = CGRectOffset(verticalDescLabel.frame, 0, imageSize-10);
    verticalDescLabel.textAlignment = NSTextAlignmentLeft;
    verticalDescLabel.numberOfLines = -1;
    verticalDescLabel.text = NSLocalizedString(@"Trigger to eliminate all blocks/bombs in vertical line",nil);
    verticalDescLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];
    
    [bombTypeView addSubview:verticalBombView];
    [bombTypeView addSubview:verticalLabel];
    [bombTypeView addSubview:verticalDescLabel];
    
    // Horizontal Bomb
    UIImageView *horizontalBombView = [[UIImageView alloc]initWithFrame:verticalBombView.frame];
    horizontalBombView.frame = CGRectOffset(verticalBombView.frame, 0, yOffset);
    horizontalBombView.image = [UIImage imageNamed:@"horizontalBomb.png"];
    
    CustomLabel *horizontalLabel  = [[CustomLabel alloc]initWithFrame:verticalLabel.frame fontSize:fontSize];
    horizontalLabel.frame = CGRectOffset(verticalLabel.frame, 0, yOffset);
    horizontalLabel.text = NSLocalizedString(@"H-Bomb", nil);
    horizontalLabel.textAlignment = NSTextAlignmentLeft;
    
    CustomLabel *horizontalDescLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(horizontalLabel.frame.origin.x,
                                                                                    horizontalLabel.frame.origin.y,
                                                                                    labelWidth,
                                                                                    descLabelHeight)
                                                                fontSize:subFontSize];
    
    horizontalDescLabel.frame = CGRectOffset(horizontalDescLabel.frame, 0, imageSize-10);
    horizontalDescLabel.textAlignment = NSTextAlignmentLeft;
    horizontalDescLabel.numberOfLines = -1;
    horizontalDescLabel.text = NSLocalizedString(@"Trigger to eliminate all blocks/bombs in horizontal line",nil);
    horizontalDescLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];

    [bombTypeView addSubview:horizontalBombView];
    [bombTypeView addSubview:horizontalLabel];
    [bombTypeView addSubview:horizontalDescLabel];
    
    // Random Bomb
    UIImageView *randomBombView = [[UIImageView alloc]initWithFrame:horizontalBombView.frame];
    randomBombView.frame = CGRectOffset(horizontalBombView.frame, 0, yOffset);
    randomBombView.image = [UIImage imageNamed:@"randomBombTut.png"];
    CustomLabel *randomLabel  = [[CustomLabel alloc]initWithFrame:horizontalLabel.frame fontSize:fontSize];
    randomLabel.frame = CGRectOffset(horizontalLabel.frame, 0, yOffset);
    randomLabel.text = NSLocalizedString(@"R-Bomb", nil);
    randomLabel.textAlignment = NSTextAlignmentLeft;
    
    CustomLabel *randomDescLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(randomLabel.frame.origin.x,
                                                                                randomLabel.frame.origin.y,
                                                                                labelWidth,
                                                                                descLabelHeight)
                                                            fontSize:subFontSize];
    
    randomDescLabel.frame = CGRectOffset(randomDescLabel.frame, 0, imageSize-10);
    randomDescLabel.textAlignment = NSTextAlignmentLeft;
    randomDescLabel.numberOfLines = -1;
    randomDescLabel.text = NSLocalizedString(@"Trigger to randomly swap all blocks postion",nil);
    randomDescLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];

    [bombTypeView addSubview:randomBombView];
    [bombTypeView addSubview:randomLabel];
    [bombTypeView addSubview:randomDescLabel];
    
    // Circle Bomb
    UIImageView *circleBombView = [[UIImageView alloc]initWithFrame:randomBombView.frame];
    circleBombView.frame = CGRectOffset(randomBombView.frame, 0, yOffset);
    circleBombView.image = [UIImage imageNamed:@"circleBomb.png"];
    CustomLabel *circleLabel  = [[CustomLabel alloc]initWithFrame:randomLabel.frame fontSize:fontSize];
    circleLabel.frame = CGRectOffset(randomLabel.frame, 0, yOffset);
    circleLabel.text = NSLocalizedString(@"S-Bomb", nil);
    circleLabel.textAlignment = NSTextAlignmentLeft;

    CustomLabel *circleDescLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(circleLabel.frame.origin.x,
                                                                                circleLabel.frame.origin.y,
                                                                                labelWidth,
                                                                                descLabelHeight)
                                                            fontSize:subFontSize];
    
    circleDescLabel.frame = CGRectOffset(circleDescLabel.frame, 0, imageSize-10);
    circleDescLabel.textAlignment = NSTextAlignmentLeft;
    circleDescLabel.numberOfLines = -1;
    circleDescLabel.text = NSLocalizedString(@"Trigger to eliminate blocks/bombs within the circle",nil);
    circleDescLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];

    [bombTypeView addSubview:circleBombView];
    [bombTypeView addSubview:circleLabel];
    [bombTypeView addSubview:circleDescLabel];
    
    // Color Bomb
    UIImageView *colorBombView = [[UIImageView alloc]initWithFrame:circleBombView.frame];
    colorBombView.frame = CGRectOffset(circleBombView.frame, 0, yOffset);
    colorBombView.image = [UIImage imageNamed:@"colorBomb.png"];
    CustomLabel *colorLabel  = [[CustomLabel alloc]initWithFrame:circleLabel.frame fontSize:fontSize];
    colorLabel.frame = CGRectOffset(circleLabel.frame, 0, yOffset);
    colorLabel.text =NSLocalizedString(@"C-Bomb", nil);
    colorLabel.textAlignment = NSTextAlignmentLeft;
    
    CustomLabel *colorDescLabel = [[CustomLabel alloc]initWithFrame:CGRectMake(colorLabel.frame.origin.x,
                                                                               colorLabel.frame.origin.y,
                                                                               labelWidth,
                                                                               descLabelHeight)
                                                           fontSize:subFontSize];
    
    colorDescLabel.frame = CGRectOffset(colorDescLabel.frame, 0, imageSize-10);
    colorDescLabel.textAlignment = NSTextAlignmentLeft;
    colorDescLabel.numberOfLines = -1;
    colorDescLabel.text = NSLocalizedString(@"Trigger to eliminate blocks/bombs with same color",nil);
    colorDescLabel.textColor = [UIColor colorWithWhite:0.400 alpha:1.000];

    [bombTypeView addSubview:colorBombView];
    [bombTypeView addSubview:colorLabel];
    [bombTypeView addSubview:colorDescLabel];
    
    [UIView animateWithDuration:0.5 animations:^{
        bombTypeView.frame = CGRectOffset(bombTypeView.frame, -screenWidth,0);
    }];
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
//    [_particleView playButtonSound];
    [_particleView playSound:kSoundTypeButtonSound];

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
