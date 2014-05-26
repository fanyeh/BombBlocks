//
//  LevelMakerController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/22.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "LevelMakerController.h"
#import "LevelTrialController.h"
#import "GamePad.h"
#import "GameAssetCell.h"
#import "GameAsset.h"
#import "Snake.h"

@interface LevelMakerController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *gameAssetTable;
    NSMutableArray *assetLibrary;
    BOOL assetTableIsShow;
    GameAsset *currentAsset;
}
@end

@implementation LevelMakerController

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
    self.gamePad = [[GamePad alloc]initEmptyGamePad];
    [self.view addSubview:self.gamePad];
    
    UIPanGestureRecognizer *panBlock = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(blockPan:)];
    [self.gamePad addGestureRecognizer:panBlock];
    

    
    currentAsset = [[GameAsset alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
    currentAsset.layer.borderWidth = 1;
    [self.view addSubview:currentAsset];
    UITapGestureRecognizer *currentAssetTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showAssetTable)];
    [currentAsset addGestureRecognizer:currentAssetTap];
    
    gameAssetTable = [[UITableView alloc]initWithFrame:CGRectMake(320, 0, 120, self.view.frame.size.height)];
    gameAssetTable.delegate = self;
    gameAssetTable.dataSource = self;
    [gameAssetTable registerNib:[UINib nibWithNibName:@"GameAssetCell" bundle:nil] forCellReuseIdentifier:@"GameAssetCell"];
    [self.view addSubview:gameAssetTable];
    
    assetLibrary = [[NSMutableArray alloc]init];
    
    GameAsset *wallAsset = [[GameAsset alloc]init];
    [wallAsset setAssetType:kAssetTypeWall];
    
    GameAsset *monsterAsset = [[GameAsset alloc]init];
    [monsterAsset setAssetType:kAssetTypeMonster];
    
    GameAsset *shieldAsset = [[GameAsset alloc]init];
    [shieldAsset setAssetType:kAssetTypeShield];
    
    GameAsset *swordAsset = [[GameAsset alloc]init];
    [swordAsset setAssetType:kAssetTypeSword];

    GameAsset *magicAsset = [[GameAsset alloc]init];
    [magicAsset setAssetType:kAssetTypeMagic];

    
    [assetLibrary addObject:wallAsset];
    [assetLibrary addObject:monsterAsset];
    [assetLibrary addObject:shieldAsset];
    [assetLibrary addObject:swordAsset];
    [assetLibrary addObject:magicAsset];
    
    assetTableIsShow = NO;
    
    for (UIView *v in [self.gamePad assetArray]) {
        UITapGestureRecognizer *colorChangeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeBlockColor:)];
        [v addGestureRecognizer:colorChangeTap];
    }
    
    UIButton *trialButton = [[UIButton alloc]initWithFrame:CGRectMake(110, 10, 100, 50)];
    [trialButton setTitle:@"Trial" forState:UIControlStateNormal];
    trialButton.titleLabel.textColor = [UIColor blackColor];
    [trialButton addTarget:self action:@selector(tryGame:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:trialButton];
}

- (void)tryGame:(UIButton *)sender
{
    LevelTrialController *controller = [[LevelTrialController alloc]init];
    controller.assetArray = [self.gamePad assetArray];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)showAssetTable
{
    if (!assetTableIsShow) {
        [UIView animateWithDuration:0.5 animations:^{
            
            gameAssetTable.frame = CGRectOffset(gameAssetTable.frame, -120, 0);
            
        } completion:^(BOOL finished) {
            
            assetTableIsShow = YES;

        }];
    }
    else {
        [UIView animateWithDuration:0.5 animations:^{
            
            gameAssetTable.frame = CGRectOffset(gameAssetTable.frame, 120, 0);

        } completion:^(BOOL finished) {
            
            assetTableIsShow = NO;

        }];
    }
}

#pragma mark - Game Asset Table

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameAssetCell"];
    if (!cell)
        cell =[[GameAssetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GameAssetCell"];
    
    GameAsset *asset = [assetLibrary objectAtIndex:indexPath.row];
    cell.assetImageView.backgroundColor = asset.backgroundColor;
    cell.assetNameLabel.text = asset.assetNameLabel.text;
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [assetLibrary count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameAsset *asset = [assetLibrary objectAtIndex:indexPath.row];
    [currentAsset setAssetType:asset.gameAssetType];

    [self showAssetTable];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)blockPan:(UIPanGestureRecognizer *)sender
{
    CGPoint location = [sender locationInView:self.gamePad];
    for (GameAsset *v in [self.gamePad assetArray]) {
        
        if (CGRectContainsPoint(v.frame, location)) {
            
            [v setAssetType:currentAsset.gameAssetType];
        }
    }
}

- (void)changeBlockColor:(UITapGestureRecognizer *)sender
{
    GameAsset *asset = (GameAsset *)sender.view;
    if (asset.gameAssetType == kAssetTypeEmpty) {
        
        [asset setAssetType:currentAsset.gameAssetType];

    } else {

        [asset setAssetType:kAssetTypeEmpty];
    }
}

#pragma mark - Hide statu bar

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
