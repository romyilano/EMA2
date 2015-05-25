//
//  NLSAVViewController.m
//  App
//
//  Created by Amir on 5/25/15.
//  Copyright (c) 2015 Colleen's. All rights reserved.
//

#import "NLSAVViewController.h"

@implementation NLSAVViewController

@synthesize url, player, playerItem, playerView, playButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"loading player view controller");
    //self.view = self.playerView;
    [self loadURL];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)syncUI {
    if ((self.player.currentItem != nil) &&
        ([self.player.currentItem status] == AVPlayerItemStatusReadyToPlay)) {
        self.playButton.enabled = YES;
    }
    else {
        self.playButton.enabled = NO;
    }
}

- (void)loadURL {
    NSLog(@"loading url %@", self.url);
    self.playerItem = [AVPlayerItem playerItemWithURL:self.url];
    [playerItem addObserver:self forKeyPath:@"status" options:0 context:&ItemStatusContext];
    self.player = [AVPlayer playerWithPlayerItem:playerItem];
}

- (IBAction)loadAssetFromURL:sender {
    
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.url options:nil];
    NSString *tracksKey = @"tracks";
    
    [asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:
     ^{
         
         // Completion handler block.
         dispatch_async(dispatch_get_main_queue(),
                ^{
                    NSError *error;
                    AVKeyValueStatus status = [asset statusOfValueForKey:tracksKey error:&error];
                    
                    if (status == AVKeyValueStatusLoaded) {
                        self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
                        // ensure that this is done before the playerItem is associated with the player
                        [self.playerItem addObserver:self forKeyPath:@"status"
                                             options:NSKeyValueObservingOptionInitial context:&ItemStatusContext];
                        [[NSNotificationCenter defaultCenter] addObserver:self
                                                                 selector:@selector(playerItemDidReachEnd:)
                                                                     name:AVPlayerItemDidPlayToEndTimeNotification
                                                                   object:self.playerItem];
                        self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
                        [self.playerView setPlayer:self.player];
                    }
                    else {
                        // You should deal with the error appropriately.
                        NSLog(@"The asset's tracks were not loaded:\n%@", [error localizedDescription]);
                    }
                });
     }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    if (context == &ItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           [self syncUI];
                       });
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object
                           change:change context:context];
    return;
}

- (IBAction)play:sender {
    [player play];
    // Register with the notification center after creating the player item.
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playerItemDidReachEnd:)
     name:AVPlayerItemDidPlayToEndTimeNotification
     object:[self.player currentItem]];
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    [self.player seekToTime:kCMTimeZero];
}


@end
