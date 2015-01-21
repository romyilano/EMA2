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

@synthesize standardSlider = _standardSlider;
@synthesize lowerLabel = _lowerLabel;
@synthesize upperLabel = _upperLabel;
@synthesize purchaseButton = _purchaseButton;

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
    UITextView *messageText = [[UITextView alloc] initWithFrame:CGRectMake(0, 110, bounds.size.width, 50)];
    messageText.text =  @"Search Settings";
    messageText.layer.shadowColor = [[UIColor blackColor] CGColor];
    messageText.layer.shadowOffset = CGSizeMake(1.0,1.0);
    messageText.layer.shadowRadius = 3.0;
    [messageText setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [messageText setBackgroundColor:[UIColor clearColor]];
    [messageText setTextColor:[UIColor blackColor]];
    [messageText setTextAlignment:NSTextAlignmentCenter];
    [messageText setEditable:NO];
    
    NSArray *segArray = @[@"Relevance", @"Date Asc", @"Date Desc"];
    UISegmentedControl *searchSeg = [[UISegmentedControl alloc] initWithItems:segArray];
    [searchSeg setCenter: self.view.center];
    searchSeg.frame = CGRectMake(self.view.center.x - 150, 175, 300, 50);
    
    // Search settings section
    UITextView *maxYear = [[UITextView alloc] initWithFrame:CGRectMake(0, 250, bounds.size.width, 50)];
    maxYear.text =  @"Year Range";
    maxYear.layer.shadowColor = [[UIColor blackColor] CGColor];
    maxYear.layer.shadowOffset = CGSizeMake(1.0,1.0);
    maxYear.layer.shadowRadius = 3.0;
    [maxYear setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [maxYear setBackgroundColor:[UIColor clearColor]];
    [maxYear setTextColor:[UIColor blackColor]];
    [maxYear setTextAlignment:NSTextAlignmentCenter];
    [maxYear setEditable:NO];
    
    //Slider Labels
    UILabel *lowerLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 10.0)];
    [lowerLabel setBackgroundColor:[UIColor clearColor]];
    [lowerLabel setCenter: self.view.center];
    [lowerLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [lowerLabel setTextColor:[UIColor whiteColor]];
    lowerLabel.frame = CGRectMake(self.view.center.x - 132, 280, 128, 16);
    lowerLabel.text = @"1977";
    self.lowerLabel = lowerLabel;
    
    UILabel *upperLabel  = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 10.0)];
    [upperLabel setBackgroundColor:[UIColor clearColor]];
    [upperLabel setCenter: self.view.center];
    [upperLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
    [upperLabel setTextColor:[UIColor whiteColor]];
    upperLabel.frame = CGRectMake(self.view.center.x + 100, 280, 128, 16);
    upperLabel.text = @"2015";
    self.upperLabel = upperLabel;
    
    //Slider
    NMRangeSlider* slider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 10.0)];
    slider.minimumValue = 0;
    slider.maximumValue = 38;
    slider.lowerValue = 0;
    slider.upperValue = 38;
    slider.minimumRange = 2;
    [slider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [slider setBackgroundColor:[UIColor clearColor]];
    [slider setCenter: self.view.center];
    slider.frame = CGRectMake(self.view.center.x - 150, 300, 300, 50);
    self.standardSlider = slider;
    
    //Purchase Button
    UIButton* purchaseButton = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 10.0)];
    [purchaseButton addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    [purchaseButton setBackgroundColor:[UIColor blackColor]];
    [purchaseButton setCenter: self.view.center];
    purchaseButton.frame = CGRectMake(self.view.center.x - 150, 384, 300, 100);
    purchaseButton.titleLabel.text = @"Purchase the Complete Set (1977-2015)";
    self.purchaseButton = purchaseButton;


    //Place all subviews
    [vibrancyEffectView.contentView addSubview:messageText];
    [vibrancyEffectView.contentView addSubview:searchLabel];
    [vibrancyEffectView.contentView addSubview:doneButton];
    [vibrancyEffectView.contentView addSubview:searchSeg];
    [vibrancyEffectView.contentView addSubview:maxYear];
    [vibrancyEffectView.contentView addSubview:lowerLabel];
    [vibrancyEffectView.contentView addSubview:upperLabel];
    [vibrancyEffectView.contentView addSubview:slider];
    [vibrancyEffectView.contentView addSubview:purchaseButton];
    
    UITableView *tv = [[UITableView alloc] initWithFrame:bounds style:UITableViewStyleGrouped];
    self.view = blurEffectView;

}

-(void)sliderAction:(id)sender
{
    UISlider *slider = (UISlider*)sender;

    self.lowerLabel.text = [NSString stringWithFormat:@"%d", (int)self.standardSlider.lowerValue + 1977];
    self.upperLabel.text = [NSString stringWithFormat:@"%d", (int)self.standardSlider.upperValue + 1977];
    NSLog(@"%@", self.upperLabel.text);
    //-- Do further actions
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    // add gesture recognizer to window
    
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
