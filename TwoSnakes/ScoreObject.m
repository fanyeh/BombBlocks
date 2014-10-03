//
//  ScoreObject.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/9/1.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "ScoreObject.h"

@implementation ScoreObject

-(id)initWithScore:(NSInteger)score
{
    self = [super init];
    if (self) {
        _score = score;
        _interval = 0.1/score;
    }
    return self;
}
@end
