//
//  AVAudioPlayer+VolumeFade.m
//  TwoSnakes
//
//  Created by Jack Yeh on 2014/9/5.
//  Copyright (c) 2014年 MarriageKiller. All rights reserved.
//

#import "AVAudioPlayer+VolumeFade.h"

@implementation AVAudioPlayer (VolumeFade)

-(void)doVolumeFade
{
    if (self.volume > 0.1) {
        self.volume = self.volume - 0.1;
        [self performSelector:@selector(doVolumeFade) withObject:nil afterDelay:0.1];
    } else {
        // Stop and get the sound ready for playing again
        [self stop];
        self.currentTime = 0;
        [self prepareToPlay];
        self.volume = 1.0;
    }
}

@end
