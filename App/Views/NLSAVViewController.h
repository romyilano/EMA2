//
//  NLSAVViewController.h
//  App
//
//  Created by Amir on 5/25/15.
//  Copyright (c) 2015 Colleen's. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "NLSPlayerView.h"

@class AVPlayer;

@interface NLSAVViewController : UIViewController {

}

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) IBOutlet NLSPlayerView *playerView;

@end
