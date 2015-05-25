//
//  NLSPlayerView.m
//  App
//
//  Created by Amir on 5/25/15.
//  Copyright (c) 2015 Colleen's. All rights reserved.
//

#import "NLSPlayerView.h"

@implementation NLSPlayerView
+ (Class)layerClass {
    return [AVPlayerLayer class];
}
- (AVPlayer*)player {
    return [(AVPlayerLayer *)[self layer] player];
}
- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}
@end
