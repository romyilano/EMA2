//
//  NLSSettingsViewController.m
//  App
//
//  Created by Amir on 1/12/15.
//  Copyright (c) 2015 Colleen's. All rights reserved.
//

#import "NLSSettingsViewController.h"

@interface NLSSettingsViewController ()

@end

@implementation NLSSettingsViewController

-(void)viewDidLoad{
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    [blurEffectView setFrame:self.view.bounds];
    
    UIVisualEffect *vibrancyEffect = [UIVibrancyEffect effectForBlurEffect:blurEffect];
    UIVisualEffectView *vibrancyEffectView = [[UIVisualEffectView alloc] initWithEffect:vibrancyEffect];
    [vibrancyEffectView setFrame:self.view.bounds];
    
    [blurEffectView.contentView addSubview:vibrancyEffectView];
    
    CGRect bounds = self.view.bounds;
    
    
    //Done button
    UIButton *doneButton = [[UIButton alloc]
                            initWithFrame:CGRectMake(bounds.size.width - 100, 20, 100, 50)];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(dismissSettingView) forControlEvents:UIControlEventTouchUpInside];

    
    // Settings Label for vibrant text
    UILabel *searchLabel = [[UILabel alloc] init];
    [searchLabel setText:@"Settings"];
    [searchLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:50]];
    [searchLabel setBackgroundColor:[UIColor clearColor]];
    [searchLabel setTextColor:[UIColor whiteColor]];
    [searchLabel sizeToFit];
    [searchLabel setCenter: self.view.center];
    searchLabel.textAlignment = NSTextAlignmentCenter;
    searchLabel.frame = CGRectMake(0, 30, bounds.size.width, 100);
    searchLabel.minimumScaleFactor = 8;
    searchLabel.adjustsFontSizeToFitWidth = YES;
    
    // Search settings section
    UITextView *messageText = [[UITextView alloc] initWithFrame:CGRectMake(0, 110, bounds.size.width, bounds.size.height)];
    messageText.text =  @"Search Settings";
    messageText.layer.shadowColor = [[UIColor blackColor] CGColor];
    messageText.layer.shadowOffset = CGSizeMake(1.0,1.0);
    messageText.layer.shadowRadius = 3.0;
    [messageText setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [messageText setBackgroundColor:[UIColor clearColor]];
    [messageText setTextColor:[UIColor blackColor]];
    [messageText setTextAlignment:NSTextAlignmentCenter];
    [messageText setEditable:NO];
    
    NSArray *segArray = @[@"Okapi", @"Date Asc", @"Date Desc"];
    UISegmentedControl *searchSeg = [[UISegmentedControl alloc] initWithItems:segArray];
    [searchSeg setCenter: self.view.center];
    searchSeg.frame = CGRectMake(self.view.center.x - 150, 175, 300, 50);
    
    [vibrancyEffectView.contentView addSubview:messageText];
    [vibrancyEffectView.contentView addSubview:searchLabel];
    [vibrancyEffectView.contentView addSubview:doneButton];
    [vibrancyEffectView.contentView addSubview:searchSeg];
    
    self.view = blurEffectView;

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // add gesture recognizer to window

//    UITapGestureRecognizer *dismiss = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSettingView)];
//    UISwipeGestureRecognizer *swipeH = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSettingView)];
    UISwipeGestureRecognizer *swipeV = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(dismissSettingView)];
//    [swipeH setDirection:(UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft )];
//    [swipeV setDirection:(UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown )];
//
//
//    [self.view addGestureRecognizer:dismiss];
//    [self.view addGestureRecognizer:swipeH];
    [self.view addGestureRecognizer:swipeV];

    
//    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapBehind:)];
//    [recognizer setNumberOfTapsRequired:1];
//    recognizer.cancelsTouchesInView = NO; //So the user can still interact with controls in the modal view
//    [self.view addGestureRecognizer:recognizer];
//    recognizer.delegate = self;
    
    
}

- (void)handleTapBehind:(UITapGestureRecognizer *)sender
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        // passing nil gives us coordinates in the window
        CGPoint location = [sender locationInView:nil];
        
        // convert the tap's location into the local view's coordinate system, and test to see if it's in or outside. If outside, dismiss the view.
        if (![self.view pointInside:[self.view convertPoint:location fromView:self.view] withEvent:nil]) {
            NSLog(@"%@", NSStringFromSelector(_cmd));
            // remove the recognizer first so it's view.window is valid
            [self.view removeGestureRecognizer:sender];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)dismissSettingView
{
    
    NSLog(@"%@", NSStringFromSelector(_cmd));
    
    [self dismissViewControllerAnimated:YES completion:^(void){
        //Save Prefs
    }];
    
}

#pragma mark - UIGestureRecognizer Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
