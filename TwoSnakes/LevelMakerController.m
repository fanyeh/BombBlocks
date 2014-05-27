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

@interface LevelMakerController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
{
    UITableView *gameAssetTable;
    NSMutableArray *assetLibrary;
    BOOL assetTableIsShow;
    GameAsset *currentAsset;
    UITextField *levelNameField;
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
    
    gameAssetTable = [[UITableView alloc]initWithFrame:CGRectMake(320, self.gamePad.frame.origin.y, 120, self.gamePad.frame.size.height)];
    gameAssetTable.backgroundColor = [UIColor whiteColor];
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
    
    GameAsset *goalAsset = [[GameAsset alloc]init];
    [goalAsset setAssetType:kAssetTypeGoal];

    [assetLibrary addObject:wallAsset];
    [assetLibrary addObject:monsterAsset];
    [assetLibrary addObject:shieldAsset];
    [assetLibrary addObject:swordAsset];
    [assetLibrary addObject:magicAsset];
    [assetLibrary addObject:goalAsset];
    
    assetTableIsShow = NO;
    
    for (UIView *v in [self.gamePad assetArray]) {
        UITapGestureRecognizer *colorChangeTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(changeBlockColor:)];
        [v addGestureRecognizer:colorChangeTap];
    }
    
    UIButton *trialButton = [[UIButton alloc]initWithFrame:CGRectMake(70, 10, 50, 20)];
    trialButton.layer.borderWidth = 1;
    [trialButton setTitle:@"Trial" forState:UIControlStateNormal];
    trialButton.backgroundColor = [UIColor blackColor];
    [trialButton addTarget:self action:@selector(tryGame:) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:trialButton];
    
    UIButton *clearButton = [[UIButton alloc]initWithFrame:CGRectMake(70, 50, 50, 20)];
    clearButton.layer.borderWidth = 1;
    [clearButton setTitle:@"Clear" forState:UIControlStateNormal];
    clearButton.backgroundColor = [UIColor blackColor];
    [clearButton addTarget:self action:@selector(clearGame) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:clearButton];
    
    UIButton *outputButton = [[UIButton alloc]initWithFrame:CGRectMake(130, 10, 70, 20)];
    outputButton.layer.borderWidth = 1;
    [outputButton setTitle:@"Output" forState:UIControlStateNormal];
    outputButton.backgroundColor = [UIColor blackColor];
    [outputButton addTarget:self action:@selector(outputGame) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:outputButton];
    
    UIButton *listButton = [[UIButton alloc]initWithFrame:CGRectMake(210, 10, 50, 20)];
    listButton.layer.borderWidth = 1;
    [listButton setTitle:@"List" forState:UIControlStateNormal];
    listButton.backgroundColor = [UIColor blackColor];
    [listButton addTarget:self action:@selector(listAllLevels) forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:listButton];
    
    levelNameField = [[UITextField alloc]initWithFrame:CGRectMake(130, 50, 180, 25)];
    levelNameField.borderStyle = UITextBorderStyleLine;
    levelNameField.placeholder = @"Enter Level Name";
    levelNameField.delegate = self;
    [self.view addSubview:levelNameField];
    
    
}

- (void)clearGame
{
    for (GameAsset *v in [self.gamePad assetArray]) {
        [v setAssetType:kAssetTypeEmpty];
    }
}

- (void)tryGame:(UIButton *)sender
{
    LevelTrialController *controller = [[LevelTrialController alloc]init];
    controller.assetArray = [self.gamePad assetArray];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)outputGame
{
    if (levelNameField.text.length > 0) {
        
        NSMutableDictionary *jsonDictionary = [[NSMutableDictionary alloc]init];
        for (GameAsset *v in [self.gamePad assetArray]) {
            NSDictionary *assetDict = @{
                                            @"Row" : [NSNumber numberWithInteger:v.indexPath.row] ,
                                            @"Column" : [NSNumber numberWithInteger:v.indexPath.section],
                                            @"AssetType" : [NSNumber numberWithInt:v.gameAssetType]
                                            
                                            };
            
            [jsonDictionary setObject:assetDict forKey:[NSString stringWithFormat:@"%ld%ld",v.indexPath.row,v.indexPath.section]];
        }
        
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary options:0 error:nil];

        [self checkFolder];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString * fileDirectory = [documentsDirectory stringByAppendingPathComponent:@"GameLevels"];
        
        NSString *fileName = [NSString stringWithFormat:@"%@.json",levelNameField.text];
        NSString *savedImagePath = [fileDirectory stringByAppendingPathComponent:fileName];
        [jsonData writeToFile:savedImagePath atomically:NO];
        
    } else {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Enter level name first" message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
    }
}

- (NSArray *)listAllLevels
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"GameLevels"];
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:nil];
    
    NSLog(@"%@", directoryContent);
    return directoryContent;
}

- (void)loadLevel
{
    
}

- (void)checkFolder
{
    // Create sub directory name using key for diary under document directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    // Get documents folder
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //Create folder
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"GameLevels"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
}

- (void)showAssetTable
{
    if (!assetTableIsShow) {
        currentAsset.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.5 animations:^{
            
            gameAssetTable.frame = CGRectOffset(gameAssetTable.frame, -120, 0);
            
        } completion:^(BOOL finished) {
            
            assetTableIsShow = YES;
            currentAsset.userInteractionEnabled = YES;

        }];
    }
    else {
        currentAsset.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.5 animations:^{
            
            gameAssetTable.frame = CGRectOffset(gameAssetTable.frame, 120, 0);

        } completion:^(BOOL finished) {
            
            assetTableIsShow = NO;
            currentAsset.userInteractionEnabled = YES;

        }];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [levelNameField resignFirstResponder];
    return YES;
}

#pragma mark - Game Asset Table

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameAssetCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GameAssetCell"];
    if (!cell)
        cell =[[GameAssetCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GameAssetCell"];
    
    GameAsset *asset = [assetLibrary objectAtIndex:indexPath.row];
    cell.assetImageView.backgroundColor = asset.backgroundColor;
    cell.assetNameLabel.text = asset.assetName;
    
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
        
        if (CGRectContainsPoint(v.frame, location)) 
            
                [v setAssetType:currentAsset.gameAssetType];

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

#pragma mark - menu controls

- (void)pauseGame
{
    [super pauseGame];
    if (self.gamePause) {
        [self menuFade:NO];
        self.gamePause = NO;
    }
    else {
        [self menuFade:YES];
        self.gamePause = YES;
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
