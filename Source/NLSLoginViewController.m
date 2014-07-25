//
//  NLSLoginViewController.m
//  App
//
//  Created by 4m1r on 6/18/14.
//  Copyright (c) 2014 Slyce. All rights reserved.
//

#import "NLSLoginViewController.h"
#import "FacebookSDK.h"

@interface NLSLoginViewController () <
    FBLoginViewDelegate>
{
    UILabel *_statusLabel;
    UIButton *_loginButton;
}

@end

@implementation NLSLoginViewController

@synthesize delegate = _delegate;

#pragma mark - view lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.height, [[UIScreen mainScreen] bounds].size.width);
    UITableView *table = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];

    
    [self.view addSubview:table];

}

#pragma mark - gesture recognizers

- (void)_handleButtonPress:(UIButton *)button
{

}

@end
