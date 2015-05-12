//
//  NLSFeedViewController.m
//  App
//
//  Created by Amir on 5/11/15.
//  Copyright (c) 2015 Colleen's. All rights reserved.
//

#import "NLSFeedViewController.h"
#import "MWFeedParser.h"

@interface NLSFeedViewController ()

@end

@implementation NLSFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    NSURL *feedURL = [NSURL URLWithString:@"http://images.apple.com/main/rss/hotnews/hotnews.rss"];
    MWFeedParser *feedParser = [[MWFeedParser alloc] initWithFeedURL:feedURL];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
