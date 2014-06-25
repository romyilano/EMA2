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


}

#pragma mark - gesture recognizers

- (void)_handleButtonPress:(UIButton *)button
{

}

@end
