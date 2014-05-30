//
//  LevelListController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/27.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "LevelListController.h"
#import "LevelTrialController.h"
#import "LevelMakerController.h"

@interface LevelListController () <UITableViewDataSource,UITableViewDelegate , UIAlertViewDelegate>
{
    UITableView *levelListTable;
    NSArray *levelArray;
    NSArray *paths;
    NSString *documentsDirectory;
    NSString *dataPath;
    LoadLevelType loadType;
    NSDictionary *levelAssets;
}

@end

@implementation LevelListController

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
    CGRect tableRect = CGRectMake(0,50, 320, 518);
    levelListTable = [[UITableView alloc]initWithFrame:tableRect];
    levelListTable.delegate = self;
    levelListTable.dataSource = self;
    [levelListTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:levelListTable];
    
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    dataPath = [documentsDirectory stringByAppendingPathComponent:@"GameLevels"];
    
    UILabel *exitLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 10, 100, 30)];
    exitLabel.text = @"Exit";
    exitLabel.userInteractionEnabled = YES;
    exitLabel.textColor = [UIColor blackColor];
    [self.view addSubview:exitLabel];
    
    UITapGestureRecognizer *exitTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(exit)];
    [exitLabel addGestureRecognizer:exitTap];
    
    levelArray = [self listAllLevels];
}

- (void)exit
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell)
        cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    
    cell.textLabel.text = [levelArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [levelArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *filePath = [dataPath stringByAppendingPathComponent:[levelArray objectAtIndex:indexPath.row]];
    NSData *levelData = [NSData dataWithContentsOfFile:filePath];
    levelAssets = [NSJSONSerialization JSONObjectWithData:levelData options:NSJSONReadingAllowFragments error:nil];
    
    UIAlertView *loadAlert = [[UIAlertView alloc]initWithTitle:@"Loading Level"
                                                       message:@"Select Load Type"
                                                      delegate:self
                                             cancelButtonTitle:@"Cancel"
                                             otherButtonTitles:@"Play" ,@"Edit", nil];
    
    [loadAlert show];
}

- (void)playGame:(NSDictionary *)gameAssets
{
    LevelTrialController *controller = [[LevelTrialController alloc]init];
    controller.assetDict = gameAssets;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)editGame:(NSDictionary *)gameAssets
{
    LevelMakerController *controller = [[LevelMakerController alloc]init];
    controller.assetDict = gameAssets;
    [self presentViewController:controller animated:YES completion:nil];
}

- (NSArray *)listAllLevels
{
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:nil];
    return directoryContent;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            break;
        case 1:
            [self playGame:levelAssets];
            break;
        case 2:
            [self editGame:levelAssets];
            break;
    }
}

@end
