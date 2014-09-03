//
//  MKAppDelegate.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/4/29.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <CoreFoundation/CoreFoundation.h>
#import <AVFoundation/AVFoundation.h>

@interface MKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) AVAudioPlayer *audioPlayer;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
