//
//  NLSAVViewController.m
//  App
//
//  Created by Amir on 5/25/15.
//  Copyright (c) 2015 Colleen's. All rights reserved.
//

#import "NLSAVViewController.h"

@implementation NLSAVViewController

@synthesize url, playerView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"loading player view controller");
    NLSPlayerView *pv = [[NLSPlayerView alloc] initWithFrame:self.view.frame];
    self.playerView = pv;
    self.playerView.url = url;
    [pv loadURL];
    [self setView:pv];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    if (self.playerView.player != nil && [self.playerView.player currentItem] != nil)
        [[self.playerView.player currentItem] removeObserver:self forKeyPath:@"status"];
}




@end
