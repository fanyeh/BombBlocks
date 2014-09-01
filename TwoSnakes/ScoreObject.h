//
//  ScoreObject.h
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/9/1.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ScoreObject : NSObject
-(id)initWithScore:(NSInteger)score;

@property (nonatomic,assign) NSInteger score;
@property (nonatomic,assign) NSTimeInterval interval;

@end
