//
//  NLSPlayerView.h
//  App
//
//  Created by Amir on 5/25/15.
//  Copyright (c) 2015 Colleen's. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface NLSPlayerView : UIView {
    // Define this constant for the key-value observation context.
    const NSString *ItemStatusContext;
}
@property (nonatomic, strong) NSURL *url;
@property (nonatomic) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;

@property (nonatomic, weak) IBOutlet UIButton *playButton;
- (IBAction)loadAssetFromURL:sender;
- (IBAction)play:sender;
- (void)syncUI;
- (void)loadURL;
@end

