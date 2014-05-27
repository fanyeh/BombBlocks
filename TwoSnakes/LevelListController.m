//
//  LevelListController.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/5/27.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "LevelListController.h"
#import "LevelTrialController.h"

@interface LevelListController () <UITableViewDataSource,UITableViewDelegate>
{
    UITableView *levelListTable;
    NSArray *levelArray;
    NSArray *paths;
    NSString *documentsDirectory;
    NSString *dataPath;
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
    levelListTable = [[UITableView alloc]initWithFrame:self.view.frame];
    levelListTable.delegate = self;
    levelListTable.dataSource = self;
    [levelListTable registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    [self.view addSubview:levelListTable];
    
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    dataPath = [documentsDirectory stringByAppendingPathComponent:@"GameLevels"];
    
    levelArray = [self listAllLevels];
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
    NSDictionary *levelAssets = [NSJSONSerialization JSONObjectWithData:levelData options:NSJSONReadingAllowFragments error:nil];
    [self tryGame:levelAssets];
}

- (void)tryGame:(NSDictionary *)gameAssets
{
    LevelTrialController *controller = [[LevelTrialController alloc]init];
    controller.assetDict = gameAssets;
    [self presentViewController:controller animated:YES completion:nil];
}

- (NSArray *)listAllLevels
{
    NSArray *directoryContent = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dataPath error:nil];
    return directoryContent;
}

@end
